import logging
from typing import Generator, Optional

from fastapi import Depends, HTTPException, status, WebSocket, Request
from fastapi.security import OAuth2PasswordBearer
from jose import jwt
from pydantic import ValidationError
from sqlalchemy.orm import Session

from app import security
from app.config import settings
from app.database.session import SessionLocal
from app.models.access import UserModel
from app.schemas.access import TokenPayload


LOGGER = logging.getLogger()
# reusable_oauth2 = OAuth2PasswordBearer(tokenUrl=f"login/access-token")


class JWTAuth(OAuth2PasswordBearer):

    def __init__(self, **kwargs):
        super().__init__(**kwargs)

    async def __call__(self, request: Request=None, websocket: WebSocket=None) -> Optional[OAuth2PasswordBearer]:
        request = request or websocket
        if not request:
            if self.auto_error:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail="Not authenticated"
                )
            return None
        return await super().__call__(request)


reusable_oauth2 = JWTAuth(tokenUrl=f"login/access-token")


def get_db() -> Generator:
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()


def get_current_user(db: Session = Depends(get_db), token: str = Depends(reusable_oauth2)) -> UserModel:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[security.ALGORITHM])
        LOGGER.info(f"Payload: {payload}")
        token_data = TokenPayload(**payload)
    except (jwt.JWTError, ValidationError):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Could not validate credentials")
    email = token_data.sub
    LOGGER.info(f"Extracted email {email} from bearer token.")
    user = db.query(UserModel).filter_by(email=token_data.sub).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="User not found")
    return user
