from pydantic import BaseModel

from packages.core.application.ports.clinical_document_repository import (
    ClinicalDocumentRepository,
)
from packages.core.application.ports.clinical_event_repository import ClinicalEventRepository
from packages.core.domain.clinical_records.models import ClinicalEvent
from packages.shared.errors.base import ValidationError


class UpdateClinicalEventInput(BaseModel):
    owner_id: str
    event_id: str
    event_type: str | None = None
    title: str | None = None
    event_date: str | None = None
    summary: str | None = None
    severity: str | None = None
    source: str | None = None
    linked_document_id: str | None = None


class UpdateClinicalEventOutput(BaseModel):
    event: ClinicalEvent


class UpdateClinicalEventService:
    def __init__(
        self,
        repository: ClinicalEventRepository,
        clinical_document_repository: ClinicalDocumentRepository,
    ) -> None:
        self._repository = repository
        self._clinical_document_repository = clinical_document_repository

    def execute(self, data: UpdateClinicalEventInput) -> UpdateClinicalEventOutput:
        event = self._repository.get(data.event_id)
        if event is None or event.owner_id != data.owner_id:
            raise ValidationError("clinical_event not found")

        update_payload = data.model_dump(
            exclude={"owner_id", "event_id"},
            exclude_none=True,
        )

        linked_document_id = update_payload.get("linked_document_id")
        if linked_document_id:
            documents = self._clinical_document_repository.list_by_pet(event.pet_id)
            if not any(document.id == linked_document_id for document in documents):
                raise ValidationError("linked clinical document not found")

        updated = event.model_copy(update=update_payload)
        return UpdateClinicalEventOutput(event=self._repository.save(updated))
