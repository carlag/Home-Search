from typing import List, Optional

from pydantic import BaseModel, Field

from app.models.property_ import SaveMark
from app.schemas.station import Station


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


class PropertyList(BaseModel):
    properties: List[Property]
