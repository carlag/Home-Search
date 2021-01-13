import logging
from typing import Dict, Any, Callable, List

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from map_server import get_stations_information, Location, StationList
from property_server import PostcodeList, PropertyList, floorplan_reader, PropertyServer

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

property_server = PropertyServer()


@app.get("/stations/origin/{lat},{lng}", response_model=StationList)
async def get_stations(lat: str, lng: str) -> StationList:
    try:
        stations = StationList(stations=get_stations_information(Location(lat, lng)))
        return stations
    except Exception as err:
        raise HTTPException(status_code=500, detail=f"Unable to get stations information: {err}")


@app.get("/image/{image_file}")
async def get_floorplan_area_image(image_file: str) -> Dict[str, Any]:
    return _get_area(image_file, floorplan_reader.get_area_image)


@app.get("/pdf/{pdf_file}")
async def get_floorplan_area_pdf(pdf_file: str) -> Dict[str, Any]:
    return _get_area(pdf_file, floorplan_reader.get_area_pdf)


@app.post("/properties/", response_model=PropertyList)
async def get_properties(postcodes: PostcodeList) -> PropertyList:
    return property_server.get_property_information(postcodes.postcodes)


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
