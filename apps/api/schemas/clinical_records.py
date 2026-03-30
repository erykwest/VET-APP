from pydantic import BaseModel


class UpdatePetHealthProfileRequest(BaseModel):
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


class CreateClinicalDocumentRequest(BaseModel):
    title: str
    document_type: str
    document_date: str
    summary: str | None = None
    source: str | None = None
    file_path: str | None = None
    original_filename: str | None = None
    extracted_text_summary: str | None = None
    status: str = "uploaded"
    verified_by_user: bool = False
