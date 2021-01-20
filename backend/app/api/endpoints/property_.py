from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db
from app.like_reject_server import save_property_mark
from app.models.property_ import SaveMark
from app.property_server import PropertyServer
from app.schemas.property_ import PropertyList, PostcodeList

router = APIRouter()
property_server = PropertyServer(page_size=10)


@router.post("/properties", response_model=PropertyList)
async def get_properties(*, db: Session = Depends(get_db), postcodes: PostcodeList) -> PropertyList:
    return property_server.get_property_information(db, postcodes.postcodes)


@router.post("/properties/reset", response_model=PropertyList)
async def get_properties(*, db: Session = Depends(get_db), postcodes: PostcodeList) -> PropertyList:
    return property_server.get_property_information(db, postcodes.postcodes, reset=True)


@router.get("/mark/{listing_url:path}/as/{mark}")
async def mark_property(*, db: Session = Depends(get_db), listing_url: str, mark: SaveMark):
    save_property_mark(db, listing_url, mark)


@router.get("/all_liked_properties", response_model=PropertyList)
async def get_all_liked_properties(db: Session = Depends(get_db)) -> PropertyList:
    return property_server.get_all_liked_properties(db)