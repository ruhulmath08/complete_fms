from __future__ import annotations

import logging
from datetime import date, datetime
from decimal import Decimal
from uuid import UUID, uuid4

from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.modules.cows.domain.rules import (
    AcquisitionSource,
    assert_milk_allowed,
    assert_not_archived,
    parse_acquired_by,
    parse_gender,
    parse_purpose,
    validate_feed_name,
    validate_non_negative_price,
    validate_positive_quantity,
    validate_purchase_fields,
    validate_tag_number,
    validate_unit,
)
from app.modules.cows.infrastructure.models import (
    CowFeedingModel,
    CowModel,
    MilkProductionModel,
)

logger = logging.getLogger(__name__)


def _clamp_paging(limit: int | None, offset: int | None) -> tuple[int, int]:
    lim = 20 if limit is None else limit
    off = 0 if offset is None else offset
    if lim < 1 or lim > 100:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Limit must be between 1 and 100.",
            status_code=422,
            details={"field": "limit"},
        )
    if off < 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Offset must be greater than or equal to zero.",
            status_code=422,
            details={"field": "offset"},
        )
    return lim, off


class CowService:
    def __init__(self, db: Session) -> None:
        self.db = db

    def create(
        self,
        *,
        owner_id: UUID,
        tag_number: str,
        purpose: str,
        gender: str,
        acquired_by: str,
        name: str | None = None,
        breed: str | None = None,
        date_of_birth: date | None = None,
        color: str | None = None,
        weight: Decimal | None = None,
        age: int | None = None,
        purchase_date: date | None = None,
        purchase_price: Decimal | None = None,
        notes: str | None = None,
    ) -> CowModel:
        tag = validate_tag_number(tag_number)
        purpose_v = parse_purpose(purpose)
        gender_v = parse_gender(gender)
        acquired_v = parse_acquired_by(acquired_by)
        purchase_date_v, purchase_price_v = validate_purchase_fields(
            acquired_by=acquired_v,
            purchase_date=purchase_date,
            purchase_price=purchase_price,
        )
        self._assert_tag_available(owner_id, tag)

        cow = CowModel(
            id=uuid4(),
            owner_id=owner_id,
            tag_number=tag,
            name=name.strip() if name else None,
            breed=breed.strip() if breed else None,
            date_of_birth=date_of_birth,
            purpose=purpose_v.value,
            gender=gender_v.value,
            color=color.strip() if color else None,
            weight=weight,
            age=age,
            acquired_by=acquired_v.value,
            purchase_date=purchase_date_v,
            purchase_price=purchase_price_v,
            notes=notes.strip() if notes else None,
            is_archived=False,
        )
        self.db.add(cow)
        try:
            self.db.commit()
        except IntegrityError as exc:
            self.db.rollback()
            raise AppError(
                code="TAG_ALREADY_EXISTS",
                message="An active cow with this tag number already exists.",
                status_code=409,
            ) from exc
        self.db.refresh(cow)
        logger.info("Cow created cow_id=%s owner_id=%s", cow.id, owner_id)
        return cow

    def list(
        self,
        *,
        owner_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
        include_archived: bool = False,
    ) -> tuple[list[CowModel], int]:
        lim, off = _clamp_paging(limit, offset)
        filters = [CowModel.owner_id == owner_id]
        if not include_archived:
            filters.append(CowModel.is_archived.is_(False))

        total = self.db.scalar(
            select(func.count()).select_from(CowModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(CowModel)
                .where(*filters)
                .order_by(CowModel.created_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def get(self, *, owner_id: UUID, cow_id: UUID) -> CowModel:
        cow = self.db.scalar(
            select(CowModel).where(
                CowModel.id == cow_id, CowModel.owner_id == owner_id
            )
        )
        if cow is None:
            raise AppError(
                code="COW_NOT_FOUND",
                message="Cow not found.",
                status_code=404,
            )
        return cow

    def update(
        self,
        *,
        owner_id: UUID,
        cow_id: UUID,
        tag_number: str | None = None,
        purpose: str | None = None,
        gender: str | None = None,
        acquired_by: str | None = None,
        name: str | None = None,
        breed: str | None = None,
        date_of_birth: date | None = None,
        color: str | None = None,
        weight: Decimal | None = None,
        age: int | None = None,
        purchase_date: date | None = None,
        purchase_price: Decimal | None = None,
        notes: str | None = None,
        fields_set: set[str] | None = None,
    ) -> CowModel:
        cow = self.get(owner_id=owner_id, cow_id=cow_id)
        assert_not_archived(cow.is_archived)
        set_fields = fields_set or set()

        if tag_number is not None:
            tag = validate_tag_number(tag_number)
            self._assert_tag_available(owner_id, tag, exclude_cow_id=cow.id)
            cow.tag_number = tag

        if purpose is not None:
            cow.purpose = parse_purpose(purpose).value
        if gender is not None:
            cow.gender = parse_gender(gender).value

        acquired_v = (
            parse_acquired_by(acquired_by)
            if acquired_by is not None
            else AcquisitionSource(cow.acquired_by)
        )
        if acquired_by is not None:
            cow.acquired_by = acquired_v.value

        next_purchase_date = cow.purchase_date
        next_purchase_price = cow.purchase_price
        if "purchase_date" in set_fields:
            next_purchase_date = purchase_date
        if "purchase_price" in set_fields:
            next_purchase_price = purchase_price
        if (
            acquired_by is not None
            or "purchase_date" in set_fields
            or "purchase_price" in set_fields
        ):
            next_purchase_date, next_purchase_price = validate_purchase_fields(
                acquired_by=acquired_v,
                purchase_date=next_purchase_date,
                purchase_price=next_purchase_price,
            )
            cow.purchase_date = next_purchase_date
            cow.purchase_price = next_purchase_price

        if "name" in set_fields:
            cow.name = name.strip() if name else None
        if "breed" in set_fields:
            cow.breed = breed.strip() if breed else None
        if "date_of_birth" in set_fields:
            cow.date_of_birth = date_of_birth
        if "color" in set_fields:
            cow.color = color.strip() if color else None
        if "weight" in set_fields:
            cow.weight = weight
        if "age" in set_fields:
            cow.age = age
        if "notes" in set_fields:
            cow.notes = notes.strip() if notes else None

        self.db.add(cow)
        try:
            self.db.commit()
        except IntegrityError as exc:
            self.db.rollback()
            raise AppError(
                code="TAG_ALREADY_EXISTS",
                message="An active cow with this tag number already exists.",
                status_code=409,
            ) from exc
        self.db.refresh(cow)
        logger.info("Cow updated cow_id=%s owner_id=%s", cow.id, owner_id)
        return cow

    def archive(self, *, owner_id: UUID, cow_id: UUID) -> CowModel:
        cow = self.get(owner_id=owner_id, cow_id=cow_id)
        if cow.is_archived:
            return cow
        cow.is_archived = True
        self.db.add(cow)
        self.db.commit()
        self.db.refresh(cow)
        logger.info("Cow archived cow_id=%s owner_id=%s", cow.id, owner_id)
        return cow

    def _assert_tag_available(
        self,
        owner_id: UUID,
        tag: str,
        *,
        exclude_cow_id: UUID | None = None,
    ) -> None:
        stmt = select(CowModel.id).where(
            CowModel.owner_id == owner_id,
            CowModel.tag_number == tag,
            CowModel.is_archived.is_(False),
        )
        if exclude_cow_id is not None:
            stmt = stmt.where(CowModel.id != exclude_cow_id)
        existing = self.db.scalar(stmt)
        if existing is not None:
            raise AppError(
                code="TAG_ALREADY_EXISTS",
                message="An active cow with this tag number already exists.",
                status_code=409,
            )


class MilkProductionService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.cows = CowService(db)

    def add(
        self,
        *,
        owner_id: UUID,
        cow_id: UUID,
        produced_at: datetime,
        quantity: Decimal,
        unit: str,
        price_per_unit: Decimal,
        note: str | None = None,
    ) -> MilkProductionModel:
        cow = self.cows.get(owner_id=owner_id, cow_id=cow_id)
        assert_not_archived(cow.is_archived)
        assert_milk_allowed(cow.purpose)
        qty = validate_positive_quantity(quantity)
        unit_v = validate_unit(unit)
        price = validate_non_negative_price(price_per_unit)

        row = MilkProductionModel(
            id=uuid4(),
            cow_id=cow.id,
            owner_id=owner_id,
            produced_at=produced_at,
            quantity=qty,
            unit=unit_v,
            price_per_unit=price,
            note=note.strip() if note else None,
        )
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info(
            "Milk production added id=%s cow_id=%s owner_id=%s",
            row.id,
            cow.id,
            owner_id,
        )
        return row

    def list(
        self,
        *,
        owner_id: UUID,
        cow_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
    ) -> tuple[list[MilkProductionModel], int]:
        self.cows.get(owner_id=owner_id, cow_id=cow_id)
        lim, off = _clamp_paging(limit, offset)
        filters = [
            MilkProductionModel.owner_id == owner_id,
            MilkProductionModel.cow_id == cow_id,
        ]
        total = self.db.scalar(
            select(func.count()).select_from(MilkProductionModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(MilkProductionModel)
                .where(*filters)
                .order_by(MilkProductionModel.produced_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total


class CowFeedingService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.cows = CowService(db)

    def add(
        self,
        *,
        owner_id: UUID,
        cow_id: UUID,
        fed_at: datetime,
        feed_name: str,
        quantity: Decimal,
        unit: str,
        note: str | None = None,
    ) -> CowFeedingModel:
        cow = self.cows.get(owner_id=owner_id, cow_id=cow_id)
        assert_not_archived(cow.is_archived)
        qty = validate_positive_quantity(quantity)
        unit_v = validate_unit(unit)
        feed = validate_feed_name(feed_name)

        row = CowFeedingModel(
            id=uuid4(),
            cow_id=cow.id,
            owner_id=owner_id,
            fed_at=fed_at,
            feed_name=feed,
            quantity=qty,
            unit=unit_v,
            note=note.strip() if note else None,
        )
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info(
            "Cow feeding added id=%s cow_id=%s owner_id=%s",
            row.id,
            cow.id,
            owner_id,
        )
        return row

    def list(
        self,
        *,
        owner_id: UUID,
        cow_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
    ) -> tuple[list[CowFeedingModel], int]:
        self.cows.get(owner_id=owner_id, cow_id=cow_id)
        lim, off = _clamp_paging(limit, offset)
        filters = [
            CowFeedingModel.owner_id == owner_id,
            CowFeedingModel.cow_id == cow_id,
        ]
        total = self.db.scalar(
            select(func.count()).select_from(CowFeedingModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(CowFeedingModel)
                .where(*filters)
                .order_by(CowFeedingModel.fed_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total
