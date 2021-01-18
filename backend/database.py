import logging
from typing import Optional, List

from redis import Redis


LOGGER = logging.getLogger()


class DB:
    def __init__(self, host: str, port: int, **kwargs):
        self.db = Redis(host=host, port=port, **kwargs)

    def get_cached_area(self, floorplan_url: str) -> Optional[float]:
        area = self.db.hget("floorplans", floorplan_url)
        if area:
            LOGGER.info(f"Retrieved area for {floorplan_url} from cache. Area: {area}")
            return float(area)
        else:
            LOGGER.info(f"Area for {floorplan_url} is not yet cached.")
            return None

    def cache_area(self, floorplan_url: str, area: float) -> None:
        LOGGER.info(f"Caching area of {area} for {floorplan_url}")
        self.db.hset(name="floorplans", key=floorplan_url, value=area)

    def get_property_mark(self, listing_id: str) -> Optional[str]:
        return self.db.hget("properties", listing_id)

    def mark_property(self, listing_id: str, save_mark: str) -> None:
        # TODO: If it is already cached with a different mark, need to pop it from the
        #       save_mark hash list...

        self.db.hset(name="properties", key=listing_id, value=save_mark)
        self.db.lpush(save_mark, listing_id)

    def get_all_property_ids_with_mark(self, save_mark: str) -> List[str]:
        return [self.db.rpoplpush(save_mark, save_mark) for _ in range(self.db.llen(save_mark))]


db = DB(host="redis", port=6379, decode_responses=True)
LOGGER.info(f"Connected to DB: {db}")

