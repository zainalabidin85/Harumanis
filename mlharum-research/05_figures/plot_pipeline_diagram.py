"""
Generate a schematic pipeline diagram for the paper (Figure 1).

Usage:
    python 05_figures/plot_pipeline_diagram.py
"""
import os
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyArrowPatch

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_DIR = os.path.join(SCRIPT_DIR, "output")

STEPS = [
    ("Field Image\n(mango + open hand)", "#f7f7f7"),
    ("MediaPipe\nHandLandmarker\n→ knuckle_width_px", "#deebf7"),
    ("YOLOv8\n4-class detector\n→ bbox + stage", "#e5f5e0"),
    ("Size Estimator\nsize_cm = (bbox_h / knuckle_px)\n× 1.8 cm", "#fee8c8"),
    ("Harvest Predictor\nharvest_date from\ngrowth_phases table", "#f2f0f7"),
    ("Result\nlabel, size_cm,\nharvest_date, days", "#fff7bc"),
]

EDGE_COLOR = "#555555"
ARROW_COLOR = "#333333"


def main():
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    fig, ax = plt.subplots(figsize=(12, 3.2))
    ax.set_xlim(0, 12)
    ax.set_ylim(0, 3.2)
    ax.axis("off")

    box_w = 1.7
    box_h = 2.2
    y_center = 1.6
    x_start = 0.3
    x_gap = 2.0

    for i, (label, color) in enumerate(STEPS):
        x = x_start + i * x_gap
        rect = mpatches.FancyBboxPatch(
            (x, y_center - box_h / 2), box_w, box_h,
            boxstyle="round,pad=0.05",
            facecolor=color, edgecolor=EDGE_COLOR, linewidth=1.2,
        )
        ax.add_patch(rect)
        ax.text(
            x + box_w / 2, y_center, label,
            ha="center", va="center", fontsize=7.5, wrap=True,
            multialignment="center",
        )

        if i < len(STEPS) - 1:
            ax.annotate(
                "", xy=(x + x_gap, y_center),
                xytext=(x + box_w, y_center),
                arrowprops=dict(arrowstyle="->", color=ARROW_COLOR, lw=1.5),
            )

    ax.set_title("MLharum Detection Pipeline", fontsize=11, fontweight="bold", pad=6)
    plt.tight_layout()

    path = os.path.join(OUTPUT_DIR, "pipeline_diagram.png")
    fig.savefig(path, dpi=300, bbox_inches="tight")
    plt.close(fig)
    print(f"Saved → {path}")


if __name__ == "__main__":
    main()
