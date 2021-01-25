import logging
from typing import Optional, List

from sqlalchemy.orm import Session

from app.models.property_ import PropertyModel, SaveMark, SavedModel

LOGGER = logging.getLogger()


def check_if_property_marked(db: Session, listing_id: str, user_email: str) -> Optional[SaveMark]:
    property_ = (db
                 .query(PropertyModel)
                 .join(SavedModel)
                 .filter(PropertyModel.listing_id == listing_id,
                         SavedModel.user_email == user_email)
                 .first())
    if property_:
        LOGGER.debug(f"Property: {property_}\nproperty_.marks: {property_.marks[0]}")
        return SaveMark(property_.marks[0].mark)
    else:
        return None


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
    properties = (db
                  .query(PropertyModel)
                  .join(SavedModel)
                  .filter(SavedModel.mark == SaveMark.LIKE,
                          SavedModel.user_email == user_email)
                  .all())
    return [property_.listing_id for property_ in properties] if properties else []
