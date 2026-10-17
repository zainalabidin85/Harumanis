"""ToyyibPay payment gateway. API reference: https://toyyibpay.com/apireference/"""
import hashlib
import hmac
import json
import re
from typing import Optional

import httpx
from config import settings

PRODUCTION_BASE = "https://toyyibpay.com"
SANDBOX_BASE = "https://dev.toyyibpay.com"

STATUS_SUCCESS = "1"
STATUS_PENDING = "2"


class ToyyibPayError(Exception):
    """ToyyibPay answered, but not with what we asked for (it returns HTTP 200 for errors too)."""


def _base_url() -> str:
    return SANDBOX_BASE if settings.toyyibpay_sandbox else PRODUCTION_BASE


def payment_url(bill_code: str) -> str:
    return f"{_base_url()}/{bill_code}"


def clean_text(text: str, limit: int) -> str:
    """billName and billDescription accept only letters, digits, spaces and underscores."""
    cleaned = re.sub(r"[^A-Za-z0-9 _]", " ", text)
    cleaned = re.sub(r" +", " ", cleaned).strip()
    return cleaned[:limit].strip()


def digits_only(phone: Optional[str]) -> str:
    return re.sub(r"\D", "", phone or "")


def _parse_json(body: str):
    try:
        return json.loads(body)
    except ValueError:
        # Account/category errors come back as plain text such as "[KEY-DID-NOT-EXIST]".
        raise ToyyibPayError(body.strip()[:200] or "empty response")


def bill_payload(
    order_id: int,
    buyer_name: str,
    buyer_email: str,
    buyer_phone: Optional[str],
    total_price: float,
    description: str,
) -> dict:
    return {
        "userSecretKey": settings.toyyibpay_secret_key,
        "categoryCode": settings.toyyibpay_category_code,
        "billName": clean_text(f"Harumanis Order {order_id}", 30),
        "billDescription": clean_text(description, 100),
        "billPriceSetting": "1",
        "billPayorInfo": "1",
        "billAmount": str(int(round(total_price * 100))),
        "billReturnUrl": f"{settings.api_base_url}/orders/{order_id}/payment/redirect",
        "billCallbackUrl": f"{settings.api_base_url}/orders/payment/callback",
        "billExternalReferenceNo": str(order_id),
        "billTo": buyer_name,
        "billEmail": buyer_email,
        "billPhone": digits_only(buyer_phone),
        "billPaymentChannel": settings.toyyibpay_payment_channel,
    }


def parse_bill_code(body: str) -> str:
    data = _parse_json(body)
    if isinstance(data, list) and data and isinstance(data[0], dict) and data[0].get("BillCode"):
        return data[0]["BillCode"]
    raise ToyyibPayError(str(data)[:200])


def create_bill(**kwargs) -> str:
    """Create a fixed-amount bill and return its BillCode."""
    resp = httpx.post(
        f"{_base_url()}/index.php/api/createBill",
        data=bill_payload(**kwargs),
        timeout=15,
    )
    resp.raise_for_status()
    return parse_bill_code(resp.text)


def callback_hash_valid(form: dict) -> bool:
    """hash = MD5(userSecretKey + status + order_id + refno + "ok"), per the API reference."""
    if not settings.toyyibpay_secret_key:
        return False
    source = (
        settings.toyyibpay_secret_key
        + str(form.get("status", ""))
        + str(form.get("order_id", ""))
        + str(form.get("refno", ""))
        + "ok"
    )
    expected = hashlib.md5(source.encode()).hexdigest()
    return hmac.compare_digest(expected, str(form.get("hash", "")))


def transactions_show_paid(body: str) -> bool:
    data = _parse_json(body)
    if not isinstance(data, list):
        raise ToyyibPayError(str(data)[:200])
    return any(str(t.get("billpaymentStatus")) == STATUS_SUCCESS for t in data if isinstance(t, dict))


def bill_paid(bill_code: str) -> bool:
    """Ask ToyyibPay directly whether a bill has a successful payment."""
    resp = httpx.post(
        f"{_base_url()}/index.php/api/getBillTransactions",
        data={"billCode": bill_code, "userSecretKey": settings.toyyibpay_secret_key},
        timeout=15,
    )
    resp.raise_for_status()
    return transactions_show_paid(resp.text)
