import hashlib
import hmac
import httpx
from config import settings


BILLPLZ_BASE = "https://www.billplz.com/api/v3"
BILLPLZ_SANDBOX_BASE = "https://www.billplz-sandbox.com/api/v3"


def _base_url() -> str:
    return BILLPLZ_SANDBOX_BASE if settings.billplz_sandbox else BILLPLZ_BASE


def create_bill(order_id: int, buyer_email: str, buyer_name: str, total_price: float, description: str) -> dict:
    """Create a Billplz bill and return the bill dict (id, url)."""
    amount_cents = int(round(total_price * 100))
    payload = {
        "collection_id": settings.billplz_collection_id,
        "email": buyer_email,
        "name": buyer_name,
        "amount": amount_cents,
        "description": description,
        "callback_url": f"{settings.api_base_url}/orders/payment/callback",
        "redirect_url": f"{settings.api_base_url}/orders/{order_id}/payment/redirect",
        "reference_1_label": "Order ID",
        "reference_1": str(order_id),
    }
    resp = httpx.post(
        f"{_base_url()}/bills",
        data=payload,
        auth=(settings.billplz_api_key, ""),
        timeout=15,
    )
    resp.raise_for_status()
    data = resp.json()
    return {"bill_id": data["id"], "payment_url": data["url"]}


def verify_webhook_signature(payload: dict, x_signature: str) -> bool:
    """Verify Billplz X-Signature header to confirm the webhook is genuine."""
    sorted_keys = sorted(payload.keys())
    source = "|".join(f"{k}{payload[k]}" for k in sorted_keys)
    expected = hmac.new(
        settings.billplz_x_signature.encode(),
        source.encode(),
        hashlib.sha256,
    ).hexdigest()
    return hmac.compare_digest(expected, x_signature)
