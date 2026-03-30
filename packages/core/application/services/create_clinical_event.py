from pydantic import BaseModel

from packages.core.application.ports.clinical_document_repository import (
    ClinicalDocumentRepository,
)
from packages.core.application.ports.clinical_event_repository import ClinicalEventRepository
from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.clinical_records.models import ClinicalEvent
from packages.shared.errors.base import ValidationError


class CreateClinicalEventInput(BaseModel):
    owner_id: str
    pet_id: str
    event_type: str
    title: str
    event_date: str
    summary: str | None = None
    severity: str | None = None
    source: str | None = None
    linked_document_id: str | None = None


class CreateClinicalEventOutput(BaseModel):
    event: ClinicalEvent


class CreateClinicalEventService:
    def __init__(
        self,
        repository: ClinicalEventRepository,
        pet_profile_repository: PetProfileRepository,
        clinical_document_repository: ClinicalDocumentRepository,
    ) -> None:
        self._repository = repository
        self._pet_profile_repository = pet_profile_repository
        self._clinical_document_repository = clinical_document_repository

    def execute(self, data: CreateClinicalEventInput) -> CreateClinicalEventOutput:
        pet_profile = self._pet_profile_repository.get(data.pet_id)
        if pet_profile is None or pet_profile.owner_id != data.owner_id:
            raise ValidationError("pet_profile not found")

        if data.linked_document_id:
            documents = self._clinical_document_repository.list_by_pet(data.pet_id)
            if not any(document.id == data.linked_document_id for document in documents):
                raise ValidationError("linked clinical document not found")

        event = ClinicalEvent(**data.model_dump())
        return CreateClinicalEventOutput(event=self._repository.save(event))
