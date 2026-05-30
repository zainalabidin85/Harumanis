import io
import os
import uuid
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from fastapi.responses import StreamingResponse
from PIL import Image as PILImage
from sqlalchemy.orm import Session
from database import get_db
from models.farm import Farm
from models.farm_image import FarmImage
from models.user import User
from auth_utils import get_current_user
from schemas import FarmImageResponse
from config import settings

router = APIRouter()

MAX_IMAGES = 5
MAX_SIZE_BYTES = 3 * 1024 * 1024  # 3 MB
THUMB_MAX_PX = 900
THUMB_DIR = "./storage/thumbnails/farms"


def _image_url(filename: str) -> str:
    return f"{settings.api_base_url}/storage/images/farms/{filename}"


def _thumb_url(filename: str) -> str:
    return f"{settings.api_base_url}/farms/thumbnail/{filename}"


def _to_response(img: FarmImage) -> FarmImageResponse:
    return FarmImageResponse(
        id=img.id,
        farm_id=img.farm_id,
        url=_image_url(img.filename),
        thumb_url=_thumb_url(img.filename),
        caption=img.caption,
        uploaded_at=img.uploaded_at,
    )


@router.get("/thumbnail/{filename}")
def get_thumbnail(filename: str):
    os.makedirs(THUMB_DIR, exist_ok=True)
    thumb_path = os.path.join(THUMB_DIR, filename)

    if not os.path.exists(thumb_path):
        orig_path = os.path.join(settings.farm_images_path, filename)
        if not os.path.exists(orig_path):
            raise HTTPException(status_code=404, detail="Image not found")
        img = PILImage.open(orig_path)
        img.thumbnail((THUMB_MAX_PX, THUMB_MAX_PX), PILImage.LANCZOS)
        if img.mode in ("RGBA", "P"):
            img = img.convert("RGB")
        img.save(thumb_path, "JPEG", quality=82, optimize=True)

    with open(thumb_path, "rb") as f:
        data = f.read()
    return StreamingResponse(
        io.BytesIO(data),
        media_type="image/jpeg",
        headers={"Cache-Control": "public, max-age=604800"},
    )


@router.get("/{farm_id}/images", response_model=list[FarmImageResponse])
def list_images(farm_id: int, db: Session = Depends(get_db), _: User = Depends(get_current_user)):
    farm = db.query(Farm).filter(Farm.id == farm_id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")
    return [_to_response(img) for img in farm.images]


@router.post("/{farm_id}/images", response_model=FarmImageResponse, status_code=status.HTTP_201_CREATED)
async def upload_image(
    farm_id: int,
    file: UploadFile = File(...),
    caption: str = Form(default=""),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == current_user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")

    current_count = db.query(FarmImage).filter(FarmImage.farm_id == farm_id).count()
    if current_count >= MAX_IMAGES:
        raise HTTPException(status_code=400, detail=f"Maximum {MAX_IMAGES} images per farm reached.")

    if not (file.content_type or "").startswith("image/"):
        raise HTTPException(status_code=422, detail="File must be an image.")

    data = await file.read()
    if len(data) > MAX_SIZE_BYTES:
        raise HTTPException(status_code=413, detail="Image must be under 3 MB.")
    if not data:
        raise HTTPException(status_code=422, detail="Empty file received.")

    ext = (file.filename or "img.jpg").rsplit(".", 1)[-1].lower()
    if ext not in ("jpg", "jpeg", "png", "webp"):
        ext = "jpg"
    filename = f"farm{farm_id}_{uuid.uuid4().hex}.{ext}"

    os.makedirs(settings.farm_images_path, exist_ok=True)
    with open(os.path.join(settings.farm_images_path, filename), "wb") as f:
        f.write(data)

    img = FarmImage(
        farm_id=farm_id,
        filename=filename,
        caption=caption.strip() or None,
    )
    db.add(img)
    db.commit()
    db.refresh(img)
    return _to_response(img)


@router.delete("/{farm_id}/images/{image_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_image(
    farm_id: int,
    image_id: int,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    farm = db.query(Farm).filter(Farm.id == farm_id, Farm.user_id == current_user.id).first()
    if not farm:
        raise HTTPException(status_code=404, detail="Farm not found")

    img = db.query(FarmImage).filter(FarmImage.id == image_id, FarmImage.farm_id == farm_id).first()
    if not img:
        raise HTTPException(status_code=404, detail="Image not found")

    filepath = os.path.join(settings.farm_images_path, img.filename)
    if os.path.exists(filepath):
        os.remove(filepath)

    db.delete(img)
    db.commit()
