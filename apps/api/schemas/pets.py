from pydantic import BaseModel


class CreatePetProfileRequest(BaseModel):
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
