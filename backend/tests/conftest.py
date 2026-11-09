from __future__ import annotations

import io
from collections.abc import Generator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.api.v1.deps import get_settings_dep
from app.core.config import Settings, get_settings
from app.db.base import Base
from app.db.session import get_db
from app.main import create_app
from app.modules.auth.infrastructure import models as _models  # noqa: F401


@pytest.fixture()
def settings(tmp_path: Path) -> Settings:
    return Settings(
        app_name="complete-fms-test",
        environment="test",
        secret_key="test-secret-key-not-for-production",
        database_url="sqlite+pysqlite:///:memory:",
        upload_root=str(tmp_path / "uploads"),
        access_token_ttl_seconds=900,
        refresh_token_ttl_seconds=604800,
        cors_origins="http://testserver",
    )


@pytest.fixture()
def db_session(settings: Settings) -> Generator[Session, None, None]:
    engine = create_engine(
        "sqlite+pysqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    Base.metadata.create_all(bind=engine)
    TestingSessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)
        engine.dispose()


@pytest.fixture()
def client(
    settings: Settings, db_session: Session, monkeypatch: pytest.MonkeyPatch
) -> Generator[TestClient, None, None]:
    get_settings.cache_clear()
    monkeypatch.setattr("app.core.config.get_settings", lambda: settings)
    monkeypatch.setattr("app.main.get_settings", lambda: settings)
    monkeypatch.setattr("app.api.v1.deps.get_settings", lambda: settings)

    app = create_app()

    def _override_db() -> Generator[Session, None, None]:
        yield db_session

    app.dependency_overrides[get_db] = _override_db
    app.dependency_overrides[get_settings_dep] = lambda: settings
    app.dependency_overrides[get_settings] = lambda: settings
    settings.profile_images_path.mkdir(parents=True, exist_ok=True)

    with TestClient(app) as test_client:
        yield test_client

    app.dependency_overrides.clear()
    get_settings.cache_clear()


@pytest.fixture()
def sample_image() -> tuple[str, io.BytesIO, str]:
    data = (
        b"\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01"
        b"\x00\x00\x00\x01\x08\x02\x00\x00\x00\x90wS\xde"
    )
    return ("profile.png", io.BytesIO(data), "image/png")


def signup_owner(
    client: TestClient, sample_image: tuple[str, io.BytesIO, str], **overrides
):
    filename, buf, content_type = sample_image
    buf.seek(0)
    fields = {
        "full_name": "Farm Owner",
        "email": "owner@example.com",
        "phone": "+8801711111111",
        "address": "Dhaka",
        "latitude": "23.81",
        "longitude": "90.41",
        "password": "Password1",
        "confirm_password": "Password1",
    }
    for key, value in overrides.items():
        fields[key] = str(value) if not isinstance(value, str) else value
    files = {"profile_image": (filename, buf, content_type)}
    return client.post("/api/v1/auth/signup", data=fields, files=files)
