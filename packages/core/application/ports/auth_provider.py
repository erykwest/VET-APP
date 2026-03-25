from typing import Protocol

from pydantic import BaseModel


class AuthenticatedUser(BaseModel):
    id: str
    email: str


class AuthProvider(Protocol):
    def get_current_user(self) -> AuthenticatedUser: ...
