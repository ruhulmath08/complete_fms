from fastapi import APIRouter

from app.api.v1 import health
from app.modules.auth.presentation.routers import (
    auth_router,
    config_router,
    me_router,
    settings_router,
)
from app.modules.cows.presentation.routers import cows_router
from app.modules.crops.presentation.routers import crop_cycles_router, crop_names_router
from app.modules.inventory.presentation.routers import inventory_items_router
from app.modules.poultry.presentation.routers import poultry_groups_router

api_v1_router = APIRouter(prefix="/api/v1")
api_v1_router.include_router(health.router)
api_v1_router.include_router(auth_router)
api_v1_router.include_router(me_router)
api_v1_router.include_router(settings_router)
api_v1_router.include_router(config_router)
api_v1_router.include_router(cows_router)
api_v1_router.include_router(poultry_groups_router)
api_v1_router.include_router(crop_names_router)
api_v1_router.include_router(crop_cycles_router)
api_v1_router.include_router(inventory_items_router)
