from fastapi import APIRouter

from app.api.endpoints import property_, floorplan, station

api_router = APIRouter()
api_router.include_router(property_.router, tags=["Property"])
api_router.include_router(floorplan.router, tags=["Floorplan OCR"])
api_router.include_router(station.router, tags=["Maps"])