from typing import Optional, Dict, Any

from pydantic import BaseSettings, PostgresDsn, validator


class Settings(BaseSettings):
    # Note BaseSettings will read attributes from environment variables
    POSTGRES_SERVER: str = "db"
    POSTGRES_USER: str = "admin"
    POSTGRES_PASSWORD: str
    POSTGRES_DB: str = "homesearch"
    SQLALCHEMY_DATABASE_URI: Optional[PostgresDsn] = None

    @validator("SQLALCHEMY_DATABASE_URI", pre=True)
    def assemble_db_connection(cls, v: Optional[str], values: Dict[str, Any]) -> Any:
        if isinstance(v, str):
            return v
        return PostgresDsn.build(
            scheme="postgresql",
            user=values.get("POSTGRES_USER"),
            password=values.get("POSTGRES_PASSWORD"),
            host=values.get("POSTGRES_SERVER"),
            path=f"/{values.get('POSTGRES_DB') or ''}",
        )

    GOOGLE_MAPS_API_KEY: str
    ZOOPLA_API_KEY: str

    class Config:
        fields = {
            "GOOGLE_MAPS_API_KEY": {"env": "GOOGLEMAPSAPIKEY"},
            "ZOOPLA_API_KEY": {"env": "ZOOPLAAPIKEY"},
        }


settings = Settings()
