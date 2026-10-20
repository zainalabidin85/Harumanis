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


_RING_SECTORS = 12


def _disc(radius: int) -> np.ndarray:
    return cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (2 * radius + 1, 2 * radius + 1))


def _has_white_ring(hsv: np.ndarray, inner: np.ndarray, near: int, far: int) -> bool:
    """White all the way round: a leaf or finger over one side fails its sector instead of
    leaving a squashed shape that reads long. "White" is relative to the sticker's own
    magenta, which shares its lighting, so shade and dim exposure still pass."""
    band = cv2.subtract(cv2.dilate(inner, _disc(far)), cv2.dilate(inner, _disc(near))) > 0
    ys, xs = np.nonzero(band)
    if len(xs) == 0:
        return False
    ink_v = np.median(hsv[..., 2][inner > 0])
    s, v = hsv[ys, xs, 1], hsv[ys, xs, 2]
    white = (s < 60) & (v >= 0.7 * ink_v)
    cy, cx = np.nonzero(inner)
    sector = ((np.arctan2(ys - cy.mean(), xs - cx.mean()) + np.pi) / (2 * np.pi) * _RING_SECTORS).astype(int) % _RING_SECTORS
    for k in range(_RING_SECTORS):
        in_k = sector == k
        if not in_k.any() or white[in_k].mean() < 0.8:
            return False
    return True


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
        pixel_area = cv2.countNonZero(region)
        # Ring band scales with the sticker (ring = 0.2 of its size): ~1–5 px at 15 mm in a 720 px photo.
        size = 2 * np.sqrt(pixel_area / np.pi)
        near = max(1, round(0.04 * size))
        far = max(near + 2, round(0.14 * size))
        x, y, w, h = cv2.boundingRect(c)
        img_h, img_w = mask.shape
        if x - far < 0 or y - far < 0 or x + w + far > img_w or y + h + far > img_h:
            continue  # ring runs off the frame: the sticker may be cut by the edge
        if not _has_white_ring(hsv, region, near, far):
            continue
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
