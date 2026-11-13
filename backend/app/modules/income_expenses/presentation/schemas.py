from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, Field, computed_field


class LedgerEntryCreateRequest(BaseModel):
    entry_type: str
    occurred_at: date
    category: str
    amount: Decimal
    unit: str | None = Field(default=None, max_length=32)
    note: str | None = None


class LedgerEntryUpdateRequest(BaseModel):
    entry_type: str | None = None
    occurred_at: date | None = None
    category: str | None = None
    amount: Decimal | None = None
    unit: str | None = Field(default=None, max_length=32)
    note: str | None = None


class LedgerEntryResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    entry_type: str
    occurred_at: date
    category: str
    amount: Decimal
    unit: str | None
    note: str | None
    is_archived: bool
    created_at: datetime
    updated_at: datetime

    @computed_field  # type: ignore[prop-decorator]
    @property
    def total_price(self) -> Decimal:
        return self.amount


class PeriodTotalsResponse(BaseModel):
    from_: date = Field(alias="from")
    to: date
    total_income: Decimal
    total_expenses: Decimal
    net: Decimal

    model_config = {"populate_by_name": True}


class LedgerSeriesPointResponse(BaseModel):
    bucket_start: date
    income: Decimal
    expenses: Decimal
    net: Decimal


class LedgerSeriesResponse(BaseModel):
    from_: date = Field(alias="from")
    to: date
    grain: str
    points: list[LedgerSeriesPointResponse]

    model_config = {"populate_by_name": True}
