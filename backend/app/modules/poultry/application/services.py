from __future__ import annotations

import logging
from datetime import date, datetime
from decimal import Decimal
from uuid import UUID, uuid4

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.modules.poultry.domain.rules import (
    AcquisitionSource,
    assert_eggs_allowed,
    assert_not_archived,
    parse_acquired_by,
    parse_poultry_type,
    validate_bird_count,
    validate_feed_name,
    validate_group_name,
    validate_non_negative_price,
    validate_positive_quantity,
    validate_purchase_fields,
    validate_unit,
)
from app.modules.poultry.infrastructure.models import (
    EggProductionModel,
    PoultryFeedingModel,
    PoultryGroupModel,
)

logger = logging.getLogger(__name__)


def _clamp_paging(limit: int | None, offset: int | None) -> tuple[int, int]:
    lim = 10 if limit is None else limit
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


class PoultryGroupService:
    def __init__(self, db: Session) -> None:
        self.db = db

    def create(
        self,
        *,
        owner_id: UUID,
        poultry_type: str,
        name: str,
        bird_count: int,
        acquired_by: str,
        date_acquired: date | None = None,
        purchase_date: date | None = None,
        purchase_price: Decimal | None = None,
        notes: str | None = None,
    ) -> PoultryGroupModel:
        type_v = parse_poultry_type(poultry_type)
        name_v = validate_group_name(name)
        count_v = validate_bird_count(bird_count)
        acquired_v = parse_acquired_by(acquired_by)
        purchase_date_v, purchase_price_v = validate_purchase_fields(
            acquired_by=acquired_v,
            purchase_date=purchase_date,
            purchase_price=purchase_price,
        )

        group = PoultryGroupModel(
            id=uuid4(),
            owner_id=owner_id,
            poultry_type=type_v.value,
            name=name_v,
            bird_count=count_v,
            date_acquired=date_acquired,
            acquired_by=acquired_v.value,
            purchase_date=purchase_date_v,
            purchase_price=purchase_price_v,
            notes=notes.strip() if notes else None,
            is_archived=False,
        )
        self.db.add(group)
        self.db.commit()
        self.db.refresh(group)
        logger.info("Poultry group created group_id=%s owner_id=%s", group.id, owner_id)
        return group

    def list(
        self,
        *,
        owner_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
        include_archived: bool = False,
    ) -> tuple[list[PoultryGroupModel], int]:
        lim, off = _clamp_paging(limit, offset)
        filters = [PoultryGroupModel.owner_id == owner_id]
        if not include_archived:
            filters.append(PoultryGroupModel.is_archived.is_(False))

        total = self.db.scalar(
            select(func.count()).select_from(PoultryGroupModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(PoultryGroupModel)
                .where(*filters)
                .order_by(PoultryGroupModel.created_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def get(self, *, owner_id: UUID, group_id: UUID) -> PoultryGroupModel:
        group = self.db.scalar(
            select(PoultryGroupModel).where(
                PoultryGroupModel.id == group_id,
                PoultryGroupModel.owner_id == owner_id,
            )
        )
        if group is None:
            raise AppError(
                code="POULTRY_GROUP_NOT_FOUND",
                message="Poultry group not found.",
                status_code=404,
            )
        return group

    def update(
        self,
        *,
        owner_id: UUID,
        group_id: UUID,
        poultry_type: str | None = None,
        name: str | None = None,
        bird_count: int | None = None,
        acquired_by: str | None = None,
        date_acquired: date | None = None,
        purchase_date: date | None = None,
        purchase_price: Decimal | None = None,
        notes: str | None = None,
        fields_set: set[str] | None = None,
    ) -> PoultryGroupModel:
        group = self.get(owner_id=owner_id, group_id=group_id)
        assert_not_archived(group.is_archived)
        set_fields = fields_set or set()

        if poultry_type is not None:
            group.poultry_type = parse_poultry_type(poultry_type).value
        if name is not None:
            group.name = validate_group_name(name)
        if bird_count is not None:
            group.bird_count = validate_bird_count(bird_count)

        acquired_v = (
            parse_acquired_by(acquired_by)
            if acquired_by is not None
            else AcquisitionSource(group.acquired_by)
        )
        if acquired_by is not None:
            group.acquired_by = acquired_v.value

        next_purchase_date = group.purchase_date
        next_purchase_price = group.purchase_price
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
            group.purchase_date = next_purchase_date
            group.purchase_price = next_purchase_price

        if "date_acquired" in set_fields:
            group.date_acquired = date_acquired
        if "notes" in set_fields:
            group.notes = notes.strip() if notes else None

        self.db.add(group)
        self.db.commit()
        self.db.refresh(group)
        logger.info("Poultry group updated group_id=%s owner_id=%s", group.id, owner_id)
        return group

    def archive(self, *, owner_id: UUID, group_id: UUID) -> PoultryGroupModel:
        group = self.get(owner_id=owner_id, group_id=group_id)
        if group.is_archived:
            return group
        group.is_archived = True
        self.db.add(group)
        self.db.commit()
        self.db.refresh(group)
        logger.info("Poultry group archived group_id=%s owner_id=%s", group.id, owner_id)
        return group


class PoultryFeedingService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.groups = PoultryGroupService(db)

    def add(
        self,
        *,
        owner_id: UUID,
        group_id: UUID,
        fed_at: datetime,
        feed_name: str,
        quantity: Decimal,
        unit: str,
        note: str | None = None,
    ) -> PoultryFeedingModel:
        group = self.groups.get(owner_id=owner_id, group_id=group_id)
        assert_not_archived(group.is_archived)
        qty = validate_positive_quantity(quantity)
        unit_v = validate_unit(unit)
        feed = validate_feed_name(feed_name)

        row = PoultryFeedingModel(
            id=uuid4(),
            poultry_group_id=group.id,
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
            "Poultry feeding added id=%s group_id=%s owner_id=%s",
            row.id,
            group.id,
            owner_id,
        )
        return row

    def list(
        self,
        *,
        owner_id: UUID,
        group_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
    ) -> tuple[list[PoultryFeedingModel], int]:
        self.groups.get(owner_id=owner_id, group_id=group_id)
        lim, off = _clamp_paging(limit, offset)
        filters = [
            PoultryFeedingModel.owner_id == owner_id,
            PoultryFeedingModel.poultry_group_id == group_id,
        ]
        total = self.db.scalar(
            select(func.count()).select_from(PoultryFeedingModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(PoultryFeedingModel)
                .where(*filters)
                .order_by(PoultryFeedingModel.fed_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def get(
        self, *, owner_id: UUID, group_id: UUID, feeding_id: UUID
    ) -> PoultryFeedingModel:
        self.groups.get(owner_id=owner_id, group_id=group_id)
        row = self.db.scalar(
            select(PoultryFeedingModel).where(
                PoultryFeedingModel.id == feeding_id,
                PoultryFeedingModel.poultry_group_id == group_id,
                PoultryFeedingModel.owner_id == owner_id,
            )
        )
        if row is None:
            raise AppError(
                code="POULTRY_FEEDING_NOT_FOUND",
                message="Poultry feeding entry not found.",
                status_code=404,
            )
        return row

    def update(
        self,
        *,
        owner_id: UUID,
        group_id: UUID,
        feeding_id: UUID,
        fed_at: datetime | None = None,
        feed_name: str | None = None,
        quantity: Decimal | None = None,
        unit: str | None = None,
        note: str | None = None,
        fields_set: set[str] | None = None,
    ) -> PoultryFeedingModel:
        group = self.groups.get(owner_id=owner_id, group_id=group_id)
        assert_not_archived(group.is_archived)
        row = self.get(owner_id=owner_id, group_id=group_id, feeding_id=feeding_id)
        set_fields = fields_set or set()

        if "fed_at" in set_fields and fed_at is not None:
            row.fed_at = fed_at
        if "feed_name" in set_fields and feed_name is not None:
            row.feed_name = validate_feed_name(feed_name)
        if "quantity" in set_fields and quantity is not None:
            row.quantity = validate_positive_quantity(quantity)
        if "unit" in set_fields and unit is not None:
            row.unit = validate_unit(unit)
        if "note" in set_fields:
            row.note = note.strip() if note else None

        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info(
            "Poultry feeding updated id=%s group_id=%s owner_id=%s",
            row.id,
            group_id,
            owner_id,
        )
        return row

    def delete(self, *, owner_id: UUID, group_id: UUID, feeding_id: UUID) -> None:
        group = self.groups.get(owner_id=owner_id, group_id=group_id)
        assert_not_archived(group.is_archived)
        row = self.get(owner_id=owner_id, group_id=group_id, feeding_id=feeding_id)
        self.db.delete(row)
        self.db.commit()
        logger.info(
            "Poultry feeding deleted id=%s group_id=%s owner_id=%s",
            feeding_id,
            group_id,
            owner_id,
        )


class EggProductionService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.groups = PoultryGroupService(db)

    def add(
        self,
        *,
        owner_id: UUID,
        group_id: UUID,
        produced_at: datetime,
        quantity: Decimal,
        unit: str,
        price_per_unit: Decimal,
        note: str | None = None,
    ) -> EggProductionModel:
        group = self.groups.get(owner_id=owner_id, group_id=group_id)
        assert_not_archived(group.is_archived)
        assert_eggs_allowed(group.poultry_type)
        qty = validate_positive_quantity(quantity)
        unit_v = validate_unit(unit)
        price = validate_non_negative_price(price_per_unit)

        row = EggProductionModel(
            id=uuid4(),
            poultry_group_id=group.id,
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
            "Egg production added id=%s group_id=%s owner_id=%s",
            row.id,
            group.id,
            owner_id,
        )
        return row

    def list(
        self,
        *,
        owner_id: UUID,
        group_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
    ) -> tuple[list[EggProductionModel], int]:
        self.groups.get(owner_id=owner_id, group_id=group_id)
        lim, off = _clamp_paging(limit, offset)
        filters = [
            EggProductionModel.owner_id == owner_id,
            EggProductionModel.poultry_group_id == group_id,
        ]
        total = self.db.scalar(
            select(func.count()).select_from(EggProductionModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(EggProductionModel)
                .where(*filters)
                .order_by(EggProductionModel.produced_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def get(
        self, *, owner_id: UUID, group_id: UUID, egg_id: UUID
    ) -> EggProductionModel:
        self.groups.get(owner_id=owner_id, group_id=group_id)
        row = self.db.scalar(
            select(EggProductionModel).where(
                EggProductionModel.id == egg_id,
                EggProductionModel.poultry_group_id == group_id,
                EggProductionModel.owner_id == owner_id,
            )
        )
        if row is None:
            raise AppError(
                code="EGG_NOT_FOUND",
                message="Egg production entry not found.",
                status_code=404,
            )
        return row

    def update(
        self,
        *,
        owner_id: UUID,
        group_id: UUID,
        egg_id: UUID,
        produced_at: datetime | None = None,
        quantity: Decimal | None = None,
        unit: str | None = None,
        price_per_unit: Decimal | None = None,
        note: str | None = None,
        fields_set: set[str] | None = None,
    ) -> EggProductionModel:
        group = self.groups.get(owner_id=owner_id, group_id=group_id)
        assert_not_archived(group.is_archived)
        assert_eggs_allowed(group.poultry_type)
        row = self.get(owner_id=owner_id, group_id=group_id, egg_id=egg_id)
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
            "Egg production updated id=%s group_id=%s owner_id=%s",
            row.id,
            group_id,
            owner_id,
        )
        return row

    def delete(self, *, owner_id: UUID, group_id: UUID, egg_id: UUID) -> None:
        group = self.groups.get(owner_id=owner_id, group_id=group_id)
        assert_not_archived(group.is_archived)
        row = self.get(owner_id=owner_id, group_id=group_id, egg_id=egg_id)
        self.db.delete(row)
        self.db.commit()
        logger.info(
            "Egg production deleted id=%s group_id=%s owner_id=%s",
            egg_id,
            group_id,
            owner_id,
        )
