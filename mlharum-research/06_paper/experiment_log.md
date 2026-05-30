# Experiment Log

Fill in each row as you complete the work. This becomes your paper's Methods section.

---

## Dataset

| Item | Value |
|---|---|
| Total images collected | |
| Stage 1 (training) | |
| Stage 2 (training) | |
| Stage 3 (training) | |
| Stage 4 (training) | |
| Train / Val / Test split | 70% / 15% / 15% |
| Annotation tool | Roboflow |
| Collection date range | |
| Location | |
| Number of collectors | |

---

## Knuckle Width Measurements

| Collector | Knuckle width (cm) |
|---|---|
| C01 | |
| C02 | |
| **Mean ± SD** | |

---

## YOLO Training

| Run | Base model | Epochs | Batch | Image size | mAP@0.5 | mAP@0.5:0.95 | Inference (ms, CPU) |
|---|---|---|---|---|---|---|---|
| 1 | yolov8n.pt | 100 | 16 | 640 | | | |
| 2 | yolov8s.pt | 100 | 16 | 640 | | | |
| 3 | yolov8m.pt | 100 | 8  | 640 | | | |

Selected model: **yolov8___.pt** (reason: ___)

---

## Per-class Detection Results (selected model, test set)

| Class | Precision | Recall | F1 | AP@0.5 |
|---|---|---|---|---|
| Stage 1 | | | | |
| Stage 2 | | | | |
| Stage 3 | | | | |
| Stage 4 | | | | |
| **Overall** | | | | |

---

## Sizing Validation

| Metric | Overall | Stage 1 | Stage 2 | Stage 3 | Stage 4 |
|---|---|---|---|---|---|
| N | | | | | |
| MAE (cm) | | | | | |
| RMSE (cm) | | | | | |
| MAPE (%) | | | | | |
| r² | | | | | |
| Bias (cm) | | | | | |
| LoA lower (cm) | | | | | |
| LoA upper (cm) | | | | | |

Knuckle width used: **1.8 cm** (default) / measured mean: ___

---

## Issues / Observations

- 
