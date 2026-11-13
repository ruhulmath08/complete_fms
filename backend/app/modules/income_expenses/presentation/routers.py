from __future__ import annotations

from datetime import date
from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_owner, get_db_session, get_settings_dep
from app.api.v1.schemas_common import Page, PageMeta
from app.core.config import Settings
from app.core.farm_clock import assert_not_future
from app.modules.auth.application.services import AuthService
from app.modules.auth.infrastructure.models import OwnerModel
from app.modules.income_expenses.application.services import (
    LedgerEntryService,
    PeriodTotalsService,
)
from app.modules.income_expenses.presentation.schemas import (
    LedgerEntryCreateRequest,
    LedgerEntryResponse,
    LedgerEntryUpdateRequest,
    LedgerSeriesResponse,
    PeriodTotalsResponse,
)

ledger_entries_router = APIRouter(prefix="/ledger-entries", tags=["income-expenses"])


@ledger_entries_router.post(
    "", response_model=LedgerEntryResponse, status_code=201
)
def create_ledger_entry(
    body: LedgerEntryCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> LedgerEntryResponse:
    row = LedgerEntryService(db).create(
        owner_id=owner.id,
        entry_type=body.entry_type,
        occurred_at=body.occurred_at,
        category=body.category,
        amount=body.amount,
        unit=body.unit,
        note=body.note,
    )
    return LedgerEntryResponse.model_validate(row)


@ledger_entries_router.get("", response_model=Page[LedgerEntryResponse])
def list_ledger_entries(
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
    include_archived: bool = Query(False),
    from_date: date | None = Query(None, alias="from"),
    to_date: date | None = Query(None, alias="to"),
) -> Page[LedgerEntryResponse]:
    items, total = LedgerEntryService(db).list(
        owner_id=owner.id,
        limit=limit,
        offset=offset,
        include_archived=include_archived,
        from_date=from_date,
        to_date=to_date,
    )
    return Page(
        items=[LedgerEntryResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )


@ledger_entries_router.get("/totals", response_model=PeriodTotalsResponse)
def get_period_totals(
    from_date: date = Query(..., alias="from"),
    to_date: date = Query(..., alias="to"),
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> PeriodTotalsResponse:
    farm = AuthService(db, settings).get_farm_settings(owner.id)
    assert_not_future(to_date, timezone_name=farm.timezone)
    totals = PeriodTotalsService(db).get_totals(
        owner_id=owner.id,
        from_date=from_date,
        to_date=to_date,
    )
    return PeriodTotalsResponse.model_validate(totals)


@ledger_entries_router.get("/series", response_model=LedgerSeriesResponse)
def get_ledger_series(
    from_date: date = Query(..., alias="from"),
    to_date: date = Query(..., alias="to"),
    grain: str = Query("day"),
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> LedgerSeriesResponse:
    farm = AuthService(db, settings).get_farm_settings(owner.id)
    data = PeriodTotalsService(db).get_series(
        owner_id=owner.id,
        from_date=from_date,
        to_date=to_date,
        grain=grain,
        timezone_name=farm.timezone,
    )
    return LedgerSeriesResponse.model_validate(data)


@ledger_entries_router.get("/{entry_id}", response_model=LedgerEntryResponse)
def get_ledger_entry(
    entry_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> LedgerEntryResponse:
    row = LedgerEntryService(db).get(owner_id=owner.id, entry_id=entry_id)
    return LedgerEntryResponse.model_validate(row)


@ledger_entries_router.patch("/{entry_id}", response_model=LedgerEntryResponse)
def update_ledger_entry(
    entry_id: UUID,
    body: LedgerEntryUpdateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> LedgerEntryResponse:
    row = LedgerEntryService(db).update(
        owner_id=owner.id,
        entry_id=entry_id,
        entry_type=body.entry_type,
        occurred_at=body.occurred_at,
        category=body.category,
        amount=body.amount,
        unit=body.unit,
        note=body.note,
        fields_set=set(body.model_fields_set),
    )
    return LedgerEntryResponse.model_validate(row)


@ledger_entries_router.post(
    "/{entry_id}/archive", response_model=LedgerEntryResponse
)
def archive_ledger_entry(
    entry_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> LedgerEntryResponse:
    row = LedgerEntryService(db).archive(owner_id=owner.id, entry_id=entry_id)
    return LedgerEntryResponse.model_validate(row)
