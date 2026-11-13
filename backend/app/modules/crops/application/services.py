from __future__ import annotations

import logging
from datetime import date
from decimal import Decimal
from uuid import UUID, uuid4

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.modules.crops.domain.rules import (
    assert_crop_name_active_for_cycle,
    assert_crop_name_not_archived_for_write,
    assert_cycle_not_archived,
    parse_expense_category,
    validate_area,
    validate_crop_name,
    validate_non_negative_money,
    validate_optional_text,
    validate_positive_amount,
    validate_positive_quantity,
    validate_unit,
)
from app.modules.crops.infrastructure.models import (
    CropCycleModel,
    CropExpenseModel,
    CropNameModel,
    HarvestModel,
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


class CropNameService:
    def __init__(self, db: Session) -> None:
        self.db = db

    def create(
        self,
        *,
        owner_id: UUID,
        name: str,
        notes: str | None = None,
    ) -> CropNameModel:
        name_v = validate_crop_name(name)
        self._assert_name_available(owner_id, name_v)
        row = CropNameModel(
            id=uuid4(),
            owner_id=owner_id,
            name=name_v,
            notes=validate_optional_text(notes, field="notes"),
            is_archived=False,
        )
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info("Crop name created crop_name_id=%s owner_id=%s", row.id, owner_id)
        return row

    def list(
        self,
        *,
        owner_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
        include_archived: bool = False,
    ) -> tuple[list[CropNameModel], int]:
        lim, off = _clamp_paging(limit, offset)
        filters = [CropNameModel.owner_id == owner_id]
        if not include_archived:
            filters.append(CropNameModel.is_archived.is_(False))
        total = self.db.scalar(
            select(func.count()).select_from(CropNameModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(CropNameModel)
                .where(*filters)
                .order_by(CropNameModel.created_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def get(self, *, owner_id: UUID, crop_name_id: UUID) -> CropNameModel:
        row = self.db.scalar(
            select(CropNameModel).where(
                CropNameModel.id == crop_name_id,
                CropNameModel.owner_id == owner_id,
            )
        )
        if row is None:
            raise AppError(
                code="CROP_NAME_NOT_FOUND",
                message="Crop name not found.",
                status_code=404,
            )
        return row

    def update(
        self,
        *,
        owner_id: UUID,
        crop_name_id: UUID,
        name: str | None = None,
        notes: str | None = None,
        fields_set: set[str] | None = None,
    ) -> CropNameModel:
        row = self.get(owner_id=owner_id, crop_name_id=crop_name_id)
        assert_crop_name_not_archived_for_write(row.is_archived)
        set_fields = fields_set or set()
        if name is not None:
            name_v = validate_crop_name(name)
            self._assert_name_available(owner_id, name_v, exclude_id=row.id)
            row.name = name_v
        if "notes" in set_fields:
            row.notes = validate_optional_text(notes, field="notes")
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info("Crop name updated crop_name_id=%s owner_id=%s", row.id, owner_id)
        return row

    def archive(self, *, owner_id: UUID, crop_name_id: UUID) -> CropNameModel:
        row = self.get(owner_id=owner_id, crop_name_id=crop_name_id)
        if row.is_archived:
            return row
        row.is_archived = True
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info("Crop name archived crop_name_id=%s owner_id=%s", row.id, owner_id)
        return row

    def _assert_name_available(
        self,
        owner_id: UUID,
        name: str,
        *,
        exclude_id: UUID | None = None,
    ) -> None:
        stmt = select(CropNameModel.id).where(
            CropNameModel.owner_id == owner_id,
            CropNameModel.name == name,
            CropNameModel.is_archived.is_(False),
        )
        if exclude_id is not None:
            stmt = stmt.where(CropNameModel.id != exclude_id)
        if self.db.scalar(stmt) is not None:
            raise AppError(
                code="CROP_NAME_ALREADY_EXISTS",
                message="An active crop name with this label already exists.",
                status_code=409,
            )


class CropCycleService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.names = CropNameService(db)

    def create(
        self,
        *,
        owner_id: UUID,
        crop_name_id: UUID,
        planted_at: date,
        plot_name: str | None = None,
        area: Decimal | None = None,
        location: str | None = None,
        expected_harvest_at: date | None = None,
        notes: str | None = None,
    ) -> CropCycleModel:
        crop_name = self.names.get(owner_id=owner_id, crop_name_id=crop_name_id)
        assert_crop_name_active_for_cycle(crop_name.is_archived)
        row = CropCycleModel(
            id=uuid4(),
            owner_id=owner_id,
            crop_name_id=crop_name.id,
            plot_name=validate_optional_text(plot_name, field="plot_name"),
            area=validate_area(area),
            location=validate_optional_text(location, field="location"),
            planted_at=planted_at,
            expected_harvest_at=expected_harvest_at,
            notes=validate_optional_text(notes, field="notes"),
            is_archived=False,
        )
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info("Crop cycle created cycle_id=%s owner_id=%s", row.id, owner_id)
        return row

    def list(
        self,
        *,
        owner_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
        include_archived: bool = False,
    ) -> tuple[list[CropCycleModel], int]:
        lim, off = _clamp_paging(limit, offset)
        filters = [CropCycleModel.owner_id == owner_id]
        if not include_archived:
            filters.append(CropCycleModel.is_archived.is_(False))
        total = self.db.scalar(
            select(func.count()).select_from(CropCycleModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(CropCycleModel)
                .where(*filters)
                .order_by(CropCycleModel.created_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def get(self, *, owner_id: UUID, cycle_id: UUID) -> CropCycleModel:
        row = self.db.scalar(
            select(CropCycleModel).where(
                CropCycleModel.id == cycle_id,
                CropCycleModel.owner_id == owner_id,
            )
        )
        if row is None:
            raise AppError(
                code="CROP_CYCLE_NOT_FOUND",
                message="Crop cycle not found.",
                status_code=404,
            )
        return row

    def update(
        self,
        *,
        owner_id: UUID,
        cycle_id: UUID,
        crop_name_id: UUID | None = None,
        planted_at: date | None = None,
        plot_name: str | None = None,
        area: Decimal | None = None,
        location: str | None = None,
        expected_harvest_at: date | None = None,
        notes: str | None = None,
        fields_set: set[str] | None = None,
    ) -> CropCycleModel:
        row = self.get(owner_id=owner_id, cycle_id=cycle_id)
        assert_cycle_not_archived(row.is_archived)
        set_fields = fields_set or set()

        if crop_name_id is not None:
            crop_name = self.names.get(owner_id=owner_id, crop_name_id=crop_name_id)
            assert_crop_name_active_for_cycle(crop_name.is_archived)
            row.crop_name_id = crop_name.id
        if planted_at is not None:
            row.planted_at = planted_at
        if "plot_name" in set_fields:
            row.plot_name = validate_optional_text(plot_name, field="plot_name")
        if "area" in set_fields:
            row.area = validate_area(area)
        if "location" in set_fields:
            row.location = validate_optional_text(location, field="location")
        if "expected_harvest_at" in set_fields:
            row.expected_harvest_at = expected_harvest_at
        if "notes" in set_fields:
            row.notes = validate_optional_text(notes, field="notes")

        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info("Crop cycle updated cycle_id=%s owner_id=%s", row.id, owner_id)
        return row

    def archive(self, *, owner_id: UUID, cycle_id: UUID) -> CropCycleModel:
        row = self.get(owner_id=owner_id, cycle_id=cycle_id)
        if row.is_archived:
            return row
        row.is_archived = True
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info("Crop cycle archived cycle_id=%s owner_id=%s", row.id, owner_id)
        return row

    def summary(self, *, owner_id: UUID, cycle_id: UUID) -> dict[str, Decimal | UUID]:
        self.get(owner_id=owner_id, cycle_id=cycle_id)
        total_expenses = self.db.scalar(
            select(func.coalesce(func.sum(CropExpenseModel.amount), 0)).where(
                CropExpenseModel.owner_id == owner_id,
                CropExpenseModel.crop_cycle_id == cycle_id,
            )
        ) or Decimal("0")
        total_sale_income = self.db.scalar(
            select(func.coalesce(func.sum(HarvestModel.sale_amount), 0)).where(
                HarvestModel.owner_id == owner_id,
                HarvestModel.crop_cycle_id == cycle_id,
            )
        ) or Decimal("0")
        total_expenses = Decimal(str(total_expenses))
        total_sale_income = Decimal(str(total_sale_income))
        return {
            "crop_cycle_id": cycle_id,
            "total_expenses": total_expenses,
            "total_sale_income": total_sale_income,
            "result": total_sale_income - total_expenses,
        }


class CropExpenseService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.cycles = CropCycleService(db)

    def add(
        self,
        *,
        owner_id: UUID,
        cycle_id: UUID,
        spent_at: date,
        category: str,
        amount: Decimal,
        note: str | None = None,
    ) -> CropExpenseModel:
        cycle = self.cycles.get(owner_id=owner_id, cycle_id=cycle_id)
        assert_cycle_not_archived(cycle.is_archived)
        row = CropExpenseModel(
            id=uuid4(),
            crop_cycle_id=cycle.id,
            owner_id=owner_id,
            spent_at=spent_at,
            category=parse_expense_category(category).value,
            amount=validate_positive_amount(amount),
            note=validate_optional_text(note, field="note"),
        )
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info(
            "Crop expense added id=%s cycle_id=%s owner_id=%s",
            row.id,
            cycle.id,
            owner_id,
        )
        return row

    def list(
        self,
        *,
        owner_id: UUID,
        cycle_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
    ) -> tuple[list[CropExpenseModel], int]:
        self.cycles.get(owner_id=owner_id, cycle_id=cycle_id)
        lim, off = _clamp_paging(limit, offset)
        filters = [
            CropExpenseModel.owner_id == owner_id,
            CropExpenseModel.crop_cycle_id == cycle_id,
        ]
        total = self.db.scalar(
            select(func.count()).select_from(CropExpenseModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(CropExpenseModel)
                .where(*filters)
                .order_by(CropExpenseModel.spent_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def get(
        self, *, owner_id: UUID, cycle_id: UUID, expense_id: UUID
    ) -> CropExpenseModel:
        self.cycles.get(owner_id=owner_id, cycle_id=cycle_id)
        row = self.db.scalar(
            select(CropExpenseModel).where(
                CropExpenseModel.id == expense_id,
                CropExpenseModel.crop_cycle_id == cycle_id,
                CropExpenseModel.owner_id == owner_id,
            )
        )
        if row is None:
            raise AppError(
                code="CROP_EXPENSE_NOT_FOUND",
                message="Crop expense not found.",
                status_code=404,
            )
        return row

    def update(
        self,
        *,
        owner_id: UUID,
        cycle_id: UUID,
        expense_id: UUID,
        spent_at: date | None = None,
        category: str | None = None,
        amount: Decimal | None = None,
        note: str | None = None,
        fields_set: set[str] | None = None,
    ) -> CropExpenseModel:
        cycle = self.cycles.get(owner_id=owner_id, cycle_id=cycle_id)
        assert_cycle_not_archived(cycle.is_archived)
        row = self.get(
            owner_id=owner_id, cycle_id=cycle_id, expense_id=expense_id
        )
        set_fields = fields_set or set()

        if "spent_at" in set_fields and spent_at is not None:
            row.spent_at = spent_at
        if "category" in set_fields and category is not None:
            row.category = parse_expense_category(category).value
        if "amount" in set_fields and amount is not None:
            row.amount = validate_positive_amount(amount)
        if "note" in set_fields:
            row.note = validate_optional_text(note, field="note")

        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info(
            "Crop expense updated id=%s cycle_id=%s owner_id=%s",
            row.id,
            cycle_id,
            owner_id,
        )
        return row

    def delete(
        self, *, owner_id: UUID, cycle_id: UUID, expense_id: UUID
    ) -> None:
        cycle = self.cycles.get(owner_id=owner_id, cycle_id=cycle_id)
        assert_cycle_not_archived(cycle.is_archived)
        row = self.get(
            owner_id=owner_id, cycle_id=cycle_id, expense_id=expense_id
        )
        self.db.delete(row)
        self.db.commit()
        logger.info(
            "Crop expense deleted id=%s cycle_id=%s owner_id=%s",
            expense_id,
            cycle_id,
            owner_id,
        )


class HarvestService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.cycles = CropCycleService(db)

    def add(
        self,
        *,
        owner_id: UUID,
        cycle_id: UUID,
        harvested_at: date,
        quantity: Decimal,
        unit: str,
        sale_amount: Decimal | None = None,
        note: str | None = None,
    ) -> HarvestModel:
        cycle = self.cycles.get(owner_id=owner_id, cycle_id=cycle_id)
        assert_cycle_not_archived(cycle.is_archived)
        row = HarvestModel(
            id=uuid4(),
            crop_cycle_id=cycle.id,
            owner_id=owner_id,
            harvested_at=harvested_at,
            quantity=validate_positive_quantity(quantity),
            unit=validate_unit(unit),
            sale_amount=validate_non_negative_money(sale_amount),
            note=validate_optional_text(note, field="note"),
        )
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info(
            "Harvest added id=%s cycle_id=%s owner_id=%s",
            row.id,
            cycle.id,
            owner_id,
        )
        return row

    def list(
        self,
        *,
        owner_id: UUID,
        cycle_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
    ) -> tuple[list[HarvestModel], int]:
        self.cycles.get(owner_id=owner_id, cycle_id=cycle_id)
        lim, off = _clamp_paging(limit, offset)
        filters = [
            HarvestModel.owner_id == owner_id,
            HarvestModel.crop_cycle_id == cycle_id,
        ]
        total = self.db.scalar(
            select(func.count()).select_from(HarvestModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(HarvestModel)
                .where(*filters)
                .order_by(HarvestModel.harvested_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def get(
        self, *, owner_id: UUID, cycle_id: UUID, harvest_id: UUID
    ) -> HarvestModel:
        self.cycles.get(owner_id=owner_id, cycle_id=cycle_id)
        row = self.db.scalar(
            select(HarvestModel).where(
                HarvestModel.id == harvest_id,
                HarvestModel.crop_cycle_id == cycle_id,
                HarvestModel.owner_id == owner_id,
            )
        )
        if row is None:
            raise AppError(
                code="HARVEST_NOT_FOUND",
                message="Harvest not found.",
                status_code=404,
            )
        return row

    def update(
        self,
        *,
        owner_id: UUID,
        cycle_id: UUID,
        harvest_id: UUID,
        harvested_at: date | None = None,
        quantity: Decimal | None = None,
        unit: str | None = None,
        sale_amount: Decimal | None = None,
        note: str | None = None,
        fields_set: set[str] | None = None,
    ) -> HarvestModel:
        cycle = self.cycles.get(owner_id=owner_id, cycle_id=cycle_id)
        assert_cycle_not_archived(cycle.is_archived)
        row = self.get(
            owner_id=owner_id, cycle_id=cycle_id, harvest_id=harvest_id
        )
        set_fields = fields_set or set()

        if "harvested_at" in set_fields and harvested_at is not None:
            row.harvested_at = harvested_at
        if "quantity" in set_fields and quantity is not None:
            row.quantity = validate_positive_quantity(quantity)
        if "unit" in set_fields and unit is not None:
            row.unit = validate_unit(unit)
        if "sale_amount" in set_fields:
            row.sale_amount = validate_non_negative_money(sale_amount)
        if "note" in set_fields:
            row.note = validate_optional_text(note, field="note")

        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info(
            "Harvest updated id=%s cycle_id=%s owner_id=%s",
            row.id,
            cycle_id,
            owner_id,
        )
        return row

    def delete(
        self, *, owner_id: UUID, cycle_id: UUID, harvest_id: UUID
    ) -> None:
        cycle = self.cycles.get(owner_id=owner_id, cycle_id=cycle_id)
        assert_cycle_not_archived(cycle.is_archived)
        row = self.get(
            owner_id=owner_id, cycle_id=cycle_id, harvest_id=harvest_id
        )
        self.db.delete(row)
        self.db.commit()
        logger.info(
            "Harvest deleted id=%s cycle_id=%s owner_id=%s",
            harvest_id,
            cycle_id,
            owner_id,
        )
