import logging
import os
from collections import defaultdict
from typing import List, Optional

import requests
from pydantic import BaseModel, Field

from database import DB
from like_reject_server import PropertySaver, SaveMark
from map_server import Station
from ocr import Ocr

LOGGER = logging.getLogger()
ZOOPLA_API_KEY = os.environ["ZOOPLAAPIKEY"]


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
    mark: Optional[SaveMark] = None

    def __lt__(self, other: "Property"):
        return self.ocr_size < other.ocr_size


class PropertyList(BaseModel):
    properties: List[Property]


class PropertyServer:

    def __init__(self,
                 db: DB,
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

        self.zoopla_listings_url = "https://api.zoopla.co.uk/api/v1/property_listings.js"

        self.floorplan_reader = Ocr(db)
        self.property_saver = PropertySaver(db)

    def get_property_information(self, postcodes: List[str], reset: bool = False) -> PropertyList:
        properties = []
        for postcode in postcodes:
            properties += self.get_property_info_from_postcode(postcode, reset)

        return PropertyList(properties=sorted(properties, reverse=True))

    def get_property_info_from_postcode(self, postcode: str, reset: bool = False) -> List[Property]:

        if reset:
            self.pages[postcode] = 1
        else:
            self.pages[postcode] += 1
        page_number = self.pages[postcode]
        LOGGER.info(f"Sending request to Zoopla for postcode '{postcode}', page {page_number}")

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

        response = requests.get(url=self.zoopla_listings_url, params=params)
        response.raise_for_status()

        properties = []
        for property_json in response.json()["listing"]:
            property_model = Property.parse_obj(property_json)
            save_mark = self.property_saver.check_if_property_marked(property_model.listing_url)
            if save_mark:
                if save_mark == SaveMark.REJECT:
                    continue
                property_model.mark = save_mark
            if property_model.floor_plan:
                property_model.ocr_size = self.get_area(property_model.floor_plan[0])
            properties.append(property_model)

        return [property_ for property_ in properties
                if property_.ocr_size and property_.ocr_size > self.minimum_area]

    def _get_properties_from_listing_ids(self, listing_ids: List[str]) -> List[Property]:
        params = {
            "listing_id": listing_ids,
            "api_key": ZOOPLA_API_KEY,
        }
        response = requests.get(self.zoopla_listings_url, params=params)
        response.raise_for_status()

        properties = []
        for property_json in response.json()["listing"]:
            property_model = Property.parse_obj(property_json)
            property_model.mark = self.property_saver.check_if_property_marked(
                property_model.listing_url)
            if property_model.floor_plan:
                property_model.ocr_size = self.get_area(property_model.floor_plan[0])
            properties.append(property_model)

        return properties

    def get_all_like_properties(self) -> PropertyList:
        listing_ids = self.property_saver.get_all_liked_property_ids()
        return PropertyList(properties=self._get_properties_from_listing_ids(listing_ids))

    def get_area(self, image_url: str) -> Optional[float]:
        filetype = image_url.rsplit(".", 1)[1]
        try:
            area = (self.floorplan_reader.get_area_pdf(image_url)
                    if filetype == "pdf" else
                    self.floorplan_reader.get_area_image(image_url))
        except Exception as err:
            LOGGER.error(f"Unable to get area: {err}")
        else:
            return area

        return None
