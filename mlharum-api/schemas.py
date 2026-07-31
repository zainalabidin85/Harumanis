from pydantic import BaseModel, EmailStr, field_validator
from datetime import date, datetime
from typing import Optional


# ── Auth ──────────────────────────────────────────────────────────────────────

class UserRegister(BaseModel):
    name: str
    email: EmailStr
    password: str
    address: Optional[str] = None
    phone: Optional[str] = None
    whatsapp: Optional[str] = None
    role: str = "farmer"

    @field_validator('password')
    @classmethod
    def password_min_length(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError('Password must be at least 8 characters')
        return v

    @field_validator('role')
    @classmethod
    def role_valid(cls, v: str) -> str:
        if v not in ("farmer", "buyer"):
            raise ValueError('role must be farmer or buyer')
        return v


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    email: EmailStr
    otp: str
    new_password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"


class UserProfileResponse(BaseModel):
    id: int
    name: str
    email: str
    address: Optional[str] = None
    phone: Optional[str]
    whatsapp: Optional[str]
    role: str
    farm_id: Optional[int] = None
    bank_name: Optional[str] = None
    bank_account_number: Optional[str] = None
    bank_account_name: Optional[str] = None

    class Config:
        from_attributes = True


class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    address: Optional[str] = None
    phone: Optional[str] = None
    whatsapp: Optional[str] = None
    bank_name: Optional[str] = None
    bank_account_number: Optional[str] = None
    bank_account_name: Optional[str] = None


# ── Farm ──────────────────────────────────────────────────────────────────────

class FarmCreate(BaseModel):
    name: str
    location: Optional[str] = None
    gps_lat: Optional[float] = None
    gps_lng: Optional[float] = None
    total_trees: int = 0
    is_public: bool = False
    price_per_kg: Optional[float] = None


class FarmUpdate(BaseModel):
    name: Optional[str] = None
    location: Optional[str] = None
    gps_lat: Optional[float] = None
    gps_lng: Optional[float] = None
    total_trees: Optional[int] = None
    is_public: Optional[bool] = None
    price_per_kg: Optional[float] = None
    ready_in_days: Optional[int] = None


class FarmResponse(BaseModel):
    id: int
    name: str
    location: Optional[str]
    gps_lat: Optional[float]
    gps_lng: Optional[float]
    total_trees: int
    is_public: bool
    price_per_kg: Optional[float]
    ready_in_days: int = 4

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
    id: int
    label: str
    size_cm: float
    growth_stage: int
    harvest_date: date
    days_to_harvest: int
    flush_color: Optional[str] = None
    bbox_x: float
    bbox_y: float
    bbox_w: float
    bbox_h: float


class ActiveFruitResponse(BaseModel):
    id: int
    label: str
    size_cm: float
    growth_stage: int
    harvest_date: date
    days_to_harvest: int
    is_harvested: bool
    is_aborted: bool
    abort_reason: Optional[str] = None
    flush_color: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True


class FruitAbortRequest(BaseModel):
    reason: Optional[str] = None


FLUSH_COLORS = ("red", "yellow", "blue", "green", "orange", "purple")


class FruitFlushColorUpdate(BaseModel):
    color: str

    @field_validator('color')
    @classmethod
    def color_valid(cls, v: str) -> str:
        if v not in FLUSH_COLORS:
            raise ValueError(f'color must be one of {FLUSH_COLORS}')
        return v


class DetectionResponse(BaseModel):
    tree_id: int
    tree_number: str
    detection_date: datetime
    mango_count: int
    ready_for_bagging: bool
    message: str
    fruits: list[FruitResult] = []
    hand_index_x: Optional[float] = None
    hand_index_y: Optional[float] = None
    hand_pinky_x: Optional[float] = None
    hand_pinky_y: Optional[float] = None


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
    current_season: int
    total_trees: int
    total_active_fruits: int
    total_harvested_fruits: int
    total_aborted_fruits: int
    trees: list[TreeDashboard]


# ── DOA yield report ──────────────────────────────────────────────────────

class DoaStageCount(BaseModel):
    stage: int
    label: str
    count: int


class DoaFarmSummary(BaseModel):
    farm_id: int
    farm_name: str
    location: Optional[str]
    owner_id: int
    owner_name: str
    owner_phone: Optional[str]
    is_verified: bool
    total_trees: int
    active_fruits: int
    harvested_fruits: int
    aborted_fruits: int
    stage_counts: list[DoaStageCount]


class DoaYieldReport(BaseModel):
    current_season: int
    available_seasons: list[int]
    total_farms: int
    total_trees: int
    total_active_fruits: int
    total_harvested_fruits: int
    total_aborted_fruits: int
    stage_summary: list[DoaStageCount]
    farms: list[DoaFarmSummary]


class DoaVerifyOwnerRequest(BaseModel):
    is_verified: bool


# ── Farm Images ───────────────────────────────────────────────────────────

class FarmImageResponse(BaseModel):
    id: int
    farm_id: int
    url: str
    thumb_url: str
    caption: Optional[str]
    uploaded_at: datetime

    class Config:
        from_attributes = True


# ── Testimonials ──────────────────────────────────────────────────────────────

class TestimonialCreate(BaseModel):
    rating: int
    comment: Optional[str] = None

    @field_validator('rating')
    @classmethod
    def rating_valid(cls, v: int) -> int:
        if not 1 <= v <= 5:
            raise ValueError('rating must be between 1 and 5')
        return v


class TestimonialUpdate(BaseModel):
    rating: Optional[int] = None
    comment: Optional[str] = None

    @field_validator('rating')
    @classmethod
    def rating_valid(cls, v: Optional[int]) -> Optional[int]:
        if v is not None and not 1 <= v <= 5:
            raise ValueError('rating must be between 1 and 5')
        return v


class TestimonialResponse(BaseModel):
    id: int
    farm_id: int
    buyer_name: str
    rating: int
    comment: Optional[str]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# ── Announcements ─────────────────────────────────────────────────────────────

class AnnouncementCreate(BaseModel):
    title: str
    body: str
    event_date: Optional[datetime] = None
    location: Optional[str] = None


class AnnouncementUpdate(BaseModel):
    title: Optional[str] = None
    body: Optional[str] = None
    event_date: Optional[datetime] = None
    location: Optional[str] = None


class AnnouncementResponse(BaseModel):
    id: int
    title: str
    body: str
    image_url: Optional[str]
    event_date: Optional[datetime]
    location: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True


# ── Marketplace ───────────────────────────────────────────────────────────────

class MarketplaceFarmSummary(BaseModel):
    farm_id: int
    farm_name: str
    location: Optional[str]
    gps_lat: Optional[float]
    gps_lng: Optional[float]
    farmer_name: str
    farmer_verified: bool
    price_per_kg: Optional[float]
    ready_in_days: int = 4
    thumbnail_url: Optional[str]
    total_active_fruits: int
    stage_1_count: int
    stage_2_count: int
    stage_3_count: int
    earliest_harvest_date: Optional[date]
    avg_rating: Optional[float] = None
    review_count: int = 0

    class Config:
        from_attributes = True


class MarketplaceFarmDetail(MarketplaceFarmSummary):
    trees: list[TreeDashboard]
    images: list[FarmImageResponse]


# ── Orders ────────────────────────────────────────────────────────────────────

class OrderCreate(BaseModel):
    farm_id: int
    quantity_kg: float
    target_harvest_date: Optional[date] = None
    notes: Optional[str] = None


class OrderResponse(BaseModel):
    id: int
    farm_id: int
    farm_name: str
    farmer_whatsapp: Optional[str]
    buyer_id: int
    buyer_name: str
    buyer_address: Optional[str] = None
    quantity_kg: float
    price_per_kg: float
    total_price: float
    target_harvest_date: Optional[date]
    notes: Optional[str]
    status: str
    billplz_bill_id: Optional[str]
    billplz_paid: bool
    paid_at: Optional[datetime]
    confirmed_at: Optional[datetime]
    harvested_at: Optional[datetime]
    delivered_at: Optional[datetime]
    cancelled_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class OrderStatusUpdate(BaseModel):
    status: str

    @field_validator('status')
    @classmethod
    def status_valid(cls, v: str) -> str:
        valid = ("confirmed", "harvested", "delivered", "cancelled")
        if v not in valid:
            raise ValueError(f'status must be one of {valid}')
        return v


class PaymentInitResponse(BaseModel):
    order_id: int
    payment_url: str
    billplz_bill_id: str


# ── Admin ─────────────────────────────────────────────────────────────────────

class AdminStatsResponse(BaseModel):
    total_users: int
    farmers: int
    buyers: int
    admins: int
    suspended: int
    total_farms: int
    public_farms: int
    total_orders: int
    pending_orders: int
    revenue_total: float
    payout_pending_count: int
    payout_pending_amount: float


class AdminUserResponse(BaseModel):
    id: int
    name: str
    email: str
    role: str
    phone: Optional[str]
    whatsapp: Optional[str]
    is_suspended: bool
    is_verified: bool
    bank_name: Optional[str]
    bank_account_number: Optional[str]
    bank_account_name: Optional[str]
    created_at: Optional[datetime]
    farm_count: int = 0

    class Config:
        from_attributes = True


class AdminUserUpdate(BaseModel):
    role: Optional[str] = None
    is_suspended: Optional[bool] = None
    is_verified: Optional[bool] = None

    @field_validator('role')
    @classmethod
    def role_valid(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and v not in ("farmer", "buyer", "admin", "doa"):
            raise ValueError('role must be farmer, buyer, admin, or doa')
        return v


class AdminFarmResponse(BaseModel):
    id: int
    name: str
    location: Optional[str]
    is_public: bool
    price_per_kg: Optional[float]
    owner_id: int
    owner_name: str
    tree_count: int = 0
    created_at: Optional[datetime]

    class Config:
        from_attributes = True


class AdminFarmUpdate(BaseModel):
    is_public: bool


class AdminOrderResponse(BaseModel):
    id: int
    farm_id: int
    farm_name: str
    farmer_whatsapp: Optional[str]
    buyer_id: int
    buyer_name: str
    buyer_email: str
    buyer_address: Optional[str] = None
    quantity_kg: float
    price_per_kg: float
    total_price: float
    target_harvest_date: Optional[date]
    notes: Optional[str]
    status: str
    billplz_paid: bool
    paid_at: Optional[datetime]
    created_at: datetime
    payout_status: Optional[str]
    payout_reference: Optional[str]
    payout_at: Optional[datetime]
    farmer_bank_name: Optional[str]
    farmer_bank_account_number: Optional[str]
    farmer_bank_account_name: Optional[str]

    class Config:
        from_attributes = True


class PayoutUpdate(BaseModel):
    payout_reference: str
