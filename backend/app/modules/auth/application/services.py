from __future__ import annotations

import logging
from datetime import UTC, datetime, timedelta
from uuid import UUID, uuid4

import jwt
from fastapi import UploadFile
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import Settings
from app.core.errors import AppError
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    hash_token,
    new_family_id,
    new_token_id,
    verify_password,
)
from app.modules.auth.domain.rules import (
    normalize_email,
    validate_currency_code,
    validate_email,
    validate_password,
)
from app.modules.auth.infrastructure.image_store import ProfileImageStore
from app.modules.auth.infrastructure.models import (
    FarmSettingsModel,
    OwnerModel,
    RefreshTokenModel,
)

logger = logging.getLogger(__name__)


def _as_utc(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=UTC)
    return value.astimezone(UTC)


class AuthService:
    def __init__(self, db: Session, settings: Settings) -> None:
        self.db = db
        self.settings = settings
        self.images = ProfileImageStore(settings)

    def register_owner(
        self,
        *,
        full_name: str,
        email: str,
        phone: str,
        address: str,
        latitude: float,
        longitude: float,
        password: str,
        confirm_password: str,
        profile_image: UploadFile,
    ) -> OwnerModel:
        email_norm = validate_email(email)
        phone_norm = phone.strip()
        if not full_name.strip() or not phone_norm or not address.strip():
            raise AppError(
                code="VALIDATION_ERROR",
                message="All signup fields are required.",
                status_code=422,
            )
        validate_password(password, confirm_password)

        if self._get_owner_by_email(email_norm):
            raise AppError(
                code="EMAIL_ALREADY_EXISTS",
                message="Email is already registered.",
                status_code=409,
            )
        if self._get_owner_by_phone(phone_norm):
            raise AppError(
                code="PHONE_ALREADY_EXISTS",
                message="Phone is already registered.",
                status_code=409,
            )

        owner_id = uuid4()
        relative_image = self.images.save(profile_image, str(owner_id))
        owner = OwnerModel(
            id=owner_id,
            full_name=full_name.strip(),
            email=email_norm,
            phone=phone_norm,
            address=address.strip(),
            latitude=latitude,
            longitude=longitude,
            profile_image_path=relative_image,
            password_hash=hash_password(password),
        )
        settings = FarmSettingsModel(owner_id=owner_id, currency_code="BDT")
        self.db.add(owner)
        self.db.add(settings)
        self.db.commit()
        self.db.refresh(owner)
        logger.info("Owner registered owner_id=%s", owner.id)
        return owner

    def sign_in(self, *, email: str, password: str) -> dict:
        email_norm = normalize_email(email)
        owner = self._get_owner_by_email(email_norm)
        if owner is None or not verify_password(password, owner.password_hash):
            logger.info("Sign-in failed for email=%s", email_norm)
            raise AppError(
                code="INVALID_CREDENTIALS",
                message="Email or password is incorrect.",
                status_code=401,
            )
        tokens = self._issue_token_pair(owner.id, family_id=new_family_id())
        logger.info("Owner signed in owner_id=%s", owner.id)
        return tokens

    def refresh(self, *, refresh_token: str) -> dict:
        try:
            payload = decode_token(refresh_token, self.settings)
        except jwt.PyJWTError as exc:
            raise AppError(
                code="REFRESH_TOKEN_INVALID",
                message="Refresh token is invalid or expired.",
                status_code=401,
            ) from exc

        if payload.get("type") != "refresh":
            raise AppError(
                code="REFRESH_TOKEN_INVALID",
                message="Refresh token is invalid or expired.",
                status_code=401,
            )

        token_hash = hash_token(refresh_token)
        row = self.db.scalar(
            select(RefreshTokenModel).where(RefreshTokenModel.token_hash == token_hash)
        )
        now = datetime.now(UTC)

        if row is None:
            raise AppError(
                code="REFRESH_TOKEN_INVALID",
                message="Refresh token is invalid or expired.",
                status_code=401,
            )

        if row.revoked_at is not None:
            self._revoke_family(row.family_id)
            self.db.commit()
            logger.warning(
                "Refresh token reuse detected owner_id=%s family_id=%s",
                row.owner_id,
                row.family_id,
            )
            raise AppError(
                code="REFRESH_TOKEN_REUSE",
                message="Refresh token reuse detected.",
                status_code=401,
            )

        if _as_utc(row.expires_at) <= now:
            row.revoked_at = now
            self.db.commit()
            raise AppError(
                code="REFRESH_TOKEN_INVALID",
                message="Refresh token is invalid or expired.",
                status_code=401,
            )

        new_id = new_token_id()
        tokens = self._issue_token_pair(
            row.owner_id, family_id=row.family_id, token_id=new_id
        )
        row.revoked_at = now
        row.last_used_at = now
        row.replaced_by_token_id = new_id
        self.db.commit()
        return tokens

    def sign_out(self, *, owner_id: UUID, refresh_token: str | None) -> None:
        now = datetime.now(UTC)
        if refresh_token:
            token_hash = hash_token(refresh_token)
            row = self.db.scalar(
                select(RefreshTokenModel).where(
                    RefreshTokenModel.token_hash == token_hash,
                    RefreshTokenModel.owner_id == owner_id,
                )
            )
            if row and row.revoked_at is None:
                row.revoked_at = now
        else:
            self._revoke_all_active(owner_id)
        self.db.commit()
        logger.info("Owner signed out owner_id=%s", owner_id)

    def get_owner(self, owner_id: UUID) -> OwnerModel:
        owner = self.db.get(OwnerModel, owner_id)
        if owner is None:
            raise AppError(
                code="UNAUTHORIZED",
                message="Authentication required.",
                status_code=401,
            )
        return owner

    def update_profile(
        self,
        *,
        owner: OwnerModel,
        full_name: str | None,
        email: str | None,
        phone: str | None,
        address: str | None,
        latitude: float | None,
        longitude: float | None,
        profile_image: UploadFile | None,
    ) -> OwnerModel:
        if email is not None:
            email_norm = validate_email(email)
            existing = self._get_owner_by_email(email_norm)
            if existing and existing.id != owner.id:
                raise AppError(
                    code="EMAIL_ALREADY_EXISTS",
                    message="Email is already registered.",
                    status_code=409,
                )
            owner.email = email_norm
        if phone is not None:
            phone_norm = phone.strip()
            if not phone_norm:
                raise AppError(
                    code="VALIDATION_ERROR",
                    message="Phone is required.",
                    status_code=422,
                    details={"field": "phone"},
                )
            existing = self._get_owner_by_phone(phone_norm)
            if existing and existing.id != owner.id:
                raise AppError(
                    code="PHONE_ALREADY_EXISTS",
                    message="Phone is already registered.",
                    status_code=409,
                )
            owner.phone = phone_norm
        if full_name is not None:
            owner.full_name = full_name.strip()
        if address is not None:
            owner.address = address.strip()
        if latitude is not None:
            owner.latitude = latitude
        if longitude is not None:
            owner.longitude = longitude
        if profile_image is not None and profile_image.filename:
            owner.profile_image_path = self.images.replace(
                profile_image, str(owner.id), owner.profile_image_path
            )
        self.db.add(owner)
        self.db.commit()
        self.db.refresh(owner)
        return owner

    def get_farm_settings(self, owner_id: UUID) -> FarmSettingsModel:
        settings = self.db.scalar(
            select(FarmSettingsModel).where(FarmSettingsModel.owner_id == owner_id)
        )
        if settings is None:
            settings = FarmSettingsModel(owner_id=owner_id, currency_code="BDT")
            self.db.add(settings)
            self.db.commit()
            self.db.refresh(settings)
        return settings

    def update_farm_settings(
        self, *, owner_id: UUID, currency_code: str
    ) -> FarmSettingsModel:
        code = validate_currency_code(currency_code)
        settings = self.get_farm_settings(owner_id)
        settings.currency_code = code
        self.db.add(settings)
        self.db.commit()
        self.db.refresh(settings)
        return settings

    def _issue_token_pair(
        self,
        owner_id: UUID,
        *,
        family_id: UUID,
        token_id: UUID | None = None,
    ) -> dict:
        token_id = token_id or new_token_id()
        access_token, expires_in = create_access_token(
            owner_id=owner_id, settings=self.settings
        )
        refresh_token = create_refresh_token(
            owner_id=owner_id,
            settings=self.settings,
            token_id=token_id,
            family_id=family_id,
        )
        expires_at = datetime.now(UTC) + timedelta(
            seconds=self.settings.refresh_token_ttl_seconds
        )
        self.db.add(
            RefreshTokenModel(
                id=token_id,
                owner_id=owner_id,
                token_hash=hash_token(refresh_token),
                family_id=family_id,
                expires_at=expires_at,
            )
        )
        self.db.commit()
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "expires_in": expires_in,
        }

    def _get_owner_by_email(self, email: str) -> OwnerModel | None:
        return self.db.scalar(select(OwnerModel).where(OwnerModel.email == email))

    def _get_owner_by_phone(self, phone: str) -> OwnerModel | None:
        return self.db.scalar(select(OwnerModel).where(OwnerModel.phone == phone))

    def _revoke_family(self, family_id: UUID) -> None:
        now = datetime.now(UTC)
        rows = self.db.scalars(
            select(RefreshTokenModel).where(
                RefreshTokenModel.family_id == family_id,
                RefreshTokenModel.revoked_at.is_(None),
            )
        ).all()
        for row in rows:
            row.revoked_at = now

    def _revoke_all_active(self, owner_id: UUID) -> None:
        now = datetime.now(UTC)
        rows = self.db.scalars(
            select(RefreshTokenModel).where(
                RefreshTokenModel.owner_id == owner_id,
                RefreshTokenModel.revoked_at.is_(None),
            )
        ).all()
        for row in rows:
            row.revoked_at = now
