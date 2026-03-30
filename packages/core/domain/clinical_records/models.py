from datetime import UTC, date, datetime

from pydantic import BaseModel, Field

from packages.core.domain.common.entity import new_id


class ClinicalDocument(BaseModel):
    id: str = Field(default_factory=new_id)
    owner_id: str
    pet_id: str
    title: str
    document_type: str
    document_date: date
    summary: str | None = None
    source: str | None = None
    file_path: str | None = None
    original_filename: str | None = None
    extracted_text_summary: str | None = None
    status: str = "uploaded"
    verified_by_user: bool = False
    created_at: datetime = Field(default_factory=lambda: datetime.now(UTC))


class ClinicalTimelineItem(BaseModel):
    id: str
    pet_id: str
    entry_type: str
    title: str
    event_date: date
    summary: str | None = None
    source_label: str | None = None
    related_document_id: str | None = None
