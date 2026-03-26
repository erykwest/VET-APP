from packages.core.application.ports.llm_client import LLMGenerationRequest, LLMResponse
from packages.core.application.services.chat_orchestrator import (
    ChatOrchestrator,
    ChatOrchestratorInput,
)
from packages.infrastructure.llm.retrieval.in_memory_evidence_retriever import InMemoryEvidenceRetriever


class FakeLLMClient:
    def __init__(self) -> None:
        self.requests: list[LLMGenerationRequest] = []

    def generate(self, request: LLMGenerationRequest) -> LLMResponse:
        self.requests.append(request)
        return LLMResponse(
            content="Risposta sintetica con fonti.",
            provider="fake",
            model="fake-model",
            token_count=12,
            finish_reason="stop",
        )


def test_chat_orchestrator_blocks_to_triage_on_red_flags() -> None:
    client = FakeLLMClient()
    orchestrator = ChatOrchestrator(client, InMemoryEvidenceRetriever())

    result = orchestrator.answer(
        ChatOrchestratorInput(
            user_message="Il gatto ha un collasso improvviso",
            species="cat",
            pet_name="Luna",
        )
    )

    assert result.mode == "triage"
    assert result.provider == "rule-based"
    assert not client.requests


def test_chat_orchestrator_requires_sources_for_evidence_mode() -> None:
    client = FakeLLMClient()
    orchestrator = ChatOrchestrator(client, InMemoryEvidenceRetriever())

    result = orchestrator.answer(
        ChatOrchestratorInput(
            user_message="Il mio gatto vomita da due giorni, cosa posso fare?",
            species="cat",
            pet_name="Luna",
        )
    )

    assert result.mode == "evidence"
    assert result.provider == "rule-based"
    assert not result.sources
    assert not client.requests


def test_chat_orchestrator_uses_llm_when_sources_are_available() -> None:
    client = FakeLLMClient()
    orchestrator = ChatOrchestrator(client, InMemoryEvidenceRetriever())

    result = orchestrator.answer(
        ChatOrchestratorInput(
            user_message="Il mio cane tossisce da due giorni",
            species="dog",
            pet_name="Milo",
        )
    )

    assert result.mode == "evidence"
    assert result.provider == "fake"
    assert result.sources
    assert client.requests
