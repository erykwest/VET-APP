from pydantic import BaseModel


class AuthCredentialsRequest(BaseModel):
    email: str
    password: str
