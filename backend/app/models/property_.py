from enum import Enum

from sqlalchemy import Column, Enum as SqlEnum, String, Float, ForeignKey

from app.database.session import Base


class SaveMark(str, Enum):
    LIKE = "liked"
    REJECT = "rejected"
    UNSURE = "unsure"


class PropertyModel(Base):
    __tablename__ = "property"

    listing_id = Column(String, primary_key=True, nullable=False)  # TODO: Is index=True needed here? Or is that for an auto incrementing index only?
    listing_url = Column(String, nullable=False)
    longitude = Column(Float, nullable=False)
    latitude = Column(Float, nullable=False)
    price = Column(Float)
    ocr_size = Column(Float)
    floorplan_url = Column(String)

    def __repr__(self):
        return (f"PropertyModel("
                f"listing_id={self.listing_id}"
                f", listing_url={self.listing_url}"
                f", floorplan_url={self.floorplan_url}"
                f", ocr_size={self.ocr_size}")


class SavedModel(Base):
    __tablename__ = "saved"

    user_email = Column(String, ForeignKey("user.email"), primary_key=True, nullable=False)
    listing_id = Column(String, ForeignKey("property.listing_id"), primary_key=True, nullable=False)
    mark = Column(SqlEnum(SaveMark), nullable=False)
