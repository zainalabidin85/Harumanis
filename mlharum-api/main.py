from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from routers import auth, farms, detection, dashboard, training, analyze, marketplace, orders, admin, fruits
from routers import farm_images, testimonials
from services.yolo_service import load_model as load_yolo
from services.mediapipe_service import load_model as load_mediapipe
from limiter import limiter
import os

app = FastAPI(title="MLharum API", version="2.0.0")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(farms.router, prefix="/farms", tags=["farms"])
app.include_router(detection.router, prefix="/detect", tags=["detection"])
app.include_router(dashboard.router, prefix="/dashboard", tags=["dashboard"])
app.include_router(training.router, prefix="/training", tags=["training"])
app.include_router(analyze.router, prefix="/analyze", tags=["analyze"])
app.include_router(marketplace.router, prefix="/marketplace", tags=["marketplace"])
app.include_router(orders.router, prefix="/orders", tags=["orders"])
app.include_router(farm_images.router, prefix="/farms", tags=["farm-images"])
app.include_router(admin.router, prefix="/admin", tags=["admin"])
app.include_router(fruits.router, prefix="/trees", tags=["fruits"])
app.include_router(testimonials.router, prefix="/farms", tags=["reviews"])


@app.on_event("startup")
async def startup():
    load_yolo()
    load_mediapipe()
    os.makedirs("./storage/images/farms", exist_ok=True)

os.makedirs("./storage", exist_ok=True)
app.mount("/storage", StaticFiles(directory="./storage"), name="storage")


@app.get("/health")
def health():
    return {"status": "ok"}
