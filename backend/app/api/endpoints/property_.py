import asyncio
import logging
from typing import Optional

from fastapi import APIRouter, Depends, Response, status
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.like_reject_server import save_property_mark
from app.models.access import UserModel
from app.models.property_ import SaveMark
from app.property_server import PropertyServer
from app.request_queue import get_data_for_request, is_request_in_db
from app.schemas.property_ import PropertyList, PostcodeList, extract_listing_id_from_listing_url

router = APIRouter()
property_server = PropertyServer(page_size=10)
LOGGER = logging.getLogger()


@router.post("/properties/", response_model=PropertyList)
async def get_properties(*,
                         db: Session = Depends(get_db),
                         current_user: UserModel = Depends(get_current_user),
                         page_number: int,
                         postcodes: PostcodeList) -> PropertyList:
    return property_server.get_property_information(db,
                                                    postcodes.postcodes,
                                                    current_user.email,
                                                    page_number)


@router.post("/polling/properties/{request_id}", response_model=Optional[PropertyList], status_code=200)
async def get_properties(
        *,
        db: Session = Depends(get_db),
        current_user: UserModel = Depends(get_current_user),
        response: Response,
        page_number: int,  # query param
        min_area: Optional[int],  # query param
        min_price: Optional[int],  # query param
        max_price: Optional[int],  # query param
        min_beds: Optional[int],  # query param
        keywords: Optional[str],  # query param
        listing_status: Optional[str],  # query param
        request_id: str,  # path param
        postcodes: PostcodeList  # request body (post params)
) -> Optional[PropertyList]:
    if is_request_in_db(db, request_id):
        return get_data_for_request(db, request_id)

    LOGGER.info(f"New request ID: '{request_id}'")
    loop = asyncio.get_running_loop()
    await loop.run_in_executor(None, lambda: property_server.get_property_information_polling(
          db,
          postcodes.postcodes,
          current_user.email,
          request_id,
          page_number,
          min_area,
          min_price,
          max_price,
          min_beds,
          keywords,
          listing_status,
    ))
    response.status_code = status.HTTP_201_CREATED


@router.get("/mark/{listing_url:path}/as/{mark}")
async def mark_property(*,
                        db: Session = Depends(get_db),
                        current_user: UserModel = Depends(get_current_user),
                        listing_url: str,
                        mark: SaveMark):
    listing_id = extract_listing_id_from_listing_url(listing_url)
    save_property_mark(db, listing_id, current_user.email, mark)


@router.get("/all_liked_properties", response_model=PropertyList)
async def get_all_liked_properties(db: Session = Depends(get_db),
                                   current_user: UserModel = Depends(get_current_user)) -> PropertyList:
    return property_server.get_all_liked_properties(db, current_user.email)


