from sqlalchemy import Column, Integer, String, Numeric, Date, DateTime, Boolean, ForeignKey, func
from sqlalchemy.orm import relationship
from database import Base

# Valid statuses: pending → confirmed → harvested → delivered | cancelled
ORDER_STATUSES = ("pending", "confirmed", "harvested", "delivered", "cancelled")


class Order(Base):
    __tablename__ = "orders"

    id                   = Column(Integer, primary_key=True, index=True)
    buyer_id             = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    farm_id              = Column(Integer, ForeignKey("farms.id", ondelete="CASCADE"), nullable=False)
    quantity_kg          = Column(Numeric(7, 2), nullable=False)
    price_per_kg         = Column(Numeric(7, 2), nullable=False)
    total_price          = Column(Numeric(9, 2), nullable=False)
    target_harvest_date  = Column(Date, nullable=True)
    notes                = Column(String(500), nullable=True)
    status               = Column(String(20), nullable=False, default="pending")
    billplz_bill_id      = Column(String(100), nullable=True)
    billplz_paid         = Column(Boolean, default=False, nullable=False)
    paid_at              = Column(DateTime, nullable=True)
    created_at           = Column(DateTime, server_default=func.now())
    confirmed_at         = Column(DateTime, nullable=True)
    harvested_at         = Column(DateTime, nullable=True)
    delivered_at         = Column(DateTime, nullable=True)
    cancelled_at         = Column(DateTime, nullable=True)
    payout_status        = Column(String(20),  nullable=True)
    payout_reference     = Column(String(100), nullable=True)
    payout_at            = Column(DateTime,    nullable=True)

    buyer = relationship("User", back_populates="orders")
    farm  = relationship("Farm", back_populates="orders")
