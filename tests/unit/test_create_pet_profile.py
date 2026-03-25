from packages.core.application.services.create_pet_profile import (
    CreatePetProfileInput,
    CreatePetProfileService,
)
from packages.infrastructure.persistence.in_memory_repositories import InMemoryPetProfileRepository


def test_create_pet_profile() -> None:
    service = CreatePetProfileService(InMemoryPetProfileRepository())

    result = service.execute(
        CreatePetProfileInput(owner_id="user-1", name="Milo", species="dog", breed="Beagle")
    )

    assert result.pet_profile.owner_id == "user-1"
    assert result.pet_profile.name == "Milo"
