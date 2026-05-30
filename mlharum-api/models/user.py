from sqlalchemy import Column, Integer, String, Boolean, DateTime, Text, func
from sqlalchemy.orm import relationship
from database import Base


class User(Base):
    __tablename__ = "users"

    id                = Column(Integer, primary_key=True, index=True)
    name              = Column(String(100), nullable=False)
    email             = Column(String(100), unique=True, nullable=False, index=True)
    password_hash     = Column(String(255), nullable=False)
    phone             = Column(String(20))
    whatsapp          = Column(String(20), nullable=True)
    role              = Column(String(20), nullable=False, default="farmer")
    created_at        = Column(DateTime, server_default=func.now())
    reset_otp_hash      = Column(String(255), nullable=True)
    reset_otp_expires   = Column(DateTime, nullable=True)
    address             = Column(Text(),        nullable=True)
    bank_name           = Column(String(100), nullable=True)
    bank_account_number = Column(String(50),  nullable=True)
    bank_account_name   = Column(String(100), nullable=True)
    is_suspended        = Column(Boolean,     nullable=False, default=False, server_default='false')
    is_verified         = Column(Boolean,     nullable=False, default=False, server_default='false')

    farms  = relationship("Farm", back_populates="owner", cascade="all, delete-orphan")
    orders = relationship("Order", back_populates="buyer", cascade="all, delete-orphan")
