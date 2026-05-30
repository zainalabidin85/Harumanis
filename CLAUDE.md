# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MLharum is an AI-based yield estimation, ripeness prediction, and fruit management system for Harumanis mango. It consists of four components:

- **`mlharum-api/`** — FastAPI backend (Python); runs all AI server-side
- **`mlharum-app/`** — Flutter mobile app (Android-first); camera capture + results + satellite dashboard
- **`mlharum-collector/`** — Standalone Flutter app for collecting training images on-device
- **`mlharum-model/`** — YOLOv8 training pipeline (Jupyter notebooks + scripts)

## Development Commands

### API (mlharum-api)

```bash
cd mlharum-api

# Install dependencies
pip install -r requirements.txt

# Configure environment (copy and edit)
cp .env.example .env
# Required: DATABASE_URL, SECRET_KEY
# Optional: SMTP_* for password reset emails

# Run database migrations
alembic upgrade head

# Start dev server
uvicorn main:app --host 0.0.0.0 --port 8000 --reload

# API docs (auto-generated Swagger)
# http://localhost:8000/docs
```

There are two split requirements files for constrained environments:
- `requirements-core.txt` — API/auth only (no ML)
- `requirements-ml.txt` — ML dependencies only (mediapipe, ultralytics, opencv)

### Flutter App (mlharum-app / mlharum-collector)

```bash
cd mlharum-app   # or mlharum-collector

flutter pub get
flutter run                    # run on connected Android device
flutter build apk              # build release APK
flutter build apk --release    # signed release build
```

Before running, set the server address in `lib/services/api_service.dart` (`_baseUrl`).

### Model Training (mlharum-model)

```bash
cd mlharum-model
pip install -r requirements.txt

# Via Jupyter (recommended — includes data prep and validation)
jupyter notebook

# Via CLI (for remote/Colab training)
python scripts/train.py --model yolov8n.pt --epochs 100

# Copy trained weights to API
cp weights/mango_yolov8.pt ../mlharum-api/weights/mango_yolov8.pt
```

## Architecture

### AI Detection Pipeline

```
POST /detect/{tree_id}  (image upload)
  ↓
MediaPipe Hands → knuckle_width_px  (services/mediapipe_service.py)
  ↓
YOLOv8 → mango bounding boxes + growth_stage 1–4  (services/yolo_service.py)
  ↓
size_estimator → size_cm = (mango_px / knuckle_px) × HAND_SPAN_CM  (services/size_estimator.py)
  ↓
harvest_predictor → harvest_date from growth_phases table  (services/harvest_predictor.py)
  ↓
Saved to DB: Detection → Fruit records with labels e.g. "T01-001"
```

Both ML models are loaded at startup (`@app.on_event("startup")`) and held in memory — do not reload per request.

### Pulp Ripeness Analysis (V1 addition)

`POST /analyze/pulp` — color-based post-harvest ripeness. No ML model; uses Euclidean distance in normalized RGB space against reference data from Nasir et al. (2021). Samples center 20% of the image. Returns stage 1–5, Brix estimate, firmness, and `days_to_ready`. Implemented in `services/pulp_analyzer.py`.

### Training Data Collection

`POST /training/upload` — accepts image + YOLO-format annotations JSON from the Collector app. Stores to `storage/images/training/images/` and `storage/images/training/labels/`. `POST /training/train` triggers a background YOLOv8 fine-tune via `services/trainer.py`.

### Database Schema

```
users → farms → trees → detections → fruits
                  ↑________________________|
                    (tree_id shortcut on fruits)
```

Additional table: `growth_phases` — seeded lookup (migration 004) mapping growth stage + size range to `days_to_harvest`.

Migrations are plain Python scripts in `migrations/` (not standard Alembic versions). Run sequentially via `alembic upgrade head` using the custom `env.py`.

### Flutter App Structure

- **State management**: `provider` package
- **HTTP client**: `dio` with JWT stored in `flutter_secure_storage`
- **Map**: `google_maps_flutter` (satellite view, farm dashboard)
- Auth flow: `login_screen` → `home_screen` → `tree_list_screen` → `camera_screen` → `result_screen`
- Pulp analysis flow: `pulp_camera_screen` → `pulp_result_screen`

### Authentication

JWT tokens (HS256), 7-day expiry (`access_token_expire_minutes = 10080`). Password reset via 6-digit OTP sent over SMTP. SMTP silently skipped if `smtp_user`/`smtp_password` not configured.

Rate limiting is applied via `slowapi` (configured in `limiter.py`).

## Key Configuration (mlharum-api/.env)

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string |
| `SECRET_KEY` | JWT signing key |
| `YOLO_MODEL_PATH` | Path to trained `.pt` weights (default: `./weights/mango_yolov8.pt`) |
| `AVG_KNUCKLE_WIDTH_CM` | Real-world knuckle width for size estimation (default: 1.8 cm) |
| `SMTP_*` | Optional — only needed for password reset emails |

## Growth Stages Reference

| Stage | Size | Days to Harvest |
|---|---|---|
| 1 (Early) | 1.0–2.5 cm | 90 days |
| 2 (Mid) | 2.5–5.0 cm | 56 days |
| 3 (Late) | 5.0–8.0 cm | 30 days |
| 4 (Pre-harvest) | 8.0–12.0 cm | 14 days |

> Stage 2 (56 days) sourced from Nasir et al. (2021), AAFRJ. Stages 1, 3, 4 are field estimates — verify against literature if publishing.

## Versioning Context

- **V1** (current): Core pipeline complete — detection, sizing, harvest prediction, per-tree labeling, mobile app, pulp analysis
- **V2** (planned student extension): Buyer portal, push notifications, dashboard filters, harvest confirmation, PDF export
