import logging
from typing import Dict, Any, Callable

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from ocr import get_area_jpg, get_area_pdf


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


@app.get("/jpg/{image_file}")
async def get_floorplan_area(image_file: str) -> Dict[str, Any]:
    return _get_area(image_file, get_area_jpg)


@app.get("/pdf/{image_file}")
async def get_floorplan_area(image_file: str) -> Dict[str, Any]:
    return _get_area(image_file, get_area_pdf)

def _get_area(image_file: str, area_function: Callable[[str], Dict[str, Any]]) -> Dict[str, Any]:
    try:
        area = area_function(f"https://lc.zoocdn.com/{image_file}")
        return {"area": area}
    except Exception as err:
        raise HTTPException(status_code=500, detail=f"Unable to get area: {err}")