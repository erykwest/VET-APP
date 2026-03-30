from pydantic import BaseModel

from packages.core.application.ports.clinical_event_repository import ClinicalEventRepository
from packages.shared.errors.base import ValidationError


class DeleteClinicalEventInput(BaseModel):
    owner_id: str
    event_id: str


class DeleteClinicalEventOutput(BaseModel):
    deleted: bool = True


class DeleteClinicalEventService:
    def __init__(self, repository: ClinicalEventRepository) -> None:
        self._repository = repository

    def execute(self, data: DeleteClinicalEventInput) -> DeleteClinicalEventOutput:
        event = self._repository.get(data.event_id)
        if event is None or event.owner_id != data.owner_id:
            raise ValidationError("clinical_event not found")
        self._repository.delete(data.event_id)
        return DeleteClinicalEventOutput()
