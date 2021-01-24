import logging
from datetime import datetime, timedelta

from fastapi import HTTPException, status
from google.oauth2 import id_token
from google.auth.transport.requests import Request
from jose import jwt
from passlib.context import CryptContext

from app.config import settings

LOGGER = logging.getLogger()
AuthError = HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                          detail="Incorrect username or password",
                          headers={"WWW-Authenticate": "Bearer"})


DEFAULT_EXPIRY_DELTA = timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
ALGORITHM = "HS256"


def create_access_token(subject: str, expiry_delta: timedelta = DEFAULT_EXPIRY_DELTA) -> str:
    expiry = datetime.utcnow() + expiry_delta
    to_encode = {"exp": expiry, "sub": subject}
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=ALGORITHM)
    LOGGER.info(f"Created access token: {encoded_jwt}")
    return encoded_jwt


def get_email_from_google_token(google_token: str) -> str:

    idinfo = None
    try:
        # Specify the CLIENT_ID of the app that accesses the backend:
        idinfo = id_token.verify_oauth2_token(google_token, Request(), settings.CLIENT_ID)
        if idinfo['email'] and idinfo['email_verified']:
            user_email = idinfo.get('email')
            LOGGER.info(f"Verified google token for user_email: '{user_email}'")
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST,
                                detail="Unable to validate social login")
    except ValueError as err:
        # Invalid token
        LOGGER.error(f"Encountered the following error whie trying to verify the google token: {err}")
        raise AuthError

    return user_email
