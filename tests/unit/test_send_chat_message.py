import pytest

from packages.core.domain.pet_profile.models import PetProfile
from packages.core.application.services.send_chat_message import (
    SendChatMessageInput,
    SendChatMessageService,
)
from packages.infrastructure.llm.providers.echo_llm_client import EchoLLMClient
from packages.infrastructure.persistence.in_memory_repositories import (
    InMemoryConversationRepository,
    InMemoryPetProfileRepository,
)
from packages.shared.config.settings import Settings
from packages.shared.errors.base import ValidationError


def test_send_chat_message_persists_conversation() -> None:
    pet_repository = InMemoryPetProfileRepository()
    pet_repository.save(PetProfile(id="pet-1", owner_id="user-1", name="Milo", species="dog"))
    service = SendChatMessageService(
        InMemoryConversationRepository(),
        EchoLLMClient(Settings()),
        pet_repository,
    )

    result = service.execute(
        SendChatMessageInput(owner_id="user-1", pet_id="pet-1", user_message="Il mio cane tossisce")
    )

    assert len(result.conversation.messages) == 2
    assert result.reply.content.startswith("Demo reply for:")


def test_send_chat_message_rejects_empty_input() -> None:
    pet_repository = InMemoryPetProfileRepository()
    pet_repository.save(PetProfile(id="pet-1", owner_id="user-1", name="Milo", species="dog"))
    service = SendChatMessageService(
        InMemoryConversationRepository(),
        EchoLLMClient(Settings()),
        pet_repository,
    )

    with pytest.raises(ValidationError):
        service.execute(SendChatMessageInput(owner_id="user-1", pet_id="pet-1", user_message="  "))
