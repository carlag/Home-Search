import logging
import re
from io import BytesIO
from typing import Optional

import pytesseract
import requests
from PIL import Image
from pdf2image import convert_from_bytes
from redis import Redis

LOGGER = logging.getLogger()


class Ocr:

    def __init__(self, db: Redis):
        self.sqm_pattern= re.compile(r"(\d*.?\d*)[.\s]*sq[.\s]*m", re.IGNORECASE)
        self.sqft_pattern= re.compile(r"(\d*.?\d*)[.\s]*sq[.\s]*ft", re.IGNORECASE)
        self.db = db

    def get_area_image(self, floorplan_url: str) -> float:

        area = self._check_for_cached_area(floorplan_url)
        if area:
            return area

        image = requests.get(f"{floorplan_url}").content
        floorplan_text = pytesseract.image_to_string(Image.open(BytesIO(image)))
        LOGGER.debug(f"OCR text:\n\n{floorplan_text}")
        area = self._get_area_from_text(floorplan_text)
        self._cache_area(floorplan_url, area)
        return area

    def get_area_pdf(self, floorplan_url: str) -> float:

        area = self._check_for_cached_area(floorplan_url)
        if area:
            return area

        pdf = requests.get(f"{floorplan_url}").content
        image = convert_from_bytes(pdf)[0]
        floorplan_text = pytesseract.image_to_string(image)
        LOGGER.debug(f"OCR text:\n\n{floorplan_text}")
        area = self._get_area_from_text(floorplan_text)
        self._cache_area(floorplan_url, area)
        return area

    def _get_area_from_text(self, text: str) -> float:
        result = self.sqm_pattern.findall(text)
        if result:
            return max(float(area) for area in result)

        result = self.sqft_pattern.findall(text)
        if result:
            return max(float(area) * 0.092903 for area in result)

        raise ValueError("No regex matches found.")

    def _check_for_cached_area(self, floorplan_url: str) -> Optional[float]:
        area = self.db.hget("floorplans", floorplan_url)
        if area:
            LOGGER.info(f"Retrieved area for {floorplan_url} from cache. Area: {area}")
            return float(area)
        else:
            LOGGER.info(f"Area for {floorplan_url} is not yet cached.")
            return None

    def _cache_area(self, floorplan_url: str, area: float) -> None:
        LOGGER.info(f"Caching area of {area} for {floorplan_url}")
        self.db.hset(name="floorplans", key=floorplan_url, value=area)
