import logging
import re
from io import BytesIO

import pytesseract
import requests
from PIL import Image
from pdf2image import convert_from_bytes


LOGGER = logging.getLogger()


class Ocr:

    def __init__(self):
        self.sqm_pattern= re.compile(r"(\d*.?\d*)[.\s]*sq[.\s]*m", re.IGNORECASE)
        self.sqft_pattern= re.compile(r"(\d*.?\d*)[.\s]*sq[.\s]*ft", re.IGNORECASE)

    def get_area_jpg(self, floorplan_url: str) -> float:

        image = requests.get(f"{floorplan_url}.jpg").content
        floorplan_text = pytesseract.image_to_string(Image.open(BytesIO(image)))
        LOGGER.debug(f"OCR text:\n\n{floorplan_text}")
        return self._get_area_from_text(floorplan_text)

    def get_area_pdf(self, floorplan_url: str) -> float:

        pdf = requests.get(f"{floorplan_url}.pdf").content
        image = convert_from_bytes(pdf)[0]
        floorplan_text = pytesseract.image_to_string(image)
        LOGGER.debug(f"OCR text:\n\n{floorplan_text}")
        return self._get_area_from_text(floorplan_text)

    def _get_area_from_text(self, text: str) -> float:
        result = self.sqm_pattern.search(text)
        if result:
            return max(float(area) for area in result.groups())
        else:
            result = self.sqft_pattern.search(text)
            if result:
                return max(float(area) * 0.092903 for area in result.groups())

        raise ValueError("No regex matches found.")
