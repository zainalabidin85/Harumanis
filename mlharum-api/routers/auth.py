import logging
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, Request, status
from sqlalchemy.orm import Session
from database import get_db
from models.user import User
from schemas import UserRegister, UserLogin, TokenResponse, ForgotPasswordRequest, ResetPasswordRequest, UserProfileResponse, UserProfileUpdate, DeviceTokenRegister
from auth_utils import hash_password, verify_password, create_access_token, generate_otp, send_reset_email, get_current_user
from models.device_token import DeviceToken
from limiter import limiter

logger = logging.getLogger(__name__)
router = APIRouter()


@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(payload: UserRegister, db: Session = Depends(get_db)):
    if db.query(User).filter(User.email == payload.email).first():
        raise HTTPException(status_code=400, detail="Email already registered")

    user = User(
        name=payload.name,
        email=payload.email,
        password_hash=hash_password(payload.password),
        address=payload.address,
        phone=payload.phone,
        whatsapp=payload.whatsapp,
        role=payload.role,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return {"message": "Account created", "user_id": user.id, "role": user.role}


@router.post("/login", response_model=TokenResponse)
@limiter.limit("10/minute")
def login(request: Request, payload: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    if user.is_suspended:
        raise HTTPException(status_code=403, detail="Account suspended. Contact support.")

    return TokenResponse(access_token=create_access_token(user.id, user.role))


@router.post("/forgot-password", status_code=200)
@limiter.limit("5/hour")
def forgot_password(request: Request, payload: ForgotPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    # Always return 200 to avoid leaking which emails are registered
    if user:
        otp = generate_otp()
        user.reset_otp_hash = hash_password(otp)
        user.reset_otp_expires = datetime.utcnow() + timedelta(hours=1)
        db.commit()
        try:
            send_reset_email(user.email, user.name, otp)
        except Exception as exc:
            logger.error("Failed to send password reset email to %s: %s", user.email, exc)
    return {"message": "If that email is registered, a reset code has been sent."}


@router.get("/me", response_model=UserProfileResponse)
def get_me(current_user: User = Depends(get_current_user)):
    farm_id = current_user.farms[0].id if current_user.farms else None
    return UserProfileResponse(
        id=current_user.id,
        name=current_user.name,
        email=current_user.email,
        address=current_user.address,
        phone=current_user.phone,
        whatsapp=current_user.whatsapp,
        role=current_user.role,
        farm_id=farm_id,
        bank_name=current_user.bank_name,
        bank_account_number=current_user.bank_account_number,
        bank_account_name=current_user.bank_account_name,
        language=current_user.language,
    )


@router.patch("/me", response_model=UserProfileResponse)
def update_me(
    payload: UserProfileUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    for field, value in payload.model_dump(exclude_none=True).items():
        setattr(current_user, field, value)
    db.commit()
    db.refresh(current_user)
    return current_user


@router.post("/me/device-token", status_code=200)
def register_device_token(
    payload: DeviceTokenRegister,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    existing = db.query(DeviceToken).filter(DeviceToken.token == payload.device_token).first()
    if existing:
        existing.user_id = current_user.id
        existing.platform = payload.platform
    else:
        db.add(DeviceToken(user_id=current_user.id, token=payload.device_token, platform=payload.platform))
    db.commit()
    return {"message": "Device token registered"}


@router.post("/reset-password", status_code=200)
def reset_password(payload: ResetPasswordRequest, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == payload.email).first()
    if (
        not user
        or not user.reset_otp_hash
        or not user.reset_otp_expires
        or datetime.utcnow() > user.reset_otp_expires
        or not verify_password(payload.otp, user.reset_otp_hash)
    ):
        raise HTTPException(status_code=400, detail="Invalid or expired reset code.")

    user.password_hash = hash_password(payload.new_password)
    user.reset_otp_hash = None
    user.reset_otp_expires = None
    db.commit()
    return {"message": "Password updated successfully."}
