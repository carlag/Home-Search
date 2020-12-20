import logging
import re
from io import BytesIO

import pytesseract
import requests
from PIL import Image
from pdf2image import convert_from_bytes


LOGGER = logging.getLogger()
PATTERN = re.compile(r"(\d*.?\d*) sq\s?m")

def get_area_jpg(floorplan_url: str) -> float:

    image = requests.get(floorplan_url).content
    floorplan_text = pytesseract.image_to_string(Image.open(BytesIO(image)))
    LOGGER.debug(f"OCR text:\n\n{floorplan_text}")
    sqm = PATTERN.search(floorplan_text).groups()[0]
    return float(sqm)


def get_area_pdf(floorplan_url: str) -> float:

    pdf = requests.get(floorplan_url).content
    image = convert_from_bytes(pdf)[0]
    floorplan_text = pytesseract.image_to_string(image)
    LOGGER.debug(f"OCR text:\n\n{floorplan_text}")
    sqm = PATTERN.search(floorplan_text).groups()[0]
    return float(sqm)
