from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, EmailStr, Field


class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class SignInRequest(BaseModel):
    email: EmailStr
    password: str


class RefreshRequest(BaseModel):
    refresh_token: str


class SignOutRequest(BaseModel):
    refresh_token: str | None = None


class OwnerProfileResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    full_name: str
    email: EmailStr
    phone: str
    address: str
    latitude: float
    longitude: float
    profile_image_url: str
    created_at: datetime
    updated_at: datetime


class FarmSettingsResponse(BaseModel):
    model_config = {"from_attributes": True}

    id: UUID
    owner_id: UUID
    currency_code: str
    created_at: datetime
    updated_at: datetime


class FarmSettingsUpdateRequest(BaseModel):
    currency_code: str = Field(min_length=1, max_length=16)
