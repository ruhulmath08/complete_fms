from __future__ import annotations

import logging
from datetime import date
from decimal import Decimal
from uuid import UUID, uuid4

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.core.errors import AppError
from app.modules.income_expenses.domain.rules import (
    EntryType,
    assert_entry_not_archived,
    compute_net,
    parse_entry_category,
    parse_entry_type,
    validate_date_range,
    validate_optional_text,
    validate_optional_unit,
    validate_positive_amount,
)
from app.modules.income_expenses.infrastructure.models import LedgerEntryModel

logger = logging.getLogger(__name__)


def _clamp_paging(limit: int | None, offset: int | None) -> tuple[int, int]:
    lim = 20 if limit is None else limit
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


class LedgerEntryService:
    def __init__(self, db: Session) -> None:
        self.db = db

    def create(
        self,
        *,
        owner_id: UUID,
        entry_type: str,
        occurred_at: date,
        category: str,
        amount: Decimal,
        unit: str | None = None,
        note: str | None = None,
    ) -> LedgerEntryModel:
        row = LedgerEntryModel(
            id=uuid4(),
            owner_id=owner_id,
            entry_type=parse_entry_type(entry_type).value,
            occurred_at=occurred_at,
            category=parse_entry_category(category).value,
            amount=validate_positive_amount(amount),
            unit=validate_optional_unit(unit),
            note=validate_optional_text(note, field="note"),
            is_archived=False,
        )
        self.db.add(row)
        self.db.commit()
        self.db.refresh(row)
        logger.info("Ledger entry created entry_id=%s owner_id=%s", row.id, owner_id)
        return row

    def list(
        self,
        *,
        owner_id: UUID,
        limit: int | None = None,
        offset: int | None = None,
        include_archived: bool = False,
        from_date: date | None = None,
        to_date: date | None = None,
    ) -> tuple[list[LedgerEntryModel], int]:
        lim, off = _clamp_paging(limit, offset)
        if from_date is not None and to_date is not None:
            validate_date_range(from_date, to_date)
        elif from_date is not None or to_date is not None:
            raise AppError(
                code="VALIDATION_ERROR",
                message="Both from and to are required when filtering by date.",
                status_code=422,
                details={"field": "from"},
            )

        filters = [LedgerEntryModel.owner_id == owner_id]
        if not include_archived:
            filters.append(LedgerEntryModel.is_archived.is_(False))
        if from_date is not None and to_date is not None:
            filters.append(LedgerEntryModel.occurred_at >= from_date)
            filters.append(LedgerEntryModel.occurred_at <= to_date)

        total = self.db.scalar(
            select(func.count()).select_from(LedgerEntryModel).where(*filters)
        ) or 0
        items = list(
            self.db.scalars(
                select(LedgerEntryModel)
                .where(*filters)
                .order_by(
                    LedgerEntryModel.occurred_at.desc(),
                    LedgerEntryModel.created_at.desc(),
                )
                .limit(lim)
                .offset(off)
            ).all()
        )
        return items, total

    def get(self, *, owner_id: UUID, entry_id: UUID) -> LedgerEntryModel:
        row = self.db.scalar(
            select(LedgerEntryModel).where(
                LedgerEntryModel.id == entry_id,
                LedgerEntryModel.owner_id == owner_id,
            )
        )
        if row is None:
            raise AppError(
                code="LEDGER_ENTRY_NOT_FOUND",
                message="Ledger entry not found.",
                status_code=404,
            )
        return row

    def update(
        self,
        *,
        owner_id: UUID,
        entry_id: UUID,
        entry_type: str | None = None,
        occurred_at: date | None = None,
        category: str | None = None,
        amount: Decimal | None = None,
        unit: str | None = None,
        note: str | None = None,
        fields_set: set[str] | None = None,
    ) -> LedgerEntryModel:
        row = self.get(owner_id=owner_id, entry_id=entry_id)
        assert_entry_not_archived(row.is_archived)
        set_fields = fields_set or set()

        if "entry_type" in set_fields and entry_type is not None:
            row.entry_type = parse_entry_type(entry_type).value
        if "occurred_at" in set_fields and occurred_at is not None:
            row.occurred_at = occurred_at
        if "category" in set_fields and category is not None:
            row.category = parse_entry_category(category).value
        if "amount" in set_fields and amount is not None:
            row.amount = validate_positive_amount(amount)
        if "unit" in set_fields:
            row.unit = validate_optional_unit(unit)
        if "note" in set_fields:
            row.note = validate_optional_text(note, field="note")

        self.db.commit()
        self.db.refresh(row)
        logger.info("Ledger entry updated entry_id=%s owner_id=%s", row.id, owner_id)
        return row

    def archive(self, *, owner_id: UUID, entry_id: UUID) -> LedgerEntryModel:
        row = self.get(owner_id=owner_id, entry_id=entry_id)
        if row.is_archived:
            return row
        row.is_archived = True
        self.db.commit()
        self.db.refresh(row)
        logger.info("Ledger entry archived entry_id=%s owner_id=%s", row.id, owner_id)
        return row


class PeriodTotalsService:
    def __init__(self, db: Session) -> None:
        self.db = db

    def get_totals(
        self,
        *,
        owner_id: UUID,
        from_date: date,
        to_date: date,
    ) -> dict[str, Decimal | date]:
        validate_date_range(from_date, to_date)
        filters = [
            LedgerEntryModel.owner_id == owner_id,
            LedgerEntryModel.is_archived.is_(False),
            LedgerEntryModel.occurred_at >= from_date,
            LedgerEntryModel.occurred_at <= to_date,
        ]

        income = self.db.scalar(
            select(func.coalesce(func.sum(LedgerEntryModel.amount), 0)).where(
                *filters,
                LedgerEntryModel.entry_type == EntryType.INCOME.value,
            )
        )
        expenses = self.db.scalar(
            select(func.coalesce(func.sum(LedgerEntryModel.amount), 0)).where(
                *filters,
                LedgerEntryModel.entry_type == EntryType.EXPENSE.value,
            )
        )
        total_income = Decimal(income or 0).quantize(Decimal("0.01"))
        total_expenses = Decimal(expenses or 0).quantize(Decimal("0.01"))
        return {
            "from": from_date,
            "to": to_date,
            "total_income": total_income,
            "total_expenses": total_expenses,
            "net": compute_net(total_income, total_expenses),
        }
