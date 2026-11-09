from uuid import uuid4

from app.core.config import Settings
from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    hash_token,
    verify_password,
)


def test_password_hash_roundtrip() -> None:
    hashed = hash_password("Password1")
    assert hashed != "Password1"
    assert verify_password("Password1", hashed)
    assert not verify_password("wrong", hashed)


def test_token_hash_is_sha256_hex() -> None:
    digest = hash_token("abc")
    assert len(digest) == 64
    assert digest == hash_token("abc")
    assert digest != hash_token("abcd")


def test_jwt_access_and_refresh_claims() -> None:
    settings = Settings(secret_key="unit-test-secret-key-32bytes-min!!")
    owner_id = uuid4()
    access, expires_in = create_access_token(owner_id=owner_id, settings=settings)
    assert expires_in == settings.access_token_ttl_seconds
    access_claims = decode_token(access, settings)
    assert access_claims["type"] == "access"
    assert access_claims["sub"] == str(owner_id)

    token_id = uuid4()
    family_id = uuid4()
    refresh = create_refresh_token(
        owner_id=owner_id,
        settings=settings,
        token_id=token_id,
        family_id=family_id,
    )
    refresh_claims = decode_token(refresh, settings)
    assert refresh_claims["type"] == "refresh"
    assert refresh_claims["jti"] == str(token_id)
    assert refresh_claims["fid"] == str(family_id)
