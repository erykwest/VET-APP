from pydantic import BaseModel

from packages.core.application.ports.pet_profile_repository import PetProfileRepository
from packages.core.domain.pet_profile.models import PetProfile
from packages.shared.errors.base import ValidationError


class GetPetHealthProfileInput(BaseModel):
    owner_id: str
    pet_id: str


class GetPetHealthProfileOutput(BaseModel):
    pet_profile: PetProfile


class GetPetHealthProfileService:
    def __init__(self, repository: PetProfileRepository) -> None:
        self._repository = repository

    def execute(self, data: GetPetHealthProfileInput) -> GetPetHealthProfileOutput:
        pet_profile = self._repository.get(data.pet_id)
        if pet_profile is None or pet_profile.owner_id != data.owner_id:
            raise ValidationError("pet_profile not found")
        return GetPetHealthProfileOutput(pet_profile=pet_profile)
