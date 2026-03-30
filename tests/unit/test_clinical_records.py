import base64
from datetime import date

from packages.core.application.services.create_clinical_document import (
    CreateClinicalDocumentInput,
    CreateClinicalDocumentService,
)
from packages.core.application.services.create_clinical_event import (
    CreateClinicalEventInput,
    CreateClinicalEventService,
)
from packages.core.application.services.list_clinical_timeline import (
    ListClinicalTimelineInput,
    ListClinicalTimelineService,
)
from packages.core.domain.pet_profile.models import PetProfile
from packages.core.domain.reminders.models import Reminder
from packages.infrastructure.storage.document_storage import LocalClinicalDocumentStorage
from packages.shared.config.settings import get_settings
from packages.infrastructure.persistence.in_memory_repositories import (
    InMemoryClinicalDocumentRepository,
    InMemoryClinicalEventRepository,
    InMemoryPetProfileRepository,
    InMemoryReminderRepository,
)


def test_create_clinical_document_and_timeline_are_available() -> None:
    pet_repository = InMemoryPetProfileRepository()
    clinical_document_repository = InMemoryClinicalDocumentRepository()
    clinical_event_repository = InMemoryClinicalEventRepository()
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

    create_event_service = CreateClinicalEventService(
        clinical_event_repository,
        pet_repository,
        clinical_document_repository,
    )
    create_event_service.execute(
        CreateClinicalEventInput(
            owner_id="user-1",
            pet_id="pet-1",
            event_type="clinical_visit",
            title="Visita di controllo",
            event_date="2026-04-12",
            linked_document_id=create_result.document.id,
        )
    )

    timeline_service = ListClinicalTimelineService(
        clinical_document_repository,
        clinical_event_repository,
        reminder_repository,
        pet_repository,
    )
    timeline_result = timeline_service.execute(
        ListClinicalTimelineInput(owner_id="user-1", pet_id="pet-1")
    )

    assert create_result.document.title == "Esame del sangue"
    assert len(timeline_result.timeline) == 3
    assert timeline_result.timeline[0].entry_type == "reminder"
    assert timeline_result.timeline[1].entry_type == "clinical_event"
    assert timeline_result.timeline[2].entry_type == "clinical_document"


def test_upload_endpoint_persists_file_and_creates_document() -> None:
    from fastapi.testclient import TestClient

    from apps.api.main import app

    client = TestClient(app)
    pet_response = client.post("/pets", json={"name": "Luna", "species": "cat"})
    pet_id = pet_response.json()["pet_profile"]["id"]

    upload_response = client.post(
        f"/pets/{pet_id}/clinical-documents/upload",
        json={
            "title": "referto_upload.txt",
            "document_type": "clinical_visit",
            "document_date": "2026-04-16",
            "filename": "referto_upload.txt",
            "content_base64": base64.b64encode(b"referto di prova").decode("utf-8"),
            "content_type": "text/plain",
        },
    )
    assert upload_response.status_code == 200
    document = upload_response.json()["document"]
    assert document["original_filename"] == "referto_upload.txt"
    assert document["file_path"].endswith("referto_upload.txt")

    local_storage = LocalClinicalDocumentStorage(get_settings())
    stored_file = local_storage._root / document["file_path"]
    assert stored_file.exists()
