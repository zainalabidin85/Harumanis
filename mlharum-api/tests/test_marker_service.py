import cv2
import numpy as np
import pytest

from services.marker_service import detect_sticker

LEAF_GREEN = (40, 120, 40)
MAGENTA = (126, 0, 230)  # BGR of print magenta #E6007E
WHITE = (255, 255, 255)
RING = 8


def _canvas():
    return np.full((720, 1280, 3), LEAF_GREEN, np.uint8)


def _circle(img, center, diameter, ring=True):
    r = diameter // 2
    if ring:
        cv2.circle(img, center, r + RING, WHITE, -1)
    cv2.circle(img, center, r, MAGENTA, -1)
    return img


def _square(img, center, side, angle=0, ring=True):
    def box(s):
        return cv2.boxPoints((center, (s, s), angle)).astype(np.int32)
    if ring:
        cv2.fillPoly(img, [box(side + 2 * RING)], WHITE)
    cv2.fillPoly(img, [box(side)], MAGENTA)
    return img


def test_finds_circle_sticker():
    m = detect_sticker(_circle(_canvas(), (640, 360), 100))
    assert m.kind == "circle"
    assert m.width_px == pytest.approx(100, abs=3)
    assert m.span_cm == 1.5


def test_finds_square_sticker():
    m = detect_sticker(_square(_canvas(), (640, 360), 100))
    assert m.kind == "square"
    assert m.width_px == pytest.approx(100, abs=3)
    assert m.span_cm == 1.5


def test_tilted_circle_uses_long_axis():
    # A circle seen at an angle is an ellipse; its long axis is the true diameter.
    img = _canvas()
    cv2.ellipse(img, (640, 360), (50 + RING, 30 + RING), 0, 0, 360, WHITE, -1)
    cv2.ellipse(img, (640, 360), (50, 30), 0, 0, 360, MAGENTA, -1)
    m = detect_sticker(img)
    assert m.kind == "circle"
    assert m.width_px == pytest.approx(100, abs=3)


def test_rotated_square_uses_long_side():
    m = detect_sticker(_square(_canvas(), (640, 360), 100, angle=30))
    assert m.kind == "square"
    assert m.width_px == pytest.approx(100, abs=4)


def test_magenta_without_white_ring_ignored():
    assert detect_sticker(_circle(_canvas(), (640, 360), 100, ring=False)) is None


def test_irregular_magenta_shape_ignored():
    img = _canvas()
    tri = np.array([[640, 290], [580, 410], [700, 410]], np.int32)
    ring = np.array([[640, 274], [568, 418], [712, 418]], np.int32)
    cv2.fillPoly(img, [ring], WHITE)
    cv2.fillPoly(img, [tri], MAGENTA)
    assert detect_sticker(img) is None


def test_partly_covered_circle_ignored():
    # A leaf over the right third: measuring what's left would read short.
    img = _circle(_canvas(), (640, 360), 100)
    cv2.rectangle(img, (657, 300), (717, 420), LEAF_GREEN, -1)
    assert detect_sticker(img) is None


def test_tiny_sticker_ignored():
    assert detect_sticker(_circle(_canvas(), (640, 360), 15)) is None


def test_largest_sticker_wins():
    img = _circle(_canvas(), (400, 360), 60)
    _square(img, (900, 360), 120)
    assert detect_sticker(img).kind == "square"


def test_plain_image_returns_none():
    assert detect_sticker(_canvas()) is None
