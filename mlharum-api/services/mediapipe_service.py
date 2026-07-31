import numpy as np
from dataclasses import dataclass
from config import settings

_detector = None

_INDEX_MCP = 5
_PINKY_MCP = 17


@dataclass
class HandMarker:
    knuckle_width_px: float
    index_x: float
    index_y: float
    pinky_x: float
    pinky_y: float


def load_model():
    global _detector
    try:
        import mediapipe as mp
        from mediapipe.tasks import python
        from mediapipe.tasks.python import vision

        base_options = python.BaseOptions(model_asset_path=settings.hand_landmarker_path)
        options = vision.HandLandmarkerOptions(
            base_options=base_options,
            num_hands=1,
            min_hand_detection_confidence=0.7,
            min_hand_presence_confidence=0.7,
        )
        _detector = vision.HandLandmarker.create_from_options(options)
    except Exception:
        pass  # mediapipe not available — detection endpoint will be unavailable


def detect_knuckle_width(image_bgr: np.ndarray) -> HandMarker | None:
    if _detector is None:
        raise RuntimeError("MediaPipe not available.")

    import cv2
    import mediapipe as mp

    image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)
    mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=image_rgb)
    result = _detector.detect(mp_image)

    if not result.hand_landmarks:
        return None

    landmarks = result.hand_landmarks[0]
    h, w = image_bgr.shape[:2]

    index_x = landmarks[_INDEX_MCP].x * w
    index_y = landmarks[_INDEX_MCP].y * h
    pinky_x = landmarks[_PINKY_MCP].x * w
    pinky_y = landmarks[_PINKY_MCP].y * h

    knuckle_width_px = float(np.sqrt((index_x - pinky_x) ** 2 + (index_y - pinky_y) ** 2))

    return HandMarker(
        knuckle_width_px=knuckle_width_px,
        index_x=index_x,
        index_y=index_y,
        pinky_x=pinky_x,
        pinky_y=pinky_y,
    )
