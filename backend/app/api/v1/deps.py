from __future__ import annotations

from typing import Annotated
from uuid import UUID

import jwt
from fastapi import Depends
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.core.config import Settings, get_settings
from app.core.errors import AppError
from app.core.security import decode_token
from app.db.session import get_db
from app.modules.auth.infrastructure.models import OwnerModel

bearer_scheme = HTTPBearer(auto_error=False)


def get_settings_dep() -> Settings:
    return get_settings()


def get_db_session(db: Session = Depends(get_db)) -> Session:
    return db


def get_current_owner(
    credentials: Annotated[
        HTTPAuthorizationCredentials | None, Depends(bearer_scheme)
    ],
    db: Session = Depends(get_db_session),
    settings: Settings = Depends(get_settings_dep),
) -> OwnerModel:
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise AppError(
            code="UNAUTHORIZED",
            message="Authentication required.",
            status_code=401,
        )
    try:
        payload = decode_token(credentials.credentials, settings)
    except jwt.PyJWTError as exc:
        raise AppError(
            code="UNAUTHORIZED",
            message="Authentication required.",
            status_code=401,
        ) from exc

    if payload.get("type") != "access":
        raise AppError(
            code="UNAUTHORIZED",
            message="Authentication required.",
            status_code=401,
        )
    try:
        owner_id = UUID(str(payload.get("sub")))
    except (TypeError, ValueError) as exc:
        raise AppError(
            code="UNAUTHORIZED",
            message="Authentication required.",
            status_code=401,
        ) from exc

    owner = db.get(OwnerModel, owner_id)
    if owner is None:
        raise AppError(
            code="UNAUTHORIZED",
            message="Authentication required.",
            status_code=401,
        )
    return owner
