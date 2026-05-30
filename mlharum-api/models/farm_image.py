from sqlalchemy import Column, Integer, String, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from database import Base


class FarmImage(Base):
    __tablename__ = "farm_images"

    id          = Column(Integer, primary_key=True, index=True)
    farm_id     = Column(Integer, ForeignKey("farms.id", ondelete="CASCADE"), nullable=False)
    filename    = Column(String(255), nullable=False)
    caption     = Column(String(200), nullable=True)
    uploaded_at = Column(DateTime, server_default=func.now())

    farm = relationship("Farm", back_populates="images")
