import logging
from typing import List, Optional

import requests
from sqlalchemy.orm import Session

from app.config import settings
from app.like_reject_server import SaveMark, check_if_property_marked, get_all_liked_property_ids
from app.models.property_ import PropertyModel
from app.models.request import RequestModel
from app.ocr import Ocr
from app.request_queue import is_request_in_db
from app.schemas.property_ import PropertyList, Property, PostcodeList

LOGGER = logging.getLogger()
ZOOPLA_API_KEY = settings.ZOOPLA_API_KEY


class PropertyServer:

    def __init__(self,
                 minimum_area: int = 90,
                 minimum_price: int = 500_000,
                 maximum_price: int = 850_000,
                 radius: float = 0.6,  # in miles
                 page_size: int = 10,
                 listing_status: str = "sale",
                 keywords: str = "garden",
                 minimum_beds: int = 2):
        if page_size > 100 or page_size < 1:
            raise ValueError(f"{page_size} is an invalid value for page_size."
                             f" It must be between 1 and 100 inclusive.")

        self.minimum_area = minimum_area
        self.minimum_price = minimum_price
        self.maximum_price = maximum_price
        self.radius = radius
        self.page_size = page_size
        self.listing_status = listing_status
        self.keywords = keywords
        self.minimum_beds = minimum_beds

        self.zoopla_listings_url = "https://api.zoopla.co.uk/api/v1/property_listings.js"

        self.floorplan_reader = Ocr()

    def _set_filter_args(self,
                         min_area: Optional[int],
                         min_price: Optional[int],
                         max_price: Optional[int],
                         min_beds: Optional[int],
                         keywords: Optional[str],
                         listing_status: Optional[str]) -> None:
        if min_area:
            self.minimum_area = min_area
        if min_price:
            self.minimum_price = min_price
        if max_price:
            self.maximum_price = max_price
        if min_beds:
            self.minimum_beds = min_beds
        if keywords:
            self.keywords = keywords
        if listing_status:
            self.listing_status = listing_status

    def get_property_information_polling(self,
                                         db: Session,
                                         postcodes: List[str],
                                         user_email: str,
                                         request_id: str,
                                         page_number: int,
                                         min_area: Optional[int],
                                         min_price: Optional[int],
                                         max_price: Optional[int],
                                         min_beds: Optional[int],
                                         keywords: Optional[str],
                                         listing_status: Optional[str]) -> None:
        self._set_filter_args(min_area=min_area,
                              min_price=min_price,
                              max_price=max_price,
                              min_beds=min_beds,
                              keywords=keywords,
                              listing_status=listing_status)

        try:
            if is_request_in_db(db, request_id):
                raise RuntimeError(f"Attempting to poll but that id ({request_id}) is already in the DB.")
            request_model = RequestModel(request_id=request_id)
            db.add(request_model)
            db.flush()

            response = self.get_property_information(db, postcodes, user_email, page_number)
            request_model.response = response.json(by_alias=True)
            LOGGER.debug(f"Saving the following property json to the DB:\n'{request_model.response}'")
            db.commit()
        except Exception as err:
            LOGGER.info(f"Oh dear, you appear to have had an exception during the async call"
                        f" to poll for properties: {err}")
            # request_model = RequestModel(request_id=request_id)
            request_model = db.query(RequestModel).filter_by(request_id=request_id).first()
            request_model.error = str(err)
            db.add(request_model)
            db.commit()

    def get_property_information(self,
                                 db: Session,
                                 postcodes: List[str],
                                 user_email: str,
                                 page_number: int) -> PropertyList:
        properties = []
        for postcode in postcodes:
            properties += self.get_property_info_from_postcode(db, postcode, user_email, page_number)

        return PropertyList(properties=sorted(properties, reverse=True))

    def get_property_info_from_postcode(self,
                                        db: Session,
                                        postcode: str,
                                        user_email: str,
                                        page_number: int) -> List[Property]:

        properties_json = self._get_property_listing(postcode, page_number)
        properties_schema = []
        properties_count = len(properties_json)
        for property_number, property_json in enumerate(properties_json):
            property_schema = Property.parse_obj(property_json)
            property_model = property_schema.to_orm()
            LOGGER.info(f"Working on property {property_number + 1}/{properties_count} - {property_model}:")
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
            LOGGER.info(f"Complete working on property {property_model.listing_id}.")

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

    def _get_property_listing(self, postcode: str, page_number: int = 1):
        LOGGER.info(f"Sending request to Zoopla for postcode '{postcode}', page {page_number}")

        params = {
            "postcode": postcode,
            "keywords": self.keywords,
            "radius": self.radius,
            "listing_status": self.listing_status,
            "minimum_price": self.minimum_price,
            "maximum_price": self.maximum_price,
            "minimum_beds": self.minimum_beds,
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
        LOGGER.info(f"Found property {listing_id} in DB.")
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


def parse_ws_data(data: str) -> List[str]:
    postcodes = PostcodeList.parse_obj(data)
    return postcodes.postcodes
