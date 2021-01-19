from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker


# SQLALCHEMY_DATABASE_URI = ""
#
#
# engine = create_engine(SQLALCHEMY_DATABASE_URI, pool_pre_ping=True)
# SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


# Hack to test with old redis db
from app.database.redis_database import db


def SessionLocal():
    return db