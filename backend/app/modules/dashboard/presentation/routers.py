from __future__ import annotations

from datetime import date

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_owner, get_db_session, get_settings_dep
from app.core.config import Settings
from app.modules.auth.infrastructure.models import OwnerModel
from app.modules.dashboard.application.services import DashboardAggregateService
from app.modules.dashboard.presentation.schemas import DashboardAggregatesResponse

dashboard_router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@dashboard_router.get("/aggregates", response_model=DashboardAggregatesResponse)
def get_dashboard_aggregates(
    from_date: date = Query(..., alias="from"),
    to_date: date = Query(..., alias="to"),
    grain: str = Query(..., min_length=3),
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> DashboardAggregatesResponse:
    data = DashboardAggregateService(db, settings).get_aggregates(
        owner_id=owner.id,
        from_date=from_date,
        to_date=to_date,
        grain=grain,
    )
    return DashboardAggregatesResponse.model_validate(data)
