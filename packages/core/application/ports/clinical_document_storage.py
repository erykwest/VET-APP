from typing import Protocol

from pydantic import BaseModel


class StoredClinicalDocument(BaseModel):
    file_path: str
    original_filename: str
    content_type: str | None = None
    size_bytes: int


class ClinicalDocumentStorage(Protocol):
    def save_document(
        self,
        *,
        owner_id: str,
        pet_id: str,
        document_id: str,
        filename: str,
        content: bytes,
        content_type: str | None = None,
    ) -> StoredClinicalDocument: ...
