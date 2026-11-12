from __future__ import annotations

import logging
from datetime import date, datetime
from decimal import Decimal
from uuid import UUID, uuid4

from fastapi import UploadFile
from sqlalchemy import func, select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.errors import AppError
from app.modules.cows.domain.rules import (
    TAG_GENERATION_MAX_ATTEMPTS,
    AcquisitionSource,
    assert_milk_allowed,
    assert_not_archived,
    build_generated_tag,
    parse_acquired_by,
    parse_gender,
    parse_purpose,
    validate_feed_name,
    validate_non_negative_price,
    validate_positive_quantity,
    validate_purchase_fields,
    validate_required_name_breed,
    validate_unit,
)
from app.modules.cows.infrastructure.image_store import CowImageStore
from app.modules.cows.infrastructure.models import (
    CowFeedingModel,
    CowModel,
    MilkProductionModel,
)

logger = logging.getLogger(__name__)


def _clamp_paging(
    limit: int | None,
    offset: int | None,
    *,
    default_limit: int = 20,
) -> tuple[int, int]:
    lim = default_limit if limit is None else limit
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
    def __init__(self, db: Session, settings: Settings | None = None) -> None:
        self.db = db
        self.settings = settings or get_settings()
        self.images = CowImageStore(self.settings)

    def create(
        self,
        *,
        owner_id: UUID,
        purpose: str,
        gender: str,
        acquired_by: str,
        name: str,
        breed: str,
        date_of_birth: date | None = None,
        color: str | None = None,
        weight: Decimal | None = None,
        age: int | None = None,
        purchase_date: date | None = None,
        purchase_price: Decimal | None = None,
        notes: str | None = None,
        image: UploadFile | None = None,
    ) -> CowModel:
        cleaned_name, cleaned_breed = validate_required_name_breed(
            name=name, breed=breed
        )
        purpose_v = parse_purpose(purpose)
        gender_v = parse_gender(gender)
        acquired_v = parse_acquired_by(acquired_by)
        purchase_date_v, purchase_price_v = validate_purchase_fields(
            acquired_by=acquired_v,
            purchase_date=purchase_date,
            purchase_price=purchase_price,
        )

        cow_id = uuid4()
        tag = self._generate_unique_tag(
            owner_id=owner_id, name=cleaned_name, breed=cleaned_breed
        )
        image_path: str | None = None
        if image is not None and image.filename:
            image_path = self.images.save(image, str(owner_id), str(cow_id))

        cow = CowModel(
            id=cow_id,
            owner_id=owner_id,
            tag_number=tag,
            name=cleaned_name,
            breed=cleaned_breed,
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
            image_path=image_path,
            is_archived=False,
        )
        self.db.add(cow)
        try:
            self.db.commit()
        except IntegrityError as exc:
            self.db.rollback()
            if image_path:
                self.images.delete(image_path)
            raise AppError(
                code="TAG_ALREADY_EXISTS",
                message="An active cow with this tag number already exists.",
                status_code=409,
            ) from exc
        self.db.refresh(cow)
        logger.info(
            "Cow created cow_id=%s owner_id=%s tag=%s", cow.id, owner_id, cow.tag_number
        )
        return cow

    def list(
        self,
        *,
        owner_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
        include_archived: bool = False,
    ) -> tuple[list[CowModel], int]:
        lim, off = _clamp_paging(limit, offset, default_limit=10)
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
            if name is None or not name.strip():
                raise AppError(
                    code="VALIDATION_ERROR",
                    message="Name is required.",
                    status_code=422,
                    details={"field": "name"},
                )
            cow.name = name.strip()
        if "breed" in set_fields:
            if breed is None or not breed.strip():
                raise AppError(
                    code="VALIDATION_ERROR",
                    message="Breed is required.",
                    status_code=422,
                    details={"field": "breed"},
                )
            cow.breed = breed.strip()
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
        self.db.commit()
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

    def attach_image(
        self, *, owner_id: UUID, cow_id: UUID, image: UploadFile
    ) -> CowModel:
        cow = self.get(owner_id=owner_id, cow_id=cow_id)
        assert_not_archived(cow.is_archived)
        cow.image_path = self.images.replace(
            image, str(owner_id), str(cow_id), cow.image_path
        )
        self.db.add(cow)
        self.db.commit()
        self.db.refresh(cow)
        logger.info("Cow image attached cow_id=%s owner_id=%s", cow.id, owner_id)
        return cow

    def clear_image(self, *, owner_id: UUID, cow_id: UUID) -> CowModel:
        cow = self.get(owner_id=owner_id, cow_id=cow_id)
        assert_not_archived(cow.is_archived)
        self.images.delete(cow.image_path)
        cow.image_path = None
        self.db.add(cow)
        self.db.commit()
        self.db.refresh(cow)
        logger.info("Cow image cleared cow_id=%s owner_id=%s", cow.id, owner_id)
        return cow

    def resolve_image_path(self, *, owner_id: UUID, cow_id: UUID):
        cow = self.get(owner_id=owner_id, cow_id=cow_id)
        if not cow.image_path:
            raise AppError(
                code="COW_IMAGE_NOT_FOUND",
                message="Cow image not found.",
                status_code=404,
            )
        return self.images.resolve(cow.image_path)

    def _generate_unique_tag(
        self, *, owner_id: UUID, name: str, breed: str
    ) -> str:
        for _ in range(TAG_GENERATION_MAX_ATTEMPTS):
            candidate = build_generated_tag(name, breed)
            if not self._active_tag_exists(owner_id, candidate):
                return candidate
        raise AppError(
            code="TAG_GENERATION_FAILED",
            message="Could not generate a unique tag number. Please try again.",
            status_code=500,
        )

    def _active_tag_exists(self, owner_id: UUID, tag: str) -> bool:
        existing = self.db.scalar(
            select(CowModel.id).where(
                CowModel.owner_id == owner_id,
                CowModel.tag_number == tag,
                CowModel.is_archived.is_(False),
            )
        )
        return existing is not None


class MilkProductionService:
    def __init__(self, db: Session, settings: Settings | None = None) -> None:
        self.db = db
        self.cows = CowService(db, settings)

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
        lim, off = _clamp_paging(limit, offset, default_limit=10)
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

    def get(
        self, *, owner_id: UUID, cow_id: UUID, milk_id: UUID
    ) -> MilkProductionModel:
        self.cows.get(owner_id=owner_id, cow_id=cow_id)
        row = self.db.scalar(
            select(MilkProductionModel).where(
                MilkProductionModel.id == milk_id,
                MilkProductionModel.cow_id == cow_id,
                MilkProductionModel.owner_id == owner_id,
            )
        )
        if row is None:
            raise AppError(
                code="MILK_NOT_FOUND",
                message="Milk production entry not found.",
                status_code=404,
            )
        return row

    def update(
        self,
        *,
        owner_id: UUID,
        cow_id: UUID,
        milk_id: UUID,
        produced_at: datetime | None = None,
        quantity: Decimal | None = None,
        unit: str | None = None,
        price_per_unit: Decimal | None = None,
        note: str | None = None,
        fields_set: set[str] | None = None,
    ) -> MilkProductionModel:
        cow = self.cows.get(owner_id=owner_id, cow_id=cow_id)
        assert_not_archived(cow.is_archived)
        assert_milk_allowed(cow.purpose)
        row = self.get(owner_id=owner_id, cow_id=cow_id, milk_id=milk_id)
        set_fields = fields_set or set()

        if "produced_at" in set_fields and produced_at is not None:
            row.produced_at = produced_at
        if "quantity" in set_fields and quantity is not None:
            row.quantity = validate_positive_quantity(quantity)
        if "unit" in set_fields and unit is not None:
            row.unit = validate_unit(unit)
        if "price_per_unit" in set_fields and price_per_unit is not None:
            row.price_per_unit = validate_non_negative_price(price_per_unit)
        if "note" in set_fields:
            row.note = note.strip() if note else None

        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info(
            "Milk production updated id=%s cow_id=%s owner_id=%s",
            row.id,
            cow_id,
            owner_id,
        )
        return row

    def delete(self, *, owner_id: UUID, cow_id: UUID, milk_id: UUID) -> None:
        cow = self.cows.get(owner_id=owner_id, cow_id=cow_id)
        assert_not_archived(cow.is_archived)
        row = self.get(owner_id=owner_id, cow_id=cow_id, milk_id=milk_id)
        self.db.delete(row)
        self.db.commit()
        logger.info(
            "Milk production deleted id=%s cow_id=%s owner_id=%s",
            milk_id,
            cow_id,
            owner_id,
        )


class CowFeedingService:
    def __init__(self, db: Session, settings: Settings | None = None) -> None:
        self.db = db
        self.cows = CowService(db, settings)

    def add(
        self,
        *,
        owner_id: UUID,
        cow_id: UUID,
        fed_at: datetime,
        feed_name: str,
        quantity: Decimal,
        unit: str,
        unit_cost: Decimal,
        note: str | None = None,
    ) -> CowFeedingModel:
        cow = self.cows.get(owner_id=owner_id, cow_id=cow_id)
        assert_not_archived(cow.is_archived)
        qty = validate_positive_quantity(quantity)
        unit_v = validate_unit(unit)
        feed = validate_feed_name(feed_name)
        cost = validate_non_negative_price(unit_cost, field="unit_cost")

        row = CowFeedingModel(
            id=uuid4(),
            cow_id=cow.id,
            owner_id=owner_id,
            fed_at=fed_at,
            feed_name=feed,
            quantity=qty,
            unit=unit_v,
            unit_cost=cost,
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
        lim, off = _clamp_paging(limit, offset, default_limit=10)
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

    def get(
        self, *, owner_id: UUID, cow_id: UUID, feeding_id: UUID
    ) -> CowFeedingModel:
        self.cows.get(owner_id=owner_id, cow_id=cow_id)
        row = self.db.scalar(
            select(CowFeedingModel).where(
                CowFeedingModel.id == feeding_id,
                CowFeedingModel.cow_id == cow_id,
                CowFeedingModel.owner_id == owner_id,
            )
        )
        if row is None:
            raise AppError(
                code="FEEDING_NOT_FOUND",
                message="Feeding entry not found.",
                status_code=404,
            )
        return row

    def update(
        self,
        *,
        owner_id: UUID,
        cow_id: UUID,
        feeding_id: UUID,
        fed_at: datetime | None = None,
        feed_name: str | None = None,
        quantity: Decimal | None = None,
        unit: str | None = None,
        unit_cost: Decimal | None = None,
        note: str | None = None,
        fields_set: set[str] | None = None,
    ) -> CowFeedingModel:
        cow = self.cows.get(owner_id=owner_id, cow_id=cow_id)
        assert_not_archived(cow.is_archived)
        row = self.get(owner_id=owner_id, cow_id=cow_id, feeding_id=feeding_id)
        set_fields = fields_set or set()

        if "fed_at" in set_fields and fed_at is not None:
            row.fed_at = fed_at
        if "feed_name" in set_fields and feed_name is not None:
            row.feed_name = validate_feed_name(feed_name)
        if "quantity" in set_fields and quantity is not None:
            row.quantity = validate_positive_quantity(quantity)
        if "unit" in set_fields and unit is not None:
            row.unit = validate_unit(unit)
        if "unit_cost" in set_fields and unit_cost is not None:
            row.unit_cost = validate_non_negative_price(unit_cost, field="unit_cost")
        if "note" in set_fields:
            row.note = note.strip() if note else None

        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info(
            "Cow feeding updated id=%s cow_id=%s owner_id=%s",
            row.id,
            cow_id,
            owner_id,
        )
        return row

    def delete(self, *, owner_id: UUID, cow_id: UUID, feeding_id: UUID) -> None:
        cow = self.cows.get(owner_id=owner_id, cow_id=cow_id)
        assert_not_archived(cow.is_archived)
        row = self.get(owner_id=owner_id, cow_id=cow_id, feeding_id=feeding_id)
        self.db.delete(row)
        self.db.commit()
        logger.info(
            "Cow feeding deleted id=%s cow_id=%s owner_id=%s",
            feeding_id,
            cow_id,
            owner_id,
        )
