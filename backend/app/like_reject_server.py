import logging
from typing import Optional, List
from urllib.parse import urljoin, urlparse, unquote

from sqlalchemy.orm import Session

from app.models.property_ import PropertyModel, SaveMark

LOGGER = logging.getLogger()


def check_if_property_marked(db: Session, listing_url: str) -> Optional[SaveMark]:
    listing_id = _extract_listing_id_from_listing_url(listing_url)
    property_ = db.query(PropertyModel).filter_by(listing_id=listing_id).first()
    if property_:
        save_mark = property_.mark
        if save_mark:
            LOGGER.info(f"Property {listing_id} already marked as {save_mark}")
            return SaveMark(save_mark)
    return None


def save_property_mark(db: Session, listing_url: str, save_mark: SaveMark) -> None:

    listing_id = _extract_listing_id_from_listing_url(listing_url)
    LOGGER.info(f"Marking property {listing_id} as {save_mark.value}")
    property_ = db.query(PropertyModel).filter_by(listing_id=listing_id).first()
    property_.mark = save_mark
    db.commit()


def get_all_liked_property_ids(db: Session) -> List[str]:
    properties = db.query(PropertyModel).filter_by(mark=SaveMark.LIKE).all()
    return [property_.listing_id for property_ in properties]


def _extract_listing_id_from_listing_url(listing_url: str) -> str:
    decoded_url = unquote(listing_url)
    url_no_query = urljoin(decoded_url, urlparse(decoded_url).path)
    listing_id = url_no_query.rsplit("/", 1)[-1]
    try:
        int(listing_id)
    except ValueError as err:
        raise ValueError(f"Failed to extract listing_id from listing URL {listing_url}: {err}")
    return listing_id
