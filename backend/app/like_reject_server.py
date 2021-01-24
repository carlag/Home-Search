import logging
from typing import Optional, List

from sqlalchemy.orm import Session

from app.models.property_ import PropertyModel, SaveMark, SavedModel

LOGGER = logging.getLogger()


def check_if_property_marked(db: Session, listing_id: str, user_email: str) -> Optional[SaveMark]:
    result = (db
              .query(PropertyModel)
              .join(SavedModel)
              .filter(PropertyModel.listing_id == listing_id,
                      SavedModel.user_email == user_email)
              .first())
    if not result or type(result) == PropertyModel:
        return None
    else:
        LOGGER.info(f"result: {result}")
        LOGGER.info(f"result __dir__: {result.__dir__()}")
        property_, saved = result
        SaveMark(saved.mark)


def save_property_mark(db: Session, listing_id: str, user_email: str, save_mark: SaveMark) -> None:
    LOGGER.info(f"Marking property {listing_id} as {save_mark.value} for user {user_email}")
    property_ = db.query(PropertyModel).filter_by(listing_id=listing_id).first()
    if property_:
        saved_model = SavedModel(user_email=user_email, listing_id=listing_id, mark=save_mark)
        db.add(saved_model)
        db.commit()
    else:
        LOGGER.warning(f"Attempting to mark uncached property '{listing_id}' as {save_mark.value}")


def get_all_liked_property_ids(db: Session, user_email: str) -> List[str]:
    properties, saved = (db
                         .query(PropertyModel)
                         .join(SavedModel)
                         .filter(SavedModel.mark == SaveMark.LIKE,
                                 SavedModel.user_email == user_email)
                         .all())
    return [property_.listing_id for property_ in properties] if properties else []
