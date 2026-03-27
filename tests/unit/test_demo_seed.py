from datetime import date

from packages.infrastructure.persistence.demo_seed import build_demo_seed


def test_demo_seed_keeps_owner_and_relationships_aligned() -> None:
    seed = build_demo_seed("demo-user", today=date(2026, 3, 26))

    pet_ids = {pet["id"] for pet in seed.pet_profiles}
    assert pet_ids == {"pet-moka", "pet-oliver"}

    for pet in seed.pet_profiles:
        assert pet["owner_id"] == "demo-user"

    for conversation in seed.conversations:
        assert conversation["owner_id"] == "demo-user"
        assert conversation["pet_id"] in pet_ids
        assert len(conversation["messages"]) >= 2

    for reminder in seed.reminders:
        assert reminder["owner_id"] == "demo-user"
        assert reminder["pet_id"] in pet_ids
        assert reminder["due_date"] >= "2026-03-26"
