from fastapi import FastAPI

from ocr import get_area

app = FastAPI()


@app.get("/uri/{uri}")
async def get_floorplan_area(uri):
    return {"area": get_area(f"https://lc.zoocdn.com/{uri}")}