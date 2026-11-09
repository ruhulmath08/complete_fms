from __future__ import annotations

from decimal import Decimal
from enum import StrEnum

from app.core.errors import AppError


class ExpenseCategory(StrEnum):
    LABOUR = "labour"
    FERTILIZERS = "fertilizers"
    PESTICIDES_AND_CHEMICALS = "pesticides_and_chemicals"
    SEEDS = "seeds"
    IRRIGATION = "irrigation"
    EQUIPMENT = "equipment"
    OTHER = "other"


def parse_expense_category(value: str) -> ExpenseCategory:
    try:
        return ExpenseCategory(value)
    except ValueError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message=(
                "Expense category must be labour, fertilizers, "
                "pesticides_and_chemicals, seeds, irrigation, equipment, or other."
            ),
            status_code=422,
            details={"field": "category"},
        ) from exc


def validate_crop_name(name: str) -> str:
    cleaned = name.strip()
    if not cleaned:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Crop name is required.",
            status_code=422,
            details={"field": "name"},
        )
    return cleaned


def validate_optional_text(value: str | None, *, field: str) -> str | None:
    if value is None:
        return None
    cleaned = value.strip()
    return cleaned or None


def validate_area(area: Decimal | None) -> Decimal | None:
    if area is None:
        return None
    if area < 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Area must be greater than or equal to zero.",
            status_code=422,
            details={"field": "area"},
        )
    return area


def validate_positive_amount(amount: Decimal, *, field: str = "amount") -> Decimal:
    if amount <= 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Amount must be greater than zero.",
            status_code=422,
            details={"field": field},
        )
    return amount


def validate_non_negative_money(
    amount: Decimal | None, *, field: str = "sale_amount"
) -> Decimal | None:
    if amount is None:
        return None
    if amount < 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Sale amount must be greater than or equal to zero.",
            status_code=422,
            details={"field": field},
        )
    return amount


def validate_positive_quantity(quantity: Decimal) -> Decimal:
    if quantity <= 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Quantity must be greater than zero.",
            status_code=422,
            details={"field": "quantity"},
        )
    return quantity


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


def assert_crop_name_not_archived_for_write(is_archived: bool) -> None:
    if is_archived:
        raise AppError(
            code="CROP_NAME_ARCHIVED",
            message="This crop name is archived and cannot be modified.",
            status_code=409,
        )


def assert_crop_name_active_for_cycle(is_archived: bool) -> None:
    if is_archived:
        raise AppError(
            code="CROP_NAME_ARCHIVED",
            message="Archived crop names cannot be selected for a crop cycle.",
            status_code=422,
        )


def assert_cycle_not_archived(is_archived: bool) -> None:
    if is_archived:
        raise AppError(
            code="CROP_CYCLE_ARCHIVED",
            message="This crop cycle is archived and cannot be modified.",
            status_code=409,
        )
