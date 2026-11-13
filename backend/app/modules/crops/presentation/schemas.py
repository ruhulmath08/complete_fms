from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, Field


class CropNameCreateRequest(BaseModel):
    name: str = Field(min_length=1, max_length=255)
    notes: str | None = None


class CropNameUpdateRequest(BaseModel):
    name: str | None = Field(default=None, min_length=1, max_length=255)
    notes: str | None = None


class CropNameResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    name: str
    notes: str | None
    is_archived: bool
    created_at: datetime
    updated_at: datetime


class CropCycleCreateRequest(BaseModel):
    crop_name_id: UUID
    planted_at: date
    plot_name: str | None = None
    area: Decimal | None = None
    location: str | None = None
    expected_harvest_at: date | None = None
    notes: str | None = None


class CropCycleUpdateRequest(BaseModel):
    crop_name_id: UUID | None = None
    planted_at: date | None = None
    plot_name: str | None = None
    area: Decimal | None = None
    location: str | None = None
    expected_harvest_at: date | None = None
    notes: str | None = None


class CropCycleResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    crop_name_id: UUID
    plot_name: str | None
    area: Decimal | None
    location: str | None
    planted_at: date
    expected_harvest_at: date | None
    notes: str | None
    is_archived: bool
    created_at: datetime
    updated_at: datetime


class CropExpenseCreateRequest(BaseModel):
    spent_at: date
    category: str
    amount: Decimal
    note: str | None = None


class CropExpenseUpdateRequest(BaseModel):
    spent_at: date | None = None
    category: str | None = None
    amount: Decimal | None = None
    note: str | None = None


class CropExpenseResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    crop_cycle_id: UUID
    spent_at: date
    category: str
    amount: Decimal
    note: str | None
    created_at: datetime


class HarvestCreateRequest(BaseModel):
    harvested_at: date
    quantity: Decimal
    unit: str = Field(min_length=1, max_length=32)
    sale_amount: Decimal | None = None
    note: str | None = None


class HarvestUpdateRequest(BaseModel):
    harvested_at: date | None = None
    quantity: Decimal | None = None
    unit: str | None = Field(default=None, min_length=1, max_length=32)
    sale_amount: Decimal | None = None
    note: str | None = None


class HarvestResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    crop_cycle_id: UUID
    harvested_at: date
    quantity: Decimal
    unit: str
    sale_amount: Decimal | None
    note: str | None
    created_at: datetime


class CycleSummaryResponse(BaseModel):
    crop_cycle_id: UUID
    total_expenses: Decimal
    total_sale_income: Decimal
    result: Decimal
