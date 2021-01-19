from fastapi import HTTPException, APIRouter

from app.map_server import get_stations_information, Location
from app.schemas.station import StationList


router = APIRouter()


@router.get("/stations/origin/{lat},{lng}", response_model=StationList)
async def get_stations(lat: str, lng: str) -> StationList:
    try:
        stations = StationList(stations=get_stations_information(Location(lat, lng)))
        return stations
    except Exception as err:
        raise HTTPException(status_code=500, detail=f"Unable to get stations information: {err}")