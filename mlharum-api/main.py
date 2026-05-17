from fastapi import FastAPI
from routers import auth, farms, detection, dashboard
from services.yolo_service import load_model as load_yolo
from services.mediapipe_service import load_model as load_mediapipe

app = FastAPI(title="MLharum API", version="1.0.0")

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(farms.router, prefix="/farms", tags=["farms"])
app.include_router(detection.router, prefix="/detect", tags=["detection"])
app.include_router(dashboard.router, prefix="/dashboard", tags=["dashboard"])


@app.on_event("startup")
async def startup():
    load_yolo()
    load_mediapipe()


@app.get("/health")
def health():
    return {"status": "ok"}
