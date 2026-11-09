from typing import Generic, TypeVar

from pydantic import BaseModel, Field

T = TypeVar("T")


class PageMeta(BaseModel):
    total: int
    limit: int
    offset: int


class Page(BaseModel, Generic[T]):
    items: list[T]
    meta: PageMeta


class HealthResponse(BaseModel):
    status: str = "ok"


class SuggestedUnitsResponse(BaseModel):
    items: list[str] = Field(
        default_factory=lambda: ["kg", "g", "L", "ml", "pcs", "bag", "dozen"]
    )


SUGGESTED_UNITS = ["kg", "g", "L", "ml", "pcs", "bag", "dozen"]
