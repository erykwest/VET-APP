from typing import Protocol

from packages.core.domain.pet_profile.models import PetProfile


class PetProfileRepository(Protocol):
    def save(self, pet_profile: PetProfile) -> PetProfile: ...

    def get(self, pet_id: str) -> PetProfile | None: ...

    def list_by_owner(self, owner_id: str) -> list[PetProfile]: ...
