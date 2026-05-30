# MLharum — AI Harumanis Mango Management System

MLharum is an end-to-end AI system for Harumanis mango farms. It estimates fruit yield, predicts harvest dates, assesses pulp ripeness, and connects farmers directly to buyers — all from a smartphone.

## Downloads

| App | For | Download |
|---|---|---|
| Ai-Harumanis | Farmers | [Ai-Harumanis-v1.5.2.apk](https://github.com/zainalabidin85/Harumanis/releases/download/v1.0.0/Ai-Harumanis-v1.5.2.apk) |
| BeliHarumanis | Buyers | [BeliHarumanis-v1.7.0.apk](https://github.com/zainalabidin85/Harumanis/releases/download/v1.0.0/BeliHarumanis-v1.7.0.apk) |

> Android only. Enable **Install from unknown sources** in your device settings before installing.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        MLharum API                          │
│                    (FastAPI + PostgreSQL)                    │
│                                                             │
│   YOLOv8 Detection  ·  MediaPipe Sizing  ·  Pulp Analyzer  │
└────────────┬──────────────┬──────────────┬──────────────────┘
             │              │              │
     ┌───────┴──────┐ ┌─────┴──────┐ ┌────┴────────┐
     │  MLharum App │ │Harumanis   │ │ Admin Panel │
     │  (Farmer)    │ │App (Buyer) │ │             │
     └──────────────┘ └────────────┘ └─────────────┘
             │
     ┌───────┴──────┐
     │  Collector   │
     │  App         │
     └──────────────┘
```

The API is the central brain — it runs all AI models server-side. The four apps communicate with it over HTTPS. No AI runs on-device.

### AI Detection Flow

```
Farmer takes photo of mango tree
         ↓
MediaPipe detects hand in frame → measures knuckle width in pixels (scale reference)
         ↓
YOLOv8 detects each mango → bounding box + growth stage (1–4)
         ↓
Size estimator → fruit diameter in cm = (mango_px / knuckle_px) × 1.8 cm
         ↓
Harvest predictor → days to harvest based on stage + size
         ↓
Results saved to database, each fruit labelled (e.g. T01-001)
```

---

## The Four Apps

### 1. MLharum App — For Farmers

The main field app. Farmers use this to scan their mango trees, monitor growth, and manage their farm.

**Key screens:**
- **Home** — farm overview, recent detections, quick actions
- **Tree List** — all trees in a farm with detection history
- **Tree Detail** — per-tree fruit count, growth stage breakdown, harvest timeline
- **Camera** — point camera at tree (with hand in frame) to trigger AI detection
- **Detection Result** — fruit count, average size, estimated harvest date, per-fruit labels
- **Pulp Camera** — photograph a cut mango cross-section for pulp ripeness analysis
- **Pulp Result** — ripeness stage (1–5), estimated Brix (sweetness), firmness, days until ready
- **Farm Photos** — photo gallery for each farm
- **Dashboard** — satellite map view of all farms and tree locations
- **Orders** — incoming orders from buyers

---

### 2. Harumanis App — For Buyers

Buyers use this app to browse farms, check fruit availability, and place orders.

**Key screens:**
- **Marketplace** — browse available farms and their mango listings with price per kg
- **Farm Detail** — farm profile, photos, available stock, seller contact
- **Order** — place an order with quantity and delivery details
- **My Orders** — track order status from pending to delivered
- **Order Detail** — full order breakdown, payment status
- **Pulp Camera / Result** — buyers can also scan received fruit to verify ripeness

---

### 3. MLharum Admin — For Administrators

A management panel for overseeing the entire platform.

**Key screens:**
- **Dashboard** — platform-wide stats: total users, farms, detections, orders
- **Users** — view and manage all farmer and buyer accounts
- **Farms** — browse and manage all registered farms
- **Orders** — monitor all marketplace transactions
- **Payouts** — manage farmer payout records

---

### 4. Collector App — For Research / Data Collection

A standalone app used to build the AI training dataset. Used by researchers and field assistants to capture annotated mango images.

**Key screens:**
- **Camera** — capture photos of mango trees for training data
- **Annotation** — annotate each captured image with YOLO-format bounding boxes and growth stage labels
- **Stats** — view upload counts and live model training status triggered from the API
- **Settings** — configure the API server address

Collected images and labels are uploaded to the API and used to fine-tune the YOLOv8 model.

---

## Growth Stages

| Stage | Description | Size | Days to Harvest |
|---|---|---|---|
| 1 | Early fruitlet | 1.0–2.5 cm | ~90 days |
| 2 | Mid growth (bagging window) | 2.5–5.0 cm | ~56 days |
| 3 | Late growth | 5.0–8.0 cm | ~30 days |
| 4 | Pre-harvest | 8.0–12.0 cm | ~14 days |

---

## Pulp Ripeness Stages

| Stage | Description |
|---|---|
| 1 | Unripe — firm, pale yellow |
| 2 | Slightly ripe — some colour, low Brix |
| 3 | Ripe — golden yellow, optimal Brix |
| 4 | Very ripe — deep colour, soft |
| 5 | Overripe — past optimal, high Brix but declining firmness |

Ripeness is assessed using Euclidean distance in RGB colour space against reference data from Nasir et al. (2021).

---

## Tech Stack

| Layer | Technology |
|---|---|
| Backend API | FastAPI, PostgreSQL, SQLAlchemy, Alembic |
| Object Detection | YOLOv8 (Ultralytics) |
| Hand Landmark | MediaPipe |
| Mobile Apps | Flutter (Android) |
| Authentication | JWT (HS256), OTP email reset |
| Payments | Billplz |
