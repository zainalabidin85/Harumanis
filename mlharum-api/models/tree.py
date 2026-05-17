from sqlalchemy import Column, Integer, String, Numeric, Text, DateTime, ForeignKey, func, UniqueConstraint
from sqlalchemy.orm import relationship
from database import Base


class Tree(Base):
    __tablename__ = "trees"
    __table_args__ = (UniqueConstraint("farm_id", "tree_number"),)

    id          = Column(Integer, primary_key=True, index=True)
    farm_id     = Column(Integer, ForeignKey("farms.id", ondelete="CASCADE"), nullable=False)
    tree_number = Column(String(20), nullable=False)
    gps_lat     = Column(Numeric(9, 6))
    gps_lng     = Column(Numeric(9, 6))
    notes       = Column(Text)
    created_at  = Column(DateTime, server_default=func.now())

    farm       = relationship("Farm", back_populates="trees")
    detections = relationship("Detection", back_populates="tree", cascade="all, delete-orphan")
    fruits     = relationship("Fruit", back_populates="tree")
