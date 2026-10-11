import pytest
from pydantic import ValidationError

from schemas import UserProfileResponse, UserProfileUpdate
from services.size_estimator import DEFAULT_HAND_SPAN_CM, estimate_size, resolve_hand_span_cm
from services.yolo_service import MangoDetection


def _mango(w, h):
    return MangoDetection(bbox_x=0, bbox_y=0, bbox_w=w, bbox_h=h, growth_stage=0, confidence=0.9)


def test_default_span_is_three_average_knuckles():
    assert DEFAULT_HAND_SPAN_CM == pytest.approx(5.4)


def test_unset_span_falls_back_to_average():
    # NULL = old APK or user who has not measured yet
    assert resolve_hand_span_cm(None) == DEFAULT_HAND_SPAN_CM


def test_personal_span_replaces_average():
    assert resolve_hand_span_cm(6.8) == pytest.approx(6.8)


def test_size_without_span_matches_old_behaviour():
    assert estimate_size(_mango(100, 120), 100) == pytest.approx(5.4)


def test_size_scales_with_personal_span():
    assert estimate_size(_mango(100, 120), 100, hand_span_cm=6.8) == pytest.approx(6.8)
    assert estimate_size(_mango(50, 80), 100, hand_span_cm=7.0) == pytest.approx(3.5)


@pytest.mark.parametrize("span", [4.0, 5.4, 6.75, 9.0])
def test_update_accepts_plausible_spans(span):
    assert UserProfileUpdate(knuckle_span_cm=span).knuckle_span_cm == span


@pytest.mark.parametrize("span", [0, -1, 3.9, 9.1, 54, 68])
def test_update_rejects_implausible_spans(span):
    # 54 / 68 = millimetres typed into a cm field
    with pytest.raises(ValidationError):
        UserProfileUpdate(knuckle_span_cm=span)


def test_span_only_update_touches_no_other_field():
    assert UserProfileUpdate(knuckle_span_cm=6.2).model_dump(exclude_none=True) == {"knuckle_span_cm": 6.2}


def test_response_span_defaults_to_none():
    r = UserProfileResponse(id=1, name="Ali", email="ali@example.com", phone=None, whatsapp=None, role="farmer")
    assert r.knuckle_span_cm is None
