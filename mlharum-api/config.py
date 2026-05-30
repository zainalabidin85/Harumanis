from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str
    secret_key: str
    access_token_expire_minutes: int = 10080
    image_storage_path: str = "./storage/images"
    farm_images_path: str = "./storage/images/farms"
    yolo_model_path: str = "./weights/mango_yolov8.pt"
    yolo_base_model_path: str = "./weights/yolov8n.pt"
    hand_landmarker_path: str = "./weights/hand_landmarker.task"
    avg_knuckle_width_cm: float = 1.8
    bagging_min_size_cm: float = 2.5   # Stage 2 lower bound — start of bagging window
    bagging_max_size_cm: float = 5.0   # Stage 2 upper bound — end of bagging window

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

    class Config:
        env_file = ".env"


settings = Settings()
