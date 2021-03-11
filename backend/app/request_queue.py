import json
import logging
from typing import Optional

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.request import RequestModel
from app.schemas.property_ import PropertyList

LOGGER = logging.getLogger()


def is_request_in_db(db: Session, request_id: str) -> bool:
    result = db.query(RequestModel).filter_by(request_id=request_id).first()
    if result:
        LOGGER.info(f"Request id '{request_id}' already in DB.")
        return True
    else:
        LOGGER.info(f"Request id '{request_id}' is not yet in the DB.")
        return False


def get_data_for_request(db: Session, request_id: str) -> Optional[PropertyList]:
    result = db.query(RequestModel).filter_by(request_id=request_id).first()
    if result:
        if result.error:
            LOGGER.info(f"Request id '{request_id}' already in DB, but has returned an error: '{result.error}'")
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                                detail="The following error was encountered while trying to get the property"
                                       f" data for request '{request_id}': {result.error}")
        if result.response:
            LOGGER.info(f"Request id '{request_id}' already in DB. Response data is\n'{result.response}'")
            return PropertyList.parse_obj(json.loads(result.response))
        else:
            LOGGER.info(f"Request id '{request_id}' already in DB, but there is no response yet.")
            return None
    else:
        LOGGER.info(f"Request id '{request_id}' is not yet in the DB.")
        return None
