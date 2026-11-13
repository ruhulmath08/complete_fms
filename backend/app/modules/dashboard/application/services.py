from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID
from zoneinfo import ZoneInfo

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.core.farm_clock import (
    DEFAULT_FARM_TIMEZONE,
    assert_not_future,
    bucket_for,
    bucket_starts,
    parse_grain,
    resolve_timezone,
)
from app.modules.auth.application.services import AuthService
from app.modules.cows.infrastructure.models import CowModel, MilkProductionModel
from app.modules.income_expenses.domain.rules import EntryType, validate_date_range
from app.modules.income_expenses.infrastructure.models import LedgerEntryModel
from app.modules.poultry.infrastructure.models import (
    EggProductionModel,
    PoultryGroupModel,
)


class DashboardAggregateService:
    def __init__(self, db: Session, settings: Settings) -> None:
        self.db = db
        self.settings = settings

    def get_aggregates(
        self,
        *,
        owner_id: UUID,
        from_date: date,
        to_date: date,
        grain: str,
    ) -> dict:
        validate_date_range(from_date, to_date)
        grain_value = parse_grain(grain)
        farm = AuthService(self.db, self.settings).get_farm_settings(owner_id)
        tz_name = farm.timezone or DEFAULT_FARM_TIMEZONE
        assert_not_future(to_date, timezone_name=tz_name)
        tz = resolve_timezone(tz_name)
        starts = bucket_starts(from_date, to_date, grain_value)

        egg = self._sum_egg(owner_id, from_date, to_date, grain_value, tz, starts)
        milk = self._sum_milk(owner_id, from_date, to_date, grain_value, tz, starts)
        hen = self._hen_headcount(owner_id, starts)
        cows = self._cow_headcount(owner_id, starts)
        income, expenses = self._ledger_sums(
            owner_id, from_date, to_date, grain_value, starts
        )

        def points(values: dict[date, Decimal]) -> list[dict]:
            return [
                {"bucket_start": s, "value": values[s].quantize(Decimal("0.01"))}
                for s in starts
            ]

        return {
            "from": from_date,
            "to": to_date,
            "grain": grain_value,
            "timezone": tz_name,
            "series": {
                "egg_production": points(egg),
                "hen_headcount": points(hen),
                "milk": points(milk),
                "cow_production": points(cows),
                "expenses_cost": points(expenses),
                "income": points(income),
            },
        }

    def _empty(self, starts: list[date]) -> dict[date, Decimal]:
        return {s: Decimal("0") for s in starts}

    def _local_date(self, value: datetime, tz: ZoneInfo) -> date:
        if value.tzinfo is None:
            value = value.replace(tzinfo=tz)
        return value.astimezone(tz).date()

    def _sum_egg(
        self,
        owner_id: UUID,
        from_date: date,
        to_date: date,
        grain: str,
        tz: ZoneInfo,
        starts: list[date],
    ) -> dict[date, Decimal]:
        values = self._empty(starts)
        rows = self.db.execute(
            select(EggProductionModel.produced_at, EggProductionModel.quantity).where(
                EggProductionModel.owner_id == owner_id,
            )
        ).all()
        for produced_at, quantity in rows:
            day = self._local_date(produced_at, tz)
            if day < from_date or day > to_date:
                continue
            bucket = bucket_for(day, grain)
            if bucket in values:
                values[bucket] += Decimal(quantity or 0)
        return values

    def _sum_milk(
        self,
        owner_id: UUID,
        from_date: date,
        to_date: date,
        grain: str,
        tz: ZoneInfo,
        starts: list[date],
    ) -> dict[date, Decimal]:
        values = self._empty(starts)
        rows = self.db.execute(
            select(MilkProductionModel.produced_at, MilkProductionModel.quantity).where(
                MilkProductionModel.owner_id == owner_id,
            )
        ).all()
        for produced_at, quantity in rows:
            day = self._local_date(produced_at, tz)
            if day < from_date or day > to_date:
                continue
            bucket = bucket_for(day, grain)
            if bucket in values:
                values[bucket] += Decimal(quantity or 0)
        return values

    def _hen_headcount(
        self, owner_id: UUID, starts: list[date]
    ) -> dict[date, Decimal]:
        total = self.db.scalar(
            select(func.coalesce(func.sum(PoultryGroupModel.bird_count), 0)).where(
                PoultryGroupModel.owner_id == owner_id,
                PoultryGroupModel.is_archived.is_(False),
            )
        )
        value = Decimal(total or 0)
        return {s: value for s in starts}

    def _cow_headcount(
        self, owner_id: UUID, starts: list[date]
    ) -> dict[date, Decimal]:
        total = self.db.scalar(
            select(func.count()).select_from(CowModel).where(
                CowModel.owner_id == owner_id,
                CowModel.is_archived.is_(False),
            )
        )
        value = Decimal(total or 0)
        return {s: value for s in starts}

    def _ledger_sums(
        self,
        owner_id: UUID,
        from_date: date,
        to_date: date,
        grain: str,
        starts: list[date],
    ) -> tuple[dict[date, Decimal], dict[date, Decimal]]:
        income = self._empty(starts)
        expenses = self._empty(starts)
        rows = self.db.execute(
            select(
                LedgerEntryModel.occurred_at,
                LedgerEntryModel.entry_type,
                LedgerEntryModel.amount,
            ).where(
                LedgerEntryModel.owner_id == owner_id,
                LedgerEntryModel.is_archived.is_(False),
                LedgerEntryModel.occurred_at >= from_date,
                LedgerEntryModel.occurred_at <= to_date,
            )
        ).all()
        for occurred_at, entry_type, amount in rows:
            bucket = bucket_for(occurred_at, grain)
            if bucket not in income:
                continue
            value = Decimal(amount or 0)
            if entry_type == EntryType.INCOME.value:
                income[bucket] += value
            elif entry_type == EntryType.EXPENSE.value:
                expenses[bucket] += value
        return income, expenses
