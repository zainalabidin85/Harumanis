from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str
    secret_key: str
    access_token_expire_minutes: int = 129600  # 90 days; the app renews it on every open (POST /auth/refresh)
    image_storage_path: str = "./storage/images"
    farm_images_path: str = "./storage/images/farms"
    announcement_images_path: str = "./storage/images/announcements"
    yolo_model_path: str = "./weights/mango_yolov8.pt"
    yolo_base_model_path: str = "./weights/yolov8n.pt"
    hand_landmarker_path: str = "./weights/hand_landmarker.task"
    avg_knuckle_width_cm: float = 1.8
    bagging_min_size_cm: float = 4.0   # DOA Bagging stage lower bound (40mm) — start of bagging window
    bagging_max_size_cm: float = 4.5   # DOA Bagging stage upper bound (45mm) — end of bagging window

    # Printed reference sticker: magenta circle or square on a white ring. Wins over the hand when both are in frame.
    sticker_circle_diameter_cm: float = 1.5
    sticker_square_side_cm: float = 1.5
    sticker_hue_min: int = 140         # OpenCV hue scale 0–180; print magenta #E6007E ≈ 163
    sticker_hue_max: int = 175
    sticker_sat_min: int = 120
    sticker_val_min: int = 90
    sticker_min_area_px: int = 400

    # SMTP for password reset emails
    smtp_host: str = "smtp.gmail.com"
    smtp_port: int = 587
    smtp_user: str = ""
    smtp_password: str = ""
    smtp_from_name: str = "MLharum"

    # ToyyibPay payment gateway
    toyyibpay_secret_key: str = ""
    toyyibpay_category_code: str = ""
    toyyibpay_sandbox: bool = True
    toyyibpay_payment_channel: str = "0"  # 0 = FPX, 1 = card, 2 = both
    api_base_url: str = "https://mlharum.unitani.com"

    # Firebase Cloud Messaging (push notifications)
    firebase_credentials_path: str = "./firebase-service-account.json"

    class Config:
        env_file = ".env"
        # Leftover keys (e.g. the old BILLPLZ_* lines) must not stop the API from starting.
        extra = "ignore"


settings = Settings()
