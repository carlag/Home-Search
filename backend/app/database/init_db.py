import logging
from time import sleep

import sqlalchemy

from app.database import base  # noqa: F401
from app.database.session import engine, Base

LOGGER = logging.getLogger()


def init_db() -> None:
    LOGGER.info("Creating initial data")
    wait = 5
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
            wait = max(wait * 2, 60)  # Exponential backoff with a plateau at 1 minute
    else:
        LOGGER.error(f"Failed to connect to DB after max retries:\n{message}")


if __name__ == "__main__":
    init_db()
