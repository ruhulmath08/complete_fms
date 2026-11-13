from __future__ import annotations

from fastapi import APIRouter, Depends, File, Form, Response, UploadFile
from fastapi.responses import FileResponse
from sqlalchemy.orm import Session

from app.api.v1.deps import get_current_owner, get_db_session, get_settings_dep
from app.api.v1.schemas_common import SUGGESTED_UNITS, SuggestedUnitsResponse
from app.core.config import Settings
from app.modules.auth.application.services import AuthService
from app.modules.auth.infrastructure.image_store import ProfileImageStore
from app.modules.auth.infrastructure.models import OwnerModel
from app.modules.auth.presentation.schemas import (
    FarmSettingsResponse,
    FarmSettingsUpdateRequest,
    OwnerProfileResponse,
    RefreshRequest,
    SignInRequest,
    SignOutRequest,
    TokenResponse,
)

auth_router = APIRouter(prefix="/auth", tags=["auth"])
me_router = APIRouter(tags=["profile"])
settings_router = APIRouter(tags=["farm-settings"])
config_router = APIRouter(prefix="/config", tags=["config"])


def _profile_response(owner: OwnerModel) -> OwnerProfileResponse:
    return OwnerProfileResponse(
        id=owner.id,
        full_name=owner.full_name,
        email=owner.email,
        phone=owner.phone,
        address=owner.address,
        latitude=owner.latitude,
        longitude=owner.longitude,
        profile_image_url="/api/v1/me/profile-image",
        created_at=owner.created_at,
        updated_at=owner.updated_at,
    )


def _service(db: Session, settings: Settings) -> AuthService:
    return AuthService(db, settings)


@auth_router.post("/signup", response_model=OwnerProfileResponse, status_code=201)
def signup(
    full_name: str = Form(...),
    email: str = Form(...),
    phone: str = Form(...),
    address: str = Form(...),
    latitude: float = Form(...),
    longitude: float = Form(...),
    password: str = Form(...),
    confirm_password: str = Form(...),
    profile_image: UploadFile = File(...),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> OwnerProfileResponse:
    service = _service(db, settings)
    owner = service.register_owner(
        full_name=full_name,
        email=email,
        phone=phone,
        address=address,
        latitude=latitude,
        longitude=longitude,
        password=password,
        confirm_password=confirm_password,
        profile_image=profile_image,
    )
    return _profile_response(owner)


@auth_router.post("/signin", response_model=TokenResponse)
def signin(
    body: SignInRequest,
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> TokenResponse:
    tokens = _service(db, settings).sign_in(email=body.email, password=body.password)
    return TokenResponse(**tokens)


@auth_router.post("/refresh", response_model=TokenResponse)
def refresh(
    body: RefreshRequest,
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> TokenResponse:
    tokens = _service(db, settings).refresh(refresh_token=body.refresh_token)
    return TokenResponse(**tokens)


@auth_router.post("/signout", status_code=204)
def signout(
    body: SignOutRequest = SignOutRequest(),
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> Response:
    _service(db, settings).sign_out(
        owner_id=owner.id, refresh_token=body.refresh_token
    )
    return Response(status_code=204)


@me_router.get("/me", response_model=OwnerProfileResponse)
def get_me(owner: OwnerModel = Depends(get_current_owner)) -> OwnerProfileResponse:
    return _profile_response(owner)


@me_router.patch("/me", response_model=OwnerProfileResponse)
def patch_me(
    full_name: str | None = Form(None),
    email: str | None = Form(None),
    phone: str | None = Form(None),
    address: str | None = Form(None),
    latitude: float | None = Form(None),
    longitude: float | None = Form(None),
    profile_image: UploadFile | None = File(None),
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> OwnerProfileResponse:
    updated = _service(db, settings).update_profile(
        owner=owner,
        full_name=full_name,
        email=email,
        phone=phone,
        address=address,
        latitude=latitude,
        longitude=longitude,
        profile_image=profile_image,
    )
    return _profile_response(updated)


@me_router.get("/me/profile-image")
def get_profile_image(
    owner: OwnerModel = Depends(get_current_owner),
    settings: Settings = Depends(get_settings_dep),
) -> FileResponse:
    path = ProfileImageStore(settings).resolve(owner.profile_image_path)
    return FileResponse(path)


@settings_router.get("/farm-settings", response_model=FarmSettingsResponse)
def get_farm_settings(
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> FarmSettingsResponse:
    row = _service(db, settings).get_farm_settings(owner.id)
    return FarmSettingsResponse.model_validate(row)


@settings_router.patch("/farm-settings", response_model=FarmSettingsResponse)
def patch_farm_settings(
    body: FarmSettingsUpdateRequest,
    owner: OwnerModel = Depends(get_current_owner),
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> FarmSettingsResponse:
    row = _service(db, settings).update_farm_settings(
        owner_id=owner.id,
        currency_code=body.currency_code,
        timezone=body.timezone,
        fields_set=set(body.model_fields_set),
    )
    return FarmSettingsResponse.model_validate(row)


@config_router.get("/suggested-units", response_model=SuggestedUnitsResponse)
def suggested_units() -> SuggestedUnitsResponse:
    return SuggestedUnitsResponse(items=list(SUGGESTED_UNITS))
