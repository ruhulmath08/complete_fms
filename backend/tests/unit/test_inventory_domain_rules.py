from decimal import Decimal

import pytest

from app.core.errors import AppError
from app.modules.inventory.domain.rules import (
    StockChangeType,
    apply_stock_change,
    assert_item_not_archived,
    compute_total_price,
    parse_inventory_category,
    parse_stock_change_type,
    validate_item_name,
    validate_non_negative_money,
    validate_non_negative_quantity,
    validate_positive_quantity_change,
)


def test_parse_category_and_change_type() -> None:
    assert parse_inventory_category("feed").value == "feed"
    assert parse_inventory_category("other").value == "other"
    with pytest.raises(AppError) as exc:
        parse_inventory_category("labour")
    assert exc.value.code == "VALIDATION_ERROR"

    assert parse_stock_change_type("add") == StockChangeType.ADD
    assert parse_stock_change_type("use") == StockChangeType.USE
    with pytest.raises(AppError):
        parse_stock_change_type("remove")


def test_quantities_and_total_price() -> None:
    assert validate_item_name(" Feed ") == "Feed"
    with pytest.raises(AppError):
        validate_item_name("  ")

    assert validate_non_negative_quantity(Decimal("0")) == Decimal("0")
    with pytest.raises(AppError):
        validate_non_negative_quantity(Decimal("-1"))

    assert validate_positive_quantity_change(Decimal("1")) == Decimal("1")
    with pytest.raises(AppError):
        validate_positive_quantity_change(Decimal("0"))

    assert validate_non_negative_money(Decimal("0")) == Decimal("0")
    with pytest.raises(AppError):
        validate_non_negative_money(Decimal("-0.01"))

    assert compute_total_price(Decimal("2"), Decimal("10.50")) == Decimal("21.00")


def test_apply_stock_change_and_archive_guard() -> None:
    assert apply_stock_change(
        current_quantity=Decimal("10"),
        change_type=StockChangeType.ADD,
        quantity_change=Decimal("2"),
    ) == Decimal("12")
    assert apply_stock_change(
        current_quantity=Decimal("10"),
        change_type=StockChangeType.USE,
        quantity_change=Decimal("10"),
    ) == Decimal("0")

    with pytest.raises(AppError) as exc:
        apply_stock_change(
            current_quantity=Decimal("5"),
            change_type=StockChangeType.USE,
            quantity_change=Decimal("6"),
        )
    assert exc.value.code == "INSUFFICIENT_STOCK"
    assert exc.value.status_code == 409
    assert exc.value.details["quantity"] == "5"
    assert exc.value.details["requested"] == "6"

    assert_item_not_archived(False)
    with pytest.raises(AppError) as exc:
        assert_item_not_archived(True)
    assert exc.value.code == "INVENTORY_ITEM_ARCHIVED"
