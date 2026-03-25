from pydantic import BaseModel


class Citation(BaseModel):
    source: str
    snippet: str | None = None
