from fastapi import FastAPI

from ocr import get_area

app = FastAPI()


@app.get("/image/{image_file}")
async def get_floorplan_area(image_file):
    return {"area": get_area(f"https://lc.zoocdn.com/{image_file}")}