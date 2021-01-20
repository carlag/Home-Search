from typing import List

from pydantic import BaseModel, Field


class Station(BaseModel):
    address: str
    distance: float
    duration: float

    def __lt__(self, other: "Station"):
        return self.duration < other.duration


class StationList(BaseModel):
    stations: List[Station]