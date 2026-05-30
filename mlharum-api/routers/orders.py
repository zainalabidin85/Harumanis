import logging
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Request, status
from fastapi.responses import HTMLResponse
from sqlalchemy.orm import Session
from database import get_db
from models.farm import Farm
from models.order import Order
from models.user import User
from auth_utils import get_current_user, require_buyer, require_farmer
from schemas import OrderCreate, OrderResponse, OrderStatusUpdate, PaymentInitResponse
from services import billplz_service

logger = logging.getLogger(__name__)
router = APIRouter()

PLATFORM_FEE_RATE = 0.02  # Billplz 1% + Zainal maintenance 1%


def _order_to_response(order: Order) -> OrderResponse:
    return OrderResponse(
        id=order.id,
        farm_id=order.farm_id,
        farm_name=order.farm.name,
        farmer_whatsapp=order.farm.owner.whatsapp,
        buyer_id=order.buyer_id,
        buyer_name=order.buyer.name,
        buyer_address=order.buyer.address,
        quantity_kg=float(order.quantity_kg),
        price_per_kg=float(order.price_per_kg),
        total_price=float(order.total_price),
        target_harvest_date=order.target_harvest_date,
        notes=order.notes,
        status=order.status,
        billplz_bill_id=order.billplz_bill_id,
        billplz_paid=order.billplz_paid,
        paid_at=order.paid_at,
        confirmed_at=order.confirmed_at,
        harvested_at=order.harvested_at,
        delivered_at=order.delivered_at,
        cancelled_at=order.cancelled_at,
        created_at=order.created_at,
    )


# ── Buyer endpoints ───────────────────────────────────────────────────────────

@router.post("", response_model=OrderResponse, status_code=status.HTTP_201_CREATED)
def create_order(payload: OrderCreate, buyer: User = Depends(require_buyer), db: Session = Depends(get_db)):
    farm = db.query(Farm).filter(Farm.id == payload.farm_id, Farm.is_public == True).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found or not publicly listed")
    if not farm.price_per_kg:
        raise HTTPException(status_code=400, detail="Farmer has not set a price yet. Please check back later.")

    unpaid_count = db.query(Order).filter(
        Order.buyer_id == buyer.id,
        Order.status.in_(["pending", "confirmed"]),
        Order.billplz_paid == False,
    ).count()
    if unpaid_count >= 3:
        raise HTTPException(status_code=429, detail="You have 3 unpaid orders. Please pay or cancel existing orders before placing a new one.")

    price = round(float(farm.price_per_kg) * (1 + PLATFORM_FEE_RATE), 2)
    total = round(payload.quantity_kg * price, 2)
    order = Order(
        buyer_id=buyer.id,
        farm_id=farm.id,
        quantity_kg=payload.quantity_kg,
        price_per_kg=price,
        total_price=total,
        target_harvest_date=payload.target_harvest_date,
        notes=payload.notes,
        status="pending",
    )
    db.add(order)
    db.commit()
    db.refresh(order)
    return _order_to_response(order)


@router.get("/my", response_model=list[OrderResponse])
def my_orders(buyer: User = Depends(require_buyer), db: Session = Depends(get_db)):
    orders = db.query(Order).filter(Order.buyer_id == buyer.id).order_by(Order.created_at.desc()).all()
    return [_order_to_response(o) for o in orders]


@router.post("/{order_id}/pay", response_model=PaymentInitResponse)
def initiate_payment(order_id: int, buyer: User = Depends(require_buyer), db: Session = Depends(get_db)):
    order = db.query(Order).filter(Order.id == order_id, Order.buyer_id == buyer.id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.billplz_paid:
        raise HTTPException(status_code=400, detail="Order already paid")

    try:
        bill = billplz_service.create_bill(
            order_id=order.id,
            buyer_email=buyer.email,
            buyer_name=buyer.name,
            total_price=float(order.total_price),
            description=f"Harumanis order from {order.farm.name} — {order.quantity_kg} kg",
        )
    except Exception as exc:
        logger.error("Billplz bill creation failed for order %s: %s", order_id, exc)
        raise HTTPException(status_code=502, detail="Payment gateway error. Please try again.")

    order.billplz_bill_id = bill["bill_id"]
    db.commit()

    return PaymentInitResponse(
        order_id=order.id,
        payment_url=bill["payment_url"],
        billplz_bill_id=bill["bill_id"],
    )


# ── Payment redirect (browser → app deep link) ───────────────────────────────

@router.get("/{order_id}/payment/redirect", response_class=HTMLResponse)
def payment_redirect(order_id: int):
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Payment Complete</title>
  <style>
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{ font-family: -apple-system, sans-serif; background: #FFFBEB;
           display: flex; align-items: center; justify-content: center;
           min-height: 100vh; padding: 24px; }}
    .card {{ background: #fff; border-radius: 24px; padding: 40px 32px;
             max-width: 360px; width: 100%; text-align: center;
             box-shadow: 0 4px 24px rgba(0,0,0,0.08); }}
    .icon {{ font-size: 64px; margin-bottom: 20px; }}
    h2 {{ color: #B45309; font-size: 22px; margin-bottom: 8px; }}
    p {{ color: #6B7280; font-size: 14px; margin-bottom: 28px; line-height: 1.5; }}
    a.btn {{ display: block; background: #B45309; color: #fff; padding: 14px 24px;
             border-radius: 14px; text-decoration: none; font-weight: 600;
             font-size: 15px; }}
    .note {{ margin-top: 16px; font-size: 12px; color: #9CA3AF; }}
  </style>
  <script>
    window.onload = function() {{
      setTimeout(function() {{
        window.location.href = 'harumanis://payment/success?order_id={order_id}';
      }}, 800);
    }};
  </script>
</head>
<body>
  <div class="card">
    <div class="icon">🥭</div>
    <h2>Payment Received!</h2>
    <p>Thank you. Your order has been confirmed.<br>Returning you to the Harumanis app&hellip;</p>
    <a class="btn" href="harumanis://payment/success?order_id={order_id}">Open Harumanis App</a>
    <p class="note">If the app does not open automatically, tap the button above.</p>
  </div>
</body>
</html>"""
    return HTMLResponse(content=html)


# ── Payment callback (Billplz webhook) ───────────────────────────────────────

@router.post("/payment/callback")
async def payment_callback(request: Request, db: Session = Depends(get_db)):
    form = dict(await request.form())
    x_signature = request.headers.get("X-Signature", "")

    if not billplz_service.verify_webhook_signature(form, x_signature):
        raise HTTPException(status_code=400, detail="Invalid signature")

    bill_id = form.get("id")
    paid = form.get("paid", "false").lower() == "true"

    order = db.query(Order).filter(Order.billplz_bill_id == bill_id).first()
    if order and paid and not order.billplz_paid:
        now = datetime.utcnow()
        order.billplz_paid = True
        order.paid_at = now
        order.status = "confirmed"
        if order.confirmed_at is None:
            order.confirmed_at = now
        db.commit()

    return {"status": "ok"}


# ── Farmer endpoints (manage incoming orders) ─────────────────────────────────

@router.get("/farm/{farm_id}", response_model=list[OrderResponse])
def farm_orders(farm_id: int, farmer: User = Depends(require_farmer), db: Session = Depends(get_db)):
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == farmer.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    orders = db.query(Order).filter(Order.farm_id == farm_id).order_by(Order.created_at.desc()).all()
    return [_order_to_response(o) for o in orders]


@router.patch("/{order_id}/status", response_model=OrderResponse)
def update_order_status(
    order_id: int,
    payload: OrderStatusUpdate,
    farmer: User = Depends(require_farmer),
    db: Session = Depends(get_db),
):
    order = db.query(Order).filter(Order.id == order_id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")

    farm = db.query(Farm).filter(Farm.id == order.farm_id, Farm.user_id == farmer.id).first()
    if not farm:
        raise HTTPException(status_code=403, detail="Not your farm's order")

    now = datetime.utcnow()
    order.status = payload.status
    if payload.status == "confirmed" and order.confirmed_at is None:
        order.confirmed_at = now
    elif payload.status == "harvested" and order.harvested_at is None:
        order.harvested_at = now
    elif payload.status == "delivered" and order.delivered_at is None:
        order.delivered_at = now
    elif payload.status == "cancelled" and order.cancelled_at is None:
        order.cancelled_at = now
    db.commit()
    db.refresh(order)
    return _order_to_response(order)
