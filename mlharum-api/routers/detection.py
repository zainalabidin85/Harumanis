import os
import uuid
import cv2
import numpy as np
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from models.tree import Tree
from models.fruit import Detection, Fruit
from schemas import DetectionResponse, FruitResult
from auth_utils import get_current_user
from services.mediapipe_service import detect_knuckle_width
from services.yolo_service import detect_mangoes
from services.size_estimator import estimate_size
from services.harvest_predictor import predict_harvest
from config import settings

router = APIRouter()


def _load_image(data: bytes) -> np.ndarray:
    arr = np.frombuffer(data, np.uint8)
    return cv2.imdecode(arr, cv2.IMREAD_COLOR)


def _save_image(image_bgr: np.ndarray, tree_id: int) -> str:
    os.makedirs(settings.image_storage_path, exist_ok=True)
    filename = f"{tree_id}_{uuid.uuid4().hex}.jpg"
    path = os.path.join(settings.image_storage_path, filename)
    cv2.imwrite(path, image_bgr)
    return path


@router.post("/{tree_id}", response_model=DetectionResponse)
async def run_detection(
    tree_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    tree = (
        db.query(Tree)
        .join(Tree.farm)
        .filter(Tree.id == tree_id, Tree.farm.has(user_id=current_user.id))
        .first()
    )
    if not tree:
        raise HTTPException(status_code=404, detail="Tree not found")

    image_data = await file.read()
    image_bgr = _load_image(image_data)
    if image_bgr is None:
        raise HTTPException(status_code=422, detail="Invalid image file")

    knuckle_width_px = detect_knuckle_width(image_bgr)
    if knuckle_width_px is None:
        raise HTTPException(status_code=422, detail="No hand detected. Hold your open palm beside the fruit.")

    mango_detections = detect_mangoes(image_bgr)
    if not mango_detections:
        raise HTTPException(status_code=422, detail="No mangoes detected in the image.")

    image_path = _save_image(image_bgr, tree_id)

    detection_record = Detection(
        tree_id=tree_id,
        image_path=image_path,
        mango_count=len(mango_detections),
        knuckle_width_px=knuckle_width_px,
    )
    db.add(detection_record)
    db.flush()

    fruit_results = []
    sequence = 1

    for det in mango_detections:
        size_cm = estimate_size(det, knuckle_width_px)
        harvest_date, days_to_harvest = predict_harvest(size_cm, det.growth_stage, db)
        label = f"{tree.tree_number}-{sequence:03d}"

        fruit = Fruit(
            detection_id=detection_record.id,
            tree_id=tree_id,
            label=label,
            size_cm=size_cm,
            growth_stage=det.growth_stage,
            harvest_date=harvest_date,
            bbox_x=det.bbox_x,
            bbox_y=det.bbox_y,
            bbox_w=det.bbox_w,
            bbox_h=det.bbox_h,
        )
        db.add(fruit)

        fruit_results.append(FruitResult(
            label=label,
            size_cm=size_cm,
            growth_stage=det.growth_stage,
            harvest_date=harvest_date,
            days_to_harvest=days_to_harvest,
            bbox_x=det.bbox_x,
            bbox_y=det.bbox_y,
            bbox_w=det.bbox_w,
            bbox_h=det.bbox_h,
        ))
        sequence += 1

    db.commit()

    return DetectionResponse(
        tree_id=tree_id,
        tree_number=tree.tree_number,
        detection_date=detection_record.detected_at,
        mango_count=len(mango_detections),
        fruits=fruit_results,
    )


@router.get("/{tree_id}/history")
def detection_history(
    tree_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    tree = (
        db.query(Tree)
        .join(Tree.farm)
        .filter(Tree.id == tree_id, Tree.farm.has(user_id=current_user.id))
        .first()
    )
    if not tree:
        raise HTTPException(status_code=404, detail="Tree not found")

    detections = (
        db.query(Detection)
        .filter(Detection.tree_id == tree_id)
        .order_by(Detection.detected_at.desc())
        .all()
    )

    return [
        {
            "detection_id": d.id,
            "detected_at": d.detected_at,
            "mango_count": d.mango_count,
        }
        for d in detections
    ]
