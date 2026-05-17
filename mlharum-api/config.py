from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    database_url: str
    secret_key: str
    access_token_expire_minutes: int = 10080
    image_storage_path: str = "./storage/images"
    yolo_model_path: str = "./weights/mango_yolov8.pt"
    avg_knuckle_width_cm: float = 1.8

    class Config:
        env_file = ".env"


settings = Settings()
