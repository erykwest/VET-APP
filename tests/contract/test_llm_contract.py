from packages.core.application.ports.llm_client import LLMGenerationRequest
from packages.infrastructure.llm.providers.echo_llm_client import EchoLLMClient
from packages.shared.config.settings import Settings


def test_llm_contract_returns_metadata() -> None:
    client = EchoLLMClient(Settings())

    response = client.generate(
        LLMGenerationRequest(system_prompt="You are helpful.", user_prompt="Hello")
    )

    assert response.provider
    assert response.model
    assert response.token_count >= 0
    assert response.finish_reason == "stop"
