from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Centralized configuration for the LLM service.
    # Loads from environment variables or .env file.
    MONGODB_URI: str = Field(default="mongodb://localhost:27017")
    MONGODB_DB_NAME: str = Field(default="memovo")

    APP_ENV: str = Field(default="development")
    APP_PORT: int = Field(default=8000)

    ALLOWED_ORIGINS: list[str] = Field(default=["*"])

    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", extra="ignore"
    )


settings = Settings()
