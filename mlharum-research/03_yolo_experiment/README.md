# Step 3 — YOLO Training Experiment

## Goal
Train YOLOv8 on the Harumanis dataset, evaluate on the held-out test set,
and record all metrics needed for the paper's Table 2 (Detection Results).

---

## Workflow

```bash
# 1. Train the model (runs in mlharum-model/)
cd mlharum-model
python scripts/train.py --model yolov8n.pt --epochs 100

# 2. Evaluate on test set and save metrics
cd ../mlharum-research
python 03_yolo_experiment/evaluate_paper.py

# Results saved to: 03_yolo_experiment/results/
```

---

## Models to compare (Table 2 in paper)

Run training once for each variant. Record results in `experiment_log.md`.

| Variant | Command | Expected mAP@0.5 |
|---|---|---|
| YOLOv8n (nano) | `--model yolov8n.pt` | baseline |
| YOLOv8s (small) | `--model yolov8s.pt` | +2–4% |
| YOLOv8m (medium) | `--model yolov8m.pt` | +3–6% |

> For a mobile-deployed system, **YOLOv8n** is the expected final choice (speed vs accuracy tradeoff).
> Include all three in the paper to justify the choice.

---

## Metrics to report (for paper)

From `evaluate_paper.py` output:

| Metric | Description |
|---|---|
| mAP@0.5 | Standard detection metric |
| mAP@0.5:0.95 | Stricter IoU range |
| Precision | Per-class and overall |
| Recall | Per-class and overall |
| F1 | Harmonic mean |
| Inference time (ms) | On CPU (mobile-representative) |

---

## Output files (in `results/`)

- `metrics_summary.csv` — all runs in one table
- `confusion_matrix.png` — used in Figure 3 of paper
- `pr_curve.png` — precision-recall curve
- `training_curves.png` — loss + mAP over epochs
