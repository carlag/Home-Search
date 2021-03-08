import logging
from typing import Optional

from sqlalchemy.orm import Session

from app.models.property_ import PropertyModel
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
        LOGGER.info(f"Request id '{request_id}' already in DB. Response data is\n'{result.response}'")
        return PropertyList.parse_obj(result.response) if result.response else None
    else:
        LOGGER.info(f"Request id '{request_id}' is not yet in the DB.")
        return None
