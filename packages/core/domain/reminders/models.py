from datetime import date

from pydantic import BaseModel, Field

from packages.core.domain.common.entity import new_id


class Reminder(BaseModel):
    id: str = Field(default_factory=new_id)
    owner_id: str
    pet_id: str
    title: str
    due_date: date
    notes: str | None = None
