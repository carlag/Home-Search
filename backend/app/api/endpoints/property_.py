import asyncio
import logging

from fastapi import APIRouter, Depends, WebSocket
from sqlalchemy.orm import Session

from app.api.deps import get_db, get_current_user
from app.like_reject_server import save_property_mark
from app.models.access import UserModel
from app.models.property_ import SaveMark
from app.property_server import PropertyServer, parse_ws_data
from app.schemas.property_ import PropertyList, PostcodeList, extract_listing_id_from_listing_url

router = APIRouter()
property_server = PropertyServer(page_size=10)
LOGGER = logging.getLogger()


@router.post("/properties", response_model=PropertyList)
async def get_properties(*,
                         db: Session = Depends(get_db),
                         current_user: UserModel = Depends(get_current_user),
                         postcodes: PostcodeList) -> PropertyList:
    return property_server.get_property_information(db, postcodes.postcodes, current_user.email)


@router.post("/properties/reset", response_model=PropertyList)
async def get_properties(*,
                         db: Session = Depends(get_db),
                         current_user: UserModel = Depends(get_current_user),
                         postcodes: PostcodeList) -> PropertyList:
    return property_server.get_property_information(
        db, postcodes.postcodes, current_user.email, reset=True)


@router.websocket("/ws/properties")
async def get_properties_ws(*,
                            db: Session = Depends(get_db),
                            current_user: UserModel = Depends(get_current_user),
                            websocket: WebSocket) -> None:
    loop = asyncio.get_running_loop()
    await websocket.accept()
    data = await websocket.receive_text()
    postcodes = parse_ws_data(data)  # TODO or do nothing id just a ping... might need loop?
    result = await loop.run_in_executor(
        None, lambda: property_server.get_property_information(db, postcodes, current_user.email))
    await websocket.send_text(result.json())


@router.websocket("/ws/test")
async def websocket_endpoint(*, current_user: UserModel = Depends(get_current_user), websocket: WebSocket):
    await websocket.accept()
    while True:
        data = await websocket.receive_text()
        await websocket.send_text(f"Message text was: {data}")


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
