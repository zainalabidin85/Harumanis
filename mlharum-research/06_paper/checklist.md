# Submission Checklist — COMPAG

## Before submission, all items must be checked ✓

### Data
- [ ] ≥ 600 annotated training images (≥ 150 per class)
- [ ] ≥ 120 validation images with caliper ground truth (≥ 30 per stage)
- [ ] Knuckle width measured from all data collectors (mean ± SD reported)
- [ ] Dataset available on Roboflow (public or DOI) for reproducibility
- [ ] `experiment_log.md` fully filled in

### YOLO Experiment
- [ ] Trained ≥ 2 model variants (YOLOv8n, YOLOv8s)
- [ ] `03_yolo_experiment/results/metrics_summary.csv` complete
- [ ] Confusion matrix figure generated (300 dpi)
- [ ] PR curve figure generated (300 dpi)
- [ ] Inference time on CPU measured (mobile-representative device)

### Sizing Validation
- [ ] `04_sizing_validation/results/pipeline_output.csv` complete (no_hand + no_mango rates reported)
- [ ] `04_sizing_validation/results/sizing_metrics.csv` complete
- [ ] Scatter plot generated (300 dpi)
- [ ] Bland-Altman plot generated (300 dpi)
- [ ] Error by stage boxplot generated (300 dpi)

### Paper Figures
- [ ] Fig. 1 — pipeline diagram
- [ ] Fig. 2 — sample detection photo (annotated screenshot)
- [ ] Fig. 3 — confusion matrix
- [ ] Fig. 4 — PR curve
- [ ] Fig. 5 — scatter plot
- [ ] Fig. 6 — Bland-Altman
- [ ] Fig. 7 — error by stage

### Writing
- [ ] Abstract ≤ 250 words
- [ ] Keywords listed (suggest: Mango, YOLOv8, Size estimation, MediaPipe, Precision agriculture, Growth stage)
- [ ] All figures cited in text
- [ ] Nasir et al. (2021) cited for growth stage data
- [ ] Limitations section written (knuckle width assumption, single variety, image conditions)
- [ ] Dataset DOI / link included in Data Availability statement

### Journal Requirements (COMPAG, Elsevier)
- [ ] Manuscript in Word or LaTeX (Elsevier template)
- [ ] Highlights (3–5 bullet points, ≤ 85 chars each)
- [ ] Graphical abstract (1 image, 520 × 1050 px recommended)
- [ ] Cover letter written
- [ ] All authors have approved submission

---

## Target: ≥ 0.80 mAP@0.5 and RMSE < 0.8 cm for a competitive submission
