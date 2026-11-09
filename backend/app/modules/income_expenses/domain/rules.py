from __future__ import annotations

from datetime import date
from decimal import Decimal
from enum import StrEnum

from app.core.errors import AppError


class EntryType(StrEnum):
    INCOME = "income"
    EXPENSE = "expense"


class EntryCategory(StrEnum):
    LABOUR = "labour"
    FEED_OR_SUPPLIES = "feed_or_supplies"
    UTILITIES = "utilities"
    TRANSPORT = "transport"
    EQUIPMENT = "equipment"
    LIVESTOCK_SALE = "livestock_sale"
    PRODUCT_SALE = "product_sale"
    SUBSIDY = "subsidy"
    OTHER = "other"


def parse_entry_type(value: str) -> EntryType:
    try:
        return EntryType(value)
    except ValueError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Entry type must be income or expense.",
            status_code=422,
            details={"field": "entry_type"},
        ) from exc


def parse_entry_category(value: str) -> EntryCategory:
    try:
        return EntryCategory(value)
    except ValueError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message=(
                "Category must be labour, feed_or_supplies, utilities, transport, "
                "equipment, livestock_sale, product_sale, subsidy, or other."
            ),
            status_code=422,
            details={"field": "category"},
        ) from exc


def validate_optional_text(value: str | None, *, field: str) -> str | None:
    if value is None:
        return None
    cleaned = value.strip()
    return cleaned or None


def validate_optional_unit(unit: str | None) -> str | None:
    if unit is None:
        return None
    cleaned = unit.strip()
    return cleaned or None


def validate_positive_amount(amount: Decimal) -> Decimal:
    if amount <= 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Amount must be greater than zero.",
            status_code=422,
            details={"field": "amount"},
        )
    return amount.quantize(Decimal("0.01"))


def validate_date_range(from_date: date, to_date: date) -> None:
    if from_date > to_date:
        raise AppError(
            code="VALIDATION_ERROR",
            message="from must be less than or equal to to.",
            status_code=422,
            details={"field": "from"},
        )


def assert_entry_not_archived(is_archived: bool) -> None:
    if is_archived:
        raise AppError(
            code="LEDGER_ENTRY_ARCHIVED",
            message="This ledger entry is archived and cannot be modified.",
            status_code=409,
        )


def compute_net(total_income: Decimal, total_expenses: Decimal) -> Decimal:
    return (total_income - total_expenses).quantize(Decimal("0.01"))
