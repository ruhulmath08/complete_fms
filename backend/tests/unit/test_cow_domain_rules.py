from datetime import date
from decimal import Decimal

import pytest

from app.core.errors import AppError
from app.modules.cows.domain.rules import (
    AcquisitionSource,
    assert_milk_allowed,
    assert_not_archived,
    build_generated_tag,
    parse_acquired_by,
    parse_gender,
    parse_purpose,
    validate_feed_name,
    validate_non_negative_price,
    validate_positive_quantity,
    validate_purchase_fields,
    validate_required_name_breed,
    validate_tag_number,
    validate_unit,
)


def test_parse_enums() -> None:
    assert parse_purpose("milk").value == "milk"
    assert parse_gender("female").value == "female"
    assert parse_acquired_by("born_on_farm").value == "born_on_farm"


@pytest.mark.parametrize(
    "fn,value",
    [
        (parse_purpose, "dairy"),
        (parse_gender, "other"),
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


def test_milk_and_archive_guards() -> None:
    assert_milk_allowed("milk")
    assert_milk_allowed("both")
    with pytest.raises(AppError) as exc:
        assert_milk_allowed("meat")
    assert exc.value.code == "MILK_NOT_ALLOWED_FOR_PURPOSE"

    assert_not_archived(False)
    with pytest.raises(AppError) as exc:
        assert_not_archived(True)
    assert exc.value.code == "COW_ARCHIVED"


def test_quantity_price_unit_tag() -> None:
    assert validate_tag_number(" A-1 ") == "A-1"
    with pytest.raises(AppError):
        validate_tag_number("  ")

    assert validate_positive_quantity(Decimal("1.5")) == Decimal("1.5")
    with pytest.raises(AppError):
        validate_positive_quantity(Decimal("0"))

    assert validate_non_negative_price(Decimal("0")) == Decimal("0")
    with pytest.raises(AppError):
        validate_non_negative_price(Decimal("-1"))

    assert validate_unit(" L ") == "L"
    assert validate_feed_name(" Grass ") == "Grass"


def test_generated_tag_and_required_name_breed() -> None:
    name, breed = validate_required_name_breed(name=" Bella ", breed=" Holstein ")
    assert name == "Bella"
    assert breed == "Holstein"

    with pytest.raises(AppError) as missing_name:
        validate_required_name_breed(name="  ", breed="Holstein")
    assert missing_name.value.code == "VALIDATION_ERROR"

    with pytest.raises(AppError) as missing_breed:
        validate_required_name_breed(name="Bella", breed=None)
    assert missing_breed.value.code == "VALIDATION_ERROR"

    with pytest.raises(AppError) as too_long:
        validate_required_name_breed(name="A" * 40, breed="B" * 40)
    assert too_long.value.code == "VALIDATION_ERROR"

    tag = build_generated_tag("Bella", "Holstein")
    assert tag.startswith("BellaHolstein")
    assert tag[-6:].isdigit()
    assert len(tag) == len("BellaHolstein") + 6
