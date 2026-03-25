from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    environment: str = Field(default="development", alias="ENVIRONMENT")
    app_name: str = Field(default="Vet App", alias="APP_NAME")
    api_host: str = Field(default="127.0.0.1", alias="API_HOST")
    api_port: int = Field(default=8000, alias="API_PORT")
    supabase_url: str = Field(default="", alias="SUPABASE_URL")
    supabase_anon_key: str = Field(default="", alias="SUPABASE_ANON_KEY")
    supabase_service_role_key: str = Field(default="", alias="SUPABASE_SERVICE_ROLE_KEY")
    llm_provider: str = Field(default="echo", alias="LLM_PROVIDER")
    llm_model: str = Field(default="demo-model", alias="LLM_MODEL")
    llm_api_key: str = Field(default="", alias="LLM_API_KEY")
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")
    enable_telemetry: bool = Field(default=False, alias="ENABLE_TELEMETRY")


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()
