import secrets
import smtplib
from datetime import datetime, timedelta
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from passlib.context import CryptContext
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain: str, hashed: str) -> bool:
    return pwd_context.verify(plain, hashed)


def create_access_token(user_id: int, role: str = "farmer") -> str:
    expire = datetime.utcnow() + timedelta(minutes=settings.access_token_expire_minutes)
    return jwt.encode({"sub": str(user_id), "role": role, "exp": expire}, settings.secret_key, algorithm="HS256")


def generate_otp() -> str:
    return str(secrets.randbelow(900000) + 100000)


def send_reset_email(to_email: str, to_name: str, otp: str) -> None:
    if not settings.smtp_user or not settings.smtp_password:
        return  # SMTP not configured; skip silently in dev

    msg = MIMEMultipart("alternative")
    msg["Subject"] = "MLharum - Password Reset Code"
    msg["From"] = f"{settings.smtp_from_name} <{settings.smtp_user}>"
    msg["To"] = to_email

    body = (
        f"Hi {to_name},\n\n"
        f"Your password reset code is:\n\n"
        f"  {otp}\n\n"
        f"This code is valid for 1 hour. Enter it in the MLharum app to set a new password.\n\n"
        f"If you did not request this, you can ignore this email.\n\n"
        f"— MLharum Team"
    )
    msg.attach(MIMEText(body, "plain"))

    with smtplib.SMTP(settings.smtp_host, settings.smtp_port) as server:
        server.starttls()
        server.login(settings.smtp_user, settings.smtp_password)
        server.sendmail(settings.smtp_user, to_email, msg.as_string())


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid or expired token",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.secret_key, algorithms=["HS256"])
        user_id = int(payload.get("sub"))
    except (JWTError, TypeError, ValueError):
        raise credentials_exception

    user = db.query(User).filter(User.id == user_id).first()
    if user is None:
        raise credentials_exception
    return user


def require_buyer(user: User = Depends(get_current_user)) -> User:
    if user.role != "buyer":
        raise HTTPException(status_code=403, detail="Buyer account required")
    return user


def require_farmer(user: User = Depends(get_current_user)) -> User:
    if user.role not in ("farmer", "admin"):
        raise HTTPException(status_code=403, detail="Farmer account required")
    return user


def require_admin(user: User = Depends(get_current_user)) -> User:
    if user.role != "admin":
        raise HTTPException(status_code=403, detail="Admin account required")
    return user


def require_doa(user: User = Depends(get_current_user)) -> User:
    if user.role not in ("doa", "admin"):
        raise HTTPException(status_code=403, detail="DOA account required")
    return user
