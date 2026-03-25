from pydantic import BaseModel

from packages.core.application.ports.conversation_repository import ConversationRepository
from packages.core.domain.conversation.models import Conversation


class ListConversationsInput(BaseModel):
    owner_id: str


class ListConversationsOutput(BaseModel):
    conversations: list[Conversation]


class ListConversationsService:
    def __init__(self, repository: ConversationRepository) -> None:
        self._repository = repository

    def execute(self, data: ListConversationsInput) -> ListConversationsOutput:
        return ListConversationsOutput(conversations=self._repository.list_by_owner(data.owner_id))
