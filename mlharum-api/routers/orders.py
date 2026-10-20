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
from services import toyyibpay_service
from config import settings

logger = logging.getLogger(__name__)
router = APIRouter()

PLATFORM_FEE_RATE = 0.02  # payment gateway fee + Zainal maintenance 1%

# Shown by Beli 1.10+; 1.9.5 shows its own generic "failed" text but is still refused.
MARKETPLACE_PAUSED_DETAIL = (
    "Beli Harumanis ditutup buat sementara. Pesanan dan bayaran baharu tidak diterima. / "
    "Beli Harumanis is paused for now. New orders and payments are not accepted."
)


def _require_marketplace_open() -> None:
    if not settings.marketplace_open:
        raise HTTPException(status_code=503, detail=MARKETPLACE_PAUSED_DETAIL)


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
        payment_bill_code=order.payment_bill_code,
        is_paid=order.is_paid,
        billplz_bill_id=order.payment_bill_code,
        billplz_paid=order.is_paid,
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
    _require_marketplace_open()
    farm = db.query(Farm).filter(Farm.id == payload.farm_id, Farm.is_public == True).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found or not publicly listed")
    if not farm.price_per_kg:
        raise HTTPException(status_code=400, detail="Farmer has not set a price yet. Please check back later.")

    unpaid_count = db.query(Order).filter(
        Order.buyer_id == buyer.id,
        Order.status.in_(["pending", "confirmed"]),
        Order.is_paid == False,
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


def _mark_paid(order: Order) -> None:
    """Record a verified payment. Never moves the order backwards (e.g. from harvested)."""
    if order.is_paid:
        return
    now = datetime.utcnow()
    order.is_paid = True
    order.paid_at = now
    if order.status == "pending":
        order.status = "confirmed"
    if order.confirmed_at is None:
        order.confirmed_at = now


@router.post("/{order_id}/pay", response_model=PaymentInitResponse)
def initiate_payment(order_id: int, buyer: User = Depends(require_buyer), db: Session = Depends(get_db)):
    _require_marketplace_open()
    order = db.query(Order).filter(Order.id == order_id, Order.buyer_id == buyer.id).first()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    if order.is_paid:
        raise HTTPException(status_code=400, detail="Order already paid")
    if order.status != "confirmed":
        raise HTTPException(status_code=400, detail="The farmer must confirm this order before payment.")

    # Reuse the order's bill so pressing Pay Now twice can't create two payable bills.
    if not order.payment_bill_code:
        try:
            order.payment_bill_code = toyyibpay_service.create_bill(
                order_id=order.id,
                buyer_name=buyer.name,
                buyer_email=buyer.email,
                buyer_phone=buyer.phone or buyer.whatsapp,
                total_price=float(order.total_price),
                description=f"Harumanis order {order.id} from {order.farm.name}",
            )
        except Exception as exc:
            logger.error("ToyyibPay bill creation failed for order %s: %s", order_id, exc)
            raise HTTPException(status_code=502, detail="Payment gateway error. Please try again.")
        db.commit()

    return PaymentInitResponse(
        order_id=order.id,
        payment_url=toyyibpay_service.payment_url(order.payment_bill_code),
        bill_code=order.payment_bill_code,
    )


# ── Payment return page (browser → app deep link) ────────────────────────────

_RETURN_PAGES = {
    # state: (icon, colour, Malay title, English title, Malay body, English body, deep link)
    "paid": ("🥭", "#B45309", "Bayaran Diterima!", "Payment Received!",
             "Terima kasih. Pesanan anda telah dibayar.",
             "Thank you. Your order has been paid.",
             "harumanis://payment/success?order_id={id}"),
    "pending": ("⏳", "#B45309", "Bayaran Sedang Disahkan", "Confirming Your Payment",
                "Kami masih menunggu pengesahan daripada bank. Status pesanan akan dikemas kini sebentar lagi.",
                "We are still waiting for the bank to confirm. Your order will update shortly.",
                "harumanis://orders?order_id={id}"),
    "failed": ("⚠️", "#B91C1C", "Bayaran Tidak Berjaya", "Payment Not Completed",
               "Tiada caj dibuat. Anda boleh cuba bayar semula dari halaman pesanan.",
               "You were not charged. You can try again from the order page.",
               "harumanis://orders?order_id={id}"),
}


def _return_page(state: str, order_id: int) -> str:
    icon, colour, title_ms, title_en, body_ms, body_en, link = _RETURN_PAGES[state]
    link = link.format(id=order_id)
    return f"""<!DOCTYPE html>
<html lang="ms">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{title_ms}</title>
  <style>
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{ font-family: -apple-system, sans-serif; background: #FFFBEB;
           display: flex; align-items: center; justify-content: center;
           min-height: 100vh; padding: 24px; }}
    .card {{ background: #fff; border-radius: 24px; padding: 40px 32px;
             max-width: 360px; width: 100%; text-align: center;
             box-shadow: 0 4px 24px rgba(0,0,0,0.08); }}
    .icon {{ font-size: 64px; margin-bottom: 20px; }}
    h2 {{ color: {colour}; font-size: 22px; margin-bottom: 4px; }}
    h3 {{ color: #9CA3AF; font-size: 14px; font-weight: 500; margin-bottom: 12px; }}
    p {{ color: #6B7280; font-size: 14px; line-height: 1.5; }}
    p.en {{ color: #9CA3AF; font-size: 13px; margin: 4px 0 28px; }}
    a.btn {{ display: block; background: #B45309; color: #fff; padding: 14px 24px;
             border-radius: 14px; text-decoration: none; font-weight: 600;
             font-size: 15px; }}
  </style>
  <script>
    window.onload = function() {{
      setTimeout(function() {{ window.location.href = '{link}'; }}, 800);
    }};
  </script>
</head>
<body>
  <div class="card">
    <div class="icon">{icon}</div>
    <h2>{title_ms}</h2>
    <h3>{title_en}</h3>
    <p>{body_ms}</p>
    <p class="en">{body_en}</p>
    <a class="btn" href="{link}">Buka Beli Harumanis / Open app</a>
  </div>
</body>
</html>"""


@router.get("/{order_id}/payment/redirect", response_class=HTMLResponse)
def payment_redirect(order_id: int, status_id: str = "", db: Session = Depends(get_db)):
    """ToyyibPay sends the buyer here after paying. The query string is not signed,
    so a payment only counts once ToyyibPay itself confirms the bill is paid."""
    order = db.query(Order).filter(Order.id == order_id).first()
    if order and not order.is_paid and order.payment_bill_code:
        try:
            if toyyibpay_service.bill_paid(order.payment_bill_code):
                _mark_paid(order)
                db.commit()
        except Exception as exc:
            logger.warning("ToyyibPay status check failed for order %s: %s", order_id, exc)

    if order and order.is_paid:
        state = "paid"
    elif status_id in (toyyibpay_service.STATUS_SUCCESS, toyyibpay_service.STATUS_PENDING):
        # ToyyibPay says success/pending but has not confirmed it to us yet; the callback will.
        state = "pending"
    else:
        state = "failed"
    return HTMLResponse(content=_return_page(state, order_id))


# ── Payment callback (ToyyibPay server-to-server) ────────────────────────────

@router.post("/payment/callback")
async def payment_callback(request: Request, db: Session = Depends(get_db)):
    form = dict(await request.form())

    if not toyyibpay_service.callback_hash_valid(form):
        logger.warning("ToyyibPay callback with invalid hash for bill %s", form.get("billcode"))
        raise HTTPException(status_code=400, detail="Invalid hash")

    if str(form.get("status")) == toyyibpay_service.STATUS_SUCCESS:
        order = db.query(Order).filter(Order.payment_bill_code == form.get("billcode")).first()
        if order and str(order.id) == str(form.get("order_id")):
            _mark_paid(order)
            db.commit()
        else:
            logger.warning("ToyyibPay callback for unknown bill %s / order %s",
                           form.get("billcode"), form.get("order_id"))

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
