from packages.infrastructure.llm.sources.registry_seed import build_initial_seed_catalog


def test_registry_seed_catalog_contains_expected_registries_and_domains() -> None:
    catalog = build_initial_seed_catalog()

    registry_keys = {row["registry_key"] for row in catalog["registries"]}
    domain_hosts = {row["host"] for row in catalog["domains"]}

    assert {"ooir_jif", "research_com", "pjip_sjr", "avma_direct"} <= registry_keys
    assert {"ooir.org", "research.com", "pjip.org", "avmajournals.avma.org"} <= domain_hosts


def test_registry_seed_catalog_marks_ranking_sites_as_discovery_only() -> None:
    catalog = build_initial_seed_catalog()
    domains = {row["host"]: row for row in catalog["domains"]}

    assert domains["ooir.org"]["discovery_only"] is True
    assert domains["research.com"]["allowed_for_direct_ingest"] is False
    assert domains["pjip.org"]["allowed_for_direct_ingest"] is False
    assert domains["avmajournals.avma.org"]["allowed_for_direct_ingest"] is True
