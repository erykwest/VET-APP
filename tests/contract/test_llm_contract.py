from packages.infrastructure.llm.providers.echo_llm_client import EchoLLMClient
from packages.shared.config.settings import Settings


def test_llm_contract_returns_metadata() -> None:
    client = EchoLLMClient(Settings())

    response = client.generate_reply([])

    assert response.provider
    assert response.model
    assert response.token_count >= 0
