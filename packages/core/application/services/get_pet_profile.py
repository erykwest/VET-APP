from pydantic import BaseModel

from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.pet_profile.models import PetProfile
from packages.shared.errors.base import ValidationError


class GetPetProfileInput(BaseModel):
    pet_id: str


class GetPetProfileOutput(BaseModel):
    pet_profile: PetProfile


class GetPetProfileService:
    def __init__(self, repository: PetProfileRepository) -> None:
        self._repository = repository

    def execute(self, data: GetPetProfileInput) -> GetPetProfileOutput:
        pet_profile = self._repository.get(data.pet_id)
        if pet_profile is None:
            raise ValidationError("pet_profile not found")
        return GetPetProfileOutput(pet_profile=pet_profile)
