from sqlalchemy import Column, String

from app.database.session import Base


class UserModel(Base):
    __tablename__ = "users"

    user_email: Column(String, nullable=False)