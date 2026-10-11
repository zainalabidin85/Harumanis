from typing import Optional

from config import settings
from services.yolo_service import MangoDetection


# Average distance across 4 MCP knuckles (index to pinky) in cm.
# Only used when the user has not saved their own measurement (users.knuckle_span_cm).
DEFAULT_HAND_SPAN_CM = settings.avg_knuckle_width_cm * 3  # ~5.4 cm for 3-knuckle span


def resolve_hand_span_cm(user_span_cm) -> float:
    """The user's own knuckle span if saved, otherwise the population average."""
    if user_span_cm is None:
        return DEFAULT_HAND_SPAN_CM
    return float(user_span_cm)


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
