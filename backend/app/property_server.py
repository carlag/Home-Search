import logging
from collections import defaultdict
from typing import List, Optional

import requests
from sqlalchemy.orm import Session

from app.config import settings
from app.like_reject_server import SaveMark, check_if_property_marked, get_all_liked_property_ids
from app.models.property_ import PropertyModel
from app.ocr import Ocr
from app.schemas.property_ import PropertyList, Property

LOGGER = logging.getLogger()
ZOOPLA_API_KEY = settings.ZOOPLA_API_KEY


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

        self.zoopla_listings_url = "https://api.zoopla.co.uk/api/v1/property_listings.js"

        self.floorplan_reader = Ocr()

    def get_property_information(self,
                                 db: Session,
                                 postcodes: List[str],
                                 user_email: str,
                                 reset: bool = False) -> PropertyList:
        properties = []
        for postcode in postcodes:
            properties += self.get_property_info_from_postcode(db, postcode, user_email, reset)

        return PropertyList(properties=sorted(properties, reverse=True))

    def get_property_info_from_postcode(self,
                                        db: Session,
                                        postcode: str,
                                        user_email: str,
                                        reset: bool = False) -> List[Property]:

        properties_json = self._get_property_listing(postcode, reset)
        properties_schema = []
        for property_json in properties_json:
            property_schema = Property.parse_obj(property_json)
            property_model = property_schema.to_orm()
            LOGGER.info(f"Working on property {property_model}:")
            if not _is_property_in_db(db, property_model.listing_id):
                db.add(property_model)
                db.flush()
            else:
                save_mark = check_if_property_marked(db, property_model.listing_id, user_email)
                if save_mark:
                    if save_mark == SaveMark.REJECT:
                        continue
                    property_schema.mark = save_mark
            if property_schema.floor_plan:
                property_schema.ocr_size = self.get_area(db=db,
                                                         image_url=property_model.floorplan_url,
                                                         listing_id=property_model.listing_id)
            properties_schema.append(property_schema)

        filtered_properties_schema = [property_ for property_ in properties_schema
                                      if property_.ocr_size and property_.ocr_size > self.minimum_area]
        db.commit()
        return filtered_properties_schema

    def _get_properties_from_listing_ids(
            self, db: Session, user_email: str, listing_ids: List[str]) -> List[Property]:
        if not listing_ids:
            LOGGER.warning(f"Unable to get properties as no listing ids were passed.")
            return []

        params = {
            "listing_id": listing_ids,
            "api_key": ZOOPLA_API_KEY,
        }
        response = requests.get(self.zoopla_listings_url, params=params)
        response.raise_for_status()

        property_schemas = []
        for property_json in response.json()["listing"]:
            property_schema = Property.parse_obj(property_json)
            property_model = property_schema.to_orm()
            property_schema.mark = check_if_property_marked(db, property_model.listing_id, user_email)
            if property_schema.floor_plan:
                property_schema.ocr_size = self.get_area(db,
                                                         property_model.floorplan_url,
                                                         property_model.listing_id)
            property_schemas.append(property_schema)

        return property_schemas

    def get_all_liked_properties(self, db: Session, user_email: str) -> PropertyList:
        listing_ids = get_all_liked_property_ids(db, user_email)
        return PropertyList(properties=self._get_properties_from_listing_ids(db, user_email, listing_ids))

    def get_area(self, db: Session, image_url: str, listing_id: str) -> Optional[float]:
        cached_area = _get_cached_area(db, listing_id)
        if cached_area:
            return cached_area

        filetype = image_url.rsplit(".", 1)[1]
        try:
            area = (self.floorplan_reader.get_area_pdf(image_url)
                    if filetype == "pdf" else
                    self.floorplan_reader.get_area_image(image_url))
        except Exception as err:
            LOGGER.error(f"Unable to get area: {err}")
            area = float("nan")

        _cache_area(db, listing_id, area)
        return area

    def _get_property_listing(self, postcode: str, reset: bool):
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
        return response.json()["listing"]


def _is_property_in_db(db: Session, listing_id: str) -> bool:
    result = db.query(PropertyModel).filter_by(listing_id=listing_id).first()
    if result:
        LOGGER.info(f"Found property {listing_id} in DB")
        return True
    else:
        LOGGER.info(f"Property {listing_id} is not yet in the DB.")
        return False


def _get_cached_area(db: Session, listing_id: str) -> Optional[float]:
    property_ = db.query(PropertyModel).filter_by(listing_id=listing_id).first()
    try:
        area = property_.ocr_size
    except AttributeError:
        return None
    if area:
        LOGGER.info(f"Retrieved area of {area} for property {listing_id} from cache.")
        return float(area)
    else:
        return None


def _cache_area(db: Session, listing_id: str, area: Optional[float]) -> None:
    LOGGER.info(f"Caching area of {area} for {listing_id}")
    property_ = db.query(PropertyModel).filter_by(listing_id=listing_id).first()
    property_.ocr_size = area
