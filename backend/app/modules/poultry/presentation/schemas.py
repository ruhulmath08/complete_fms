from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, Field


class PoultryGroupCreateRequest(BaseModel):
    poultry_type: str
    name: str = Field(min_length=1, max_length=255)
    bird_count: int = Field(ge=0)
    acquired_by: str
    date_acquired: date | None = None
    purchase_date: date | None = None
    purchase_price: Decimal | None = None
    notes: str | None = None


class PoultryGroupUpdateRequest(BaseModel):
    poultry_type: str | None = None
    name: str | None = Field(default=None, min_length=1, max_length=255)
    bird_count: int | None = Field(default=None, ge=0)
    acquired_by: str | None = None
    date_acquired: date | None = None
    purchase_date: date | None = None
    purchase_price: Decimal | None = None
    notes: str | None = None


class PoultryGroupResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    poultry_type: str
    name: str
    bird_count: int
    date_acquired: date | None
    acquired_by: str
    purchase_date: date | None
    purchase_price: Decimal | None
    notes: str | None
    is_archived: bool
    created_at: datetime
    updated_at: datetime


class PoultryFeedingCreateRequest(BaseModel):
    fed_at: datetime
    feed_name: str = Field(min_length=1, max_length=255)
    quantity: Decimal
    unit: str = Field(min_length=1, max_length=32)
    note: str | None = None


class PoultryFeedingUpdateRequest(BaseModel):
    fed_at: datetime | None = None
    feed_name: str | None = Field(default=None, min_length=1, max_length=255)
    quantity: Decimal | None = None
    unit: str | None = Field(default=None, min_length=1, max_length=32)
    note: str | None = None


class PoultryFeedingResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    poultry_group_id: UUID
    fed_at: datetime
    feed_name: str
    quantity: Decimal
    unit: str
    note: str | None
    created_at: datetime


class EggProductionCreateRequest(BaseModel):
    produced_at: datetime
    quantity: Decimal
    unit: str = Field(min_length=1, max_length=32)
    price_per_unit: Decimal
    note: str | None = None


class EggProductionUpdateRequest(BaseModel):
    produced_at: datetime | None = None
    quantity: Decimal | None = None
    unit: str | None = Field(default=None, min_length=1, max_length=32)
    price_per_unit: Decimal | None = None
    note: str | None = None


class EggProductionResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    poultry_group_id: UUID
    produced_at: datetime
    quantity: Decimal
    unit: str
    price_per_unit: Decimal
    note: str | None
    created_at: datetime
