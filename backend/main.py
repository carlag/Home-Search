import logging
from typing import Dict, Any, Callable, List

import redis
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from map_server import get_stations_information, Location, StationList
from ocr import Ocr
from property_server import PostcodeList, send_request_to_zoopla, PropertyList

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


db = redis.Redis(host='redis', port=6379)
LOGGER.info(f"Connected to DB: {db}")

floorplan_reader = Ocr(db)


@app.get("/stations/origin/{lat},{lng}", response_model=StationList)
async def get_stations(lat: str, lng: str) -> Dict[str, List[Dict[str, Any]]]:
    try:
        return get_stations_information(Location(lat, lng))
    except Exception as err:
        raise HTTPException(status_code=500, detail=f"Unable to get stations information: {err}")


@app.get("/image/{image_file}")
async def get_floorplan_area(image_file: str) -> Dict[str, Any]:
    return _get_area(image_file, floorplan_reader.get_area_image)


@app.get("/pdf/{image_file}")
async def get_floorplan_area(image_file: str) -> Dict[str, Any]:
    return _get_area(image_file, floorplan_reader.get_area_pdf)


@app.post("/properties/", response_model=PropertyList)
async def get_properties(postcodes: PostcodeList) -> Dict[str, Any]:
    return send_request_to_zoopla(postcodes.postcodes[0])


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
