from typing import List, Optional
from urllib.parse import urljoin, urlparse, unquote

from pydantic import BaseModel, Field

from app.models.property_ import SaveMark, PropertyModel


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
    # stations: Optional[List[Station]] = None
    mark: Optional[SaveMark] = None

    def __lt__(self, other: "Property"):
        return self.ocr_size < other.ocr_size

    def to_orm(self) -> PropertyModel:
        listing_id = extract_listing_id_from_listing_url(self.listing_url)
        floorplan_url = self.floor_plan[0] if self.floor_plan else None
        return PropertyModel(listing_id=listing_id,
                             listing_url=self.listing_url,
                             longitude=self.longitude,
                             latitude=self.latitude,
                             price=self.price,
                             ocr_size=self.ocr_size,
                             floorplan_url=floorplan_url,
                             mark=self.mark)


class PropertyList(BaseModel):
    properties: List[Property]


def extract_listing_id_from_listing_url(listing_url: str) -> str:
    decoded_url = unquote(listing_url)
    url_no_query = urljoin(decoded_url, urlparse(decoded_url).path)
    listing_id = url_no_query.rsplit("/", 1)[-1]
    try:
        int(listing_id)
    except ValueError as err:
        raise ValueError(f"Failed to extract listing_id from listing URL {listing_url}: {err}")
    return listing_id
