from functools import lru_cache
from pathlib import Path

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict

BACKEND_ROOT = Path(__file__).resolve().parents[2]


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(BACKEND_ROOT / ".env"),
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "complete-fms-api"
    environment: str = "local"
    secret_key: str = Field(default="dev-only-change-me")
    database_url: str = Field(
        default="postgresql+psycopg2://postgres:postgres@localhost:5432/complete_fms"
    )
    upload_root: str = "uploads"
    access_token_ttl_seconds: int = 900
    refresh_token_ttl_seconds: int = 604800
    cors_origins: str = "http://localhost:5173,http://127.0.0.1:5173"
    max_profile_image_bytes: int = 5 * 1024 * 1024
    max_cow_image_bytes: int = 5 * 1024 * 1024

    @property
    def cors_origin_list(self) -> list[str]:
        return [o.strip() for o in self.cors_origins.split(",") if o.strip()]

    @property
    def upload_path(self) -> Path:
        path = Path(self.upload_root)
        if not path.is_absolute():
            path = BACKEND_ROOT / path
        return path

    @property
    def profile_images_path(self) -> Path:
        return self.upload_path / "profile_images"

    @property
    def cow_images_path(self) -> Path:
        return self.upload_path / "cow_images"


@lru_cache
def get_settings() -> Settings:
    return Settings()
