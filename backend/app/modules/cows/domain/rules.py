from __future__ import annotations

import secrets
from decimal import Decimal
from enum import StrEnum
from typing import Any

from app.core.errors import AppError

TAG_DIGIT_LEN = 6
TAG_MAX_LEN = 64
TAG_GENERATION_MAX_ATTEMPTS = 10


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


def validate_required_name_breed(*, name: str | None, breed: str | None) -> tuple[str, str]:
    cleaned_name = (name or "").strip()
    cleaned_breed = (breed or "").strip()
    if not cleaned_name:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Name is required.",
            status_code=422,
            details={"field": "name"},
        )
    if not cleaned_breed:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Breed is required.",
            status_code=422,
            details={"field": "breed"},
        )
    if len(cleaned_name) + len(cleaned_breed) + TAG_DIGIT_LEN > TAG_MAX_LEN:
        raise AppError(
            code="VALIDATION_ERROR",
            message=(
                "Name and breed are too long to generate a tag number "
                f"(max combined length before digits is {TAG_MAX_LEN - TAG_DIGIT_LEN})."
            ),
            status_code=422,
            details={"fields": ["name", "breed"]},
        )
    return cleaned_name, cleaned_breed


def build_generated_tag(name: str, breed: str) -> str:
    suffix = f"{secrets.randbelow(10**TAG_DIGIT_LEN):0{TAG_DIGIT_LEN}d}"
    return f"{name}{breed}{suffix}"


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


def validate_non_negative_price(
    price: Decimal, *, field: str = "price_per_unit"
) -> Decimal:
    if price < 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Price must be greater than or equal to zero.",
            status_code=422,
            details={"field": field},
        )
    return price


def compute_row_total(quantity: Decimal, unit_price: Decimal) -> Decimal:
    return (quantity * unit_price).quantize(Decimal("0.01"))


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
