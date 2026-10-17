import hashlib
from types import SimpleNamespace

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient

from config import settings
from database import get_db
from routers import orders
from services import toyyibpay_service as tp

SECRET = "test-secret-key"


@pytest.fixture(autouse=True)
def toyyibpay_settings(monkeypatch):
    monkeypatch.setattr(settings, "toyyibpay_secret_key", SECRET)
    monkeypatch.setattr(settings, "toyyibpay_category_code", "cat123")
    monkeypatch.setattr(settings, "toyyibpay_sandbox", True)


def _hash(status, order_id, refno):
    return hashlib.md5(f"{SECRET}{status}{order_id}{refno}ok".encode()).hexdigest()


# ── Service helpers ───────────────────────────────────────────────────────────

def test_clean_text_keeps_only_allowed_characters_and_limit():
    assert tp.clean_text("Ladang Pak Ali (Kangar) — 2.5kg!", 100) == "Ladang Pak Ali Kangar 2 5kg"
    assert len(tp.clean_text("x" * 50, 30)) == 30


def test_bill_payload():
    p = tp.bill_payload(
        order_id=42, buyer_name="Siti", buyer_email="siti@example.com",
        buyer_phone="+60 12-345 6789", total_price=153.0, description="Harumanis order 42 from Ladang D'Pak",
    )
    assert p["billAmount"] == "15300"
    assert p["billPriceSetting"] == "1"
    assert p["billPayorInfo"] == "1"
    assert p["billPhone"] == "60123456789"
    assert p["billExternalReferenceNo"] == "42"
    assert p["categoryCode"] == "cat123"
    assert len(p["billName"]) <= 30
    assert "'" not in p["billDescription"]
    assert p["billReturnUrl"].endswith("/orders/42/payment/redirect")
    assert p["billCallbackUrl"].endswith("/orders/payment/callback")


def test_amount_rounds_to_whole_cents():
    p = tp.bill_payload(order_id=1, buyer_name="a", buyer_email="a@b.co", buyer_phone=None,
                        total_price=10.005, description="x")
    assert p["billAmount"] in ("1000", "1001")
    assert p["billPhone"] == ""


def test_parse_bill_code():
    assert tp.parse_bill_code('[{"BillCode":"gcbhict9"}]') == "gcbhict9"
    for bad in ("[KEY-DID-NOT-EXIST]", '{"status":"error","msg":"billName"}', "", "[]"):
        with pytest.raises(tp.ToyyibPayError):
            tp.parse_bill_code(bad)


def test_payment_url_follows_sandbox_setting(monkeypatch):
    assert tp.payment_url("abc") == "https://dev.toyyibpay.com/abc"
    monkeypatch.setattr(settings, "toyyibpay_sandbox", False)
    assert tp.payment_url("abc") == "https://toyyibpay.com/abc"


def test_callback_hash():
    form = {"status": "1", "order_id": "42", "refno": "TP123", "billcode": "b1"}
    assert tp.callback_hash_valid({**form, "hash": _hash("1", "42", "TP123")})
    # A forged success with a hash computed for a failed payment is rejected.
    assert not tp.callback_hash_valid({**form, "hash": _hash("3", "42", "TP123")})
    assert not tp.callback_hash_valid(form)


def test_callback_hash_rejected_without_secret(monkeypatch):
    monkeypatch.setattr(settings, "toyyibpay_secret_key", "")
    form = {"status": "1", "order_id": "42", "refno": "TP123"}
    form["hash"] = hashlib.md5(b"142TP123ok").hexdigest()
    assert not tp.callback_hash_valid(form)


def test_transactions_show_paid():
    assert tp.transactions_show_paid('[{"billpaymentStatus":"3"},{"billpaymentStatus":"1"}]')
    assert not tp.transactions_show_paid('[{"billpaymentStatus":"2"}]')
    assert not tp.transactions_show_paid("[]")
    with pytest.raises(tp.ToyyibPayError):
        tp.transactions_show_paid("No data found!")


# ── Order state ───────────────────────────────────────────────────────────────

def _order(**kw):
    base = dict(id=42, status="confirmed", is_paid=False, paid_at=None, confirmed_at=None,
                payment_bill_code="b1")
    base.update(kw)
    return SimpleNamespace(**base)


def test_mark_paid_never_moves_order_backwards():
    o = _order(status="harvested")
    orders._mark_paid(o)
    assert o.is_paid and o.paid_at is not None
    assert o.status == "harvested"


def test_mark_paid_confirms_pending_order():
    o = _order(status="pending")
    orders._mark_paid(o)
    assert o.status == "confirmed" and o.confirmed_at is not None


def test_mark_paid_keeps_first_payment_time():
    o = _order(is_paid=True, paid_at="earlier")
    orders._mark_paid(o)
    assert o.paid_at == "earlier"


# ── Routes ────────────────────────────────────────────────────────────────────

class _FakeQuery:
    def __init__(self, result):
        self.result = result

    def filter(self, *a, **k):
        return self

    def first(self):
        return self.result


class _FakeDB:
    def __init__(self, order):
        self.order = order
        self.commits = 0

    def query(self, *a):
        return _FakeQuery(self.order)

    def commit(self):
        self.commits += 1


def _client(order):
    db = _FakeDB(order)
    app = FastAPI()
    app.include_router(orders.router, prefix="/orders")
    app.dependency_overrides[get_db] = lambda: db
    return TestClient(app), db


def test_callback_marks_paid():
    order = _order()
    client, db = _client(order)
    r = client.post("/orders/payment/callback", data={
        "status": "1", "order_id": "42", "refno": "TP1", "billcode": "b1",
        "hash": _hash("1", "42", "TP1"),
    })
    assert r.status_code == 200
    assert order.is_paid and db.commits == 1


def test_callback_with_bad_hash_changes_nothing():
    order = _order()
    client, db = _client(order)
    r = client.post("/orders/payment/callback", data={
        "status": "1", "order_id": "42", "refno": "TP1", "billcode": "b1", "hash": "forged",
    })
    assert r.status_code == 400
    assert not order.is_paid and db.commits == 0


def test_callback_for_failed_payment_changes_nothing():
    order = _order()
    client, _ = _client(order)
    r = client.post("/orders/payment/callback", data={
        "status": "3", "order_id": "42", "refno": "TP1", "billcode": "b1",
        "hash": _hash("3", "42", "TP1"),
    })
    assert r.status_code == 200
    assert not order.is_paid


def test_callback_order_id_must_match_bill():
    order = _order(id=99)
    client, _ = _client(order)
    client.post("/orders/payment/callback", data={
        "status": "1", "order_id": "42", "refno": "TP1", "billcode": "b1",
        "hash": _hash("1", "42", "TP1"),
    })
    assert not order.is_paid


def test_return_page_trusts_toyyibpay_not_the_query_string(monkeypatch):
    monkeypatch.setattr(tp, "bill_paid", lambda code: False)
    order = _order()
    client, _ = _client(order)
    # A hand-typed status_id=1 must not mark the order paid or show success.
    r = client.get("/orders/42/payment/redirect?status_id=1&billcode=b1")
    assert not order.is_paid
    assert "harumanis://payment/success" not in r.text
    assert "Confirming Your Payment" in r.text


def test_return_page_success_when_toyyibpay_confirms(monkeypatch):
    monkeypatch.setattr(tp, "bill_paid", lambda code: True)
    order = _order()
    client, _ = _client(order)
    r = client.get("/orders/42/payment/redirect?status_id=1&billcode=b1")
    assert order.is_paid
    assert "harumanis://payment/success?order_id=42" in r.text


def test_return_page_failed_payment(monkeypatch):
    monkeypatch.setattr(tp, "bill_paid", lambda code: False)
    client, _ = _client(_order())
    r = client.get("/orders/42/payment/redirect?status_id=3&billcode=b1")
    assert "Payment Not Completed" in r.text
    assert "harumanis://orders?order_id=42" in r.text


def test_return_page_survives_gateway_error(monkeypatch):
    def boom(code):
        raise tp.ToyyibPayError("down")
    monkeypatch.setattr(tp, "bill_paid", boom)
    client, _ = _client(_order())
    r = client.get("/orders/42/payment/redirect?status_id=2&billcode=b1")
    assert r.status_code == 200
    assert "Confirming Your Payment" in r.text
