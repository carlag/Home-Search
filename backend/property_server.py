import logging
from typing import List, Optional, Any, Dict

import os
import requests
from pydantic import BaseModel


LOGGER = logging.getLogger()


ZOOPLA_API_KEY = os.environ["ZOOPLAAPIKEY"]

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

    @classmethod
    def from_json(cls, json: Dict[str, Any]) -> "Property":
        json["listing_url"] = json["details_url"]
        return cls.parse_obj(json)


class PropertyList(BaseModel):
    properties: List[Property]
    

def send_request_to_zoopla(postcode: str) -> Dict[str, Any]:
    # Make this a generator over page_number

    LOGGER.info(f"Sending request to Zoopla: {postcode}")

    zoopla_listings_url = "https://api.zoopla.co.uk/api/v1/property_listings.js"
    params = {
        "postcode": postcode,
        "keywords": "garden",
        "radius": "5.0",
        "listing_status": "sale",
        "minimum_price": "500000",
        "maximum_price": "850000",
        "minimum_beds": "2",
        "page_size": "100",
        "api_key": ZOOPLA_API_KEY,
    }
    
    response = requests.get(url=zoopla_listings_url, params=params)
    response.raise_for_status()

    properties: List[Property] = []
    for property_ in response.json()["listing"]:

        properties.append(Property.from_json(property_))

    properties = PropertyList(properties=properties)

    return properties.dict()
