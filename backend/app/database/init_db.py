import logging
from time import sleep

import sqlalchemy
from sqlalchemy.ext.declarative import declarative_base

from app.database.base_class import Base
from app.database.session import engine
from app.database import base  # noqa: F401


LOGGER = logging.getLogger()


def init_db() -> None:
    LOGGER.info("Creating initial data")
    wait = 10
    message = ""
    for retry in range(5):
        try:
            Base.metadata.create_all(engine)
            LOGGER.info("Initial data created")
            break
        except sqlalchemy.exc.OperationalError as err:
            message = err
            LOGGER.warning(f"Failed to connect to DB on retry {retry}. Waiting for {wait}s before trying again.")
            sleep(wait)
            wait = max(wait * 2, 300)
    else:
        LOGGER.error(f"Failed to connect to DB after max retries:\n{message}")


if __name__ == "__main__":
    init_db()
