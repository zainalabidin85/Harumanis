import cv2
import mediapipe as mp
import numpy as np

_hands = None


def load_model():
    global _hands
    _hands = mp.solutions.hands.Hands(
        static_image_mode=True,
        max_num_hands=1,
        min_detection_confidence=0.7,
    )


def detect_knuckle_width(image_bgr: np.ndarray) -> float | None:
    """
    Returns the pixel width between the index and pinky MCP knuckles.
    Returns None if no hand is detected.
    """
    if _hands is None:
        raise RuntimeError("MediaPipe model not loaded. Call load_model() first.")

    image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)
    results = _hands.process(image_rgb)

    if not results.multi_hand_landmarks:
        return None

    landmarks = results.multi_hand_landmarks[0].landmark
    h, w = image_bgr.shape[:2]

    # MCP joints: index finger = 5, pinky = 17
    index_mcp = landmarks[mp.solutions.hands.HandLandmark.INDEX_FINGER_MCP]
    pinky_mcp = landmarks[mp.solutions.hands.HandLandmark.PINKY_MCP]

    index_x = index_mcp.x * w
    pinky_x = pinky_mcp.x * w

    return abs(index_x - pinky_x)
