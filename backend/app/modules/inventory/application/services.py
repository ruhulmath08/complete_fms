from __future__ import annotations

import logging
from datetime import date
from decimal import Decimal
from uuid import UUID, uuid4

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.modules.inventory.domain.rules import (
    apply_stock_change,
    assert_item_not_archived,
    parse_inventory_category,
    parse_stock_change_type,
    validate_item_name,
    validate_non_negative_money,
    validate_non_negative_quantity,
    validate_optional_text,
    validate_positive_quantity_change,
    validate_unit,
)
from app.modules.inventory.infrastructure.models import (
    InventoryItemModel,
    StockUpdateModel,
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


class InventoryItemService:
    def __init__(self, db: Session) -> None:
        self.db = db

    def create(
        self,
        *,
        owner_id: UUID,
        name: str,
        category: str,
        quantity: Decimal,
        unit: str,
        price_per_unit: Decimal,
        note: str | None = None,
    ) -> InventoryItemModel:
        row = InventoryItemModel(
            id=uuid4(),
            owner_id=owner_id,
            name=validate_item_name(name),
            category=parse_inventory_category(category).value,
            quantity=validate_non_negative_quantity(quantity),
            unit=validate_unit(unit),
            price_per_unit=validate_non_negative_money(price_per_unit),
            note=validate_optional_text(note, field="note"),
            is_archived=False,
        )
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info("Inventory item created item_id=%s owner_id=%s", row.id, owner_id)
        return row

    def list(
        self,
        *,
        owner_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
        include_archived: bool = False,
    ) -> tuple[list[InventoryItemModel], int]:
        lim, off = _clamp_paging(limit, offset)
        filters = [InventoryItemModel.owner_id == owner_id]
        if not include_archived:
            filters.append(InventoryItemModel.is_archived.is_(False))
        total = self.db.scalar(
            select(func.count()).select_from(InventoryItemModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(InventoryItemModel)
                .where(*filters)
                .order_by(InventoryItemModel.created_at.desc())
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def get(self, *, owner_id: UUID, item_id: UUID) -> InventoryItemModel:
        row = self.db.scalar(
            select(InventoryItemModel).where(
                InventoryItemModel.id == item_id,
                InventoryItemModel.owner_id == owner_id,
            )
        )
        if row is None:
            raise AppError(
                code="INVENTORY_ITEM_NOT_FOUND",
                message="Inventory item not found.",
                status_code=404,
            )
        return row

    def update(
        self,
        *,
        owner_id: UUID,
        item_id: UUID,
        name: str | None = None,
        category: str | None = None,
        unit: str | None = None,
        price_per_unit: Decimal | None = None,
        note: str | None = None,
        fields_set: set[str] | None = None,
    ) -> InventoryItemModel:
        row = self.get(owner_id=owner_id, item_id=item_id)
        assert_item_not_archived(row.is_archived)
        set_fields = fields_set or set()

        if "name" in set_fields and name is not None:
            row.name = validate_item_name(name)
        if "category" in set_fields and category is not None:
            row.category = parse_inventory_category(category).value
        if "unit" in set_fields and unit is not None:
            row.unit = validate_unit(unit)
        if "price_per_unit" in set_fields and price_per_unit is not None:
            row.price_per_unit = validate_non_negative_money(price_per_unit)
        if "note" in set_fields:
            row.note = validate_optional_text(note, field="note")

        self.db.commit()
        self.db.refresh(row)
        logger.info("Inventory item updated item_id=%s owner_id=%s", row.id, owner_id)
        return row

    def archive(self, *, owner_id: UUID, item_id: UUID) -> InventoryItemModel:
        row = self.get(owner_id=owner_id, item_id=item_id)
        if row.is_archived:
            return row
        row.is_archived = True
        self.db.commit()
        self.db.refresh(row)
        logger.info("Inventory item archived item_id=%s owner_id=%s", row.id, owner_id)
        return row


class StockUpdateService:
    def __init__(self, db: Session) -> None:
        self.db = db
        self.items = InventoryItemService(db)

    def add(
        self,
        *,
        owner_id: UUID,
        item_id: UUID,
        occurred_at: date,
        change_type: str,
        quantity_change: Decimal,
        reason: str | None = None,
    ) -> StockUpdateModel:
        item = self.items.get(owner_id=owner_id, item_id=item_id)
        assert_item_not_archived(item.is_archived)

        change = parse_stock_change_type(change_type)
        qty = validate_positive_quantity_change(quantity_change)
        item.quantity = apply_stock_change(
            current_quantity=item.quantity,
            change_type=change,
            quantity_change=qty,
        )

        row = StockUpdateModel(
            id=uuid4(),
            inventory_item_id=item.id,
            owner_id=owner_id,
            occurred_at=occurred_at,
            change_type=change.value,
            quantity_change=qty,
            reason=validate_optional_text(reason, field="reason"),
        )
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info(
            "Stock update recorded update_id=%s item_id=%s type=%s",
            row.id,
            item_id,
            change.value,
        )
        return row

    def list_by_item(
        self,
        *,
        owner_id: UUID,
        item_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
    ) -> tuple[list[StockUpdateModel], int]:
        self.items.get(owner_id=owner_id, item_id=item_id)
        lim, off = _clamp_paging(limit, offset)
        filters = [
            StockUpdateModel.owner_id == owner_id,
            StockUpdateModel.inventory_item_id == item_id,
        ]
        total = self.db.scalar(
            select(func.count()).select_from(StockUpdateModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(StockUpdateModel)
                .where(*filters)
                .order_by(
                    StockUpdateModel.occurred_at.desc(),
                    StockUpdateModel.created_at.desc(),
                )
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def list_by_category(
        self,
        *,
        owner_id: UUID,
        category: str,
        limit: int | None = None,
        offset: int | None = None,
    ) -> tuple[list[tuple[StockUpdateModel, InventoryItemModel]], int]:
        cat = parse_inventory_category(category).value
        lim, off = _clamp_paging(limit, offset)
        filters = [
            StockUpdateModel.owner_id == owner_id,
            InventoryItemModel.owner_id == owner_id,
            InventoryItemModel.category == cat,
        ]
        total = self.db.scalar(
            select(func.count())
            .select_from(StockUpdateModel)
            .join(
                InventoryItemModel,
                InventoryItemModel.id == StockUpdateModel.inventory_item_id,
            )
            .where(*filters)
        ) or 0
        rows = list(
            self.db.execute(
                select(StockUpdateModel, InventoryItemModel)
                .join(
                    InventoryItemModel,
                    InventoryItemModel.id == StockUpdateModel.inventory_item_id,
                )
                .where(*filters)
                .order_by(
                    StockUpdateModel.occurred_at.desc(),
                    StockUpdateModel.created_at.desc(),
                )
                .limit(lim)
                .offset(off)
            ).all()
        )
        return [(r[0], r[1]) for r in rows], total
