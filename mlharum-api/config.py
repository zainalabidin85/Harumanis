from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str
    secret_key: str
    access_token_expire_minutes: int = 10080
    image_storage_path: str = "./storage/images"
    farm_images_path: str = "./storage/images/farms"
    announcement_images_path: str = "./storage/images/announcements"
    yolo_model_path: str = "./weights/mango_yolov8.pt"
    yolo_base_model_path: str = "./weights/yolov8n.pt"
    hand_landmarker_path: str = "./weights/hand_landmarker.task"
    avg_knuckle_width_cm: float = 1.8
    bagging_min_size_cm: float = 4.0   # DOA Bagging stage lower bound (40mm) — start of bagging window
    bagging_max_size_cm: float = 4.5   # DOA Bagging stage upper bound (45mm) — end of bagging window

    # SMTP for password reset emails
    smtp_host: str = "smtp.gmail.com"
    smtp_port: int = 587
    smtp_user: str = ""
    smtp_password: str = ""
    smtp_from_name: str = "MLharum"

    # Billplz payment gateway
    billplz_api_key: str = ""
    billplz_x_signature: str = ""
    billplz_collection_id: str = ""
    billplz_sandbox: bool = True
    api_base_url: str = "https://mlharum.unitani.com"

    # Firebase Cloud Messaging (push notifications)
    firebase_credentials_path: str = "./firebase-service-account.json"

    class Config:
        env_file = ".env"


settings = Settings()
