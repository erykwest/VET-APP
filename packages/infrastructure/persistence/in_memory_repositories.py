from packages.core.application.ports.clinical_document_repository import (
    ClinicalDocumentRepository,
)
from packages.core.application.ports.clinical_event_repository import ClinicalEventRepository
from packages.core.application.ports.conversation_repository import ConversationRepository
from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.application.ports.reminder_repository import ReminderRepository
from packages.core.domain.clinical_records.models import ClinicalDocument, ClinicalEvent
from packages.core.domain.conversation.models import Conversation
from packages.core.domain.pet_profile.models import PetProfile
from packages.core.domain.reminders.models import Reminder


class InMemoryPetProfileRepository(PetProfileRepository):
    def __init__(self) -> None:
        self._items: dict[str, PetProfile] = {}

    def save(self, pet_profile: PetProfile) -> PetProfile:
        self._items[pet_profile.id] = pet_profile
        return pet_profile

    def get(self, pet_id: str) -> PetProfile | None:
        return self._items.get(pet_id)

    def list_by_owner(self, owner_id: str) -> list[PetProfile]:
        return [item for item in self._items.values() if item.owner_id == owner_id]


class InMemoryConversationRepository(ConversationRepository):
    def __init__(self) -> None:
        self._items: dict[str, Conversation] = {}

    def save(self, conversation: Conversation) -> Conversation:
        self._items[conversation.id] = conversation
        return conversation

    def get(self, conversation_id: str) -> Conversation | None:
        return self._items.get(conversation_id)

    def list_by_owner(self, owner_id: str) -> list[Conversation]:
        return [item for item in self._items.values() if item.owner_id == owner_id]


class InMemoryReminderRepository(ReminderRepository):
    def __init__(self) -> None:
        self._items: list[Reminder] = []

    def save(self, reminder: Reminder) -> Reminder:
        self._items.append(reminder)
        return reminder

    def list_by_owner(self, owner_id: str) -> list[Reminder]:
        return [item for item in self._items if item.owner_id == owner_id]


class InMemoryClinicalDocumentRepository(ClinicalDocumentRepository):
    def __init__(self) -> None:
        self._items: list[ClinicalDocument] = []

    def save(self, document: ClinicalDocument) -> ClinicalDocument:
        for index, item in enumerate(self._items):
            if item.id == document.id:
                self._items[index] = document
                break
        else:
            self._items.append(document)
        return document

    def list_by_pet(self, pet_id: str) -> list[ClinicalDocument]:
        return sorted(
            [item for item in self._items if item.pet_id == pet_id],
            key=lambda item: item.document_date,
            reverse=True,
        )


class InMemoryClinicalEventRepository(ClinicalEventRepository):
    def __init__(self) -> None:
        self._items: list[ClinicalEvent] = []

    def save(self, event: ClinicalEvent) -> ClinicalEvent:
        for index, item in enumerate(self._items):
            if item.id == event.id:
                self._items[index] = event
                break
        else:
            self._items.append(event)
        return event

    def get(self, event_id: str) -> ClinicalEvent | None:
        for item in self._items:
            if item.id == event_id:
                return item
        return None

    def delete(self, event_id: str) -> None:
        self._items = [item for item in self._items if item.id != event_id]

    def list_by_pet(self, pet_id: str) -> list[ClinicalEvent]:
        return sorted(
            [item for item in self._items if item.pet_id == pet_id],
            key=lambda item: item.event_date,
            reverse=True,
        )
