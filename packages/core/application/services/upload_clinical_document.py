from pydantic import BaseModel

from packages.core.application.ports.clinical_document_repository import (
    ClinicalDocumentRepository,
)
from packages.core.application.ports.clinical_document_storage import (
    ClinicalDocumentStorage,
)
from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.clinical_records.models import ClinicalDocument
from packages.shared.errors.base import ValidationError


class UploadClinicalDocumentInput(BaseModel):
    owner_id: str
    pet_id: str
    title: str
    document_type: str
    document_date: str
    filename: str
    content: bytes
    content_type: str | None = None
    summary: str | None = None
    source: str | None = None
    extracted_text_summary: str | None = None
    status: str = "uploaded"
    verified_by_user: bool = False


class UploadClinicalDocumentOutput(BaseModel):
    document: ClinicalDocument


class UploadClinicalDocumentService:
    def __init__(
        self,
        repository: ClinicalDocumentRepository,
        pet_profile_repository: PetProfileRepository,
        storage: ClinicalDocumentStorage,
    ) -> None:
        self._repository = repository
        self._pet_profile_repository = pet_profile_repository
        self._storage = storage

    def execute(self, data: UploadClinicalDocumentInput) -> UploadClinicalDocumentOutput:
        pet_profile = self._pet_profile_repository.get(data.pet_id)
        if pet_profile is None or pet_profile.owner_id != data.owner_id:
            raise ValidationError("pet_profile not found")
        if not data.content:
            raise ValidationError("document content must not be empty")

        document = ClinicalDocument(
            owner_id=data.owner_id,
            pet_id=data.pet_id,
            title=data.title,
            document_type=data.document_type,
            document_date=data.document_date,
            summary=data.summary,
            source=data.source,
            extracted_text_summary=data.extracted_text_summary,
            status=data.status,
            verified_by_user=data.verified_by_user,
        )
        stored = self._storage.save_document(
            owner_id=data.owner_id,
            pet_id=data.pet_id,
            document_id=document.id,
            filename=data.filename,
            content=data.content,
            content_type=data.content_type,
        )
        document = document.model_copy(
            update={
                "file_path": stored.file_path,
                "original_filename": stored.original_filename,
            }
        )
        return UploadClinicalDocumentOutput(document=self._repository.save(document))
