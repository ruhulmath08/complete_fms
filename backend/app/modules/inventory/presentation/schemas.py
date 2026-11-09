from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, Field, computed_field

from app.modules.inventory.domain.rules import compute_total_price


class InventoryItemCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    category: str
    quantity: Decimal
    unit: str = Field(min_length=1, max_length=32)
    price_per_unit: Decimal
    note: str | None = None


class InventoryItemUpdateRequest(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=255)
    category: str | None = None
    unit: str | None = Field(default=None, min_length=1, max_length=32)
    price_per_unit: Decimal | None = None
    note: str | None = None


class InventoryItemResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    name: str
    category: str
    quantity: Decimal
    unit: str
    price_per_unit: Decimal
    note: str | None
    is_archived: bool
    created_at: datetime
    updated_at: datetime

    @computed_field  # type: ignore[prop-decorator]
    @property
    def total_price(self) -> Decimal:
        return compute_total_price(self.quantity, self.price_per_unit)


class StockUpdateCreateRequest(BaseModel):
    occurred_at: date
    change_type: str
    quantity_change: Decimal
    reason: str | None = None


class StockUpdateResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    inventory_item_id: UUID
    occurred_at: date
    change_type: str
    quantity_change: Decimal
    reason: str | None
    created_at: datetime
