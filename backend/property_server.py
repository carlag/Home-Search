import logging
import os
from typing import List, Optional, Any, Dict

import redis as redis
import requests
from pydantic import BaseModel

from map_server import Station
from ocr import Ocr

LOGGER = logging.getLogger()
ZOOPLA_API_KEY = os.environ["ZOOPLAAPIKEY"]

db = redis.Redis(host='redis', port=6379)
LOGGER.info(f"Connected to DB: {db}")
floorplan_reader = Ocr(db)

class PostcodeList(BaseModel):
    postcodes: List[str]


class Property(BaseModel):
    listing_url: str
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

    @classmethod
    def from_json(cls, json: Dict[str, Any]) -> "Property":
        json["listing_url"] = json["details_url"]
        return cls.parse_obj(json)


class PropertyList(BaseModel):
    properties: List[Property]


def send_request_to_zoopla(postcode: str) -> PropertyList:
    # Make this a generator over page_number

    LOGGER.info(f"Sending request to Zoopla: {postcode}")

    zoopla_listings_url = "https://api.zoopla.co.uk/api/v1/property_listings.js"
    params = {
        "postcode": postcode,
        "keywords": "garden",
        "radius": "1.5",
        "listing_status": "sale",
        "minimum_price": "500000",
        "maximum_price": "850000",
        "minimum_beds": "2",
        "page_size": "10",
        "api_key": ZOOPLA_API_KEY,
    }
    
    response = requests.get(url=zoopla_listings_url, params=params)
    response.raise_for_status()

    properties = []
    for property_json in response.json()["listing"]:
        property_model = Property.from_json(property_json)
        if property_model.floor_plan:
            property_model.ocr_size = get_area(property_model.floor_plan[0])
        properties.append(property_model)

    return PropertyList(properties=[property_ for property_ in properties
                                    if property_.ocr_size and property_.ocr_size > 90])


def get_area(image_url: str) -> Optional[float]:
    filetype = image_url.rsplit(".", 1)[1]
    try:
        area = (floorplan_reader.get_area_pdf(image_url)
                if filetype == "pdf" else
                floorplan_reader.get_area_image(image_url))
    except ValueError as err:
        detail = f"Unable to find area in OCR text: {err}"
        LOGGER.error(detail)
    except Exception as err:
        detail = f"Unable to get area: {err}"
        LOGGER.error(detail)
    else:
        return area

    return None
