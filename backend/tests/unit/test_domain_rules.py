import pytest

from app.core.errors import AppError
from app.modules.auth.domain.rules import (
    normalize_email,
    validate_currency_code,
    validate_email,
    validate_password,
)


def test_normalize_and_validate_email() -> None:
    assert normalize_email(" Owner@Example.COM ") == "owner@example.com"
    assert validate_email("Owner@Example.COM") == "owner@example.com"


def test_invalid_email_raises() -> None:
    with pytest.raises(AppError) as exc:
        validate_email("not-an-email")
    assert exc.value.code == "VALIDATION_ERROR"


def test_password_rules() -> None:
    with pytest.raises(AppError) as exc:
        validate_password("short1")
    assert exc.value.code == "PASSWORD_INVALID"

    with pytest.raises(AppError) as exc:
        validate_password("Password1", "Password2")
    assert exc.value.code == "PASSWORD_MISMATCH"

    validate_password("Password1", "Password1")


def test_currency_code_required() -> None:
    with pytest.raises(AppError):
        validate_currency_code("  ")
    assert validate_currency_code(" USD ") == "USD"
