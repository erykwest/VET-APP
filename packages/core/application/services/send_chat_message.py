from pydantic import BaseModel

from packages.core.application.ports.conversation_repository import ConversationRepository
from packages.core.application.ports.llm_client import LLMClient
from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.conversation.models import ChatMessage, Conversation
from packages.shared.errors.base import ValidationError


class SendChatMessageInput(BaseModel):
    owner_id: str
    pet_id: str
    conversation_id: str | None = None
    user_message: str


class SendChatMessageOutput(BaseModel):
    conversation: Conversation
    reply: ChatMessage
    provider: str
    model: str


class SendChatMessageService:
    def __init__(
        self,
        repository: ConversationRepository,
        llm_client: LLMClient,
        pet_profile_repository: PetProfileRepository,
    ) -> None:
        self._repository = repository
        self._llm_client = llm_client
        self._pet_profile_repository = pet_profile_repository

    def execute(self, data: SendChatMessageInput) -> SendChatMessageOutput:
        if not data.user_message.strip():
            raise ValidationError("user_message must not be empty")
        if self._pet_profile_repository.get(data.pet_id) is None:
            raise ValidationError("pet_profile not found")

        conversation = self._load_or_create_conversation(data)
        user_message = ChatMessage(role="user", content=data.user_message.strip())
        conversation.messages.append(user_message)

        llm_response = self._llm_client.generate_reply(conversation.messages)
        reply = ChatMessage(role="assistant", content=llm_response.content)
        conversation.messages.append(reply)

        stored_conversation = self._repository.save(conversation)
        return SendChatMessageOutput(
            conversation=stored_conversation,
            reply=reply,
            provider=llm_response.provider,
            model=llm_response.model,
        )

    def _load_or_create_conversation(self, data: SendChatMessageInput) -> Conversation:
        if data.conversation_id:
            stored = self._repository.get(data.conversation_id)
            if stored:
                return stored
            raise ValidationError("conversation not found")
        return Conversation(owner_id=data.owner_id, pet_id=data.pet_id, title=f"Chat for {data.pet_id}")
