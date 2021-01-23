from enum import Enum

from sqlalchemy import Column, Enum as SqlEnum, String, Float

from app.database.base_class import Base


class SaveMark(str, Enum):
    LIKE = "liked"
    REJECT = "rejected"
    UNSURE = "unsure"


class PropertyModel(Base):
    __tablename__ = "properties"

    listing_id = Column(String, primary_key=True, nullable=False)  # TODO: Is index=True needed here? Or is that for an auto incrementing index only?
    listing_url = Column(String, nullable=False)
    longitude = Column(Float, nullable=False)
    latitude = Column(Float, nullable=False)
    price = Column(Float)
    ocr_size = Column(Float)
    floorplan_url = Column(String)
    mark = Column(SqlEnum(SaveMark))

    def __repr__(self):
        return (f"PropertyModel("
                f"listing_id={self.listing_id}"
                f", listing_url={self.listing_url}"
                f", floorplan_url={self.floorplan_url}"
                f", ocr_size={self.ocr_size}"
                f", mark={self.mark})")