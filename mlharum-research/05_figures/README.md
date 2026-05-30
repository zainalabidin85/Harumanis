# Step 5 — Paper Figures

All figures are generated automatically by scripts in Steps 3 and 4.
This folder contains one additional script for the system pipeline diagram.

---

## Figure inventory for COMPAG submission

| Figure | Script | Output file |
|---|---|---|
| Fig. 1 — System architecture | `plot_pipeline_diagram.py` | `pipeline_diagram.png` |
| Fig. 2 — Sample detection images | (manual — screenshot from app) | |
| Fig. 3 — Confusion matrix | `03_yolo_experiment/evaluate_paper.py` | `confusion_matrix_yolov8n.png` |
| Fig. 4 — PR curve | `03_yolo_experiment/evaluate_paper.py` | `pr_curve_yolov8n.png` |
| Fig. 5 — Scatter (estimated vs caliper) | `04_sizing_validation/compute_metrics.py` | `scatter_estimated_vs_caliper.png` |
| Fig. 6 — Bland-Altman | `04_sizing_validation/compute_metrics.py` | `bland_altman.png` |
| Fig. 7 — Error by growth stage | `04_sizing_validation/compute_metrics.py` | `error_by_stage.png` |

All output files land in `05_figures/output/`.

---

## Generate the pipeline diagram

```bash
python 05_figures/plot_pipeline_diagram.py
```
