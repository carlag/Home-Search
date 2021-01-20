import logging
from typing import Optional, List

from sqlalchemy.orm import Session

from app.models.property_ import PropertyModel, SaveMark

LOGGER = logging.getLogger()


def check_if_property_marked(db: Session, listing_id: str) -> Optional[SaveMark]:
    property_ = db.query(PropertyModel).filter_by(listing_id=listing_id).first()
    if property_:
        save_mark = property_.mark
        if save_mark:
            return SaveMark(save_mark)
    return None


def save_property_mark(db: Session, listing_id: str, save_mark: SaveMark) -> None:
    LOGGER.info(f"Marking property {listing_id} as {save_mark.value}")
    property_ = db.query(PropertyModel).filter_by(listing_id=listing_id).first()
    if property_:
        property_.mark = save_mark
        db.commit()
    else:
        LOGGER.warning(f"Attempting to mark uncached property '{listing_id}' as {save_mark.value}")


def get_all_liked_property_ids(db: Session) -> List[str]:
    properties = db.query(PropertyModel).filter_by(mark=SaveMark.LIKE).all()
    return [property_.listing_id for property_ in properties] if properties else []
