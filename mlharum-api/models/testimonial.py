from sqlalchemy import Column, Integer, SmallInteger, Text, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from database import Base


class Testimonial(Base):
    __tablename__ = "testimonials"

    id         = Column(Integer, primary_key=True, index=True)
    farm_id    = Column(Integer, ForeignKey("farms.id",  ondelete="CASCADE"), nullable=False)
    buyer_id   = Column(Integer, ForeignKey("users.id",  ondelete="CASCADE"), nullable=False)
    rating     = Column(SmallInteger, nullable=False)
    comment    = Column(Text, nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now())

    farm  = relationship("Farm", back_populates="testimonials")
    buyer = relationship("User")

    @property
    def buyer_name(self) -> str:
        return self.buyer.name
