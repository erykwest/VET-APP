from pydantic import BaseModel

from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.pet_profile.models import PetProfile
from packages.shared.errors.base import ValidationError


class UpdatePetHealthProfileInput(BaseModel):
    owner_id: str
    pet_id: str
    name: str | None = None
    species: str | None = None
    breed: str | None = None
    age_years: int | None = None
    birth_date: str | None = None
    sex: str | None = None
    weight_kg: float | None = None
    microchip_code: str | None = None
    neutered: bool | None = None
    notes: str | None = None


class UpdatePetHealthProfileOutput(BaseModel):
    pet_profile: PetProfile


class UpdatePetHealthProfileService:
    def __init__(self, repository: PetProfileRepository) -> None:
        self._repository = repository

    def execute(self, data: UpdatePetHealthProfileInput) -> UpdatePetHealthProfileOutput:
        pet_profile = self._repository.get(data.pet_id)
        if pet_profile is None or pet_profile.owner_id != data.owner_id:
            raise ValidationError("pet_profile not found")

        updates = data.model_dump(exclude={"owner_id", "pet_id"}, exclude_unset=True)
        updated = pet_profile.model_copy(update=updates)
        return UpdatePetHealthProfileOutput(pet_profile=self._repository.save(updated))
