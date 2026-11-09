from decimal import Decimal

import pytest

from app.core.errors import AppError
from app.modules.crops.domain.rules import (
    assert_crop_name_active_for_cycle,
    assert_crop_name_not_archived_for_write,
    assert_cycle_not_archived,
    parse_expense_category,
    validate_area,
    validate_crop_name,
    validate_non_negative_money,
    validate_positive_amount,
    validate_positive_quantity,
    validate_unit,
)


def test_parse_expense_category() -> None:
    assert parse_expense_category("labour").value == "labour"
    assert parse_expense_category("seeds").value == "seeds"
    with pytest.raises(AppError) as exc:
        parse_expense_category("fuel")
    assert exc.value.code == "VALIDATION_ERROR"


def test_name_and_amounts() -> None:
    assert validate_crop_name(" Rice ") == "Rice"
    with pytest.raises(AppError):
        validate_crop_name("  ")

    assert validate_area(None) is None
    assert validate_area(Decimal("1.5")) == Decimal("1.5")
    with pytest.raises(AppError):
        validate_area(Decimal("-1"))

    assert validate_positive_amount(Decimal("10")) == Decimal("10")
    with pytest.raises(AppError):
        validate_positive_amount(Decimal("0"))

    assert validate_non_negative_money(None) is None
    assert validate_non_negative_money(Decimal("0")) == Decimal("0")
    with pytest.raises(AppError):
        validate_non_negative_money(Decimal("-1"))

    assert validate_positive_quantity(Decimal("2")) == Decimal("2")
    assert validate_unit(" kg ") == "kg"


def test_archive_guards() -> None:
    assert_crop_name_not_archived_for_write(False)
    with pytest.raises(AppError) as exc:
        assert_crop_name_not_archived_for_write(True)
    assert exc.value.code == "CROP_NAME_ARCHIVED"
    assert exc.value.status_code == 409

    assert_crop_name_active_for_cycle(False)
    with pytest.raises(AppError) as exc:
        assert_crop_name_active_for_cycle(True)
    assert exc.value.code == "CROP_NAME_ARCHIVED"
    assert exc.value.status_code == 422

    assert_cycle_not_archived(False)
    with pytest.raises(AppError) as exc:
        assert_cycle_not_archived(True)
    assert exc.value.code == "CROP_CYCLE_ARCHIVED"
