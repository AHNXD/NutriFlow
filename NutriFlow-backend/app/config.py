from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Loaded from environment variables / a local .env file (see .env.example).

    SUPABASE_SERVICE_ROLE_KEY is used (not the anon key) because this service
    runs server-side only and needs to read data regardless of the v1
    permissive-but-still-real RLS policies in supabase/schema.sql.
    """

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    supabase_url: str = ""
    supabase_service_role_key: str = ""

    @property
    def is_configured(self) -> bool:
        return bool(self.supabase_url and self.supabase_service_role_key)


@lru_cache
def get_settings() -> Settings:
    return Settings()
