from typing import Protocol

from pydantic import BaseModel

from packages.core.domain.knowledge.models import EvidenceSource


class EvidenceRetrievalRequest(BaseModel):
    query: str
    species: str
    intent: str
    max_results: int = 3


class EvidenceRetriever(Protocol):
    def retrieve(self, request: EvidenceRetrievalRequest) -> list[EvidenceSource]: ...
