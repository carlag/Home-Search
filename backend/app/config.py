from typing import Optional, Dict, Any

from pydantic import BaseSettings, PostgresDsn, validator


class Settings(BaseSettings):
    # Environment variables (note these are read from the env var names defined in the Config class below)
    GOOGLE_MAPS_API_KEY: str
    ZOOPLA_API_KEY: str

    # Auth settings
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 90
    CLIENT_ID = "549789804729-s97gvsa0cu8k7kup7v65rp9quqafob51.apps.googleusercontent.com"
    # SECRET_KEY created using `openssl rand -hex 32`
    SECRET_KEY = "0f5bcfd8eaa37181983f87753cedee1ec027568282cb13e53c14ce294b30cbd8"

    # SQL settings
    POSTGRES_SERVER: str = "db"
    POSTGRES_USER: str = "admin"
    POSTGRES_PASSWORD: str  # Note this is an environment variable
    POSTGRES_DB: str = "homesearch"
    DATABASE_URL: Optional[PostgresDsn]  # Heroku sets this as an env var,
                                         # for local dev set the password above instead

    @validator("DATABASE_URL", pre=True)
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

    class Config:
        fields = {
            "GOOGLE_MAPS_API_KEY": {"env": "GOOGLEMAPSAPIKEY"},
            "ZOOPLA_API_KEY": {"env": "ZOOPLAAPIKEY"},
            "POSTGRES_PASSWORD": {"env": "POSTGRES_PASSWORD"},
        }


settings = Settings()
