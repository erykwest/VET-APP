from __future__ import annotations

from pathlib import Path
from urllib.parse import quote
from urllib.request import Request, urlopen

from packages.core.application.ports.clinical_document_storage import (
    StoredClinicalDocument,
)
from packages.infrastructure.persistence.supabase.client import SupabaseRestClient
from packages.shared.config.settings import Settings
from packages.shared.errors.base import ProviderError


def build_storage_path(*, owner_id: str, pet_id: str, document_id: str, filename: str) -> str:
    safe_name = Path(filename).name or "document.bin"
    return f"users/{owner_id}/pets/{pet_id}/clinical/{document_id}/{safe_name}"


class LocalClinicalDocumentStorage:
    def __init__(self, settings: Settings) -> None:
        self._root = Path(settings.local_storage_dir).resolve()

    def save_document(
        self,
        *,
        owner_id: str,
        pet_id: str,
        document_id: str,
        filename: str,
        content: bytes,
        content_type: str | None = None,
    ) -> StoredClinicalDocument:
        relative_path = build_storage_path(
            owner_id=owner_id,
            pet_id=pet_id,
            document_id=document_id,
            filename=filename,
        )
        destination = self._root / Path(relative_path)
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(content)
        return StoredClinicalDocument(
            file_path=relative_path,
            original_filename=Path(filename).name,
            content_type=content_type,
            size_bytes=len(content),
        )


class SupabaseClinicalDocumentStorage:
    def __init__(self, settings: Settings) -> None:
        self._settings = settings
        self._client = SupabaseRestClient(
            base_url=settings.supabase_url,
            api_key=settings.supabase_service_role_key,
        )

    def save_document(
        self,
        *,
        owner_id: str,
        pet_id: str,
        document_id: str,
        filename: str,
        content: bytes,
        content_type: str | None = None,
    ) -> StoredClinicalDocument:
        relative_path = build_storage_path(
            owner_id=owner_id,
            pet_id=pet_id,
            document_id=document_id,
            filename=filename,
        )
        encoded_path = quote(relative_path, safe="/")
        request = Request(
            url=(
                f"{self._settings.supabase_url.rstrip('/')}/storage/v1/object/"
                f"{self._settings.clinical_documents_bucket}/{encoded_path}"
            ),
            data=content,
            headers={
                "apikey": self._settings.supabase_service_role_key,
                "Authorization": f"Bearer {self._settings.supabase_service_role_key}",
                "Content-Type": content_type or "application/octet-stream",
                "x-upsert": "true",
            },
            method="POST",
        )
        try:
            with urlopen(request, timeout=30):
                pass
        except Exception as exc:  # pragma: no cover - network failures vary
            raise ProviderError(f"Supabase storage upload failed: {exc}") from exc

        return StoredClinicalDocument(
            file_path=relative_path,
            original_filename=Path(filename).name,
            content_type=content_type,
            size_bytes=len(content),
        )
