from config import settings
from services.yolo_service import MangoDetection


# Average distance across 4 MCP knuckles (index to pinky) in cm.
# Measured across adult hands — update if farmer population differs.
HAND_SPAN_CM = settings.avg_knuckle_width_cm * 3  # ~5.4 cm for 3-knuckle span


def estimate_size(detection: MangoDetection, knuckle_width_px: float) -> float:
    """
    Estimates real-world mango width in cm using the knuckle span as pixel reference.
    Uses the narrower dimension of the bounding box (width or height) as mango diameter.
    """
    if knuckle_width_px <= 0:
        raise ValueError("knuckle_width_px must be greater than zero.")

    mango_px = min(detection.bbox_w, detection.bbox_h)
    size_cm = (mango_px / knuckle_width_px) * HAND_SPAN_CM
    return round(size_cm, 2)
