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
        raise HTTPException(status_code=422, detail="No mango detected. Point at one mango and try again.")

    # One mango per photo — pick highest confidence detection
    best = max(mango_detections, key=lambda d: d.confidence)

    size_cm = estimate_size(best, knuckle_width_px)
    harvest_date, days_to_harvest, resolved_stage = predict_harvest(size_cm, db)

    image_path = _save_image(image_bgr, tree_id)

    detection_record = Detection(
        tree_id=tree_id,
        image_path=image_path,
        mango_count=1,
        knuckle_width_px=knuckle_width_px,
    )
    db.add(detection_record)
    db.flush()

    min_size = settings.bagging_min_size_cm
    max_size = settings.bagging_max_size_cm

    if size_cm < min_size:
        db.commit()
        return DetectionResponse(
            tree_id=tree_id,
            tree_number=tree.tree_number,
            detection_date=detection_record.detected_at,
            mango_count=1,
            ready_for_bagging=False,
            message=f"This mango is {size_cm:.1f} cm — still developing. Scan again when it reaches {min_size} cm to begin bagging.",
            fruits=[],
        )

    existing_count = db.query(Fruit).filter(Fruit.tree_id == tree_id).count()
    label = f"{tree.tree_number}-{existing_count + 1:03d}"

    fruit = Fruit(
        detection_id=detection_record.id,
        tree_id=tree_id,
        label=label,
        size_cm=size_cm,
        growth_stage=resolved_stage,
        harvest_date=harvest_date,
        bbox_x=best.bbox_x,
        bbox_y=best.bbox_y,
        bbox_w=best.bbox_w,
        bbox_h=best.bbox_h,
    )
    db.add(fruit)
    db.commit()

    fruit_result = FruitResult(
        id=fruit.id,
        label=label,
        size_cm=size_cm,
        growth_stage=resolved_stage,
        harvest_date=harvest_date,
        days_to_harvest=days_to_harvest,
        bbox_x=best.bbox_x,
        bbox_y=best.bbox_y,
        bbox_w=best.bbox_w,
        bbox_h=best.bbox_h,
    )

    if size_cm > max_size:
        return DetectionResponse(
            tree_id=tree_id,
            tree_number=tree.tree_number,
            detection_date=detection_record.detected_at,
            mango_count=1,
            ready_for_bagging=False,
            message=f"This mango ({size_cm:.1f} cm) has been recorded as {label}. Estimated harvest in {days_to_harvest} days.",
            fruits=[fruit_result],
        )

    return DetectionResponse(
        tree_id=tree_id,
        tree_number=tree.tree_number,
        detection_date=detection_record.detected_at,
        mango_count=1,
        ready_for_bagging=True,
        message=f"Ready for bagging — {size_cm:.1f} cm. Estimated harvest in {days_to_harvest} days.",
        fruits=[fruit_result],
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
