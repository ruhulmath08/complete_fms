from __future__ import annotations

from decimal import Decimal
from enum import StrEnum
from typing import Any

from app.core.errors import AppError


class PoultryType(StrEnum):
    BROILER = "broiler"
    DUCK = "duck"
    LAYER = "layer"
    LOCAL = "local"


class AcquisitionSource(StrEnum):
    PURCHASED = "purchased"
    BORN_ON_FARM = "born_on_farm"


EGG_ELIGIBLE_TYPES = {PoultryType.DUCK, PoultryType.LAYER, PoultryType.LOCAL}


def parse_poultry_type(value: str) -> PoultryType:
    try:
        return PoultryType(value)
    except ValueError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Poultry type must be broiler, duck, layer, or local.",
            status_code=422,
            details={"field": "poultry_type"},
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


def validate_group_name(name: str) -> str:
    cleaned = name.strip()
    if not cleaned:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Group name is required.",
            status_code=422,
            details={"field": "name"},
        )
    return cleaned


def validate_bird_count(bird_count: int) -> int:
    if bird_count < 0:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Bird count must be greater than or equal to zero.",
            status_code=422,
            details={"field": "bird_count"},
        )
    return bird_count


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
            code="POULTRY_GROUP_ARCHIVED",
            message="This poultry group is archived and cannot be modified.",
            status_code=409,
        )


def assert_eggs_allowed(poultry_type: str) -> None:
    if poultry_type not in {t.value for t in EGG_ELIGIBLE_TYPES}:
        raise AppError(
            code="EGGS_NOT_ALLOWED_FOR_TYPE",
            message="Egg production is only allowed for duck, layer, or local groups.",
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
