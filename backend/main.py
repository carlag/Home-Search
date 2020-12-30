import logging
from typing import Dict, Any, Callable, List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from map_server import get_stations_information, Location
from ocr import Ocr

LOGGER = logging.getLogger()
logging.basicConfig(level=logging.INFO)

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


floorplan_reader = Ocr()


@app.get("/stations/origin/{lat},{lng}")
async def get_stations(lat: str, lng: str) -> Dict[str, List[Dict[str, Any]]]:
    try:
        return {"stations": get_stations_information(Location(lat, lng))}
    except Exception as err:
        raise HTTPException(status_code=500, detail=f"Unable to get stations information: {err}")

@app.get("/image/{image_file}")
async def get_floorplan_area(image_file: str) -> Dict[str, Any]:
    return _get_area(image_file, floorplan_reader.get_area_image)


@app.get("/pdf/{image_file}")
async def get_floorplan_area(image_file: str) -> Dict[str, Any]:
    return _get_area(image_file, floorplan_reader.get_area_pdf)


def _get_area(image_file: str, area_function: Callable[[str], Dict[str, Any]]) -> Dict[str, Any]:
    try:
        url = f"https://lc.zoocdn.com/{image_file}"
        area = area_function(url)
        LOGGER.info(f"Area for request '{url}': '{area}'")
        return {"area": area}
    except ValueError as err:
        raise HTTPException(status_code=500, detail=f"Unable to find area in OCR text: {err}")
    except Exception as err:
        raise HTTPException(status_code=500, detail=f"Unable to get area: {err}")