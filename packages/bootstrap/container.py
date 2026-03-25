from functools import lru_cache

from packages.core.application.ports.auth_provider import AuthProvider
from packages.core.application.services.create_pet_profile import CreatePetProfileService
from packages.core.application.services.create_reminder import CreateReminderService
from packages.core.application.services.get_pet_profile import GetPetProfileService
from packages.core.application.services.list_conversations import ListConversationsService
from packages.core.application.services.list_pet_profiles import ListPetProfilesService
from packages.core.application.services.list_reminders import ListRemindersService
from packages.core.application.services.send_chat_message import SendChatMessageService
from packages.core.application.services.update_pet_profile import UpdatePetProfileService
from packages.infrastructure.auth.bootstrap_auth_provider import BootstrapAuthProvider
from packages.infrastructure.auth.supabase_auth_provider import SupabaseAuthProvider
from packages.infrastructure.llm.providers.echo_llm_client import EchoLLMClient
from packages.infrastructure.persistence.in_memory_repositories import (
    InMemoryConversationRepository,
    InMemoryPetProfileRepository,
    InMemoryReminderRepository,
)
from packages.infrastructure.persistence.supabase.client import (
    build_supabase_client,
    build_supabase_public_client,
)
from packages.infrastructure.persistence.supabase.supabase_repositories import (
    SupabaseConversationRepository,
    SupabasePetProfileRepository,
    SupabaseReminderRepository,
)
from packages.shared.config.settings import Settings, get_settings


class ApplicationContainer:
    def __init__(self, settings: Settings) -> None:
        self.settings = settings
        self.auth_provider = self._build_auth_provider()
        (
            self.pet_profile_repository,
            self.conversation_repository,
            self.reminder_repository,
        ) = self._build_repositories()
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

    def _build_auth_provider(self) -> AuthProvider:
        if self.settings.auth_backend == "supabase":
            return SupabaseAuthProvider(
                public_client=build_supabase_public_client(self.settings),
                admin_client=build_supabase_client(self.settings),
            )
        return BootstrapAuthProvider(self.settings)

    def _build_repositories(
        self,
    ) -> tuple[
        InMemoryPetProfileRepository | SupabasePetProfileRepository,
        InMemoryConversationRepository | SupabaseConversationRepository,
        InMemoryReminderRepository | SupabaseReminderRepository,
    ]:
        if self.settings.persistence_backend == "supabase":
            client = build_supabase_client(self.settings)
            return (
                SupabasePetProfileRepository(client),
                SupabaseConversationRepository(client),
                SupabaseReminderRepository(client),
            )
        return (
            InMemoryPetProfileRepository(),
            InMemoryConversationRepository(),
            InMemoryReminderRepository(),
        )


@lru_cache(maxsize=1)
def get_container() -> ApplicationContainer:
    return ApplicationContainer(get_settings())


def reset_container() -> None:
    get_container.cache_clear()
