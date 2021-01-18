import logging
from enum import Enum
from typing import Optional, List
from urllib.parse import urljoin, urlparse, unquote

from database import DB

LOGGER = logging.getLogger()


class SaveMark(str, Enum):
    LIKE = "liked"
    REJECT = "rejected"
    UNSURE = "unsure"


class PropertySaver:

    def __init__(self, db: DB):
        self.db = db

    def check_if_property_marked(self, listing_url: str) -> Optional[SaveMark]:
        listing_id = _extract_listing_id_from_listing_url(listing_url)
        save_mark = self.db.get_property_mark(listing_id)
        if save_mark:
            LOGGER.info(f"Property {listing_id} already marked as {save_mark}")
            return SaveMark(save_mark)
        else:
            return None

    def mark_property(self, listing_url: str, save_mark: SaveMark) -> None:
        # TODO: If it is already cached with a different mark, need to pop it from the
        #       save_mark hash list...

        listing_id = _extract_listing_id_from_listing_url(listing_url)
        LOGGER.info(f"Marking property {listing_id} as {save_mark.value}")
        self.db.mark_property(listing_id, save_mark.value)

    def get_all_liked_property_ids(self) -> List[str]:
        return self.db.get_all_property_ids_with_mark(SaveMark.LIKE.value)


def _extract_listing_id_from_listing_url(listing_url: str) -> str:
    decoded_url = unquote(listing_url)
    url_no_query = urljoin(decoded_url, urlparse(decoded_url).path)
    listing_id = url_no_query.rsplit("/", 1)[-1]
    try:
        int(listing_id)
    except ValueError as err:
        raise ValueError(f"Failed to extract listing_id from listing URL {listing_url}: {err}")
    return listing_id
