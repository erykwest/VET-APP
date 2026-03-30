from datetime import date

from packages.core.application.services.create_clinical_document import (
    CreateClinicalDocumentInput,
    CreateClinicalDocumentService,
)
from packages.core.application.services.list_clinical_timeline import (
    ListClinicalTimelineInput,
    ListClinicalTimelineService,
)
from packages.core.domain.pet_profile.models import PetProfile
from packages.core.domain.reminders.models import Reminder
from packages.infrastructure.persistence.in_memory_repositories import (
    InMemoryClinicalDocumentRepository,
    InMemoryPetProfileRepository,
    InMemoryReminderRepository,
)


def test_create_clinical_document_and_timeline_are_available() -> None:
    pet_repository = InMemoryPetProfileRepository()
    clinical_document_repository = InMemoryClinicalDocumentRepository()
    reminder_repository = InMemoryReminderRepository()
    pet_repository.save(PetProfile(id="pet-1", owner_id="user-1", name="Milo", species="dog"))
    reminder_repository.save(
        Reminder(
            id="rem-1",
            owner_id="user-1",
            pet_id="pet-1",
            title="Vaccino annuale",
            due_date=date(2026, 4, 20),
        )
    )

    create_service = CreateClinicalDocumentService(clinical_document_repository, pet_repository)
    create_result = create_service.execute(
        CreateClinicalDocumentInput(
            owner_id="user-1",
            pet_id="pet-1",
            title="Esame del sangue",
            document_type="lab_result",
            document_date="2026-04-10",
            summary="Emocromo di controllo",
        )
    )

    timeline_service = ListClinicalTimelineService(
        clinical_document_repository,
        reminder_repository,
        pet_repository,
    )
    timeline_result = timeline_service.execute(
        ListClinicalTimelineInput(owner_id="user-1", pet_id="pet-1")
    )

    assert create_result.document.title == "Esame del sangue"
    assert len(timeline_result.timeline) == 2
    assert timeline_result.timeline[0].entry_type == "reminder"
    assert timeline_result.timeline[1].entry_type == "clinical_document"
