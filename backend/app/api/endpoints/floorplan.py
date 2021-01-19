import logging
from typing import Dict, Any, Callable

from fastapi import APIRouter, HTTPException

from app.database.session import SessionLocal
from app.like_reject_server import PropertySaver
from app.property_server import PropertyServer

LOGGER = logging.getLogger()
router = APIRouter()
db = SessionLocal()
property_server = PropertyServer(db, page_size=10)
property_saver = PropertySaver(db)


@router.get("/image/{image_file}")
async def get_floorplan_area_image(image_file: str) -> Dict[str, Any]:
    return _get_area(image_file, property_server.floorplan_reader.get_area_image)


@router.get("/pdf/{pdf_file}")
async def get_floorplan_area_pdf(pdf_file: str) -> Dict[str, Any]:
    return _get_area(pdf_file, property_server.floorplan_reader.get_area_pdf)


def _get_area(image_file: str, area_function: Callable[[str], float]) -> Dict[str, Any]:
    try:
        url = f"https://lc.zoocdn.com/{image_file}"
        area = area_function(url)
        LOGGER.info(f"Area for request '{url}': '{area}'")
        return {"area": area}
    except ValueError as err:
        detail = f"Unable to find area in OCR text: {err}"
        LOGGER.error(detail)
        raise HTTPException(status_code=500, detail=detail)
    except Exception as err:
        detail = f"Unable to get area: {err}"
        LOGGER.error(detail)
        raise HTTPException(status_code=500, detail=detail)
