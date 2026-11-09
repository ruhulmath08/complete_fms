from __future__ import annotations

from decimal import Decimal
from enum import StrEnum
from typing import Any

from app.core.errors import AppError


class CowPurpose(StrEnum):
    MILK = "milk"
    MEAT = "meat"
    BOTH = "both"


class Gender(StrEnum):
    FEMALE = "female"
    MALE = "male"
    UNKNOWN = "unknown"


class AcquisitionSource(StrEnum):
    PURCHASED = "purchased"
    BORN_ON_FARM = "born_on_farm"


def parse_purpose(value: str) -> CowPurpose:
    try:
        return CowPurpose(value)
    except ValueError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Purpose must be milk, meat, or both.",
            status_code=422,
            details={"field": "purpose"},
        ) from exc


def parse_gender(value: str) -> Gender:
    try:
        return Gender(value)
    except ValueError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Gender must be female, male, or unknown.",
            status_code=422,
            details={"field": "gender"},
        ) from exc


def parse_acquired_by(value: str) -> AcquisitionSource:
    try:
        return AcquisitionSource(value)
    except ValueError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Acquired by must be purchased or born_on_farm.",
            status_code=422,
            details={"field": "acquired_by"},
        ) from exc


def validate_tag_number(tag_number: str) -> str:
    cleaned = tag_number.strip()
    if not cleaned:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Tag number is required.",
            status_code=422,
            details={"field": "tag_number"},
        )
    return cleaned


def validate_purchase_fields(
    *,
    acquired_by: AcquisitionSource,
    purchase_date: Any,
    purchase_price: Decimal | None,
) -> tuple[Any, Decimal | None]:
    if acquired_by == AcquisitionSource.PURCHASED:
        if purchase_date is None or purchase_price is None:
            raise AppError(
                code="PURCHASE_FIELDS_INVALID",
                message="Purchase date and price are required when acquired by purchase.",
                status_code=422,
            )
        if purchase_price < 0:
            raise AppError(
                code="PURCHASE_FIELDS_INVALID",
                message="Purchase price must be greater than or equal to zero.",
                status_code=422,
                details={"field": "purchase_price"},
            )
        return purchase_date, purchase_price

    if purchase_date is not None or purchase_price is not None:
        raise AppError(
            code="PURCHASE_FIELDS_INVALID",
            message="Purchase date and price must be omitted when not purchased.",
            status_code=422,
        )
    return None, None


def assert_not_archived(is_archived: bool) -> None:
    if is_archived:
        raise AppError(
            code="COW_ARCHIVED",
            message="This cow is archived and cannot be modified.",
            status_code=409,
        )


def assert_milk_allowed(purpose: str) -> None:
    if purpose not in (CowPurpose.MILK, CowPurpose.BOTH):
        raise AppError(
            code="MILK_NOT_ALLOWED_FOR_PURPOSE",
            message="Milk production is only allowed for cows with purpose milk or both.",
            status_code=422,
        )


def validate_positive_quantity(quantity: Decimal) -> Decimal:
    if quantity <= 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Quantity must be greater than zero.",
            status_code=422,
            details={"field": "quantity"},
        )
    return quantity


def validate_non_negative_price(price: Decimal) -> Decimal:
    if price < 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Price must be greater than or equal to zero.",
            status_code=422,
            details={"field": "price_per_unit"},
        )
    return price


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


def validate_feed_name(feed_name: str) -> str:
    cleaned = feed_name.strip()
    if not cleaned:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Feed name is required.",
            status_code=422,
            details={"field": "feed_name"},
        )
    return cleaned
