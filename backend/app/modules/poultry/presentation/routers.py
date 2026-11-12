from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_owner, get_db_session
from app.api.v1.schemas_common import Page, PageMeta
from app.modules.auth.infrastructure.models import OwnerModel
from app.modules.poultry.application.services import (
    EggProductionService,
    PoultryFeedingService,
    PoultryGroupService,
)
from app.modules.poultry.presentation.schemas import (
    EggProductionCreateRequest,
    EggProductionResponse,
    PoultryFeedingCreateRequest,
    PoultryFeedingResponse,
    PoultryGroupCreateRequest,
    PoultryGroupResponse,
    PoultryGroupUpdateRequest,
)

poultry_groups_router = APIRouter(prefix="/poultry-groups", tags=["poultry"])


@poultry_groups_router.post("", response_model=PoultryGroupResponse, status_code=201)
def create_poultry_group(
    body: PoultryGroupCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> PoultryGroupResponse:
    group = PoultryGroupService(db).create(
        owner_id=owner.id,
        poultry_type=body.poultry_type,
        name=body.name,
        bird_count=body.bird_count,
        acquired_by=body.acquired_by,
        date_acquired=body.date_acquired,
        purchase_date=body.purchase_date,
        purchase_price=body.purchase_price,
        notes=body.notes,
    )
    return PoultryGroupResponse.model_validate(group)


@poultry_groups_router.get("", response_model=Page[PoultryGroupResponse])
def list_poultry_groups(
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
    include_archived: bool = Query(False),
) -> Page[PoultryGroupResponse]:
    items, total = PoultryGroupService(db).list(
        owner_id=owner.id,
        limit=limit,
        offset=offset,
        include_archived=include_archived,
    )
    return Page(
        items=[PoultryGroupResponse.model_validate(g) for g in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )


@poultry_groups_router.get("/{group_id}", response_model=PoultryGroupResponse)
def get_poultry_group(
    group_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> PoultryGroupResponse:
    group = PoultryGroupService(db).get(owner_id=owner.id, group_id=group_id)
    return PoultryGroupResponse.model_validate(group)


@poultry_groups_router.patch("/{group_id}", response_model=PoultryGroupResponse)
def update_poultry_group(
    group_id: UUID,
    body: PoultryGroupUpdateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> PoultryGroupResponse:
    fields_set = set(body.model_fields_set)
    group = PoultryGroupService(db).update(
        owner_id=owner.id,
        group_id=group_id,
        poultry_type=body.poultry_type,
        name=body.name,
        bird_count=body.bird_count,
        acquired_by=body.acquired_by,
        date_acquired=body.date_acquired,
        purchase_date=body.purchase_date,
        purchase_price=body.purchase_price,
        notes=body.notes,
        fields_set=fields_set,
    )
    return PoultryGroupResponse.model_validate(group)


@poultry_groups_router.post("/{group_id}/archive", response_model=PoultryGroupResponse)
def archive_poultry_group(
    group_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> PoultryGroupResponse:
    group = PoultryGroupService(db).archive(owner_id=owner.id, group_id=group_id)
    return PoultryGroupResponse.model_validate(group)


@poultry_groups_router.post(
    "/{group_id}/feedings",
    response_model=PoultryFeedingResponse,
    status_code=201,
)
def add_poultry_feeding(
    group_id: UUID,
    body: PoultryFeedingCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> PoultryFeedingResponse:
    row = PoultryFeedingService(db).add(
        owner_id=owner.id,
        group_id=group_id,
        fed_at=body.fed_at,
        feed_name=body.feed_name,
        quantity=body.quantity,
        unit=body.unit,
        note=body.note,
    )
    return PoultryFeedingResponse.model_validate(row)


@poultry_groups_router.get(
    "/{group_id}/feedings",
    response_model=Page[PoultryFeedingResponse],
)
def list_poultry_feedings(
    group_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
) -> Page[PoultryFeedingResponse]:
    items, total = PoultryFeedingService(db).list(
        owner_id=owner.id, group_id=group_id, limit=limit, offset=offset
    )
    return Page(
        items=[PoultryFeedingResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )


@poultry_groups_router.post(
    "/{group_id}/egg-productions",
    response_model=EggProductionResponse,
    status_code=201,
)
def add_egg_production(
    group_id: UUID,
    body: EggProductionCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> EggProductionResponse:
    row = EggProductionService(db).add(
        owner_id=owner.id,
        group_id=group_id,
        produced_at=body.produced_at,
        quantity=body.quantity,
        unit=body.unit,
        price_per_unit=body.price_per_unit,
        note=body.note,
    )
    return EggProductionResponse.model_validate(row)


@poultry_groups_router.get(
    "/{group_id}/egg-productions",
    response_model=Page[EggProductionResponse],
)
def list_egg_productions(
    group_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
) -> Page[EggProductionResponse]:
    items, total = EggProductionService(db).list(
        owner_id=owner.id, group_id=group_id, limit=limit, offset=offset
    )
    return Page(
        items=[EggProductionResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )
