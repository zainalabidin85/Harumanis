# Step 2 — Dataset Preparation

## Goal
Verify that annotations are complete and correct before training begins.
A broken dataset produces misleading metrics that waste weeks of work.

---

## Workflow

```bash
cd mlharum-research

# 1. Check annotation quality and class balance
python 02_dataset_prep/check_dataset.py

# 2. If class imbalance > 3:1, run augmentation on the minority class
cd mlharum-model
python scripts/augment.py --class_name stage-1 --multiplier 3
```

---

## What `check_dataset.py` reports

- Total images per split (train / val / test)
- Label count per class per split
- Images with no label file (missing annotations)
- Images with empty label files (unannotated)
- Bounding box sanity check (coordinates out of range 0–1)

Fix all warnings before moving to Step 3.

---

## Expected output (healthy dataset)

```
Dataset: mlharum-model/datasets/labeled
─────────────────────────────────────────
Split    Images   stage-1  stage-2  stage-3  stage-4
train      420      105      108      102      105
val         90       22       23       22       23
test        90       22       23       22       23
─────────────────────────────────────────
No missing labels.
No empty label files.
All bounding boxes valid.
✓ Dataset looks good.
```
