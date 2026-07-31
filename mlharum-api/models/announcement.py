from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, func
from database import Base


class Announcement(Base):
    __tablename__ = "announcements"

    id             = Column(Integer, primary_key=True, index=True)
    title          = Column(String(150), nullable=False)
    body           = Column(String(2000), nullable=False)
    image_filename = Column(String(255), nullable=True)
    event_date     = Column(DateTime, nullable=True)
    location       = Column(String(255), nullable=True)
    created_by     = Column(Integer, ForeignKey("users.id"), nullable=False)
    created_at     = Column(DateTime, server_default=func.now())
    updated_at     = Column(DateTime, nullable=True)
