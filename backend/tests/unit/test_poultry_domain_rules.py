from datetime import date
from decimal import Decimal

import pytest

from app.core.errors import AppError
from app.modules.poultry.domain.rules import (
    AcquisitionSource,
    assert_eggs_allowed,
    assert_not_archived,
    parse_acquired_by,
    parse_poultry_type,
    validate_bird_count,
    validate_feed_name,
    validate_group_name,
    validate_non_negative_price,
    validate_positive_quantity,
    validate_purchase_fields,
    validate_unit,
)


def test_parse_enums() -> None:
    assert parse_poultry_type("broiler").value == "broiler"
    assert parse_poultry_type("duck").value == "duck"
    assert parse_poultry_type("layer").value == "layer"
    assert parse_poultry_type("local").value == "local"
    assert parse_acquired_by("born_on_farm").value == "born_on_farm"


@pytest.mark.parametrize(
    "fn,value",
    [
        (parse_poultry_type, "turkey"),
        (parse_acquired_by, "gift"),
    ],
)
def test_invalid_enums(fn, value) -> None:
    with pytest.raises(AppError) as exc:
        fn(value)
    assert exc.value.code == "VALIDATION_ERROR"


def test_purchase_fields_required_when_purchased() -> None:
    with pytest.raises(AppError) as exc:
        validate_purchase_fields(
            acquired_by=AcquisitionSource.PURCHASED,
            purchase_date=None,
            purchase_price=None,
        )
    assert exc.value.code == "PURCHASE_FIELDS_INVALID"

    d, p = validate_purchase_fields(
        acquired_by=AcquisitionSource.PURCHASED,
        purchase_date=date(2024, 1, 1),
        purchase_price=Decimal("100.00"),
    )
    assert d == date(2024, 1, 1)
    assert p == Decimal("100.00")


def test_purchase_fields_forbidden_when_born() -> None:
    with pytest.raises(AppError) as exc:
        validate_purchase_fields(
            acquired_by=AcquisitionSource.BORN_ON_FARM,
            purchase_date=date(2024, 1, 1),
            purchase_price=Decimal("10"),
        )
    assert exc.value.code == "PURCHASE_FIELDS_INVALID"

    d, p = validate_purchase_fields(
        acquired_by=AcquisitionSource.BORN_ON_FARM,
        purchase_date=None,
        purchase_price=None,
    )
    assert d is None and p is None


def test_eggs_and_archive_guards() -> None:
    assert_eggs_allowed("duck")
    assert_eggs_allowed("layer")
    assert_eggs_allowed("local")
    with pytest.raises(AppError) as exc:
        assert_eggs_allowed("broiler")
    assert exc.value.code == "EGGS_NOT_ALLOWED_FOR_TYPE"

    assert_not_archived(False)
    with pytest.raises(AppError) as exc:
        assert_not_archived(True)
    assert exc.value.code == "POULTRY_GROUP_ARCHIVED"


def test_name_count_quantity_price_unit() -> None:
    assert validate_group_name(" House A ") == "House A"
    with pytest.raises(AppError):
        validate_group_name("  ")

    assert validate_bird_count(0) == 0
    assert validate_bird_count(12) == 12
    with pytest.raises(AppError):
        validate_bird_count(-1)

    assert validate_positive_quantity(Decimal("1.5")) == Decimal("1.5")
    with pytest.raises(AppError):
        validate_positive_quantity(Decimal("0"))

    assert validate_non_negative_price(Decimal("0")) == Decimal("0")
    with pytest.raises(AppError):
        validate_non_negative_price(Decimal("-1"))

    assert validate_unit(" pcs ") == "pcs"
    assert validate_feed_name(" Mash ") == "Mash"
