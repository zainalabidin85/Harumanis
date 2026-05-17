from pydantic import BaseModel, EmailStr
from datetime import date, datetime
from typing import Optional


# ── Auth ──────────────────────────────────────────────────────────────────────

class UserRegister(BaseModel):
    name: str
    email: EmailStr
    password: str
    phone: Optional[str] = None


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


# ── Farm ──────────────────────────────────────────────────────────────────────

class FarmCreate(BaseModel):
    name: str
    location: Optional[str] = None
    gps_lat: Optional[float] = None
    gps_lng: Optional[float] = None
    total_trees: int = 0


class FarmResponse(BaseModel):
    id: int
    name: str
    location: Optional[str]
    gps_lat: Optional[float]
    gps_lng: Optional[float]
    total_trees: int

    class Config:
        from_attributes = True


# ── Tree ──────────────────────────────────────────────────────────────────────

class TreeCreate(BaseModel):
    tree_number: str
    gps_lat: Optional[float] = None
    gps_lng: Optional[float] = None
    notes: Optional[str] = None


class TreeBulkCreate(BaseModel):
    trees: list[TreeCreate]


class TreeResponse(BaseModel):
    id: int
    tree_number: str
    gps_lat: Optional[float]
    gps_lng: Optional[float]
    notes: Optional[str]

    class Config:
        from_attributes = True


# ── Detection & Fruit ─────────────────────────────────────────────────────────

class FruitResult(BaseModel):
    label: str
    size_cm: float
    growth_stage: int
    harvest_date: date
    days_to_harvest: int
    bbox_x: float
    bbox_y: float
    bbox_w: float
    bbox_h: float


class DetectionResponse(BaseModel):
    tree_id: int
    tree_number: str
    detection_date: datetime
    mango_count: int
    fruits: list[FruitResult]


# ── Dashboard ─────────────────────────────────────────────────────────────────

class TreeDashboard(BaseModel):
    tree_number: str
    gps_lat: Optional[float]
    gps_lng: Optional[float]
    fruit_count: int
    earliest_harvest_date: Optional[date]
    growth_stage: Optional[int]


class FarmDashboard(BaseModel):
    farm_id: int
    farm_name: str
    total_trees: int
    total_active_fruits: int
    trees: list[TreeDashboard]
