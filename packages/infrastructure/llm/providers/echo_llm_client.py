from packages.core.application.ports.llm_client import LLMClient, LLMResponse
from packages.core.domain.conversation.models import ChatMessage
from packages.shared.config.settings import Settings


class EchoLLMClient(LLMClient):
    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    def generate_reply(self, messages: list[ChatMessage]) -> LLMResponse:
        latest = messages[-1].content if messages else ""
        content = f"Demo reply for: {latest}"
        return LLMResponse(
            content=content,
            provider=self._settings.llm_provider,
            model=self._settings.llm_model,
            token_count=len(content.split()),
        )
