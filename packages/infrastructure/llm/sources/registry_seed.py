from __future__ import annotations

import json
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any


@dataclass(frozen=True)
class RegistrySeed:
    registry_key: str
    display_name: str
    registry_kind: str
    metric_name: str
    normalization_strategy: str
    weight: float
    source_url: str
    notes: str


@dataclass(frozen=True)
class DomainSeed:
    host: str
    display_name: str
    base_url: str
    source_kind: str
    discovery_only: bool
    allowed_for_direct_ingest: bool
    authority_score: float
    direct_source_score: float
    veterinary_relevance_score: float
    evidence_policy: str
    notes: str


@dataclass(frozen=True)
class RegistryEntrySeed:
    registry_key: str
    host: str
    journal_title: str
    raw_rank: int | None = None
    registry_size: int | None = None
    raw_metric_name: str | None = None
    raw_metric_value: float | None = None
    normalized_percentile: float | None = None
    source_url: str | None = None


INITIAL_REGISTRIES: tuple[RegistrySeed, ...] = (
    RegistrySeed(
        registry_key="ooir_jif",
        display_name="OOIR JIF Ranking",
        registry_kind="ranking",
        metric_name="jif",
        normalization_strategy="rank_percentile",
        weight=0.350,
        source_url=(
            "https://ooir.org/journals.php?field=Plant+%26+Animal+Science"
            "&category=Veterinary+Sciences&metric=jif"
        ),
        notes="Ranking secondario, utile per discovery e confronto tra journal.",
    ),
    RegistrySeed(
        registry_key="research_com",
        display_name="Research.com Veterinary Ranking",
        registry_kind="ranking",
        metric_name="estimated_h_index",
        normalization_strategy="rank_percentile",
        weight=0.350,
        source_url="https://research.com/journals-rankings/animal-science-and-veterinary",
        notes="Ranking secondario basato su metodologia proprietaria.",
    ),
    RegistrySeed(
        registry_key="pjip_sjr",
        display_name="PJIP Veterinary Ranking",
        registry_kind="ranking",
        metric_name="sjr",
        normalization_strategy="rank_percentile",
        weight=0.300,
        source_url="https://www.pjip.org/Veterinary-journal-rankings.html",
        notes="Usare una sola metrica base per evitare doppio conteggio.",
    ),
    RegistrySeed(
        registry_key="avma_direct",
        display_name="AVMA Journals Direct Source",
        registry_kind="direct_source",
        metric_name="editorial_authority",
        normalization_strategy="manual",
        weight=0.000,
        source_url="https://avmajournals.avma.org",
        notes="Fonte diretta primaria, non confrontabile come ranking.",
    ),
)

INITIAL_DOMAINS: tuple[DomainSeed, ...] = (
    DomainSeed(
        host="pubmed.ncbi.nlm.nih.gov",
        display_name="PubMed",
        base_url="https://pubmed.ncbi.nlm.nih.gov",
        source_kind="knowledge_base",
        discovery_only=True,
        allowed_for_direct_ingest=False,
        authority_score=0.980,
        direct_source_score=0.850,
        veterinary_relevance_score=0.850,
        evidence_policy="allow_auto_ingest",
        notes="Indicizzazione primaria per abstract e metadata biomedici.",
    ),
    DomainSeed(
        host="pmc.ncbi.nlm.nih.gov",
        display_name="PubMed Central",
        base_url="https://pmc.ncbi.nlm.nih.gov",
        source_kind="knowledge_base",
        discovery_only=False,
        allowed_for_direct_ingest=True,
        authority_score=0.990,
        direct_source_score=0.920,
        veterinary_relevance_score=0.850,
        evidence_policy="allow_auto_ingest",
        notes="Preferibile per full text open access.",
    ),
    DomainSeed(
        host="wsava.org",
        display_name="WSAVA",
        base_url="https://wsava.org",
        source_kind="association",
        discovery_only=False,
        allowed_for_direct_ingest=True,
        authority_score=0.950,
        direct_source_score=0.980,
        veterinary_relevance_score=0.980,
        evidence_policy="allow_manual_docs",
        notes="Guideline e position statement di alto valore pratico.",
    ),
    DomainSeed(
        host="aaha.org",
        display_name="AAHA",
        base_url="https://www.aaha.org",
        source_kind="association",
        discovery_only=False,
        allowed_for_direct_ingest=True,
        authority_score=0.930,
        direct_source_score=0.960,
        veterinary_relevance_score=0.960,
        evidence_policy="allow_manual_docs",
        notes="Fonte utile per guideline e standard clinici companion animals.",
    ),
    DomainSeed(
        host="merckvetmanual.com",
        display_name="Merck Veterinary Manual",
        base_url="https://www.merckvetmanual.com",
        source_kind="knowledge_base",
        discovery_only=False,
        allowed_for_direct_ingest=True,
        authority_score=0.900,
        direct_source_score=0.880,
        veterinary_relevance_score=0.970,
        evidence_policy="allow_manual_docs",
        notes="Knowledge base secondaria, non sostituisce guideline o review.",
    ),
    DomainSeed(
        host="ooir.org",
        display_name="OOIR",
        base_url="https://ooir.org",
        source_kind="other",
        discovery_only=True,
        allowed_for_direct_ingest=False,
        authority_score=0.250,
        direct_source_score=0.100,
        veterinary_relevance_score=0.250,
        evidence_policy="curated_only",
        notes="Discovery/ranking source only. Non usare come evidenza clinica diretta.",
    ),
    DomainSeed(
        host="research.com",
        display_name="Research.com",
        base_url="https://research.com",
        source_kind="other",
        discovery_only=True,
        allowed_for_direct_ingest=False,
        authority_score=0.250,
        direct_source_score=0.100,
        veterinary_relevance_score=0.250,
        evidence_policy="curated_only",
        notes="Discovery/ranking source only. Non usare come evidenza clinica diretta.",
    ),
    DomainSeed(
        host="pjip.org",
        display_name="PJIP",
        base_url="https://www.pjip.org",
        source_kind="other",
        discovery_only=True,
        allowed_for_direct_ingest=False,
        authority_score=0.250,
        direct_source_score=0.100,
        veterinary_relevance_score=0.250,
        evidence_policy="curated_only",
        notes="Discovery/ranking source only. Non usare come evidenza clinica diretta.",
    ),
    DomainSeed(
        host="avmajournals.avma.org",
        display_name="AVMA Journals",
        base_url="https://avmajournals.avma.org",
        source_kind="journal",
        discovery_only=False,
        allowed_for_direct_ingest=True,
        authority_score=0.960,
        direct_source_score=0.980,
        veterinary_relevance_score=0.950,
        evidence_policy="allow_manual_docs",
        notes="Fonte diretta primaria per articoli JAVMA e altri journal AVMA.",
    ),
)

INITIAL_REGISTRY_ENTRIES: tuple[RegistryEntrySeed, ...] = (
    RegistryEntrySeed(
        registry_key="avma_direct",
        host="avmajournals.avma.org",
        journal_title="AVMA Journals",
        normalized_percentile=1.000,
        source_url="https://avmajournals.avma.org",
    ),
)


def build_initial_seed_catalog() -> dict[str, list[dict[str, Any]]]:
    return {
        "registries": [asdict(item) for item in INITIAL_REGISTRIES],
        "domains": [asdict(item) for item in INITIAL_DOMAINS],
        "registry_entries": [asdict(item) for item in INITIAL_REGISTRY_ENTRIES],
    }


def load_registry_entry_snapshot(path: str | Path) -> list[dict[str, Any]]:
    raw = json.loads(Path(path).read_text(encoding="utf-8"))
    if not isinstance(raw, list):
        raise ValueError("Registry snapshot must be a JSON array of entry objects.")
    return [dict(item) for item in raw]
