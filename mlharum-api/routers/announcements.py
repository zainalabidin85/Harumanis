import os
import uuid
from datetime import datetime
from typing import Optional
from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile, status
from sqlalchemy.orm import Session
from sqlalchemy import or_
from database import get_db
from models.announcement import Announcement
from models.user import User
from auth_utils import get_current_user, require_doa
from schemas import AnnouncementUpdate, AnnouncementResponse
from config import settings
from services import push_service

router = APIRouter()

MAX_SIZE_BYTES = 3 * 1024 * 1024  # 3 MB


def _image_url(filename: Optional[str]) -> Optional[str]:
    if not filename:
        return None
    return f"{settings.api_base_url}/storage/images/announcements/{filename}"


def _to_response(a: Announcement) -> AnnouncementResponse:
    return AnnouncementResponse(
        id=a.id,
        title=a.title,
        body=a.body,
        image_url=_image_url(a.image_filename),
        event_date=a.event_date,
        location=a.location,
        created_at=a.created_at,
    )


@router.get("", response_model=list[AnnouncementResponse])
def list_announcements(
    upcoming: bool = Query(False),
    db: Session = Depends(get_db),
    _: User = Depends(get_current_user),
):
    q = db.query(Announcement)
    if upcoming:
        q = q.filter(or_(Announcement.event_date == None, Announcement.event_date >= datetime.utcnow()))  # noqa: E711
    announcements = q.order_by(Announcement.created_at.desc()).all()
    return [_to_response(a) for a in announcements]


@router.get("/{announcement_id}", response_model=AnnouncementResponse)
def get_announcement(
    announcement_id: int,
    db: Session = Depends(get_db),
    _: User = Depends(get_current_user),
):
    a = db.query(Announcement).filter(Announcement.id == announcement_id).first()
    if not a:
        raise HTTPException(status_code=404, detail="Announcement not found")
    return _to_response(a)


@router.post("", response_model=AnnouncementResponse, status_code=status.HTTP_201_CREATED)
async def create_announcement(
    title: str = Form(...),
    body: str = Form(...),
    event_date: Optional[datetime] = Form(default=None),
    location: Optional[str] = Form(default=None),
    file: Optional[UploadFile] = File(default=None),
    current_user: User = Depends(require_doa),
    db: Session = Depends(get_db),
):
    image_filename = None
    if file is not None:
        if not (file.content_type or "").startswith("image/"):
            raise HTTPException(status_code=422, detail="File must be an image.")
        data = await file.read()
        if len(data) > MAX_SIZE_BYTES:
            raise HTTPException(status_code=413, detail="Image must be under 3 MB.")
        if data:
            ext = (file.filename or "img.jpg").rsplit(".", 1)[-1].lower()
            if ext not in ("jpg", "jpeg", "png", "webp"):
                ext = "jpg"
            image_filename = f"announcement_{uuid.uuid4().hex}.{ext}"
            os.makedirs(settings.announcement_images_path, exist_ok=True)
            with open(os.path.join(settings.announcement_images_path, image_filename), "wb") as f:
                f.write(data)

    a = Announcement(
        title=title.strip(),
        body=body.strip(),
        image_filename=image_filename,
        event_date=event_date,
        location=location.strip() if location else None,
        created_by=current_user.id,
    )
    db.add(a)
    db.commit()
    db.refresh(a)

    push_service.send_to_farmers(
        db,
        title=a.title,
        body=a.body[:120],
        data={"type": "announcement", "announcement_id": str(a.id)},
        exclude_user_id=current_user.id,
    )

    return _to_response(a)


@router.patch("/{announcement_id}", response_model=AnnouncementResponse)
def update_announcement(
    announcement_id: int,
    payload: AnnouncementUpdate,
    _: User = Depends(require_doa),
    db: Session = Depends(get_db),
):
    a = db.query(Announcement).filter(Announcement.id == announcement_id).first()
    if not a:
        raise HTTPException(status_code=404, detail="Announcement not found")

    if payload.title is not None:
        a.title = payload.title.strip()
    if payload.body is not None:
        a.body = payload.body.strip()
    if payload.event_date is not None:
        a.event_date = payload.event_date
    if payload.location is not None:
        a.location = payload.location.strip() or None
    a.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(a)
    return _to_response(a)


@router.delete("/{announcement_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_announcement(
    announcement_id: int,
    _: User = Depends(require_doa),
    db: Session = Depends(get_db),
):
    a = db.query(Announcement).filter(Announcement.id == announcement_id).first()
    if not a:
        raise HTTPException(status_code=404, detail="Announcement not found")

    if a.image_filename:
        filepath = os.path.join(settings.announcement_images_path, a.image_filename)
        if os.path.exists(filepath):
            os.remove(filepath)

    db.delete(a)
    db.commit()
