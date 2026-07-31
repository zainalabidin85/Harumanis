from sqlalchemy import Column, Integer, String, Numeric, Date, DateTime, Boolean, ForeignKey, func, SmallInteger
from sqlalchemy.orm import relationship
from database import Base


class Detection(Base):
    __tablename__ = "detections"

    id               = Column(Integer, primary_key=True, index=True)
    tree_id          = Column(Integer, ForeignKey("trees.id", ondelete="CASCADE"), nullable=False)
    image_path       = Column(String(500))
    mango_count      = Column(Integer, default=0)
    knuckle_width_px = Column(Numeric(6, 2))
    detected_at      = Column(DateTime, server_default=func.now())

    tree   = relationship("Tree", back_populates="detections")
    fruits = relationship("Fruit", back_populates="detection", cascade="all, delete-orphan")


class Fruit(Base):
    __tablename__ = "fruits"

    id           = Column(Integer, primary_key=True, index=True)
    detection_id = Column(Integer, ForeignKey("detections.id", ondelete="CASCADE"), nullable=False)
    tree_id      = Column(Integer, ForeignKey("trees.id"), nullable=False)
    label        = Column(String(30), nullable=False)
    size_cm      = Column(Numeric(5, 2))
    growth_stage = Column(SmallInteger)
    harvest_date = Column(Date)
    bbox_x       = Column(Numeric(6, 2))
    bbox_y       = Column(Numeric(6, 2))
    bbox_w       = Column(Numeric(6, 2))
    bbox_h       = Column(Numeric(6, 2))
    season        = Column(Integer, nullable=False)
    flush_color   = Column(String(20), nullable=True)
    is_harvested  = Column(Boolean, default=False)
    harvested_at  = Column(DateTime)
    is_aborted    = Column(Boolean, default=False, nullable=False, server_default='false')
    abort_reason  = Column(String(200), nullable=True)
    aborted_at    = Column(DateTime, nullable=True)
    created_at    = Column(DateTime, server_default=func.now())

    detection = relationship("Detection", back_populates="fruits")
    tree      = relationship("Tree", back_populates="fruits")
