# Step 1 — Data Collection

## Goal
Collect field images for two purposes:
1. **YOLO training images** — annotated with bounding boxes + growth stage labels
2. **Sizing validation images** — paired with caliper ground-truth measurements

Both can be collected in the same field session.

---

## A. Image Capture Protocol (follow `protocol.md`)

Key rules:
- Photographer holds phone **horizontally**, both hands on device
- A **second person** holds one open palm flat beside the mango (index finger side facing camera)
- Capture **one mango per photo**
- Capture in natural daylight (avoid deep shade or direct midday glare)
- Minimum **3 angles** per fruit: straight-on, 30° left, 30° right

---

## B. Ground Truth Collection (for sizing validation)

After each photo:
1. Measure the **longest axis** of the mango with a digital caliper (±0.01 mm)
2. Record in `ground_truth_template.csv`
3. **Keep the image filename as the key** — rename the photo to match the CSV row

Required columns: `image_id`, `tree_id`, `growth_stage`, `caliper_length_cm`, `notes`

---

## C. Target Dataset Size

| Growth stage | Min images (training) | Min fruits (sizing validation) |
|---|---|---|
| Stage 1 (Early, 1–2.5 cm) | 150 | 30 |
| Stage 2 (Mid, 2.5–5 cm) | 150 | 30 |
| Stage 3 (Late, 5–8 cm) | 150 | 30 |
| Stage 4 (Pre-harvest, 8–12 cm) | 150 | 30 |
| **Total** | **600** | **120** |

> 600 images is the recommended minimum for a COMPAG dataset.
> If class distribution is uneven, use `02_dataset_prep/check_dataset.py` and the augmentation
> script in `mlharum-model/scripts/augment.py`.

---

## D. Annotation Tool

Use **Roboflow** (free account) to label bounding boxes.
- Project type: Object Detection
- Classes (exact names): `stage-1`, `stage-2`, `stage-3`, `stage-4`
- Export format: **YOLOv8**
- Export split: 70% train / 15% val / 15% test

Place exported dataset at:
```
mlharum-model/datasets/labeled/
  train/images/   train/labels/
  val/images/     val/labels/
  test/images/    test/labels/
  data.yaml
```
