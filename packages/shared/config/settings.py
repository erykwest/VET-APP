from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    environment: str = Field(default="development", alias="ENVIRONMENT")
    app_name: str = Field(default="Vet App", alias="APP_NAME")
    api_host: str = Field(default="127.0.0.1", alias="API_HOST")
    api_port: int = Field(default=8000, alias="API_PORT")
    persistence_backend: str = Field(default="in_memory", alias="PERSISTENCE_BACKEND")
    auth_backend: str = Field(default="bootstrap", alias="AUTH_BACKEND")
    database_url: str = Field(default="", alias="DATABASE_URL")
    supabase_url: str = Field(default="", alias="SUPABASE_URL")
    supabase_anon_key: str = Field(default="", alias="SUPABASE_ANON_KEY")
    supabase_service_role_key: str = Field(default="", alias="SUPABASE_SERVICE_ROLE_KEY")
    supabase_db_host: str = Field(default="", alias="SUPABASE_DB_HOST")
    supabase_db_port: int = Field(default=5432, alias="SUPABASE_DB_PORT")
    supabase_db_name: str = Field(default="postgres", alias="SUPABASE_DB_NAME")
    supabase_db_user: str = Field(default="", alias="SUPABASE_DB_USER")
    supabase_db_password: str = Field(default="", alias="SUPABASE_DB_PASSWORD")
    bootstrap_user_id: str = Field(default="demo-user", alias="BOOTSTRAP_USER_ID")
    bootstrap_user_email: str = Field(default="demo@vetapp.local", alias="BOOTSTRAP_USER_EMAIL")
    llm_provider: str = Field(default="echo", alias="LLM_PROVIDER")
    llm_model: str = Field(default="demo-model", alias="LLM_MODEL")
    llm_api_key: str = Field(default="", alias="LLM_API_KEY")
    log_level: str = Field(default="INFO", alias="LOG_LEVEL")
    enable_telemetry: bool = Field(default=False, alias="ENABLE_TELEMETRY")


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings()


def reset_settings() -> None:
    get_settings.cache_clear()
