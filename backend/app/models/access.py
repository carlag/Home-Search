from sqlalchemy import Column, String

from app.database.session import Base


class UserModel(Base):
    __tablename__ = "user"

    email = Column(String, primary_key=True, nullable=False)