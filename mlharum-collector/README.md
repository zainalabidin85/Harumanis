# MLharum Collector

Standalone Android app for collecting Harumanis mango training images.

## Setup

1. **Run the API server** (`mlharum-api`) on a machine accessible from your phone.
2. **Install the app** on Android (`flutter build apk --release`).
3. **On first launch**, enter the server URL (e.g. `http://192.168.1.x:8000`) and your name.

## Usage

1. Tap **Capture** — point at a mango fruit on the tree.
2. On the label screen, pick the **growth stage** (or "Unknown").
3. Add optional notes, then tap **Upload to Server**.
4. Check the **Stats** tab to see dataset counts by stage.

## Growth Stages

| Stage | Size |
|-------|------|
| Stage 1 | Fruit set, tiny < 2 cm |
| Stage 2 | Early growth 2–4 cm |
| Stage 3 | Mid growth 4–6 cm |
| Stage 4 | Late growth 6–8 cm |
| Stage 5 | Near maturity > 8 cm |
| Stage 6 | Mature / color change |
| Unknown | Not sure |

## Server Storage

Images are saved to:
```
storage/images/training/<stage>/<uuid>.jpg
```
Upload log is at `storage/images/training/uploads.csv`.
