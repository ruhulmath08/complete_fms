from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_owner, get_db_session
from app.api.v1.schemas_common import Page, PageMeta
from app.modules.auth.infrastructure.models import OwnerModel
from app.modules.inventory.application.services import (
    InventoryItemService,
    StockUpdateService,
)
from app.modules.inventory.presentation.schemas import (
    InventoryItemCreateRequest,
    InventoryItemResponse,
    InventoryItemUpdateRequest,
    StockUpdateCreateRequest,
    StockUpdateResponse,
)

inventory_items_router = APIRouter(prefix="/inventory-items", tags=["inventory"])


@inventory_items_router.post(
    "", response_model=InventoryItemResponse, status_code=201
)
def create_inventory_item(
    body: InventoryItemCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> InventoryItemResponse:
    row = InventoryItemService(db).create(
        owner_id=owner.id,
        name=body.name,
        category=body.category,
        quantity=body.quantity,
        unit=body.unit,
        price_per_unit=body.price_per_unit,
        note=body.note,
    )
    return InventoryItemResponse.model_validate(row)


@inventory_items_router.get("", response_model=Page[InventoryItemResponse])
def list_inventory_items(
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
    include_archived: bool = Query(False),
) -> Page[InventoryItemResponse]:
    items, total = InventoryItemService(db).list(
        owner_id=owner.id,
        limit=limit,
        offset=offset,
        include_archived=include_archived,
    )
    return Page(
        items=[InventoryItemResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )


@inventory_items_router.get("/{item_id}", response_model=InventoryItemResponse)
def get_inventory_item(
    item_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> InventoryItemResponse:
    row = InventoryItemService(db).get(owner_id=owner.id, item_id=item_id)
    return InventoryItemResponse.model_validate(row)


@inventory_items_router.patch("/{item_id}", response_model=InventoryItemResponse)
def update_inventory_item(
    item_id: UUID,
    body: InventoryItemUpdateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> InventoryItemResponse:
    row = InventoryItemService(db).update(
        owner_id=owner.id,
        item_id=item_id,
        name=body.name,
        category=body.category,
        unit=body.unit,
        price_per_unit=body.price_per_unit,
        note=body.note,
        fields_set=set(body.model_fields_set),
    )
    return InventoryItemResponse.model_validate(row)


@inventory_items_router.post(
    "/{item_id}/archive", response_model=InventoryItemResponse
)
def archive_inventory_item(
    item_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> InventoryItemResponse:
    row = InventoryItemService(db).archive(owner_id=owner.id, item_id=item_id)
    return InventoryItemResponse.model_validate(row)


@inventory_items_router.post(
    "/{item_id}/stock-updates",
    response_model=StockUpdateResponse,
    status_code=201,
)
def add_stock_update(
    item_id: UUID,
    body: StockUpdateCreateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
) -> StockUpdateResponse:
    row = StockUpdateService(db).add(
        owner_id=owner.id,
        item_id=item_id,
        occurred_at=body.occurred_at,
        change_type=body.change_type,
        quantity_change=body.quantity_change,
        reason=body.reason,
    )
    return StockUpdateResponse.model_validate(row)


@inventory_items_router.get(
    "/{item_id}/stock-updates", response_model=Page[StockUpdateResponse]
)
def list_stock_updates(
    item_id: UUID,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    limit: int = Query(10, ge=1, le=100),
    offset: int = Query(0, ge=0),
) -> Page[StockUpdateResponse]:
    items, total = StockUpdateService(db).list_by_item(
        owner_id=owner.id,
        item_id=item_id,
        limit=limit,
        offset=offset,
    )
    return Page(
        items=[StockUpdateResponse.model_validate(i) for i in items],
        meta=PageMeta(total=total, limit=limit, offset=offset),
    )
