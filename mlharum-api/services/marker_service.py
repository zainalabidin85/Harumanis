"""Finds the printed reference sticker (magenta circle or square on a white ring)."""
import cv2
import numpy as np
from dataclasses import dataclass
from config import settings

_KERNEL = np.ones((5, 5), np.uint8)


@dataclass
class StickerMarker:
    kind: str          # "circle" | "square"
    width_px: float    # true diameter / long side, from pixel area and fitted aspect ratio
    span_cm: float
    center_x: float
    center_y: float


def _has_white_ring(hsv: np.ndarray, inner: np.ndarray) -> bool:
    near = cv2.dilate(inner, np.ones((7, 7), np.uint8))
    far = cv2.dilate(inner, np.ones((17, 17), np.uint8))
    band = cv2.subtract(far, near) > 0  # 3–8 px outside the edge
    if not band.any():
        return False
    s, v = hsv[..., 1][band], hsv[..., 2][band]
    return np.mean((s < 60) & (v > 170)) >= 0.6


# Widths come from the filled pixel count, not the contour: contour points sit on the
# edge pixels' centres, which reads 1–2 px short — ~4% on a 15 mm sticker.

def _as_square(contour: np.ndarray, area: float, pixel_area: int) -> float | None:
    approx = cv2.approxPolyDP(contour, 0.04 * cv2.arcLength(contour, True), True)
    if len(approx) != 4 or not cv2.isContourConvex(approx):
        return None
    (_, _), (w, h), _ = cv2.minAreaRect(contour)
    long_side, short_side = max(w, h), min(w, h)
    if short_side == 0 or long_side / short_side > 1.6 or area / (w * h) < 0.85:
        return None
    return float(np.sqrt(pixel_area * long_side / short_side))


def _as_circle(contour: np.ndarray, area: float, pixel_area: int) -> float | None:
    if len(contour) < 5:
        return None
    hull_area = cv2.contourArea(cv2.convexHull(contour))
    if hull_area == 0 or area / hull_area < 0.95:
        return None
    (_, _), (a, b), _ = cv2.fitEllipse(contour)
    major, minor = max(a, b), min(a, b)
    if minor == 0 or major / minor > 2.0:
        return None
    if not 0.92 <= area / (np.pi * a * b / 4) <= 1.08:
        return None
    return float(np.sqrt(4 * pixel_area / np.pi * major / minor))


def detect_sticker(image_bgr: np.ndarray) -> StickerMarker | None:
    hsv = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2HSV)
    mask = cv2.inRange(
        hsv,
        (settings.sticker_hue_min, settings.sticker_sat_min, settings.sticker_val_min),
        (settings.sticker_hue_max, 255, 255),
    )
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, _KERNEL)
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, _KERNEL)
    contours, _ = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_NONE)

    best = None
    for c in contours:
        area = cv2.contourArea(c)
        if area < settings.sticker_min_area_px:
            continue
        region = np.zeros(mask.shape, np.uint8)
        cv2.drawContours(region, [c], -1, 255, -1)
        if not _has_white_ring(hsv, region):
            continue
        pixel_area = cv2.countNonZero(region)
        width = _as_square(c, area, pixel_area)
        if width is not None:
            kind, span = "square", settings.sticker_square_side_cm
        else:
            width = _as_circle(c, area, pixel_area)
            if width is None:
                continue
            kind, span = "circle", settings.sticker_circle_diameter_cm
        if best is None or width > best.width_px:
            m = cv2.moments(c)
            best = StickerMarker(kind, width, span, m["m10"] / m["m00"], m["m01"] / m["m00"])
    return best
