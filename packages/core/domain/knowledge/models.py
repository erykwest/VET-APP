from pydantic import BaseModel


class Citation(BaseModel):
    source: str
    snippet: str | None = None


class EvidenceSource(BaseModel):
    title: str
    journal: str | None = None
    year: int | None = None
    doi: str | None = None
    pmid: str | None = None
    tier: str = "C"
    clinical_domain: str = "general"
    species: str = "other"
    snippet: str | None = None
    source_url: str | None = None
