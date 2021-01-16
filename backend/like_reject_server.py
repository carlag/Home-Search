import logging
from urllib.parse import urljoin, urlparse, unquote
from enum import Enum
from typing import Optional, List

from redis import Redis

LOGGER = logging.getLogger()


class SaveMark(str, Enum):
    LIKE = "liked"
    REJECT = "rejected"
    UNSURE = "unsure"


class PropertySaver:

    def __init__(self, db: Redis):
        self.db = db

    def check_if_property_marked(self, listing_url: str) -> Optional[SaveMark]:
        clean_listing_url = _clean_listing_url(listing_url)
        save_mark = self.db.hget("properties", clean_listing_url)
        if save_mark:
            LOGGER.info(f"Property {clean_listing_url} already marked as {save_mark}")
            return SaveMark(save_mark)
        else:
            return None

    def mark_property(self, listing_url: str, save_mark: SaveMark) -> None:
        # TODO: If it is already cached with a different mark, need to pop it from the
        #       save_mark hash list...

        clean_listing_url = _clean_listing_url(listing_url)
        LOGGER.info(f"Marking property {clean_listing_url} as {save_mark.value}")
        self.db.hset(name="properties", key=clean_listing_url, value=save_mark.value)
        self.db.lpush(save_mark.value, clean_listing_url)

    def get_all_liked_properties(self) -> List[str]:
        return [self.db.rpoplpush(SaveMark.LIKE.value, SaveMark.LIKE.value)
                for _ in range(self.db.llen(SaveMark.LIKE.value))]


def _clean_listing_url(listing_url: str) -> str:
    url = unquote(listing_url)
    return urljoin(url, urlparse(url).path)
