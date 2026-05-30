import csv
import json
import os
import uuid
from datetime import datetime

from fastapi import APIRouter, File, Form, HTTPException, UploadFile
from pydantic import BaseModel

from config import settings
from services.trainer import get_status, list_base_models, start_training

router = APIRouter()

TRAINING_DIR = os.path.join(settings.image_storage_path, "training")
IMAGE_DIR = os.path.join(TRAINING_DIR, "images")
LABEL_DIR = os.path.join(TRAINING_DIR, "labels")
LOG_PATH = os.path.join(TRAINING_DIR, "uploads.csv")

# Single class — mango (pre-bagging, on-tree, with palm in frame as scale reference)
MANGO_CLASS_ID = 0

_CSV_HEADER = ["id", "filename", "box_count", "tagger", "notes", "uploaded_at"]


def _ensure_dirs():
    os.makedirs(IMAGE_DIR, exist_ok=True)
    os.makedirs(LABEL_DIR, exist_ok=True)


def _append_log(row: dict):
    write_header = not os.path.exists(LOG_PATH)
    with open(LOG_PATH, "a", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=_CSV_HEADER)
        if write_header:
            writer.writeheader()
        writer.writerow(row)


def _save_yolo_labels(image_id: str, annotations: list[dict]):
    label_path = os.path.join(LABEL_DIR, f"{image_id}.txt")
    lines = []
    for ann in annotations:
        x = float(ann["x"])
        y = float(ann["y"])
        w = float(ann["w"])
        h = float(ann["h"])
        cx = x + w / 2
        cy = y + h / 2
        lines.append(f"{MANGO_CLASS_ID} {cx:.6f} {cy:.6f} {w:.6f} {h:.6f}")
    with open(label_path, "w") as f:
        f.write("\n".join(lines))


class UploadStats(BaseModel):
    total: int
    labeled: int
    total_boxes: int


@router.post("/upload")
async def upload_training_image(
    file: UploadFile = File(...),
    annotations: str = Form(...),
    tagger: str = Form("anonymous"),
    notes: str = Form(""),
):
    content_type = file.content_type or ""
    if not content_type.startswith("image/"):
        raise HTTPException(status_code=422, detail="File must be an image.")

    try:
        parsed = json.loads(annotations)
    except json.JSONDecodeError:
        raise HTTPException(status_code=422, detail="Invalid annotations JSON.")

    if not isinstance(parsed, list) or len(parsed) == 0:
        raise HTTPException(status_code=422, detail="At least one annotation is required.")

    for ann in parsed:
        if not all(k in ann for k in ("x", "y", "w", "h")):
            raise HTTPException(status_code=422, detail="Each annotation needs x, y, w, h.")

    _ensure_dirs()

    data = await file.read()
    if len(data) == 0:
        raise HTTPException(status_code=422, detail="Empty file received.")

    ext = os.path.splitext(file.filename or "img.jpg")[1] or ".jpg"
    image_id = uuid.uuid4().hex
    filename = f"{image_id}{ext}"

    with open(os.path.join(IMAGE_DIR, filename), "wb") as f:
        f.write(data)

    _save_yolo_labels(image_id, parsed)

    _append_log({
        "id": image_id,
        "filename": f"images/{filename}",
        "box_count": len(parsed),
        "tagger": tagger.strip(),
        "notes": notes.strip(),
        "uploaded_at": datetime.utcnow().isoformat(),
    })

    return {
        "id": image_id,
        "filename": f"images/{filename}",
        "label_file": f"labels/{image_id}.txt",
        "box_count": len(parsed),
        "message": "Uploaded successfully.",
    }


class TrainRequest(BaseModel):
    base_model: str | None = None  # filename inside weights/, e.g. "philippine_mango.pt"


@router.post("/train")
def trigger_training(body: TrainRequest = TrainRequest()):
    base_path = None
    if body.base_model:
        import os as _os
        from config import settings as _settings
        api_dir = _os.path.dirname(_os.path.dirname(_os.path.abspath(__file__)))
        base_path = _os.path.join(api_dir, "weights", body.base_model)
    result = start_training(base_path)
    if not result["ok"]:
        raise HTTPException(status_code=400, detail=result["reason"])
    return {"message": result["reason"]}


@router.get("/train/status")
def training_status():
    return get_status()


@router.get("/base-models")
def available_base_models():
    """List all .pt files in weights/ — shown in Collector app so user can pick base model."""
    return list_base_models()


@router.get("/stats", response_model=UploadStats)
def upload_stats():
    _ensure_dirs()

    image_files = [f for f in os.listdir(IMAGE_DIR) if os.path.isfile(os.path.join(IMAGE_DIR, f))]
    label_files = [f for f in os.listdir(LABEL_DIR) if os.path.isfile(os.path.join(LABEL_DIR, f))]

    total_boxes = 0
    for lf in label_files:
        with open(os.path.join(LABEL_DIR, lf)) as f:
            total_boxes += sum(1 for line in f if line.strip())

    return UploadStats(
        total=len(image_files),
        labeled=len(label_files),
        total_boxes=total_boxes,
    )
