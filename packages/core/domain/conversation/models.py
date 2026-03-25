from datetime import datetime

from pydantic import BaseModel, Field

from packages.core.domain.common.entity import new_id, utc_now


class ChatMessage(BaseModel):
    id: str = Field(default_factory=new_id)
    role: str
    content: str
    created_at: datetime = Field(default_factory=utc_now)


class Conversation(BaseModel):
    id: str = Field(default_factory=new_id)
    owner_id: str
    pet_id: str
    title: str
    messages: list[ChatMessage] = Field(default_factory=list)
