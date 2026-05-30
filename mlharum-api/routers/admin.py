from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import HTMLResponse
from sqlalchemy import func
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from models.farm import Farm
from models.order import Order
from models.testimonial import Testimonial
from auth_utils import require_admin
from schemas import (
    AdminStatsResponse, AdminUserResponse, AdminUserUpdate,
    AdminFarmResponse, AdminFarmUpdate, AdminOrderResponse, PayoutUpdate,
)

router = APIRouter()

PLATFORM_FEE_RATE = 0.02


def _order_to_admin_response(order: Order) -> AdminOrderResponse:
    owner = order.farm.owner
    return AdminOrderResponse(
        id=order.id,
        farm_id=order.farm_id,
        farm_name=order.farm.name,
        farmer_whatsapp=owner.whatsapp,
        buyer_id=order.buyer_id,
        buyer_name=order.buyer.name,
        buyer_email=order.buyer.email,
        quantity_kg=float(order.quantity_kg),
        price_per_kg=float(order.price_per_kg),
        total_price=float(order.total_price),
        target_harvest_date=order.target_harvest_date,
        notes=order.notes,
        status=order.status,
        billplz_paid=order.billplz_paid,
        paid_at=order.paid_at,
        created_at=order.created_at,
        payout_status=order.payout_status,
        payout_reference=order.payout_reference,
        payout_at=order.payout_at,
        farmer_bank_name=owner.bank_name,
        farmer_bank_account_number=owner.bank_account_number,
        farmer_bank_account_name=owner.bank_account_name,
    )


# ── Stats ─────────────────────────────────────────────────────────────────────

@router.get("/stats", response_model=AdminStatsResponse)
def get_stats(admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    users = db.query(User).all()
    farms = db.query(Farm).all()
    orders = db.query(Order).all()

    revenue = sum(float(o.total_price) for o in orders if o.billplz_paid)
    payout_pending = [
        o for o in orders
        if o.status == "delivered" and o.billplz_paid and o.payout_status != "paid"
    ]

    return AdminStatsResponse(
        total_users=len(users),
        farmers=sum(1 for u in users if u.role == "farmer"),
        buyers=sum(1 for u in users if u.role == "buyer"),
        admins=sum(1 for u in users if u.role == "admin"),
        suspended=sum(1 for u in users if u.is_suspended),
        total_farms=len(farms),
        public_farms=sum(1 for f in farms if f.is_public),
        total_orders=len(orders),
        pending_orders=sum(1 for o in orders if o.status == "pending"),
        revenue_total=round(revenue, 2),
        payout_pending_count=len(payout_pending),
        payout_pending_amount=round(sum(float(o.total_price) * (1 - PLATFORM_FEE_RATE) for o in payout_pending), 2),
    )


# ── Users ─────────────────────────────────────────────────────────────────────

@router.get("/users", response_model=list[AdminUserResponse])
def list_users(
    role: Optional[str] = Query(None),
    is_suspended: Optional[bool] = Query(None),
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    q = db.query(User)
    if role:
        q = q.filter(User.role == role)
    if is_suspended is not None:
        q = q.filter(User.is_suspended == is_suspended)
    users = q.order_by(User.created_at.desc()).all()
    result = []
    for u in users:
        r = AdminUserResponse(
            id=u.id, name=u.name, email=u.email, role=u.role,
            phone=u.phone, whatsapp=u.whatsapp,
            is_suspended=u.is_suspended, is_verified=u.is_verified,
            bank_name=u.bank_name, bank_account_number=u.bank_account_number,
            bank_account_name=u.bank_account_name,
            created_at=u.created_at, farm_count=len(u.farms),
        )
        result.append(r)
    return result


@router.patch("/users/{user_id}", response_model=AdminUserResponse)
def update_user(
    user_id: int,
    payload: AdminUserUpdate,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    if user_id == admin.id:
        raise HTTPException(status_code=400, detail="Cannot modify your own account")
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(user, field, value)
    db.commit()
    db.refresh(user)
    return AdminUserResponse(
        id=user.id, name=user.name, email=user.email, role=user.role,
        phone=user.phone, whatsapp=user.whatsapp,
        is_suspended=user.is_suspended, is_verified=user.is_verified,
        bank_name=user.bank_name, bank_account_number=user.bank_account_number,
        bank_account_name=user.bank_account_name,
        created_at=user.created_at, farm_count=len(user.farms),
    )


# ── Farms ─────────────────────────────────────────────────────────────────────

@router.get("/farms", response_model=list[AdminFarmResponse])
def list_farms(
    is_public: Optional[bool] = Query(None),
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    q = db.query(Farm)
    if is_public is not None:
        q = q.filter(Farm.is_public == is_public)
    farms = q.order_by(Farm.created_at.desc()).all()
    return [
        AdminFarmResponse(
            id=f.id, name=f.name, location=f.location,
            is_public=f.is_public,
            price_per_kg=float(f.price_per_kg) if f.price_per_kg else None,
            owner_id=f.user_id, owner_name=f.owner.name,
            tree_count=len(f.trees), created_at=f.created_at,
        )
        for f in farms
    ]


@router.patch("/farms/{farm_id}", response_model=AdminFarmResponse)
def update_farm(
    farm_id: int,
    payload: AdminFarmUpdate,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    farm = db.query(Farm).filter(Farm.id == farm_id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    farm.is_public = payload.is_public
    db.commit()
    db.refresh(farm)
    return AdminFarmResponse(
        id=farm.id, name=farm.name, location=farm.location,
        is_public=farm.is_public,
        price_per_kg=float(farm.price_per_kg) if farm.price_per_kg else None,
        owner_id=farm.user_id, owner_name=farm.owner.name,
        tree_count=len(farm.trees), created_at=farm.created_at,
    )


# ── Orders ────────────────────────────────────────────────────────────────────

@router.get("/orders", response_model=list[AdminOrderResponse])
def list_orders(
    status: Optional[str] = Query(None),
    paid: Optional[bool] = Query(None),
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    q = db.query(Order)
    if status:
        q = q.filter(Order.status == status)
    if paid is not None:
        q = q.filter(Order.billplz_paid == paid)
    orders = q.order_by(Order.created_at.desc()).all()
    return [_order_to_admin_response(o) for o in orders]


# ── Payouts ───────────────────────────────────────────────────────────────────

@router.get("/payouts", response_model=list[AdminOrderResponse])
def list_payouts(admin: User = Depends(require_admin), db: Session = Depends(get_db)):
    orders = (
        db.query(Order)
        .filter(
            Order.status == "delivered",
            Order.billplz_paid == True,
            Order.payout_status != "paid",
        )
        .order_by(Order.created_at.desc())
        .all()
    )
    return [_order_to_admin_response(o) for o in orders]


@router.patch("/payouts/{order_id}", response_model=AdminOrderResponse)
def record_payout(
    order_id: int,
    payload: PayoutUpdate,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if not (order.status == "delivered" and order.billplz_paid):
        raise HTTPException(status_code=400, detail="Order is not eligible for payout")
    if order.payout_status == "paid":
        raise HTTPException(status_code=400, detail="Payout already recorded")

    order.payout_status = "paid"
    order.payout_reference = payload.payout_reference
    order.payout_at = datetime.utcnow()
    db.commit()
    db.refresh(order)
    return _order_to_admin_response(order)


@router.get("/payouts/{order_id}/invoice", response_class=HTMLResponse)
def payout_invoice(
    order_id: int,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    owner = order.farm.owner
    gross = float(order.total_price)
    fee = round(gross * PLATFORM_FEE_RATE, 2)
    net = round(gross - fee, 2)
    paid_date = order.payout_at.strftime("%d %b %Y %H:%M") if order.payout_at else "—"
    order_date = order.created_at.strftime("%d %b %Y") if order.created_at else "—"

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Payout Invoice #{order.id}</title>
  <style>
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{ font-family: -apple-system, sans-serif; background: #f1f5f9; padding: 32px 16px; color: #1e293b; }}
    .card {{ background: #fff; border-radius: 16px; padding: 32px; max-width: 560px; margin: 0 auto;
             box-shadow: 0 2px 16px rgba(0,0,0,0.08); }}
    h1 {{ font-size: 22px; color: #3730a3; margin-bottom: 4px; }}
    .sub {{ font-size: 13px; color: #64748b; margin-bottom: 28px; }}
    .section {{ margin-bottom: 24px; }}
    .section h2 {{ font-size: 13px; font-weight: 600; text-transform: uppercase;
                   letter-spacing: 0.05em; color: #94a3b8; margin-bottom: 10px; }}
    .row {{ display: flex; justify-content: space-between; padding: 6px 0;
            border-bottom: 1px solid #f1f5f9; font-size: 14px; }}
    .row:last-child {{ border-bottom: none; }}
    .label {{ color: #64748b; }}
    .value {{ font-weight: 500; }}
    .total-row {{ background: #eff6ff; border-radius: 8px; padding: 12px 14px;
                  display: flex; justify-content: space-between; margin-top: 12px; }}
    .total-label {{ font-weight: 600; color: #3730a3; font-size: 15px; }}
    .total-value {{ font-weight: 700; color: #3730a3; font-size: 18px; }}
    .ref {{ background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px;
            padding: 12px 14px; margin-top: 16px; font-size: 13px; color: #15803d; }}
    @media print {{ body {{ background: #fff; }} .card {{ box-shadow: none; }} }}
  </style>
</head>
<body>
  <div class="card">
    <h1>Payout Invoice</h1>
    <p class="sub">Order #{order.id} &nbsp;·&nbsp; {order_date}</p>

    <div class="section">
      <h2>Farmer</h2>
      <div class="row"><span class="label">Name</span><span class="value">{owner.name}</span></div>
      <div class="row"><span class="label">Bank</span><span class="value">{owner.bank_name or '—'}</span></div>
      <div class="row"><span class="label">Account No.</span><span class="value">{owner.bank_account_number or '—'}</span></div>
      <div class="row"><span class="label">Account Name</span><span class="value">{owner.bank_account_name or '—'}</span></div>
    </div>

    <div class="section">
      <h2>Order Summary</h2>
      <div class="row"><span class="label">Farm</span><span class="value">{order.farm.name}</span></div>
      <div class="row"><span class="label">Quantity</span><span class="value">{float(order.quantity_kg):.1f} kg</span></div>
      <div class="row"><span class="label">Price per kg</span><span class="value">RM {float(order.price_per_kg):.2f}</span></div>
      <div class="row"><span class="label">Buyer paid (total)</span><span class="value">RM {gross:.2f}</span></div>
      <div class="row"><span class="label">Platform fee (2%)</span><span class="value">− RM {fee:.2f}</span></div>
    </div>

    <div class="total-row">
      <span class="total-label">Net payout to farmer</span>
      <span class="total-value">RM {net:.2f}</span>
    </div>

    <div class="ref">
      ✓ &nbsp;Paid on {paid_date} &nbsp;·&nbsp; Ref: {order.payout_reference or '—'}
    </div>
  </div>
</body>
</html>"""
    return HTMLResponse(content=html)


# ── Reviews moderation ────────────────────────────────────────────────────────

@router.delete("/reviews/{review_id}", status_code=status.HTTP_204_NO_CONTENT)
def admin_delete_review(
    review_id: int,
    admin: User = Depends(require_admin),
    db: Session = Depends(get_db),
):
    t = db.query(Testimonial).filter(Testimonial.id == review_id).first()
    if not t:
        raise HTTPException(status_code=404, detail="Review not found")
    db.delete(t)
    db.commit()
