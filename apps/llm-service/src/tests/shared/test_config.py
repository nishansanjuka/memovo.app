import os
import pytest
from src.shared.config import Settings

def test_settings_default_values():
    """Test that default values are correctly set."""
    settings = Settings()
    assert settings.MONGODB_URI == "mongodb://localhost:27017"
    assert settings.MONGODB_DB_NAME == "memovo"
    assert settings.APP_ENV == "development"

def test_settings_env_override(monkeypatch):
    """Test that environment variables override defaults."""
    monkeypatch.setenv("MONGODB_URI", "mongodb://remote:27017")
    monkeypatch.setenv("MONGODB_DB_NAME", "test_db")
    
    settings = Settings()
    assert settings.MONGODB_URI == "mongodb://remote:27017"
    assert settings.MONGODB_DB_NAME == "test_db"
