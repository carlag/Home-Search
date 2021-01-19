from fastapi import APIRouter

from app.database.session import SessionLocal
from app.like_reject_server import PropertySaver, SaveMark
from app.property_server import PropertyServer
from app.schemas.property_ import PropertyList, PostcodeList

router = APIRouter()
db = SessionLocal()
property_server = PropertyServer(db, page_size=10)
property_saver = PropertySaver(db)


@router.post("/properties", response_model=PropertyList)
async def get_properties(postcodes: PostcodeList) -> PropertyList:
    return property_server.get_property_information(postcodes.postcodes)


@router.post("/properties/reset", response_model=PropertyList)
async def get_properties(postcodes: PostcodeList) -> PropertyList:
    return property_server.get_property_information(postcodes.postcodes, reset=True)


@router.get("/mark/{listing_url:path}/as/{mark}")
async def mark_property(listing_url: str, mark: SaveMark):
    property_saver.mark_property(listing_url, mark)


@router.get("/all_liked_properties", response_model=PropertyList)
async def get_all_liked_properties() -> PropertyList:
    return property_server.get_all_like_properties()