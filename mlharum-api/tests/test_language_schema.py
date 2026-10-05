import pytest
from pydantic import ValidationError

from schemas import UserProfileResponse, UserProfileUpdate


@pytest.mark.parametrize("lang", ["en", "ms"])
def test_update_accepts_supported_languages(lang):
    assert UserProfileUpdate(language=lang).language == lang


@pytest.mark.parametrize("lang", ["fr", "", "MS", "ms-MY"])
def test_update_rejects_unsupported_languages(lang):
    with pytest.raises(ValidationError):
        UserProfileUpdate(language=lang)


def test_language_only_update_touches_no_other_field():
    # routers/auth.py applies model_dump(exclude_none=True) with setattr
    assert UserProfileUpdate(language="ms").model_dump(exclude_none=True) == {"language": "ms"}


def test_update_without_language_does_not_clear_it():
    assert "language" not in UserProfileUpdate(name="Ali").model_dump(exclude_none=True)


def test_response_language_defaults_to_none():
    r = UserProfileResponse(id=1, name="Ali", email="ali@example.com", phone=None, whatsapp=None, role="farmer")
    assert r.language is None
