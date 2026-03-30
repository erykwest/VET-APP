from pydantic import BaseModel

from packages.core.application.ports.clinical_document_repository import (
    ClinicalDocumentRepository,
)
from packages.core.application.ports.clinical_event_repository import ClinicalEventRepository
from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.application.ports.reminder_repository import ReminderRepository
from packages.core.domain.clinical_records.models import ClinicalTimelineItem
from packages.shared.errors.base import ValidationError


class ListClinicalTimelineInput(BaseModel):
    owner_id: str
    pet_id: str


class ListClinicalTimelineOutput(BaseModel):
    timeline: list[ClinicalTimelineItem]


class ListClinicalTimelineService:
    def __init__(
        self,
        clinical_document_repository: ClinicalDocumentRepository,
        clinical_event_repository: ClinicalEventRepository,
        reminder_repository: ReminderRepository,
        pet_profile_repository: PetProfileRepository,
    ) -> None:
        self._clinical_document_repository = clinical_document_repository
        self._clinical_event_repository = clinical_event_repository
        self._reminder_repository = reminder_repository
        self._pet_profile_repository = pet_profile_repository

    def execute(self, data: ListClinicalTimelineInput) -> ListClinicalTimelineOutput:
        pet_profile = self._pet_profile_repository.get(data.pet_id)
        if pet_profile is None or pet_profile.owner_id != data.owner_id:
            raise ValidationError("pet_profile not found")

        timeline = [
            ClinicalTimelineItem(
                id=document.id,
                pet_id=document.pet_id,
                entry_type="clinical_document",
                title=document.title,
                event_date=document.document_date,
                summary=document.summary,
                source_label=document.document_type,
                related_document_id=document.id,
            )
            for document in self._clinical_document_repository.list_by_pet(data.pet_id)
        ]

        timeline.extend(
            ClinicalTimelineItem(
                id=event.id,
                pet_id=event.pet_id,
                entry_type="clinical_event",
                title=event.title,
                event_date=event.event_date,
                summary=event.summary,
                source_label=event.event_type,
                related_document_id=event.linked_document_id,
            )
            for event in self._clinical_event_repository.list_by_pet(data.pet_id)
        )

        for reminder in self._reminder_repository.list_by_owner(data.owner_id):
            if reminder.pet_id != data.pet_id:
                continue
            timeline.append(
                ClinicalTimelineItem(
                    id=reminder.id,
                    pet_id=reminder.pet_id,
                    entry_type="reminder",
                    title=reminder.title,
                    event_date=reminder.due_date,
                    summary=reminder.notes,
                    source_label="reminder",
                )
            )

        timeline.sort(key=lambda item: item.event_date, reverse=True)
        return ListClinicalTimelineOutput(timeline=timeline)
