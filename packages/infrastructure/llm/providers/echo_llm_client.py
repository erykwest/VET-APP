from packages.core.application.ports.llm_client import (
    LLMClient,
    LLMGenerationRequest,
    LLMResponse,
)
from packages.shared.config.settings import Settings


class EchoLLMClient(LLMClient):
    def __init__(self, settings: Settings) -> None:
        self._settings = settings

    def generate(self, request: LLMGenerationRequest) -> LLMResponse:
        content = f"Demo reply for: {request.user_prompt}"
        return LLMResponse(
            content=content,
            provider=self._settings.llm_provider,
            model=self._settings.llm_model,
            token_count=len(content.split()),
            finish_reason="stop",
        )
