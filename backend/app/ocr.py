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
        #TODO: Example that regex pattern misses: https://lc.zoocdn.com/44db19bf436b7d86c247a60993676e758538df21.gif
        self.sqm_pattern = re.compile(r"(\d*[.,\s]?\d*)[.\s]*(?:sq[.\s]*m|m[.\s]*[2|7])", re.IGNORECASE)
        self.sqft_pattern = re.compile(r"(\d*[.,\s]?\d*)[.\s]*(?:sq[.\s]*ft|ft[.\s]*[2|7])", re.IGNORECASE)

    def get_area_image(self, floorplan_url: str) -> float:
        image = requests.get(f"{floorplan_url}").content
        floorplan_text = pytesseract.image_to_string(Image.open(BytesIO(image)))
        LOGGER.debug(f"OCR text:\n\n{floorplan_text}")

        area = self._get_area_from_text(floorplan_text)
        return area

    def get_area_pdf(self, floorplan_url: str) -> float:
        pdf = requests.get(f"{floorplan_url}").content
        image = convert_from_bytes(pdf)[0]
        floorplan_text = pytesseract.image_to_string(image)
        LOGGER.debug(f"OCR text:\n\n{floorplan_text}")

        area = self._get_area_from_text(floorplan_text)
        return area

    def _get_area_from_text(self, text: str) -> float:
        result = self.sqm_pattern.findall(text)
        LOGGER.debug(f"sqm regex: {result}")
        if result:
            try:
                max_area = max(float(area.replace(",", ".")) for area in result if area)
            except ValueError:
                pass
            else:
                return max_area

        result = self.sqft_pattern.findall(text)
        LOGGER.debug(f"sqft regex: {result}")
        if result:
            return max(float(area.replace(",", ".")) * 0.092903 for area in result if area)

        return float("nan")
