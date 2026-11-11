from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends, File, Query, UploadFile
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_owner, get_db_session, get_settings_dep
from app.api.v1.schemas_common import Page, PageMeta
from app.core.config import Settings
from app.modules.auth.infrastructure.models import OwnerModel
from app.modules.cows.application.services import (
    CowFeedingService,
    CowService,
    MilkProductionService,
)
from app.modules.cows.infrastructure.models import CowModel
from app.modules.cows.presentation.schemas import (
    CowCreateRequest,
    CowFeedingResponse,
    CowResponse,
    CowUpdateRequest,
    FeedingCreateRequest,
    MilkCreateRequest,
    MilkProductionResponse,
)

cows_router = APIRouter(prefix="/cows", tags=["cows"])


def _to_cow_response(cow: CowModel) -> CowResponse:
    response = CowResponse.model_validate(cow)
    return response.model_copy(
        update={
            "image_url": (
                f"/api/v1/cows/{cow.id}/image" if cow.image_path else None
            )
        }
    )


def _cow_service(db: Session, settings: Settings) -> CowService:
    return CowService(db, settings)


@cows_router.post("", response_model=CowResponse, status_code=201)
def create_cow(
    body: CowCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> CowResponse:
    cow = _cow_service(db, settings).create(
        owner_id=owner.id,
        purpose=body.purpose,
        gender=body.gender,
        acquired_by=body.acquired_by,
        name=body.name,
        breed=body.breed,
        date_of_birth=body.date_of_birth,
        color=body.color,
        weight=body.weight,
        age=body.age,
        purchase_date=body.purchase_date,
        purchase_price=body.purchase_price,
        notes=body.notes,
    )
    return _to_cow_response(cow)


@cows_router.get("", response_model=Page[CowResponse])
def list_cows(
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    include_archived: bool = Query(False),
) -> Page[CowResponse]:
    items, total = _cow_service(db, settings).list(
        owner_id=owner.id,
        limit=limit,
        offset=offset,
        include_archived=include_archived,
    )
    return Page(
        items=[_to_cow_response(c) for c in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )


@cows_router.get("/{cow_id}", response_model=CowResponse)
def get_cow(
    cow_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> CowResponse:
    cow = _cow_service(db, settings).get(owner_id=owner.id, cow_id=cow_id)
    return _to_cow_response(cow)


@cows_router.patch("/{cow_id}", response_model=CowResponse)
def update_cow(
    cow_id: UUID,
    body: CowUpdateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> CowResponse:
    fields_set = set(body.model_fields_set)
    cow = _cow_service(db, settings).update(
        owner_id=owner.id,
        cow_id=cow_id,
        purpose=body.purpose,
        gender=body.gender,
        acquired_by=body.acquired_by,
        name=body.name,
        breed=body.breed,
        date_of_birth=body.date_of_birth,
        color=body.color,
        weight=body.weight,
        age=body.age,
        purchase_date=body.purchase_date,
        purchase_price=body.purchase_price,
        notes=body.notes,
        fields_set=fields_set,
    )
    return _to_cow_response(cow)


@cows_router.post("/{cow_id}/archive", response_model=CowResponse)
def archive_cow(
    cow_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> CowResponse:
    cow = _cow_service(db, settings).archive(owner_id=owner.id, cow_id=cow_id)
    return _to_cow_response(cow)


@cows_router.put("/{cow_id}/image", response_model=CowResponse)
def put_cow_image(
    cow_id: UUID,
    image: UploadFile = File(...),
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> CowResponse:
    cow = _cow_service(db, settings).attach_image(
        owner_id=owner.id, cow_id=cow_id, image=image
    )
    return _to_cow_response(cow)


@cows_router.delete("/{cow_id}/image", response_model=CowResponse)
def delete_cow_image(
    cow_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> CowResponse:
    cow = _cow_service(db, settings).clear_image(owner_id=owner.id, cow_id=cow_id)
    return _to_cow_response(cow)


@cows_router.get("/{cow_id}/image")
def get_cow_image(
    cow_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> FileResponse:
    path = _cow_service(db, settings).resolve_image_path(
        owner_id=owner.id, cow_id=cow_id
    )
    return FileResponse(path)


@cows_router.post(
    "/{cow_id}/milk-productions",
    response_model=MilkProductionResponse,
    status_code=201,
)
def add_milk_production(
    cow_id: UUID,
    body: MilkCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> MilkProductionResponse:
    row = MilkProductionService(db, settings).add(
        owner_id=owner.id,
        cow_id=cow_id,
        produced_at=body.produced_at,
        quantity=body.quantity,
        unit=body.unit,
        price_per_unit=body.price_per_unit,
        note=body.note,
    )
    return MilkProductionResponse.model_validate(row)


@cows_router.get(
    "/{cow_id}/milk-productions",
    response_model=Page[MilkProductionResponse],
)
def list_milk_productions(
    cow_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
) -> Page[MilkProductionResponse]:
    items, total = MilkProductionService(db, settings).list(
        owner_id=owner.id, cow_id=cow_id, limit=limit, offset=offset
    )
    return Page(
        items=[MilkProductionResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )


@cows_router.post(
    "/{cow_id}/feedings",
    response_model=CowFeedingResponse,
    status_code=201,
)
def add_feeding(
    cow_id: UUID,
    body: FeedingCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> CowFeedingResponse:
    row = CowFeedingService(db, settings).add(
        owner_id=owner.id,
        cow_id=cow_id,
        fed_at=body.fed_at,
        feed_name=body.feed_name,
        quantity=body.quantity,
        unit=body.unit,
        note=body.note,
    )
    return CowFeedingResponse.model_validate(row)


@cows_router.get(
    "/{cow_id}/feedings",
    response_model=Page[CowFeedingResponse],
)
def list_feedings(
    cow_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
) -> Page[CowFeedingResponse]:
    items, total = CowFeedingService(db, settings).list(
        owner_id=owner.id, cow_id=cow_id, limit=limit, offset=offset
    )
    return Page(
        items=[CowFeedingResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )
