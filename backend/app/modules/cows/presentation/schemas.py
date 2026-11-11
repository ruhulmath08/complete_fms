from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, Field


class CowCreateRequest(BaseModel):
    purpose: str
    gender: str
    acquired_by: str
    name: str = Field(min_length=1, max_length=255)
    breed: str = Field(min_length=1, max_length=128)
    date_of_birth: date | None = None
    color: str | None = None
    weight: Decimal | None = None
    age: int | None = Field(default=None, ge=0)
    purchase_date: date | None = None
    purchase_price: Decimal | None = None
    notes: str | None = None


class CowUpdateRequest(BaseModel):
    purpose: str | None = None
    gender: str | None = None
    acquired_by: str | None = None
    name: str | None = Field(default=None, min_length=1, max_length=255)
    breed: str | None = Field(default=None, min_length=1, max_length=128)
    date_of_birth: date | None = None
    color: str | None = None
    weight: Decimal | None = None
    age: int | None = Field(default=None, ge=0)
    purchase_date: date | None = None
    purchase_price: Decimal | None = None
    notes: str | None = None


class CowResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    tag_number: str
    name: str | None
    breed: str | None
    date_of_birth: date | None
    purpose: str
    gender: str
    color: str | None
    weight: Decimal | None
    age: int | None
    acquired_by: str
    purchase_date: date | None
    purchase_price: Decimal | None
    notes: str | None
    image_url: str | None = None
    is_archived: bool
    created_at: datetime
    updated_at: datetime


class MilkCreateRequest(BaseModel):
    produced_at: datetime
    quantity: Decimal
    unit: str = Field(min_length=1, max_length=32)
    price_per_unit: Decimal
    note: str | None = None


class MilkProductionResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    cow_id: UUID
    produced_at: datetime
    quantity: Decimal
    unit: str
    price_per_unit: Decimal
    note: str | None
    created_at: datetime


class FeedingCreateRequest(BaseModel):
    fed_at: datetime
    feed_name: str = Field(min_length=1, max_length=255)
    quantity: Decimal
    unit: str = Field(min_length=1, max_length=32)
    note: str | None = None


class CowFeedingResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    cow_id: UUID
    fed_at: datetime
    feed_name: str
    quantity: Decimal
    unit: str
    note: str | None
    created_at: datetime
