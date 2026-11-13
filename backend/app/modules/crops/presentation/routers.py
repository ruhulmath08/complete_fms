from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends, Query, Response
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_owner, get_db_session
from app.api.v1.schemas_common import Page, PageMeta
from app.modules.auth.infrastructure.models import OwnerModel
from app.modules.crops.application.services import (
    CropCycleService,
    CropExpenseService,
    CropNameService,
    HarvestService,
)
from app.modules.crops.presentation.schemas import (
    CropCycleCreateRequest,
    CropCycleResponse,
    CropCycleUpdateRequest,
    CropExpenseCreateRequest,
    CropExpenseResponse,
    CropExpenseUpdateRequest,
    CropNameCreateRequest,
    CropNameResponse,
    CropNameUpdateRequest,
    CycleSummaryResponse,
    HarvestCreateRequest,
    HarvestResponse,
    HarvestUpdateRequest,
)

crop_names_router = APIRouter(prefix="/crop-names", tags=["crops"])
crop_cycles_router = APIRouter(prefix="/crop-cycles", tags=["crops"])


@crop_names_router.post("", response_model=CropNameResponse, status_code=201)
def create_crop_name(
    body: CropNameCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CropNameResponse:
    row = CropNameService(db).create(
        owner_id=owner.id, name=body.name, notes=body.notes
    )
    return CropNameResponse.model_validate(row)


@crop_names_router.get("", response_model=Page[CropNameResponse])
def list_crop_names(
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
    include_archived: bool = Query(False),
) -> Page[CropNameResponse]:
    items, total = CropNameService(db).list(
        owner_id=owner.id,
        limit=limit,
        offset=offset,
        include_archived=include_archived,
    )
    return Page(
        items=[CropNameResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )


@crop_names_router.get("/{crop_name_id}", response_model=CropNameResponse)
def get_crop_name(
    crop_name_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CropNameResponse:
    row = CropNameService(db).get(owner_id=owner.id, crop_name_id=crop_name_id)
    return CropNameResponse.model_validate(row)


@crop_names_router.patch("/{crop_name_id}", response_model=CropNameResponse)
def update_crop_name(
    crop_name_id: UUID,
    body: CropNameUpdateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CropNameResponse:
    row = CropNameService(db).update(
        owner_id=owner.id,
        crop_name_id=crop_name_id,
        name=body.name,
        notes=body.notes,
        fields_set=set(body.model_fields_set),
    )
    return CropNameResponse.model_validate(row)


@crop_names_router.post("/{crop_name_id}/archive", response_model=CropNameResponse)
def archive_crop_name(
    crop_name_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CropNameResponse:
    row = CropNameService(db).archive(owner_id=owner.id, crop_name_id=crop_name_id)
    return CropNameResponse.model_validate(row)


@crop_cycles_router.post("", response_model=CropCycleResponse, status_code=201)
def create_crop_cycle(
    body: CropCycleCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CropCycleResponse:
    row = CropCycleService(db).create(
        owner_id=owner.id,
        crop_name_id=body.crop_name_id,
        planted_at=body.planted_at,
        plot_name=body.plot_name,
        area=body.area,
        location=body.location,
        expected_harvest_at=body.expected_harvest_at,
        notes=body.notes,
    )
    return CropCycleResponse.model_validate(row)


@crop_cycles_router.get("", response_model=Page[CropCycleResponse])
def list_crop_cycles(
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
    include_archived: bool = Query(False),
) -> Page[CropCycleResponse]:
    items, total = CropCycleService(db).list(
        owner_id=owner.id,
        limit=limit,
        offset=offset,
        include_archived=include_archived,
    )
    return Page(
        items=[CropCycleResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )


@crop_cycles_router.get("/{cycle_id}", response_model=CropCycleResponse)
def get_crop_cycle(
    cycle_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CropCycleResponse:
    row = CropCycleService(db).get(owner_id=owner.id, cycle_id=cycle_id)
    return CropCycleResponse.model_validate(row)


@crop_cycles_router.patch("/{cycle_id}", response_model=CropCycleResponse)
def update_crop_cycle(
    cycle_id: UUID,
    body: CropCycleUpdateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CropCycleResponse:
    row = CropCycleService(db).update(
        owner_id=owner.id,
        cycle_id=cycle_id,
        crop_name_id=body.crop_name_id,
        planted_at=body.planted_at,
        plot_name=body.plot_name,
        area=body.area,
        location=body.location,
        expected_harvest_at=body.expected_harvest_at,
        notes=body.notes,
        fields_set=set(body.model_fields_set),
    )
    return CropCycleResponse.model_validate(row)


@crop_cycles_router.post("/{cycle_id}/archive", response_model=CropCycleResponse)
def archive_crop_cycle(
    cycle_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CropCycleResponse:
    row = CropCycleService(db).archive(owner_id=owner.id, cycle_id=cycle_id)
    return CropCycleResponse.model_validate(row)


@crop_cycles_router.get("/{cycle_id}/summary", response_model=CycleSummaryResponse)
def get_crop_cycle_summary(
    cycle_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CycleSummaryResponse:
    data = CropCycleService(db).summary(owner_id=owner.id, cycle_id=cycle_id)
    return CycleSummaryResponse.model_validate(data)


@crop_cycles_router.post(
    "/{cycle_id}/expenses",
    response_model=CropExpenseResponse,
    status_code=201,
)
def add_crop_expense(
    cycle_id: UUID,
    body: CropExpenseCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CropExpenseResponse:
    row = CropExpenseService(db).add(
        owner_id=owner.id,
        cycle_id=cycle_id,
        spent_at=body.spent_at,
        category=body.category,
        amount=body.amount,
        note=body.note,
    )
    return CropExpenseResponse.model_validate(row)


@crop_cycles_router.get(
    "/{cycle_id}/expenses",
    response_model=Page[CropExpenseResponse],
)
def list_crop_expenses(
    cycle_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
) -> Page[CropExpenseResponse]:
    items, total = CropExpenseService(db).list(
        owner_id=owner.id, cycle_id=cycle_id, limit=limit, offset=offset
    )
    return Page(
        items=[CropExpenseResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )


@crop_cycles_router.patch(
    "/{cycle_id}/expenses/{expense_id}",
    response_model=CropExpenseResponse,
)
def update_crop_expense(
    cycle_id: UUID,
    expense_id: UUID,
    body: CropExpenseUpdateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> CropExpenseResponse:
    row = CropExpenseService(db).update(
        owner_id=owner.id,
        cycle_id=cycle_id,
        expense_id=expense_id,
        spent_at=body.spent_at,
        category=body.category,
        amount=body.amount,
        note=body.note,
        fields_set=set(body.model_fields_set),
    )
    return CropExpenseResponse.model_validate(row)


@crop_cycles_router.delete(
    "/{cycle_id}/expenses/{expense_id}",
    status_code=204,
)
def delete_crop_expense(
    cycle_id: UUID,
    expense_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> Response:
    CropExpenseService(db).delete(
        owner_id=owner.id, cycle_id=cycle_id, expense_id=expense_id
    )
    return Response(status_code=204)


@crop_cycles_router.post(
    "/{cycle_id}/harvests",
    response_model=HarvestResponse,
    status_code=201,
)
def add_harvest(
    cycle_id: UUID,
    body: HarvestCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> HarvestResponse:
    row = HarvestService(db).add(
        owner_id=owner.id,
        cycle_id=cycle_id,
        harvested_at=body.harvested_at,
        quantity=body.quantity,
        unit=body.unit,
        sale_amount=body.sale_amount,
        note=body.note,
    )
    return HarvestResponse.model_validate(row)


@crop_cycles_router.get(
    "/{cycle_id}/harvests",
    response_model=Page[HarvestResponse],
)
def list_harvests(
    cycle_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
) -> Page[HarvestResponse]:
    items, total = HarvestService(db).list(
        owner_id=owner.id, cycle_id=cycle_id, limit=limit, offset=offset
    )
    return Page(
        items=[HarvestResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )


@crop_cycles_router.patch(
    "/{cycle_id}/harvests/{harvest_id}",
    response_model=HarvestResponse,
)
def update_harvest(
    cycle_id: UUID,
    harvest_id: UUID,
    body: HarvestUpdateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> HarvestResponse:
    row = HarvestService(db).update(
        owner_id=owner.id,
        cycle_id=cycle_id,
        harvest_id=harvest_id,
        harvested_at=body.harvested_at,
        quantity=body.quantity,
        unit=body.unit,
        sale_amount=body.sale_amount,
        note=body.note,
        fields_set=set(body.model_fields_set),
    )
    return HarvestResponse.model_validate(row)


@crop_cycles_router.delete(
    "/{cycle_id}/harvests/{harvest_id}",
    status_code=204,
)
def delete_harvest(
    cycle_id: UUID,
    harvest_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> Response:
    HarvestService(db).delete(
        owner_id=owner.id, cycle_id=cycle_id, harvest_id=harvest_id
    )
    return Response(status_code=204)
