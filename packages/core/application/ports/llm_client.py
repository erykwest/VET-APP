from typing import Protocol

from pydantic import BaseModel

from packages.core.domain.conversation.models import ChatMessage


class LLMResponse(BaseModel):
    content: str
    provider: str
    model: str
    token_count: int


class LLMClient(Protocol):
    def generate_reply(self, messages: list[ChatMessage]) -> LLMResponse: ...
