import numpy as np
from dataclasses import dataclass
from config import settings

_model = None


@dataclass
class MangoDetection:
    bbox_x: float
    bbox_y: float
    bbox_w: float
    bbox_h: float
    growth_stage: int
    confidence: float


def load_model():
    global _model
    try:
        from ultralytics import YOLO
        _model = YOLO(settings.yolo_model_path)
    except (ImportError, FileNotFoundError):
        pass  # ultralytics not installed or model weights missing — detection endpoint will be unavailable


def detect_mangoes(image_bgr: np.ndarray) -> list[MangoDetection]:
    if _model is None:
        raise RuntimeError("YOLO model not available. Install requirements-ml.txt and place model weights.")

    results = _model.predict(image_bgr, verbose=False)[0]
    detections = []

    for box in results.boxes:
        x1, y1, x2, y2 = box.xyxy[0].tolist()
        detections.append(
            MangoDetection(
                bbox_x=x1,
                bbox_y=y1,
                bbox_w=x2 - x1,
                bbox_h=y2 - y1,
                growth_stage=int(box.cls[0].item()) + 1,
                confidence=float(box.conf[0].item()),
            )
        )

    return detections
