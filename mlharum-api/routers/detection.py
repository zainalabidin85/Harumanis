import asyncio
import cv2
import numpy as np
from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Request, Header
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
from services.i18n import resolve_language, t
from config import settings
from limiter import limiter

router = APIRouter()


def _load_image(data: bytes) -> np.ndarray:
    arr = np.frombuffer(data, np.uint8)
    return cv2.imdecode(arr, cv2.IMREAD_COLOR)



@limiter.limit("10/minute")
@router.post("/{tree_id}", response_model=DetectionResponse)
async def run_detection(
    request: Request,
    tree_id: int,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
    accept_language: Optional[str] = Header(default=None),
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

    loop = asyncio.get_event_loop()
    hand_marker = await loop.run_in_executor(None, detect_knuckle_width, image_bgr)
    if hand_marker is None:
        raise HTTPException(status_code=422, detail="No hand detected. Hold your open palm beside the fruit.")

    mango_detections = await loop.run_in_executor(None, detect_mangoes, image_bgr)
    if not mango_detections:
        raise HTTPException(status_code=422, detail="No mango detected. Point at one mango and try again.")

    # One mango per photo — pick highest confidence detection
    best = max(mango_detections, key=lambda d: d.confidence)

    size_cm = estimate_size(best, hand_marker.knuckle_width_px)
    harvest_date, days_to_harvest, resolved_stage = predict_harvest(size_cm, db)

    detection_record = Detection(
        tree_id=tree_id,
        mango_count=1,
        knuckle_width_px=hand_marker.knuckle_width_px,
    )
    db.add(detection_record)
    db.flush()

    min_size = settings.bagging_min_size_cm
    max_size = settings.bagging_max_size_cm
    lang = resolve_language(accept_language)
    size_text = f"{size_cm:.1f}"

    if size_cm < min_size:
        db.commit()
        return DetectionResponse(
            tree_id=tree_id,
            tree_number=tree.tree_number,
            detection_date=detection_record.detected_at,
            mango_count=1,
            ready_for_bagging=False,
            message=t("detect.early", lang, size=size_text, min_size=min_size),
            fruits=[],
            hand_index_x=hand_marker.index_x,
            hand_index_y=hand_marker.index_y,
            hand_pinky_x=hand_marker.pinky_x,
            hand_pinky_y=hand_marker.pinky_y,
        )

    current_season = datetime.now().year
    existing_count = (
        db.query(Fruit)
        .filter(Fruit.tree_id == tree_id, Fruit.season == current_season)
        .count()
    )
    label = f"{tree.tree_number}-{existing_count + 1:03d}"

    fruit = Fruit(
        detection_id=detection_record.id,
        tree_id=tree_id,
        label=label,
        size_cm=size_cm,
        growth_stage=resolved_stage,
        harvest_date=harvest_date,
        season=current_season,
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
        flush_color=fruit.flush_color,
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
            message=t("detect.late", lang, size=size_text, label=label, days=days_to_harvest),
            fruits=[fruit_result],
            hand_index_x=hand_marker.index_x,
            hand_index_y=hand_marker.index_y,
            hand_pinky_x=hand_marker.pinky_x,
            hand_pinky_y=hand_marker.pinky_y,
        )

    return DetectionResponse(
        tree_id=tree_id,
        tree_number=tree.tree_number,
        detection_date=detection_record.detected_at,
        mango_count=1,
        ready_for_bagging=True,
        message=t("detect.ready", lang, size=size_text, days=days_to_harvest),
        fruits=[fruit_result],
        hand_index_x=hand_marker.index_x,
        hand_index_y=hand_marker.index_y,
        hand_pinky_x=hand_marker.pinky_x,
        hand_pinky_y=hand_marker.pinky_y,
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
