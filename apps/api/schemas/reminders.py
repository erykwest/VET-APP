from datetime import date

from pydantic import BaseModel


class CreateReminderRequest(BaseModel):
    pet_id: str
    title: str
    due_date: date
    notes: str | None = None
