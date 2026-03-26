from packages.core.application.ports.evidence_retriever import EvidenceRetrievalRequest
from packages.infrastructure.llm.retrieval.supabase_evidence_retriever import (
    SupabaseEvidenceRetriever,
)


class FakeRpcRequest:
    def __init__(self, rows: list[dict[str, object]]) -> None:
        self._rows = rows

    def execute(self) -> object:
        return type("Response", (), {"data": self._rows})()


class FakeSupabaseClient:
    def __init__(self, rows: list[dict[str, object]]) -> None:
        self.rows = rows
        self.calls: list[tuple[str, dict[str, object]]] = []

    def rpc(self, function_name: str, payload: dict[str, object]) -> FakeRpcRequest:
        self.calls.append((function_name, payload))
        return FakeRpcRequest(self.rows)


def test_supabase_evidence_retriever_maps_rpc_rows_to_evidence_sources() -> None:
    client = FakeSupabaseClient(
        [
            {
                "document_id": "doc-1",
                "title": "AAHA Canine Life Stage Guidelines",
                "journal_name": "JAAHA",
                "publication_year": 2023,
                "reliability_tier": "A",
                "clinical_domain": ["preventive"],
                "species_tags": ["dog"],
                "content": "Preventive care should be adapted to age and risk exposure.",
                "canonical_url": "https://example.org/aaha-guideline",
            },
            {
                "document_id": "doc-1",
                "title": "AAHA Canine Life Stage Guidelines",
                "content": "Duplicate chunk should be collapsed.",
            },
        ]
    )
    retriever = SupabaseEvidenceRetriever(client)  # type: ignore[arg-type]

    results = retriever.retrieve(
        EvidenceRetrievalRequest(
            query="Il mio cane ha bisogno di un checkup?",
            species="dog",
            intent="preventive_care",
            max_results=3,
        )
    )

    assert len(results) == 1
    assert results[0].title == "AAHA Canine Life Stage Guidelines"
    assert results[0].tier == "A"
    assert results[0].clinical_domain == "preventive"
    assert results[0].species == "dog"
    assert client.calls[0][0] == "ai.match_source_chunks"
    assert client.calls[0][1]["match_count"] == 3
