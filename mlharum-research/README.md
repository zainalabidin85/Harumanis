# MLharum Research — COMPAG Paper

**Title (draft):** *A Mobile AI System for Hand-Referenced Fruit Size Estimation and Growth Stage
Classification of Harumanis Mango Using YOLOv8 and MediaPipe*

**Target journal:** Computers and Electronics in Agriculture (Elsevier)

**Supervisor:** Zainal Abidin, UniMAP

---

## Folder Structure

| Folder | What to do there |
|--------|-----------------|
| `01_data_collection/` | Field protocol, capture SOP, ground-truth CSV template |
| `02_dataset_prep/` | Verify annotations, check class balance, create splits |
| `03_yolo_experiment/` | Train, evaluate, compare model variants |
| `04_sizing_validation/` | Run pipeline on test images, compute error vs calipers |
| `05_figures/` | Generate paper-ready figures |
| `06_paper/` | Experiment log, submission checklist |

Work through the folders **in order**. Each folder has its own `README.md`.

---

## Quick Setup

```bash
cd mlharum-research
pip install -r requirements.txt
```

---

## Pipeline Overview

```
Field photo (mango + open hand)
        │
        ▼
MediaPipe HandLandmarker
  → knuckle_width_px  (index MCP to pinky MCP)
        │
        ▼
YOLOv8 (4-class: stage-1, stage-2, stage-3, stage-4)
  → bounding box (x, y, w, h)
  → growth_stage (1–4)
        │
        ▼
Size estimator
  size_cm = (bbox_h_px / knuckle_width_px) × AVG_KNUCKLE_WIDTH_CM
        │
        ▼
Harvest predictor
  harvest_date = today + days_to_harvest[stage][size_range]
```

**Scale constant:** `AVG_KNUCKLE_WIDTH_CM = 1.8 cm`
(index MCP → pinky MCP span; verify against your population in 04_sizing_validation)

---

## Paper Sections → Research Folder Mapping

| Paper section | Folder |
|---|---|
| 3.1 Dataset | 01 + 02 |
| 3.2 YOLO model | 03 |
| 3.3 Size estimation method | 04 |
| 4.1 Detection results (mAP, confusion matrix) | 03 + 05 |
| 4.2 Sizing accuracy (RMSE, Bland-Altman) | 04 + 05 |
| 4.3 System deployment | mlharum-api + mlharum-app |
