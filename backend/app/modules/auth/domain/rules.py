from __future__ import annotations

import re

from app.core.errors import AppError

_EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")
_HAS_LETTER = re.compile(r"[A-Za-z]")
_HAS_DIGIT = re.compile(r"\d")


def normalize_email(email: str) -> str:
    return email.strip().lower()


def validate_email(email: str) -> str:
    normalized = normalize_email(email)
    if not _EMAIL_RE.match(normalized):
        raise AppError(
            code="VALIDATION_ERROR",
            message="Email format is invalid.",
            status_code=422,
            details={"field": "email"},
        )
    return normalized


def validate_password(password: str, confirm_password: str | None = None) -> None:
    if len(password) < 8 or not _HAS_LETTER.search(password) or not _HAS_DIGIT.search(
        password
    ):
        raise AppError(
            code="PASSWORD_INVALID",
            message="Password must be at least 8 characters and include a letter and a number.",
            status_code=422,
        )
    if confirm_password is not None and password != confirm_password:
        raise AppError(
            code="PASSWORD_MISMATCH",
            message="Password and confirm password do not match.",
            status_code=422,
        )


def validate_currency_code(currency_code: str) -> str:
    code = currency_code.strip()
    if not code:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Currency code is required.",
            status_code=422,
            details={"field": "currency_code"},
        )
    return code


def validate_timezone(timezone_name: str) -> str:
    from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

    name = timezone_name.strip()
    if not name:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Timezone is required.",
            status_code=422,
            details={"field": "timezone"},
        )
    try:
        ZoneInfo(name)
    except ZoneInfoNotFoundError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Invalid timezone.",
            status_code=422,
            details={"field": "timezone"},
        ) from exc
    return name
