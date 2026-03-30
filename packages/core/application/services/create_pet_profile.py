from pydantic import BaseModel

from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.pet_profile.models import PetProfile


class CreatePetProfileInput(BaseModel):
    owner_id: str
    name: str
    species: str
    breed: str | None = None
    age_years: int | None = None
    birth_date: str | None = None
    sex: str | None = None
    weight_kg: float | None = None
    microchip_code: str | None = None
    neutered: bool | None = None
    notes: str | None = None


class CreatePetProfileOutput(BaseModel):
    pet_profile: PetProfile


class CreatePetProfileService:
    def __init__(self, repository: PetProfileRepository) -> None:
        self._repository = repository

    def execute(self, data: CreatePetProfileInput) -> CreatePetProfileOutput:
        pet_profile = PetProfile(**data.model_dump())
        return CreatePetProfileOutput(pet_profile=self._repository.save(pet_profile))
