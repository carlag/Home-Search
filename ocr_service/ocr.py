import re
from io import BytesIO

import pytesseract
import requests
from PIL import Image


def get_area(floorplan_url: str) -> float:

    image = requests.get(floorplan_url).content
    floorplan_text = pytesseract.image_to_string(Image.open(BytesIO(image)))
    sqm = re.search(r"(\d*.?\d*) sq m", floorplan_text).groups()[0]
    return float(sqm)
