import logging

from fastapi import FastAPI

from ocr import get_area_jpg, get_area_pdf


LOGGER = logging.getLogger()
app = FastAPI()


logging.basicConfig(level=logging.INFO)


@app.get("/jpg/{image_file}")
async def get_floorplan_area(image_file):
    return {"area": get_area_jpg(f"https://lc.zoocdn.com/{image_file}.jpg")}

@app.get("/pdf/{image_file}")
async def get_floorplan_area(image_file):
    return {"area": get_area_pdf(f"https://lc.zoocdn.com/{image_file}.pdf")}