from pydantic import BaseModel

from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.pet_profile.models import PetProfile


class ListPetProfilesInput(BaseModel):
    owner_id: str


class ListPetProfilesOutput(BaseModel):
    pet_profiles: list[PetProfile]


class ListPetProfilesService:
    def __init__(self, repository: PetProfileRepository) -> None:
        self._repository = repository

    def execute(self, data: ListPetProfilesInput) -> ListPetProfilesOutput:
        return ListPetProfilesOutput(pet_profiles=self._repository.list_by_owner(data.owner_id))
