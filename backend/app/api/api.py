from fastapi import APIRouter, HTTPException, status

from app.api.endpoints import property_, floorplan, station

api_router = APIRouter()
api_router.include_router(property_.router, tags=["Property"])
api_router.include_router(floorplan.router, tags=["Floorplan OCR"])
api_router.include_router(station.router, tags=["Maps"])

AuthError = HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                          detail="Incorrect username or password",
                          headers={"WWW-Authenticate": "Bearer"})