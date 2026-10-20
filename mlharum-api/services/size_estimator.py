from dataclasses import dataclass
from typing import Optional

from config import settings
from services.marker_service import StickerMarker
from services.mediapipe_service import HandMarker
from services.yolo_service import MangoDetection


# Average distance across 4 MCP knuckles (index to pinky) in cm.
# Only used when the user has not saved their own measurement (users.knuckle_span_cm).
DEFAULT_HAND_SPAN_CM = settings.avg_knuckle_width_cm * 3  # ~5.4 cm for 3-knuckle span

# Sticker width / mango width outside this range is not the sticker (or not this mango's).
_STICKER_TO_MANGO_MIN = 0.1
_STICKER_TO_MANGO_MAX = 2.0


@dataclass
class Reference:
    width_px: float
    span_cm: float
    type: str  # "circle" | "square" | "hand"


def resolve_hand_span_cm(user_span_cm) -> float:
    """The user's own knuckle span if saved, otherwise the population average."""
    if user_span_cm is None:
        return DEFAULT_HAND_SPAN_CM
    return float(user_span_cm)


def sticker_fits_mango(sticker_px: float, mango_px: float) -> bool:
    if mango_px <= 0:
        return False
    return _STICKER_TO_MANGO_MIN <= sticker_px / mango_px <= _STICKER_TO_MANGO_MAX


def choose_reference(
    sticker: Optional[StickerMarker],
    hand: Optional[HandMarker],
    mango_px: float,
    user_span_cm,
) -> Optional[Reference]:
    """The sticker wins when it is usable; the hand is the fallback."""
    if sticker is not None and sticker_fits_mango(sticker.width_px, mango_px):
        return Reference(sticker.width_px, sticker.span_cm, sticker.kind)
    if hand is not None:
        return Reference(hand.knuckle_width_px, resolve_hand_span_cm(user_span_cm), "hand")
    return None


def estimate_size(
    detection: MangoDetection,
    knuckle_width_px: float,
    hand_span_cm: Optional[float] = None,
) -> float:
    """
    Estimates real-world mango width in cm using the knuckle span as pixel reference.
    Uses the narrower dimension of the bounding box (width or height) as mango diameter.
    """
    if knuckle_width_px <= 0:
        raise ValueError("knuckle_width_px must be greater than zero.")

    mango_px = min(detection.bbox_w, detection.bbox_h)
    size_cm = (mango_px / knuckle_width_px) * resolve_hand_span_cm(hand_span_cm)
    return round(size_cm, 2)
