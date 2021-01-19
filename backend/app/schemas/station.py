from typing import List

from pydantic import BaseModel, Field


class Station(BaseModel):
    address: str
    distance: float
    duration: float
    property_id: str = Field(description="The ID for the property relative to which the distance"
                                         " and duration are based.")

    def __lt__(self, other: "Station"):
        return self.duration < other.duration


class StationList(BaseModel):
    stations: List[Station]