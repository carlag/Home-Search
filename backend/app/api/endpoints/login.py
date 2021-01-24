import logging
from typing import Any, Dict

from fastapi import APIRouter, Depends
from requests import Session

from app.api.deps import get_db
from app.schemas.access import Token
from app.security import create_access_token, get_email_from_google_token

LOGGER = logging.getLogger()
router = APIRouter()


@router.post("/login/swap-tokens", response_model=Token)
def login_access_token(*, db: Session = Depends(get_db), google_token) -> Dict[str, Any]:
    """
    Authenticate a Google token, and return an access token for future requests
    """
    LOGGER.info("Swapping tokens")
    user_email = get_email_from_google_token(google_token)
    LOGGER.info(f"(swap-tokens) user_email: {user_email}")
    # TODO: Add user to DB

    return {
        "access_token": create_access_token(user_email),
        "token_type": "bearer",
    }
