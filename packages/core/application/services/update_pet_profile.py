from pydantic import BaseModel

from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.pet_profile.models import PetProfile
from packages.shared.errors.base import ValidationError


class UpdatePetProfileInput(BaseModel):
    pet_id: str
    name: str
    species: str
    breed: str | None = None
    age_years: int | None = None
    notes: str | None = None


class UpdatePetProfileOutput(BaseModel):
    pet_profile: PetProfile


class UpdatePetProfileService:
    def __init__(self, repository: PetProfileRepository) -> None:
        self._repository = repository

    def execute(self, data: UpdatePetProfileInput) -> UpdatePetProfileOutput:
        pet_profile = self._repository.get(data.pet_id)
        if pet_profile is None:
            raise ValidationError("pet_profile not found")

        updated = pet_profile.model_copy(update=data.model_dump(exclude={"pet_id"}))
        return UpdatePetProfileOutput(pet_profile=self._repository.save(updated))
