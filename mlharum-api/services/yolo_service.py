import numpy as np
from dataclasses import dataclass
from ultralytics import YOLO
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
    _model = YOLO(settings.yolo_model_path)


def detect_mangoes(image_bgr: np.ndarray) -> list[MangoDetection]:
    """
    Runs YOLOv8 on the image and returns a list of detected mangoes.
    Each detection includes bounding box, growth stage class, and confidence.
    Growth stage classes must match training labels: 0=Early, 1=Mid, 2=Late, 3=Pre-harvest.
    """
    if _model is None:
        raise RuntimeError("YOLO model not loaded. Call load_model() first.")

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
                growth_stage=int(box.cls[0].item()) + 1,  # shift to 1-indexed stages
                confidence=float(box.conf[0].item()),
            )
        )

    return detections
