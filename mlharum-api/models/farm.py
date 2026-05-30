from sqlalchemy import Column, Integer, String, Numeric, DateTime, Boolean, ForeignKey, func
from sqlalchemy.orm import relationship
from database import Base


class Farm(Base):
    __tablename__ = "farms"

    id          = Column(Integer, primary_key=True, index=True)
    user_id     = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    name        = Column(String(100), nullable=False)
    location    = Column(String(255))
    gps_lat     = Column(Numeric(9, 6))
    gps_lng     = Column(Numeric(9, 6))
    total_trees = Column(Integer, default=0)
    is_public    = Column(Boolean, default=False, nullable=False)
    price_per_kg = Column(Numeric(10, 2), nullable=True)
    created_at   = Column(DateTime, server_default=func.now())

    owner  = relationship("User", back_populates="farms")
    trees  = relationship("Tree", back_populates="farm", cascade="all, delete-orphan")
    orders = relationship("Order", back_populates="farm", cascade="all, delete-orphan")
    images        = relationship("FarmImage",    back_populates="farm", cascade="all, delete-orphan")
    testimonials  = relationship("Testimonial",  back_populates="farm", cascade="all, delete-orphan")


class GrowthPhase(Base):
    __tablename__ = "growth_phases"

    stage           = Column(Integer, primary_key=True)
    label           = Column(String(50))
    size_min_cm     = Column(Numeric(4, 2))
    size_max_cm     = Column(Numeric(4, 2))
    days_to_harvest = Column(Integer)
