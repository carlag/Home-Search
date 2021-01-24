import logging
from typing import Any, Dict

from fastapi import APIRouter, Depends, Request
from fastapi.encoders import jsonable_encoder
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.models.access import UserModel
from app.schemas.access import Token
from app.security import create_access_token, get_email_from_google_token

LOGGER = logging.getLogger()
router = APIRouter()


@router.post("/login/swap-tokens", response_model=Token)
async def login_access_token(*, db: Session = Depends(get_db), request: Request = None) -> Dict[str, Any]:
    """
    Authenticate a Google token, and return an access token for future requests
    """
    LOGGER.info("Swapping tokens")
    body_bytes = await request.body()
    auth_code = jsonable_encoder(body_bytes)
    user_email = get_email_from_google_token(auth_code)

    user = db.query(UserModel).filter_by(email=user_email).first()
    if not user:
        user = UserModel(email=user_email)
        db.add(user)
        db.commit()
        LOGGER.info(f"Added user '{user}' to the DB")
    else:
        LOGGER.info(f"User '{user}' already in DB")

    token = {
        "access_token": create_access_token(user_email),
        "token_type": "bearer",
    }
    LOGGER.info(f"Returning new token: {token}")
    return token
