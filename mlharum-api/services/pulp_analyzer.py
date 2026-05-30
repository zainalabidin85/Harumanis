import io
import math

import numpy as np
from PIL import Image

# Reference data from: Nasir et al. (2021), AAFRJ 2(1):a0000190
# Five post-harvest ripeness stages measured at 2-day intervals after week-10 harvest.
# Stage 4 = ready to eat (firmness halved, sugar rising); Stage 5 = overripe.
_STAGES = [
    {"stage": 1, "r": 208, "g": 200, "b": 112, "brix": 6.36,  "firmness": 24.70, "days_after_harvest": 0},
    {"stage": 2, "r": 209, "g": 197, "b": 102, "brix": 7.52,  "firmness": 26.47, "days_after_harvest": 2},
    {"stage": 3, "r": 204, "g": 161, "b": 31,  "brix": 11.42, "firmness": 20.07, "days_after_harvest": 4},
    {"stage": 4, "r": 210, "g": 165, "b": 26,  "brix": 13.44, "firmness": 12.21, "days_after_harvest": 6},
    {"stage": 5, "r": 208, "g": 155, "b": 20,  "brix": 15.02, "firmness": 7.95,  "days_after_harvest": 8},
]

_READY_FROM_STAGE = 4


def _normalize(r: float, g: float, b: float) -> tuple[float, float, float]:
    total = r + g + b
    if total == 0:
        return 0.0, 0.0, 0.0
    return r / total, g / total, b / total


def _distance(r1: float, g1: float, b1: float, r2: float, g2: float, b2: float) -> float:
    """Euclidean distance in normalized RGB space — lighting-robust."""
    nr1, ng1, nb1 = _normalize(r1, g1, b1)
    nr2, ng2, nb2 = _normalize(r2, g2, b2)
    return math.sqrt((nr1 - nr2) ** 2 + (ng1 - ng2) ** 2 + (nb1 - nb2) ** 2)


def analyze_pulp(image_bytes: bytes) -> dict:
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    w, h = img.size

    # Sample the center 20% where the cut pulp surface is expected
    region = img.crop((int(w * 0.4), int(h * 0.4), int(w * 0.6), int(h * 0.6)))
    arr = np.array(region, dtype=float)
    avg_r = float(arr[:, :, 0].mean())
    avg_g = float(arr[:, :, 1].mean())
    avg_b = float(arr[:, :, 2].mean())

    ranked = sorted(
        [(_distance(avg_r, avg_g, avg_b, s["r"], s["g"], s["b"]), s) for s in _STAGES],
        key=lambda x: x[0],
    )
    best_dist, best = ranked[0]
    second_dist = ranked[1][0]

    # Confidence: ratio of nearest vs second-nearest distance
    ratio = best_dist / second_dist if second_dist > 0 else 0.0
    confidence = "high" if ratio < 0.4 else ("medium" if ratio < 0.7 else "low")

    days_to_ready = max(0, (_READY_FROM_STAGE - best["stage"]) * 2)

    return {
        "stage": best["stage"],
        "brix_estimate": best["brix"],
        "firmness_estimate": best["firmness"],
        "is_ready": best["stage"] >= _READY_FROM_STAGE,
        "days_to_ready": days_to_ready,
        "detected_rgb": {"r": round(avg_r), "g": round(avg_g), "b": round(avg_b)},
        "reference_rgb": {"r": best["r"], "g": best["g"], "b": best["b"]},
        "confidence": confidence,
    }
