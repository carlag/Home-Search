from sqlalchemy import Column, String

from app.database.session import Base


class RequestModel(Base):
    __tablename__ = "request"

    request_id = Column(String, primary_key=True, nullable=False)
    response = Column(String, primary_key=True, nullable=False)
