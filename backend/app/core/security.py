from __future__ import annotations

import hashlib
from datetime import UTC, datetime, timedelta
from typing import Any
from uuid import UUID, uuid4

import jwt
from argon2 import PasswordHasher
from argon2.exceptions import VerifyMismatchError

from app.core.config import Settings

_password_hasher = PasswordHasher()


def hash_password(password: str) -> str:
    return _password_hasher.hash(password)


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return _password_hasher.verify(password_hash, password)
    except VerifyMismatchError:
        return False


def hash_token(raw_token: str) -> str:
    return hashlib.sha256(raw_token.encode("utf-8")).hexdigest()


def create_access_token(
    *, owner_id: UUID, settings: Settings, extra: dict[str, Any] | None = None
) -> tuple[str, int]:
    now = datetime.now(UTC)
    expires_in = settings.access_token_ttl_seconds
    payload: dict[str, Any] = {
        "sub": str(owner_id),
        "type": "access",
        "iat": int(now.timestamp()),
        "exp": int((now + timedelta(seconds=expires_in)).timestamp()),
        "jti": str(uuid4()),
    }
    if extra:
        payload.update(extra)
    token = jwt.encode(payload, settings.secret_key, algorithm="HS256")
    return token, expires_in


def create_refresh_token(
    *, owner_id: UUID, settings: Settings, token_id: UUID, family_id: UUID
) -> str:
    now = datetime.now(UTC)
    payload = {
        "sub": str(owner_id),
        "type": "refresh",
        "iat": int(now.timestamp()),
        "exp": int(
            (now + timedelta(seconds=settings.refresh_token_ttl_seconds)).timestamp()
        ),
        "jti": str(token_id),
        "fid": str(family_id),
    }
    return jwt.encode(payload, settings.secret_key, algorithm="HS256")


def decode_token(token: str, settings: Settings) -> dict[str, Any]:
    return jwt.decode(token, settings.secret_key, algorithms=["HS256"])


def new_token_id() -> UUID:
    return uuid4()


def new_family_id() -> UUID:
    return uuid4()


def secure_filename(original: str) -> str:
    name = original.rsplit("/", 1)[-1]
    ext = "bin"
    if "." in name:
        candidate = name.rsplit(".", 1)[-1].lower()
        if candidate in {"jpg", "jpeg", "png", "webp"}:
            ext = "jpg" if candidate == "jpeg" else candidate
    return f"{uuid4().hex}.{ext}"
