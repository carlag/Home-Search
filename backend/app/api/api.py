from fastapi import APIRouter, HTTPException, status

from app.api.endpoints import property_, floorplan, station, login

api_router = APIRouter()
api_router.include_router(property_.router, tags=["Property"])
api_router.include_router(floorplan.router, tags=["Floorplan OCR"])
api_router.include_router(station.router, tags=["Maps"])
api_router.include_router(login.router, tags=["Maps"])
