from enum import Enum
from typing import NamedTuple, List, Any, Dict

import os
import requests

API_KEY = os.environ.get("MAPSAPIKEY")

class Location(NamedTuple):
    lat: str
    lng: str

    def __str__(self) -> str:
        return f"{self.lat},{self.lng}"

    def to_dict(self) -> Dict[str, Any]:
        return {
            "lat": self.lat,
            "lng": self.lng
        }


class Station(NamedTuple):
    address: str
    distance: float
    duration: float
    origin: Location

    def to_dict(self) -> Dict[str, Any]:
        return {
            "address": self.address,
            "distance": self.distance,
            "duration": self.duration,
            "origin": self.origin.to_dict(),
        }


class StationType(Enum):
    TRAIN = "train_station"
    SUBWAY = "subway_station"


def nearby_station_locations(location: Location, station_type: StationType) -> List[Location]:

    if not API_KEY:
        raise KeyError("Maps API_KEY environment variable undefined.")

    uri = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    params = {
        "location": f"{location}",
        "rankby": "distance",
        "type": station_type.value,
        "key": API_KEY,
    }
    response = requests.get(uri, params=params)
    response.raise_for_status()

    locations = [Location(result["geometry"]["location"]["lat"], result["geometry"]["location"]["lng"])
                 for result in response.json()["results"]]
    return locations


def get_stations_information(origin: Location, nearest_k: int = 4) -> List[Dict[str, Any]]:

    if not API_KEY:
        raise KeyError("Maps API_KEY environment variable undefined.")

    nearby_stations = (nearby_station_locations(origin, StationType.TRAIN)[:nearest_k]
                       + nearby_station_locations(origin, StationType.SUBWAY)[:nearest_k])

    print(nearby_stations)

    uri = "https://maps.googleapis.com/maps/api/distancematrix/json"
    params = {
        "units": "metric",
        "mode": "walking",
        "origins": f"{origin}",
        "destinations": "|".join(f"{dest}" for dest in nearby_stations),
        "key": API_KEY,
    }
    response = requests.get(uri, params=params)
    response.raise_for_status()

    stations = [Station(address=address,
                        distance=info["distance"]["value"],
                        duration=info["duration"]["value"],
                        origin=origin).to_dict()
                for address, info in zip(response.json()["destination_addresses"],
                                         response.json()["rows"][0]["elements"])]
    stations = sorted(stations, key=lambda station: station["duration"])
    return stations[:nearest_k]