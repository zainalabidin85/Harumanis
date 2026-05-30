"""
Evaluate a trained YOLOv8 model and save publication-ready metrics + figures.

Usage:
    python 03_yolo_experiment/evaluate_paper.py
    python 03_yolo_experiment/evaluate_paper.py --weights ../mlharum-model/weights/mango_yolov8.pt --run yolov8n
"""
import os
import sys
import time
import argparse
import csv
import numpy as np
import cv2

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
RESULTS_DIR = os.path.join(SCRIPT_DIR, "results")
DATA_YAML = os.path.join(SCRIPT_DIR, "..", "..", "mlharum-model", "datasets", "labeled", "data.yaml")
DEFAULT_WEIGHTS = os.path.join(SCRIPT_DIR, "..", "..", "mlharum-model", "weights", "mango_yolov8.pt")
CLASSES = ["stage-1", "stage-2", "stage-3", "stage-4"]


def measure_inference_time(model, data_yaml: str, n_samples: int = 50) -> float:
    """Returns mean inference time in ms on CPU over n_samples images."""
    from ultralytics import YOLO
    import glob

    img_dir = os.path.join(os.path.dirname(data_yaml), "test", "images")
    images = glob.glob(os.path.join(img_dir, "*.jpg"))[:n_samples]
    if not images:
        return -1.0

    times = []
    for img_path in images:
        img = cv2.imread(img_path)
        start = time.perf_counter()
        model.predict(img, verbose=False, device="cpu")
        times.append((time.perf_counter() - start) * 1000)

    return float(np.mean(times))


def evaluate(weights_path: str, data_yaml: str, run_name: str):
    from ultralytics import YOLO

    if not os.path.exists(weights_path):
        sys.exit(f"Weights not found: {weights_path}\nRun mlharum-model/scripts/train.py first.")

    os.makedirs(RESULTS_DIR, exist_ok=True)

    print(f"\nEvaluating: {run_name}")
    print(f"Weights   : {weights_path}")
    print(f"Data      : {data_yaml}\n")

    model = YOLO(weights_path)
    metrics = model.val(data=data_yaml, split="test", verbose=False)

    map50 = metrics.box.map50
    map5095 = metrics.box.map
    precision = metrics.box.mp
    recall = metrics.box.mr
    f1 = 2 * precision * recall / (precision + recall + 1e-9)

    per_class_ap50 = list(metrics.box.ap50)
    per_class_p = list(metrics.box.p) if hasattr(metrics.box, 'p') else [None] * 4
    per_class_r = list(metrics.box.r) if hasattr(metrics.box, 'r') else [None] * 4

    inf_ms = measure_inference_time(model, data_yaml)

    # ── Console summary ────────────────────────────────────────────────────────
    print(f"{'─'*50}")
    print(f"{'Metric':<25} {'Value':>10}")
    print(f"{'─'*50}")
    print(f"{'mAP@0.5':<25} {map50:>10.4f}")
    print(f"{'mAP@0.5:0.95':<25} {map5095:>10.4f}")
    print(f"{'Precision':<25} {precision:>10.4f}")
    print(f"{'Recall':<25} {recall:>10.4f}")
    print(f"{'F1':<25} {f1:>10.4f}")
    print(f"{'Inference (ms, CPU)':<25} {inf_ms:>10.1f}")
    print(f"{'─'*50}")
    print("Per-class AP@0.5:")
    for name, ap, p, r in zip(CLASSES, per_class_ap50, per_class_p, per_class_r):
        bar = "█" * int(ap * 30)
        print(f"  {name:<12}: AP={ap:.4f}  P={p:.4f}  R={r:.4f}  {bar}")

    # ── Save metrics CSV ───────────────────────────────────────────────────────
    csv_path = os.path.join(RESULTS_DIR, "metrics_summary.csv")
    file_exists = os.path.exists(csv_path)
    with open(csv_path, "a", newline="") as f:
        writer = csv.writer(f)
        if not file_exists:
            writer.writerow(["run", "mAP50", "mAP5095", "precision", "recall", "f1", "inference_ms_cpu"]
                            + [f"AP50_{c}" for c in CLASSES])
        writer.writerow(
            [run_name, round(map50, 4), round(map5095, 4), round(precision, 4),
             round(recall, 4), round(f1, 4), round(inf_ms, 1)]
            + [round(ap, 4) for ap in per_class_ap50]
        )
    print(f"\nMetrics appended → {csv_path}")

    # ── Confusion matrix ───────────────────────────────────────────────────────
    _save_confusion_matrix(metrics, run_name)

    # ── PR curve ──────────────────────────────────────────────────────────────
    _save_pr_curve(metrics, run_name)

    print(f"Figures saved → {RESULTS_DIR}/")


def _save_confusion_matrix(metrics, run_name: str):
    import matplotlib.pyplot as plt
    import matplotlib.ticker as ticker
    import seaborn as sns

    try:
        cm = metrics.confusion_matrix.matrix.astype(int)
    except Exception:
        print("  [skip] confusion matrix not available")
        return

    n = len(CLASSES)
    cm_norm = cm[:n, :n].astype(float)
    row_sums = cm_norm.sum(axis=1, keepdims=True)
    cm_norm = np.divide(cm_norm, row_sums, where=row_sums != 0)

    fig, ax = plt.subplots(figsize=(6, 5))
    sns.heatmap(
        cm_norm, annot=True, fmt=".2f", cmap="Blues",
        xticklabels=CLASSES, yticklabels=CLASSES, ax=ax,
        vmin=0, vmax=1,
    )
    ax.set_xlabel("Predicted")
    ax.set_ylabel("True")
    ax.set_title(f"Normalized Confusion Matrix — {run_name}")
    plt.tight_layout()
    path = os.path.join(RESULTS_DIR, f"confusion_matrix_{run_name}.png")
    fig.savefig(path, dpi=300)
    plt.close(fig)
    print(f"  Confusion matrix → {path}")


def _save_pr_curve(metrics, run_name: str):
    import matplotlib.pyplot as plt

    try:
        px = metrics.box.curves_results[0]
        py = metrics.box.curves_results[1]
    except Exception:
        print("  [skip] PR curve data not available from this ultralytics version")
        return

    fig, ax = plt.subplots(figsize=(6, 5))
    colors = ["#e41a1c", "#377eb8", "#4daf4a", "#984ea3"]
    for i, (name, color) in enumerate(zip(CLASSES, colors)):
        if i < py.shape[0]:
            ax.plot(px, py[i], label=f"{name} (AP={metrics.box.ap50[i]:.3f})", color=color, linewidth=1.5)
    ax.set_xlabel("Recall")
    ax.set_ylabel("Precision")
    ax.set_title(f"Precision-Recall Curve — {run_name}")
    ax.legend(loc="lower left", fontsize=9)
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1.05)
    ax.grid(True, linestyle="--", alpha=0.4)
    plt.tight_layout()
    path = os.path.join(RESULTS_DIR, f"pr_curve_{run_name}.png")
    fig.savefig(path, dpi=300)
    plt.close(fig)
    print(f"  PR curve → {path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--weights", default=DEFAULT_WEIGHTS)
    parser.add_argument("--data", default=DATA_YAML)
    parser.add_argument("--run", default="yolov8n", help="Label for this run in the CSV")
    args = parser.parse_args()
    evaluate(args.weights, args.data, args.run)
