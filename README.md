# MLharum

An AI-powered yield estimation, ripeness prediction, and fruit management system for Harumanis mango. Built for farmers, collectors, and buyers — from orchard to market.

---

## Components

| Directory | Description |
|---|---|
| `mlharum-api/` | FastAPI backend — AI detection, auth, marketplace, farm management |
| `mlharum-app/` | Flutter mobile app (Android) — camera capture, detection results, satellite dashboard |
| `mlharum-admin/` | Flutter admin panel — user and farm management |
| `harumanis-app/` | Flutter buyer app — marketplace, orders, farm browsing |
| `mlharum-collector/` | Flutter data collection app — captures training images on-device |
| `mlharum-model/` | YOLOv8 training pipeline — Jupyter notebooks and training scripts |
| `mlharum-research/` | Research validation scripts and experiment logs |

---

## Features

- **AI Detection** — YOLOv8 detects mango count and growth stage (1–4) from a photo
- **Size Estimation** — uses MediaPipe hand landmark as a scale reference (knuckle width)
- **Harvest Prediction** — estimates days to harvest from growth stage and fruit size
- **Pulp Ripeness Analysis** — post-harvest color-based ripeness scoring (stage 1–5, Brix estimate, firmness)
- **Farm Dashboard** — satellite map view of farms and trees with per-tree detection history
- **Marketplace** — buyers can browse farms, place orders, and track deliveries
- **Training Pipeline** — collect images on-device and fine-tune the YOLO model from the API

---

## AI Detection Pipeline

```
POST /detect/{tree_id}  (image upload)
  ↓
MediaPipe Hands → knuckle_width_px
  ↓
YOLOv8 → mango bounding boxes + growth_stage 1–4
  ↓
size_estimator → size_cm = (mango_px / knuckle_px) × HAND_SPAN_CM
  ↓
harvest_predictor → harvest_date from growth_phases table
  ↓
Saved to DB: Detection → Fruit records (labelled e.g. T01-001)
```

---

## Getting Started

### API (mlharum-api)

**Requirements:** Python 3.10+, PostgreSQL

```bash
cd mlharum-api

# Install dependencies
pip install -r requirements.txt

# Or install separately for constrained environments
pip install -r requirements-core.txt   # API/auth only
pip install -r requirements-ml.txt     # ML dependencies

# Configure environment
cp .env.example .env
# Edit .env — set DATABASE_URL and SECRET_KEY at minimum

# Run migrations
alembic upgrade head

# Start server
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Swagger docs available at `http://localhost:8000/docs`

### Flutter Apps (mlharum-app / harumanis-app / mlharum-collector)

**Requirements:** Flutter 3.x, Android device or emulator

```bash
cd mlharum-app   # or harumanis-app / mlharum-collector

flutter pub get
flutter run
```

Before running, set your server address in `lib/services/api_service.dart`:
```dart
static const _baseUrl = 'https://your-server-address';
```

### Model Training (mlharum-model)

```bash
cd mlharum-model
pip install -r requirements.txt

# Via Jupyter (recommended)
jupyter notebook

# Via CLI
python scripts/train.py --model yolov8n.pt --epochs 100

# Copy trained weights to API
cp weights/mango_yolov8.pt ../mlharum-api/weights/mango_yolov8.pt
```

---

## Configuration

Key environment variables for `mlharum-api/.env`:

| Variable | Description |
|---|---|
| `DATABASE_URL` | PostgreSQL connection string |
| `SECRET_KEY` | JWT signing key |
| `YOLO_MODEL_PATH` | Path to trained `.pt` weights |
| `AVG_KNUCKLE_WIDTH_CM` | Real-world knuckle width for size estimation (default: 1.8 cm) |
| `SMTP_HOST` / `SMTP_USER` / `SMTP_PASSWORD` | Optional — for password reset emails |
| `BILLPLZ_API_KEY` / `BILLPLZ_COLLECTION_ID` | Optional — for payment processing |

---

## Growth Stages Reference

| Stage | Description | Size Range | Days to Harvest |
|---|---|---|---|
| 1 | Early | 1.0–2.5 cm | ~90 days |
| 2 | Mid (bagging window) | 2.5–5.0 cm | ~56 days |
| 3 | Late | 5.0–8.0 cm | ~30 days |
| 4 | Pre-harvest | 8.0–12.0 cm | ~14 days |

> Stage 2 days-to-harvest sourced from Nasir et al. (2021), AAFRJ.

---

## Database Schema

```
users → farms → trees → detections → fruits
                  ↑________________________|
                    (tree_id shortcut on fruits)
```

Additional tables: `growth_phases`, `farm_images`, `orders`, `testimonials`

---

## Authentication

JWT tokens (HS256), 7-day expiry. Password reset via 6-digit OTP over email (requires SMTP config).

---

## Built With

- [FastAPI](https://fastapi.tiangolo.com/) — API framework
- [YOLOv8 (Ultralytics)](https://github.com/ultralytics/ultralytics) — mango detection
- [MediaPipe](https://mediapipe.dev/) — hand landmark detection
- [Flutter](https://flutter.dev/) — mobile apps
- [PostgreSQL](https://www.postgresql.org/) — database
- [SQLAlchemy](https://www.sqlalchemy.org/) + [Alembic](https://alembic.sqlalchemy.org/) — ORM and migrations
