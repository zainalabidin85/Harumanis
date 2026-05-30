# Field Data Collection SOP

**Project:** MLharum — COMPAG paper
**Version:** 1.0

---

## Equipment checklist

- [ ] Android phone with Ai-Harumanis app installed (or camera app, min 12 MP)
- [ ] Digital caliper (0.01 mm resolution)
- [ ] Printed data sheet (or `ground_truth_template.csv` on phone)
- [ ] Ruler or tape measure (for spot-check of knuckle width)
- [ ] Pen, labels, ziplock bags (optional — for sample collection)

---

## Per-fruit procedure

### Step 1 — Measure with caliper
Measure the **longest axis** (stem to tip) while fruit is still on tree.
Record: `tree_id`, `fruit_position` (e.g. "north branch, 3rd fruit"), `caliper_length_cm`.

### Step 2 — Photograph
Position: phone ~40–60 cm from fruit, lens aligned with fruit centre.
Hand placement: palm open, fingers together, held flat **directly beside** the mango so both
the hand and mango are in focus and roughly the same depth plane.

Take **3 photos** per fruit:
- `_a`: straight on
- `_b`: 30° left
- `_c`: 30° right

File naming: `T{tree_id}_{fruit_pos}_{angle}.jpg`  e.g. `T03_02_a.jpg`

### Step 3 — Record in CSV
Fill one row per image in `ground_truth_template.csv`.
`image_id` must exactly match the filename (without extension).

---

## Knuckle width calibration

Measure the knuckle span (index MCP to pinky MCP) of **each data collector** with a caliper.
Record in `knuckle_measurements.csv`:

| collector_id | name | knuckle_width_cm |
|---|---|---|
| C01 | … | … |

The system default is 1.8 cm. Report the measured mean ± SD in the paper.

---

## Session log

For each field session, record:
- Date, location (GPS coordinates), weather, time of day
- Total fruits measured, total images captured
- Any anomalies (occlusion, damaged fruit, unusual lighting)
