from __future__ import annotations

from datetime import date, datetime, timedelta
from zoneinfo import ZoneInfo, ZoneInfoNotFoundError

from app.core.errors import AppError

DEFAULT_FARM_TIMEZONE = "Asia/Dhaka"


def resolve_timezone(timezone_name: str | None) -> ZoneInfo:
    name = (timezone_name or "").strip() or DEFAULT_FARM_TIMEZONE
    try:
        return ZoneInfo(name)
    except ZoneInfoNotFoundError as exc:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Invalid timezone.",
            status_code=422,
            details={"field": "timezone"},
        ) from exc


def today_local(timezone_name: str | None = None) -> date:
    return datetime.now(resolve_timezone(timezone_name)).date()


def assert_not_future(
    to_date: date, *, timezone_name: str | None = None
) -> None:
    today = today_local(timezone_name)
    if to_date > today:
        raise AppError(
            code="FUTURE_DATE_NOT_ALLOWED",
            message="End date cannot be after today in the farm timezone.",
            status_code=422,
            details={"to": str(to_date), "today": str(today)},
        )


def parse_grain(grain: str) -> str:
    value = grain.strip().lower()
    if value not in {"day", "week", "month", "year"}:
        raise AppError(
            code="VALIDATION_ERROR",
            message="Grain must be day, week, month, or year.",
            status_code=422,
            details={"field": "grain"},
        )
    return value


def bucket_starts(from_date: date, to_date: date, grain: str) -> list[date]:
    grain = parse_grain(grain)
    if from_date > to_date:
        return []
    starts: list[date] = []
    current = _align_bucket_start(from_date, grain)
    while current <= to_date:
        starts.append(current)
        current = _next_bucket_start(current, grain)
    return starts


def bucket_for(day: date, grain: str) -> date:
    return _align_bucket_start(day, parse_grain(grain))


def _align_bucket_start(day: date, grain: str) -> date:
    if grain == "day":
        return day
    if grain == "week":
        return day - timedelta(days=day.weekday())  # Monday
    if grain == "month":
        return day.replace(day=1)
    return day.replace(month=1, day=1)


def _next_bucket_start(start: date, grain: str) -> date:
    if grain == "day":
        return start + timedelta(days=1)
    if grain == "week":
        return start + timedelta(days=7)
    if grain == "month":
        if start.month == 12:
            return date(start.year + 1, 1, 1)
        return date(start.year, start.month + 1, 1)
    return date(start.year + 1, 1, 1)
