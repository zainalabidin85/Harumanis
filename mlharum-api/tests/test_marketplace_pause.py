from types import SimpleNamespace

import pytest
from fastapi import HTTPException

from config import settings
from routers import orders

BUYER = SimpleNamespace(id=7, role="buyer")


class NoDb:
    """Any query means the endpoint went past the pause check."""
    def query(self, *a):
        raise AssertionError("endpoint touched the database while the marketplace is paused")


def test_marketplace_closed_by_default():
    assert settings.marketplace_open is False


def test_new_orders_refused_while_paused():
    with pytest.raises(HTTPException) as exc:
        orders.create_order(payload=None, buyer=BUYER, db=NoDb())
    assert exc.value.status_code == 503
    assert exc.value.detail == orders.MARKETPLACE_PAUSED_DETAIL


def test_pay_now_refused_while_paused():
    with pytest.raises(HTTPException) as exc:
        orders.initiate_payment(order_id=1, buyer=BUYER, db=NoDb())
    assert exc.value.status_code == 503


def test_paused_message_is_bilingual():
    assert "Beli Harumanis" in orders.MARKETPLACE_PAUSED_DETAIL
    assert "sementara" in orders.MARKETPLACE_PAUSED_DETAIL  # Malay
    assert "paused" in orders.MARKETPLACE_PAUSED_DETAIL     # English


def test_orders_allowed_when_reopened(monkeypatch):
    monkeypatch.setattr(settings, "marketplace_open", True)
    with pytest.raises(AssertionError, match="touched the database"):
        orders.create_order(payload=SimpleNamespace(farm_id=1), buyer=BUYER, db=NoDb())
