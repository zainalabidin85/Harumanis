import pytest

from services.marker_service import StickerMarker
from services.mediapipe_service import HandMarker
from services.size_estimator import (
    DEFAULT_HAND_SPAN_CM,
    Reference,
    choose_reference,
    estimate_size,
    sticker_fits_mango,
)
from services.yolo_service import MangoDetection


def _sticker(kind, width_px):
    return StickerMarker(kind=kind, width_px=width_px, span_cm=1.5, center_x=0, center_y=0)


def _hand(knuckle_px):
    return HandMarker(knuckle_width_px=knuckle_px, index_x=0, index_y=0, pinky_x=0, pinky_y=0)


def _mango(w, h):
    return MangoDetection(bbox_x=0, bbox_y=0, bbox_w=w, bbox_h=h, growth_stage=0, confidence=0.9)


def test_sticker_fits_mango_bounds():
    assert sticker_fits_mango(60, 160)         # 0.375: 1.5 cm sticker on a 4 cm fruit
    assert sticker_fits_mango(100, 50)         # 2.0 boundary
    assert sticker_fits_mango(100, 1000)       # 0.1 boundary
    assert not sticker_fits_mango(100, 40)     # 2.5: sticker far bigger than the fruit
    assert not sticker_fits_mango(100, 1200)   # 0.083: sticker far smaller


def test_sticker_wins_over_hand():
    ref = choose_reference(_sticker("circle", 60), _hand(80), 160, 6.5)
    assert (ref.type, ref.width_px, ref.span_cm) == ("circle", 60, 1.5)


def test_hand_used_when_no_sticker():
    assert choose_reference(None, _hand(80), 160, 6.5) == Reference(80, 6.5, "hand")


def test_hand_without_saved_span_uses_default():
    assert choose_reference(None, _hand(80), 160, None).span_cm == pytest.approx(DEFAULT_HAND_SPAN_CM)


def test_implausible_sticker_falls_back_to_hand():
    assert choose_reference(_sticker("square", 100), _hand(80), 40, 6.5).type == "hand"


def test_neither_returns_none():
    assert choose_reference(None, None, 160, 6.5) is None
    assert choose_reference(_sticker("circle", 100), None, 40, 6.5) is None


def test_size_from_sticker():
    # 160 px mango / 60 px sticker × 1.5 cm = 4.0 cm (Bagging lower bound)
    assert estimate_size(_mango(160, 200), 60, 1.5) == pytest.approx(4.0)


def test_no_reference_detail_keeps_old_app_match():
    # Old APKs show their localized no-hand message when the detail contains "No hand".
    from services.size_estimator import NO_REFERENCE_DETAIL
    assert "No hand" in NO_REFERENCE_DETAIL


def test_detection_response_reference_type_optional():
    from datetime import datetime
    from schemas import DetectionResponse
    r = DetectionResponse(tree_id=1, tree_number="T01", detection_date=datetime.now(),
                          mango_count=1, ready_for_bagging=True, message="x")
    assert r.reference_type is None and r.hand_index_x is None
