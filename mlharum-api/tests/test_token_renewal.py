from datetime import datetime, timedelta
from types import SimpleNamespace

import pytest
from fastapi import HTTPException
from jose import jwt

from auth_utils import create_access_token, renew_access_token
from config import settings


def _claims(token):
    return jwt.decode(token, settings.secret_key, algorithms=["HS256"])


def _user(suspended=False):
    return SimpleNamespace(id=7, role="farmer", is_suspended=suspended)


def test_tokens_last_ninety_days():
    assert settings.access_token_expire_minutes == 90 * 24 * 60
    exp = datetime.utcfromtimestamp(_claims(create_access_token(7))["exp"])
    remaining = exp - datetime.utcnow()
    assert timedelta(days=89, hours=23) < remaining <= timedelta(days=90)


def test_renewal_issues_a_fresh_token_for_the_same_user():
    claims = _claims(renew_access_token(_user()))
    assert claims["sub"] == "7"
    assert claims["role"] == "farmer"


def test_renewal_is_refused_for_a_suspended_account():
    with pytest.raises(HTTPException) as exc:
        renew_access_token(_user(suspended=True))
    assert exc.value.status_code == 403
