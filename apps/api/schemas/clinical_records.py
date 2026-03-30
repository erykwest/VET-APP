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


class UploadClinicalDocumentRequest(BaseModel):
    title: str
    document_type: str
    document_date: str
    filename: str
    content_base64: str
    content_type: str | None = None
    summary: str | None = None
    source: str | None = None
    extracted_text_summary: str | None = None
    status: str = "uploaded"
    verified_by_user: bool = False


class CreateClinicalEventRequest(BaseModel):
    event_type: str
    title: str
    event_date: str
    summary: str | None = None
    severity: str | None = None
    source: str | None = None
    linked_document_id: str | None = None


class UpdateClinicalEventRequest(BaseModel):
    event_type: str | None = None
    title: str | None = None
    event_date: str | None = None
    summary: str | None = None
    severity: str | None = None
    source: str | None = None
    linked_document_id: str | None = None
