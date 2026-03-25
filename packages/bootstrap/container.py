from functools import lru_cache

from packages.core.application.services.create_pet_profile import CreatePetProfileService
from packages.core.application.services.create_reminder import CreateReminderService
from packages.core.application.services.get_pet_profile import GetPetProfileService
from packages.core.application.services.list_conversations import ListConversationsService
from packages.core.application.services.list_pet_profiles import ListPetProfilesService
from packages.core.application.services.list_reminders import ListRemindersService
from packages.core.application.services.send_chat_message import SendChatMessageService
from packages.core.application.services.update_pet_profile import UpdatePetProfileService
from packages.infrastructure.auth.fake_auth_provider import FakeAuthProvider
from packages.infrastructure.llm.providers.echo_llm_client import EchoLLMClient
from packages.infrastructure.persistence.in_memory_repositories import (
    InMemoryConversationRepository,
    InMemoryPetProfileRepository,
    InMemoryReminderRepository,
)
from packages.shared.config.settings import Settings, get_settings


class ApplicationContainer:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self.auth_provider = FakeAuthProvider()
        self.pet_profile_repository = InMemoryPetProfileRepository()
        self.conversation_repository = InMemoryConversationRepository()
        self.reminder_repository = InMemoryReminderRepository()
        self.llm_client = EchoLLMClient(settings)

    def create_pet_profile_service(self) -> CreatePetProfileService:
        return CreatePetProfileService(self.pet_profile_repository)

    def get_pet_profile_service(self) -> GetPetProfileService:
        return GetPetProfileService(self.pet_profile_repository)

    def update_pet_profile_service(self) -> UpdatePetProfileService:
        return UpdatePetProfileService(self.pet_profile_repository)

    def list_pet_profiles_service(self) -> ListPetProfilesService:
        return ListPetProfilesService(self.pet_profile_repository)

    def send_chat_message_service(self) -> SendChatMessageService:
        return SendChatMessageService(
            self.conversation_repository,
            self.llm_client,
            self.pet_profile_repository,
        )

    def list_conversations_service(self) -> ListConversationsService:
        return ListConversationsService(self.conversation_repository)

    def create_reminder_service(self) -> CreateReminderService:
        return CreateReminderService(self.reminder_repository, self.pet_profile_repository)

    def list_reminders_service(self) -> ListRemindersService:
        return ListRemindersService(self.reminder_repository)


@lru_cache(maxsize=1)
def get_container() -> ApplicationContainer:
    return ApplicationContainer(get_settings())


def reset_container() -> None:
    get_container.cache_clear()
