from __future__ import annotations

from decimal import Decimal
from enum import StrEnum

from app.core.errors import AppError


class InventoryCategory(StrEnum):
    FEED = "feed"
    FERTILIZER = "fertilizer"
    PESTICIDE = "pesticide"
    SEED = "seed"
    MEDICINE = "medicine"
    EQUIPMENT = "equipment"
    FUEL = "fuel"
    OTHER = "other"


class StockChangeType(StrEnum):
    ADD = "add"
    USE = "use"


def parse_inventory_category(value: str) -> InventoryCategory:
    try:
        return InventoryCategory(value)
    except ValueError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message=(
                "Inventory category must be feed, fertilizer, pesticide, seed, "
                "medicine, equipment, fuel, or other."
            ),
            status_code=422,
            details={"field": "category"},
        ) from exc


def parse_stock_change_type(value: str) -> StockChangeType:
    try:
        return StockChangeType(value)
    except ValueError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Stock change type must be add or use.",
            status_code=422,
            details={"field": "change_type"},
        ) from exc


def validate_item_name(name: str) -> str:
    cleaned = name.strip()
    if not cleaned:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Inventory item name is required.",
            status_code=422,
            details={"field": "name"},
        )
    return cleaned


def validate_optional_text(value: str | None, *, field: str) -> str | None:
    if value is None:
        return None
    cleaned = value.strip()
    return cleaned or None


def validate_unit(unit: str) -> str:
    cleaned = unit.strip()
    if not cleaned:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Unit is required.",
            status_code=422,
            details={"field": "unit"},
        )
    return cleaned


def validate_non_negative_quantity(
    quantity: Decimal, *, field: str = "quantity"
) -> Decimal:
    if quantity < 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Quantity must be greater than or equal to zero.",
            status_code=422,
            details={"field": field},
        )
    return quantity


def validate_positive_quantity_change(quantity_change: Decimal) -> Decimal:
    if quantity_change <= 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Quantity change must be greater than zero.",
            status_code=422,
            details={"field": "quantity_change"},
        )
    return quantity_change


def validate_non_negative_money(
    amount: Decimal, *, field: str = "price_per_unit"
) -> Decimal:
    if amount < 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Price must be greater than or equal to zero.",
            status_code=422,
            details={"field": field},
        )
    return amount


def compute_total_price(quantity: Decimal, price_per_unit: Decimal) -> Decimal:
    return (quantity * price_per_unit).quantize(Decimal("0.01"))


def apply_stock_change(
    *,
    current_quantity: Decimal,
    change_type: StockChangeType,
    quantity_change: Decimal,
) -> Decimal:
    if change_type == StockChangeType.ADD:
        return current_quantity + quantity_change
    if quantity_change > current_quantity:
        raise AppError(
            code="INSUFFICIENT_STOCK",
            message="Stock update would reduce quantity below zero.",
            status_code=409,
            details={
                "quantity": str(current_quantity),
                "requested": str(quantity_change),
            },
        )
    return current_quantity - quantity_change


def assert_item_not_archived(is_archived: bool) -> None:
    if is_archived:
        raise AppError(
            code="INVENTORY_ITEM_ARCHIVED",
            message="This inventory item is archived and cannot be modified.",
            status_code=409,
        )
