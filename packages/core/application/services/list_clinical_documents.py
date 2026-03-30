from pydantic import BaseModel

from packages.core.application.ports.clinical_document_repository import (
    ClinicalDocumentRepository,
)
from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.clinical_records.models import ClinicalDocument
from packages.shared.errors.base import ValidationError


class ListClinicalDocumentsInput(BaseModel):
    owner_id: str
    pet_id: str


class ListClinicalDocumentsOutput(BaseModel):
    documents: list[ClinicalDocument]


class ListClinicalDocumentsService:
    def __init__(
        self,
        repository: ClinicalDocumentRepository,
        pet_profile_repository: PetProfileRepository,
    ) -> None:
        self._repository = repository
        self._pet_profile_repository = pet_profile_repository

    def execute(self, data: ListClinicalDocumentsInput) -> ListClinicalDocumentsOutput:
        pet_profile = self._pet_profile_repository.get(data.pet_id)
        if pet_profile is None or pet_profile.owner_id != data.owner_id:
            raise ValidationError("pet_profile not found")
        return ListClinicalDocumentsOutput(documents=self._repository.list_by_pet(data.pet_id))
