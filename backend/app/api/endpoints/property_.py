from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.like_reject_server import save_property_mark
from app.models.access import UserModel
from app.models.property_ import SaveMark
from app.property_server import PropertyServer
from app.schemas.property_ import PropertyList, PostcodeList, extract_listing_id_from_listing_url

router = APIRouter()
property_server = PropertyServer(page_size=10)


@router.post("/properties", response_model=PropertyList)
async def get_properties(*,
                         db: Session = Depends(get_db),
                         current_user: UserModel = Depends(get_current_user),
                         postcodes: PostcodeList) -> PropertyList:
    return property_server.get_property_information(db, postcodes.postcodes, current_user.user_email)


@router.post("/properties/reset", response_model=PropertyList)
async def get_properties(*,
                         db: Session = Depends(get_db),
                         current_user: UserModel = Depends(get_current_user),
                         postcodes: PostcodeList) -> PropertyList:
    return property_server.get_property_information(
        db, postcodes.postcodes, current_user.user_email, reset=True)


@router.get("/mark/{listing_url:path}/as/{mark}")
async def mark_property(*,
                        db: Session = Depends(get_db),
                        current_user: UserModel = Depends(get_current_user),
                        listing_url: str,
                        mark: SaveMark):
    listing_id = extract_listing_id_from_listing_url(listing_url)
    save_property_mark(db, listing_id, current_user.user_email, mark)


@router.get("/all_liked_properties", response_model=PropertyList)
async def get_all_liked_properties(db: Session = Depends(get_db),
                                   current_user: UserModel = Depends(get_current_user)) -> PropertyList:
    return property_server.get_all_liked_properties(db, current_user.user_email)
