import logging
import os
from collections import defaultdict
from typing import List, Optional

import redis as redis
import requests
from pydantic import BaseModel, Field

from like_reject_server import PropertySaver, SaveMark
from map_server import Station
from ocr import Ocr

LOGGER = logging.getLogger()
ZOOPLA_API_KEY = os.environ["ZOOPLAAPIKEY"]

db = redis.Redis(host='redis', port=6379, decode_responses=True)
LOGGER.info(f"Connected to DB: {db}")
floorplan_reader = Ocr(db)
property_saver = PropertySaver(db)


class PostcodeList(BaseModel):
    postcodes: List[str]


class Property(BaseModel):
    listing_url: str = Field(alias="details_url")
    ocr_size: Optional[float] = None
    longitude: float
    latitude: float
    image_url: Optional[str] = None
    status: Optional[str] = None
    property_type: Optional[str] = None
    price: Optional[int] = None
    displayable_address: Optional[str] = None
    floor_plan: Optional[List[str]] = None
    stations: Optional[List[Station]] = None

    def __lt__(self, other: "Property"):
        return self.ocr_size < other.ocr_size


class PropertyList(BaseModel):
    properties: List[Property]


class PropertyServer:

    def __init__(self,
                 minimum_area: int = 90,
                 minimum_price: int = 500_000,
                 maximum_price: int = 850_000,
                 radius: float = 0.6,  # in miles
                 page_size: int = 10):
        if page_size > 100 or page_size < 1:
            raise ValueError(f"{page_size} is an invalid value for page_size."
                             f" It must be between 1 and 100 inclusive.")

        self.pages = defaultdict(int)
        self.minimum_area = minimum_area
        self.minimum_price = minimum_price
        self.maximum_price = maximum_price
        self.radius = radius
        self.page_size = page_size

    def get_property_information(self, postcodes: List[str]) -> PropertyList:
        properties = []
        for postcode in postcodes:
            properties += self.get_property_info_from_postcode(postcode)

        return PropertyList(properties=sorted(properties, reverse=True))

    def get_property_info_from_postcode(self, postcode: str) -> List[Property]:

        self.pages[postcode] += 1
        page_number = self.pages[postcode]
        LOGGER.info(f"Sending request to Zoopla for postcode '{postcode}', page {page_number}")

        zoopla_listings_url = "https://api.zoopla.co.uk/api/v1/property_listings.js"
        params = {
            "postcode": postcode,
            "keywords": "garden",
            "radius": self.radius,
            "listing_status": "sale",
            "minimum_price": self.minimum_price,
            "maximum_price": self.maximum_price,
            "minimum_beds": 2,
            "page_size": self.page_size,
            "page_number": page_number,
            "api_key": ZOOPLA_API_KEY,
        }

        response = requests.get(url=zoopla_listings_url, params=params)
        response.raise_for_status()

        properties = []
        for property_json in response.json()["listing"]:
            property_model = Property.parse_obj(property_json)
            save_mark = property_saver.check_if_property_marked(property_model.listing_url)
            if save_mark and save_mark == SaveMark.REJECT:
                continue
            if property_model.floor_plan:
                property_model.ocr_size = get_area(property_model.floor_plan[0])
            properties.append(property_model)

        return [property_ for property_ in properties
                if property_.ocr_size and property_.ocr_size > self.minimum_area]


def get_area(image_url: str) -> Optional[float]:
    filetype = image_url.rsplit(".", 1)[1]
    try:
        area = (floorplan_reader.get_area_pdf(image_url)
                if filetype == "pdf" else
                floorplan_reader.get_area_image(image_url))
    except Exception as err:
        LOGGER.error(f"Unable to get area: {err}")
    else:
        return area

    return None
