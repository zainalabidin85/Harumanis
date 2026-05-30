import numpy as np
from config import settings

_detector = None

_INDEX_MCP = 5
_PINKY_MCP = 17


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


def detect_knuckle_width(image_bgr: np.ndarray) -> float | None:
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
    pinky_x = landmarks[_PINKY_MCP].x * w

    return abs(index_x - pinky_x)
