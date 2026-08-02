import logging
import os
from typing import Optional

import firebase_admin
from firebase_admin import credentials, messaging
from sqlalchemy.orm import Session

from config import settings
from models.device_token import DeviceToken
from models.user import User

logger = logging.getLogger(__name__)

_initialized = False


def init_firebase() -> None:
    global _initialized
    if _initialized:
        return
    if not os.path.exists(settings.firebase_credentials_path):
        logger.warning(
            "Firebase credentials not found at %s — push notifications disabled.",
            settings.firebase_credentials_path,
        )
        return
    cred = credentials.Certificate(settings.firebase_credentials_path)
    firebase_admin.initialize_app(cred)
    _initialized = True


def _send(tokens: list[str], title: str, body: str, data: Optional[dict] = None, db: Optional[Session] = None) -> None:
    if not _initialized or not tokens:
        return
    data = {k: str(v) for k, v in (data or {}).items()}
    messages = [
        messaging.Message(notification=messaging.Notification(title=title, body=body), data=data, token=token)
        for token in tokens
    ]
    responses = messaging.send_each(messages)
    dead_tokens = []
    for token, resp in zip(tokens, responses.responses):
        if not resp.success and isinstance(resp.exception, messaging.UnregisteredError):
            dead_tokens.append(token)
        elif not resp.success:
            logger.warning("FCM send failed for token %s...: %s", token[:12], resp.exception)
    if dead_tokens and db is not None:
        db.query(DeviceToken).filter(DeviceToken.token.in_(dead_tokens)).delete(synchronize_session=False)
        db.commit()


def send_to_user(db: Session, user_id: int, title: str, body: str, data: Optional[dict] = None) -> None:
    tokens = [t.token for t in db.query(DeviceToken).filter(DeviceToken.user_id == user_id).all()]
    _send(tokens, title, body, data, db)


def send_to_farmers(db: Session, title: str, body: str, data: Optional[dict] = None, exclude_user_id: Optional[int] = None) -> None:
    q = (
        db.query(DeviceToken.token)
        .join(User, User.id == DeviceToken.user_id)
        .filter(User.role.in_(("farmer", "admin", "doa")))
    )
    if exclude_user_id is not None:
        q = q.filter(User.id != exclude_user_id)
    tokens = [row[0] for row in q.all()]
    _send(tokens, title, body, data, db)
