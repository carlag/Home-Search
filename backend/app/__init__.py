import logging

from app.database.init_db import init_db

logging.basicConfig(level=logging.INFO)
LOGGER = logging.getLogger()

LOGGER.info("Starting up backend app...")
init_db()
