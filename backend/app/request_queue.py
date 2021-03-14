import json
import logging
from typing import Optional, NamedTuple, Dict

from fastapi import HTTPException, status

from app.schemas.property_ import PropertyList

LOGGER = logging.getLogger()


class PropertyResponse(NamedTuple):
    body: Optional[PropertyList] = None
    error: Optional[str] = None


class RequestManager:
    # TODO: Use Redis to make this scalable I guess
    def __init__(self):
        self.requests: Dict[str, PropertyResponse] = {}

    def _fail_if_request_does_not_exist(self, request_id: str) -> None:
        try:
            self.requests[request_id]
        except KeyError:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                                detail="Request ID '{request_id}' not found.")

    def check_for_request_id(self, request_id: str) -> bool:
        result = request_id in self.requests
        LOGGER.info(f"Request ID '{request_id}' is {'' if result else 'not'} already in DB.")
        return result

    def create_request(self, request_id: str) -> None:
        if request_id in self.requests:
            raise ValueError(f"Request ID '{request_id}' already exists")
        self.requests[request_id] = PropertyResponse()

    def set_request_body(self, request_id: str, data: PropertyList):
        self._fail_if_request_does_not_exist(request_id)
        self.requests[request_id] = PropertyResponse(body=data)

    def set_request_error(self, request_id: str, message: str):
        self._fail_if_request_does_not_exist(request_id)
        self.requests[request_id] = PropertyResponse(error=message)

    def get_data_for_request(self, request_id) -> Optional[PropertyList]:
        self._fail_if_request_does_not_exist(request_id)
        response = self.requests[request_id]

        if response.error:
            LOGGER.info(f"Request id '{request_id}' has returned an error: '{response.error}'")
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                                detail="The following error was encountered while trying to get property"
                                       f" data for request '{request_id}': {response.error}")
        elif response.body:
            LOGGER.info(f"Request id '{request_id}' returned:\n'{response.body}'")
            return PropertyList.parse_obj(response.body)
        else:
            LOGGER.info(f"Request id '{request_id}' has not responded yet.")
            return None

    def remove_request(self, request_id) -> None:
        self._fail_if_request_does_not_exist(request_id)
        del self.requests[request_id]
