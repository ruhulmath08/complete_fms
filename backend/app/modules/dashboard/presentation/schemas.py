from __future__ import annotations

from datetime import date
from decimal import Decimal

from pydantic import BaseModel, Field


class DashboardSeriesPoint(BaseModel):
    bucket_start: date
    value: Decimal


class DashboardSeriesBundle(BaseModel):
    egg_production: list[DashboardSeriesPoint]
    hen_headcount: list[DashboardSeriesPoint]
    milk: list[DashboardSeriesPoint]
    cow_production: list[DashboardSeriesPoint]
    expenses_cost: list[DashboardSeriesPoint]
    income: list[DashboardSeriesPoint]


class DashboardAggregatesResponse(BaseModel):
    from_: date = Field(alias="from")
    to: date
    grain: str
    timezone: str
    series: DashboardSeriesBundle

    model_config = {"populate_by_name": True}
