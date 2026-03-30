from pydantic import BaseModel

from packages.core.application.ports.clinical_event_repository import ClinicalEventRepository
from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.clinical_records.models import ClinicalEvent
from packages.shared.errors.base import ValidationError


class ListClinicalEventsInput(BaseModel):
    owner_id: str
    pet_id: str


class ListClinicalEventsOutput(BaseModel):
    events: list[ClinicalEvent]


class ListClinicalEventsService:
    def __init__(
        self,
        repository: ClinicalEventRepository,
        pet_profile_repository: PetProfileRepository,
    ) -> None:
        self._repository = repository
        self._pet_profile_repository = pet_profile_repository

    def execute(self, data: ListClinicalEventsInput) -> ListClinicalEventsOutput:
        pet_profile = self._pet_profile_repository.get(data.pet_id)
        if pet_profile is None or pet_profile.owner_id != data.owner_id:
            raise ValidationError("pet_profile not found")
        return ListClinicalEventsOutput(events=self._repository.list_by_pet(data.pet_id))
