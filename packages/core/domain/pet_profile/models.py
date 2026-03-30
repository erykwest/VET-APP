from pydantic import BaseModel, Field

from packages.core.domain.common.entity import new_id


class PetProfile(BaseModel):
    id: str = Field(default_factory=new_id)
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
