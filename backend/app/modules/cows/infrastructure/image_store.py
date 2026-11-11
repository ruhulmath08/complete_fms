from __future__ import annotations

from pathlib import Path

from fastapi import UploadFile

from app.core.config import Settings
from app.core.errors import AppError
from app.core.security import secure_filename

ALLOWED_CONTENT_TYPES = {
    "image/jpeg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}


class CowImageStore:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self.root = settings.cow_images_path
        self.root.mkdir(parents=True, exist_ok=True)

    def save(self, upload: UploadFile, owner_id: str, cow_id: str) -> str:
        content_type = (upload.content_type or "").lower()
        if content_type not in ALLOWED_CONTENT_TYPES:
            raise AppError(
                code="INVALID_IMAGE",
                message="Cow image must be JPEG, PNG, or WebP.",
                status_code=422,
            )

        data = upload.file.read()
        if not data:
            raise AppError(
                code="INVALID_IMAGE",
                message="Cow image file is empty.",
                status_code=422,
            )
        if len(data) > self.settings.max_cow_image_bytes:
            raise AppError(
                code="INVALID_IMAGE",
                message="Cow image exceeds the 5 MB size limit.",
                status_code=422,
            )

        folder = self.root / owner_id / cow_id
        folder.mkdir(parents=True, exist_ok=True)
        filename = secure_filename(upload.filename or "cow.jpg")
        preferred = ALLOWED_CONTENT_TYPES[content_type]
        filename = f"{filename.rsplit('.', 1)[0]}{preferred}"
        path = folder / filename
        path.write_bytes(data)
        return str(path.relative_to(self.settings.upload_path))

    def resolve(self, relative_path: str) -> Path:
        path = (self.settings.upload_path / relative_path).resolve()
        upload_root = self.settings.upload_path.resolve()
        if not str(path).startswith(str(upload_root)):
            raise AppError(
                code="COW_IMAGE_NOT_FOUND",
                message="Cow image not found.",
                status_code=404,
            )
        if not path.is_file():
            raise AppError(
                code="COW_IMAGE_NOT_FOUND",
                message="Cow image not found.",
                status_code=404,
            )
        return path

    def replace(
        self,
        upload: UploadFile,
        owner_id: str,
        cow_id: str,
        old_relative: str | None,
    ) -> str:
        new_path = self.save(upload, owner_id, cow_id)
        if old_relative:
            old = self.settings.upload_path / old_relative
            if old.is_file():
                old.unlink(missing_ok=True)
        return new_path

    def delete(self, relative_path: str | None) -> None:
        if not relative_path:
            return
        path = self.settings.upload_path / relative_path
        if path.is_file():
            path.unlink(missing_ok=True)
