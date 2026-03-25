from typing import Protocol

from packages.core.domain.conversation.models import Conversation


class ConversationRepository(Protocol):
    def save(self, conversation: Conversation) -> Conversation: ...

    def get(self, conversation_id: str) -> Conversation | None: ...

    def list_by_owner(self, owner_id: str) -> list[Conversation]: ...
