from pydantic import BaseModel

from packages.core.application.ports.clinical_document_repository import (
    ClinicalDocumentRepository,
)
from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.clinical_records.models import ClinicalDocument
from packages.shared.errors.base import ValidationError


class CreateClinicalDocumentInput(BaseModel):
    owner_id: str
    pet_id: str
    title: str
    document_type: str
    document_date: str
    summary: str | None = None
    source: str | None = None
    file_path: str | None = None
    original_filename: str | None = None
    extracted_text_summary: str | None = None
    status: str = "uploaded"
    verified_by_user: bool = False


class CreateClinicalDocumentOutput(BaseModel):
    document: ClinicalDocument


class CreateClinicalDocumentService:
    def __init__(
        self,
        repository: ClinicalDocumentRepository,
        pet_profile_repository: PetProfileRepository,
    ) -> None:
        self._repository = repository
        self._pet_profile_repository = pet_profile_repository

    def execute(self, data: CreateClinicalDocumentInput) -> CreateClinicalDocumentOutput:
        pet_profile = self._pet_profile_repository.get(data.pet_id)
        if pet_profile is None or pet_profile.owner_id != data.owner_id:
            raise ValidationError("pet_profile not found")

        document = ClinicalDocument(**data.model_dump())
        return CreateClinicalDocumentOutput(document=self._repository.save(document))
