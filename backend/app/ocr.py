import logging
import re
from io import BytesIO
from typing import Optional

import pytesseract
import requests
from PIL import Image
from pdf2image import convert_from_bytes
from sqlalchemy.orm import Session

from app.models.property_ import PropertyModel

LOGGER = logging.getLogger()


class Ocr:

    def __init__(self):
        #TODO: Example that regex pattern misses: https://lc.zoocdn.com/44db19bf436b7d86c247a60993676e758538df21.gif
        self.sqm_pattern= re.compile(r"(\d*[.,\s]?\d*)[.\s]*sq[.\s]*m", re.IGNORECASE)
        self.sqft_pattern= re.compile(r"(\d*[.,\s]?\d*)[.\s]*sq[.\s]*ft", re.IGNORECASE)

    def get_area_image(self, db: Session, floorplan_url: str) -> float:
        area = _get_cached_area(db, floorplan_url)
        if area:
            return area

        image = requests.get(f"{floorplan_url}").content
        floorplan_text = pytesseract.image_to_string(Image.open(BytesIO(image)))
        LOGGER.debug(f"OCR text:\n\n{floorplan_text}")

        area = self._get_area_from_text(floorplan_text)
        _cache_area(db, floorplan_url, area)
        return area

    def get_area_pdf(self, db: Session, floorplan_url: str) -> float:
        area = _get_cached_area(db, floorplan_url)
        if area:
            return area

        pdf = requests.get(f"{floorplan_url}").content
        image = convert_from_bytes(pdf)[0]
        floorplan_text = pytesseract.image_to_string(image)
        LOGGER.debug(f"OCR text:\n\n{floorplan_text}")

        area = self._get_area_from_text(floorplan_text)
        _cache_area(db, floorplan_url, area)
        return area

    def _get_area_from_text(self, text: str) -> float:
        result = self.sqm_pattern.findall(text)
        if result:
            return max(float(area.replace(",", ".")) for area in result)

        result = self.sqft_pattern.findall(text)
        if result:
            return max(float(area.replace(",", ".")) * 0.092903 for area in result)

        return float("nan")


def _get_cached_area(db: Session, floorplan_url: str) -> Optional[float]:
    listing_id = _get_listing_id_from_floorplan_url(db, floorplan_url)
    if listing_id:
        property_ = db.query(PropertyModel).filter_by(listing_id=listing_id).first()
        area = property_.ocr_size
        if area:
            LOGGER.info(f"Retrieved area for {floorplan_url} from cache. Area: {area}")
            return float(area)
        else:
            LOGGER.info(f"Area for {floorplan_url} is not yet cached.")
            return None
    else:
        LOGGER.info(f"Area for {floorplan_url} is not yet cached.")
        return None


def _get_listing_id_from_floorplan_url(db: Session, floorplan_url: str) -> Optional[str]:
    property_ = db.query(PropertyModel).filter_by(floorplan_url=floorplan_url).first()
    return property_.listing_id if property_ else None

# TODO: Move the caching to the property_server, will need the full PropertyModel object in order to cache now
def _cache_area(db: Session, floorplan_url: str, area: float) -> None:
    LOGGER.info(f"Caching area of {area} for {floorplan_url}")
    listing_id = _get_listing_id_from_floorplan_url(db, floorplan_url)
    property_ = db.query(PropertyModel).filter_by(listing_id=listing_id).first()
    property_.ocr_size = area
    db.commit()