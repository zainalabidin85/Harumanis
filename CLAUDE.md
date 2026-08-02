# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Ai-Harumanis is an AI-based yield estimation, ripeness prediction, and fruit management system for Harumanis mango. It consists of four components (directory names are unchanged from the project's former "MLharum" name):

- **`mlharum-api/`** — FastAPI backend (Python); runs all AI server-side
- **`mlharum-app/`** — Ai-Harumanis Flutter mobile app (Android-first, farmer-facing); camera capture + results + satellite dashboard
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
YOLOv8 → mango bounding box only, class 0  (services/yolo_service.py)
  ↓
size_estimator → size_cm = (mango_px / knuckle_px) × HAND_SPAN_CM  (services/size_estimator.py)
  ↓
harvest_predictor → size_cm lookup → growth_phases table → resolved_stage + days_to_harvest  (services/harvest_predictor.py)
  ↓
Saved to DB: Detection → Fruit records with labels e.g. "T01-001"
```

Both ML models are loaded at startup (`@app.on_event("startup")`) and held in memory — do not reload per request.

**Important — stage classification design:** YOLO is trained as single-class (`nc: 1`, class 0 = mango). It only detects the fruit bounding box. Growth stage is never classified by YOLO — it is determined purely from the measured `size_cm` via the `growth_phases` DB lookup. Do not add stage classes to YOLO; Harumanis mango shape does not change between stages, only size does, so visual stage classification would not be reliable.

**Flush color tag (farmer-facing, additive only):** Farmers physically color-tag bagging paper per blooming flush (a tree blooms ~3–4 times/season). `Fruit.flush_color` mirrors this in-app so farmers can recognize a fruit's cohort at a glance, set via `PATCH /trees/{fruit_id}/flush-color` (mlharum-app only, right after a fruit enters the Bagging stage). It is purely a display convenience layered on top of the numeric `T01-001` label — DOA's yield counts still rely on the numeric label/season counter, not on color, since color isn't unique across trees/seasons.

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

Migrations live in `migrations/versions/` as standard Alembic revision scripts. Run via `alembic upgrade head`. (`migrations/` itself only holds `env.py`/`script.py.mako` — a stray duplicate set of top-level scripts that predated `versions/` was cleaned up 2026-08-03; if you ever see loose `.py` files directly under `migrations/` again, Alembic won't load them — move them into `versions/` or delete.)

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

Aligned with the Department of Agriculture Perlis (DOA)'s 3-stage field classification (as of 2026-07):

| Stage | Size | Days to Harvest | Notes |
|---|---|---|---|
| 1 (Early) | < 40 mm (< 4.0 cm) | ~90 days | **Not persisted to the DB.** High natural fruit-abortion (drop) rate before the stem hardens — DOA doesn't treat this as a reliably countable stage. Detection returns a note to the farmer instead of creating a Fruit record. |
| 2 (Bagging) | 40–45 mm (4.0–4.5 cm) | ~56 days | Stem is firm enough to reliably hold the fruit — this is when farmers physically bag it. First stage persisted as a Fruit record. |
| 3 (Pre-harvest / late bagging) | > 45 mm (> 4.5 cm) | ~49 days | Open-ended upper bound — do not clamp to an old size cap. |

> Stage 2's 56-day figure originally sourced from Nasir et al. (2021), AAFRJ, for the old 4-stage model; DOA's mm boundaries and the 49-day Pre-harvest estimate are field figures from the 2026-07 DOA Perlis meeting — verify against literature if publishing.

## Model Retraining Plan (Next Season)

The current YOLO model has ~23 training images and produces loose bounding boxes, which slightly overestimates fruit size. Retraining is planned for the next Ai-Harumanis season.

### Goal
Tighter bounding boxes → more accurate `size_cm` measurement. Stage classification is **not** a goal — stage is determined by size, not by YOLO.

### What to do
1. Use the **Collector app** to photograph fruit across the full size range (small to near-harvest)
2. Annotate with **tight boxes** — hug the fruit edge closely, no extra padding
3. Target **100–200 images** total (more variety = better generalisation)
4. Keep `nc: 1`, `names: ['mango']` in `data.yaml` — do not add stage classes
5. Retrain: `python scripts/train.py --model yolov8n.pt --epochs 100`
6. Deploy new weights to server: `mlharum-api/weights/mango_yolov8.pt` and restart uvicorn

### What not to change
- Do not add growth stage classes to YOLO
- Do not change the size estimation formula or `AVG_KNUCKLE_WIDTH_CM` unless field-validated
- The `growth_phases` table is the source of truth for stage → days mapping

## Versioning Context

- **V1** (current): Core pipeline complete — detection, sizing, harvest prediction, per-tree labeling, mobile app, pulp analysis
- **V2** (planned student extension): Buyer portal, push notifications, dashboard filters, harvest confirmation, PDF export
