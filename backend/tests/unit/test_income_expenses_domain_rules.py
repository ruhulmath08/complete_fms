from datetime import date
from decimal import Decimal

import pytest

from app.core.errors import AppError
from app.modules.income_expenses.domain.rules import (
    EntryType,
    assert_entry_not_archived,
    compute_net,
    parse_entry_category,
    parse_entry_type,
    validate_date_range,
    validate_positive_amount,
)


def test_parse_entry_type_and_category() -> None:
    assert parse_entry_type("income") == EntryType.INCOME
    assert parse_entry_type("expense") == EntryType.EXPENSE
    with pytest.raises(AppError) as exc:
        parse_entry_type("transfer")
    assert exc.value.code == "VALIDATION_ERROR"

    assert parse_entry_category("labour").value == "labour"
    assert parse_entry_category("other").value == "other"
    with pytest.raises(AppError):
        parse_entry_category("feed")


def test_amount_date_range_net_and_archive() -> None:
    assert validate_positive_amount(Decimal("10.5")) == Decimal("10.50")
    with pytest.raises(AppError):
        validate_positive_amount(Decimal("0"))
    with pytest.raises(AppError):
        validate_positive_amount(Decimal("-1"))

    validate_date_range(date(2024, 1, 1), date(2024, 1, 31))
    with pytest.raises(AppError):
        validate_date_range(date(2024, 2, 1), date(2024, 1, 1))

    assert compute_net(Decimal("100.00"), Decimal("40.00")) == Decimal("60.00")

    assert_entry_not_archived(False)
    with pytest.raises(AppError) as exc:
        assert_entry_not_archived(True)
    assert exc.value.code == "LEDGER_ENTRY_ARCHIVED"
