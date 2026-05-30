"""
Compute sizing accuracy metrics from pipeline_output.csv and generate figures.

Usage:
    python 04_sizing_validation/compute_metrics.py
    python 04_sizing_validation/compute_metrics.py --input 04_sizing_validation/results/pipeline_output.csv
"""
import os
import argparse
import math
import csv

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import seaborn as sns
from scipy import stats

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
RESULTS_DIR = os.path.join(SCRIPT_DIR, "results")
FIGURES_DIR = os.path.join(SCRIPT_DIR, "..", "05_figures", "output")
CLASSES = ["stage-1", "stage-2", "stage-3", "stage-4"]
STAGE_COLORS = {1: "#e41a1c", 2: "#377eb8", 3: "#4daf4a", 4: "#984ea3"}


def compute_errors(df: pd.DataFrame) -> dict:
    est = df["estimated_cm"].values
    cal = df["caliper_cm"].values
    err = est - cal
    mae = np.mean(np.abs(err))
    rmse = math.sqrt(np.mean(err ** 2))
    mape = np.mean(np.abs(err) / cal) * 100
    r, p = stats.pearsonr(est, cal)
    r2 = r ** 2
    bias = np.mean(err)
    return {"n": len(df), "mae": mae, "rmse": rmse, "mape": mape, "r2": r2, "bias": bias}


def print_table(overall: dict, per_stage: dict):
    print(f"\n{'─'*60}")
    print(f"{'Metric':<12}  {'Overall':>8}  " + "  ".join(f"{'Stg'+str(s):>8}" for s in range(1, 5)))
    print(f"{'─'*60}")
    for metric in ["n", "mae", "rmse", "mape", "r2", "bias"]:
        units = {"mae": " cm", "rmse": " cm", "mape": "%", "bias": " cm"}.get(metric, "")
        fmt = ".1f" if metric in ("n",) else ".4f"
        row = f"{metric:<12}  {overall[metric]:>8{fmt}}"
        for s in range(1, 5):
            v = per_stage.get(s, {}).get(metric)
            row += f"  {v:>8{fmt}}" if v is not None else f"  {'—':>8}"
        print(row + units)
    print(f"{'─'*60}")


def plot_scatter(df: pd.DataFrame):
    fig, ax = plt.subplots(figsize=(6, 6))
    for stage, grp in df.groupby("growth_stage_gt"):
        ax.scatter(grp["caliper_cm"], grp["estimated_cm"],
                   color=STAGE_COLORS.get(stage, "grey"), label=f"Stage {stage}",
                   alpha=0.7, s=40, edgecolors="none")
    lo = min(df["caliper_cm"].min(), df["estimated_cm"].min()) - 0.5
    hi = max(df["caliper_cm"].max(), df["estimated_cm"].max()) + 0.5
    ax.plot([lo, hi], [lo, hi], "k--", linewidth=1, label="Ideal (y = x)")
    ax.set_xlabel("Caliper measurement (cm)")
    ax.set_ylabel("Estimated size (cm)")
    ax.set_title("Estimated vs Caliper Size")
    ax.legend(fontsize=9)
    ax.set_xlim(lo, hi)
    ax.set_ylim(lo, hi)
    ax.set_aspect("equal")
    ax.grid(True, linestyle="--", alpha=0.3)
    plt.tight_layout()
    _save(fig, "scatter_estimated_vs_caliper.png")


def plot_bland_altman(df: pd.DataFrame):
    mean = (df["estimated_cm"] + df["caliper_cm"]) / 2
    diff = df["estimated_cm"] - df["caliper_cm"]
    bias = diff.mean()
    sd = diff.std()
    loa_upper = bias + 1.96 * sd
    loa_lower = bias - 1.96 * sd

    fig, ax = plt.subplots(figsize=(7, 5))
    for stage, grp in df.groupby("growth_stage_gt"):
        m = (grp["estimated_cm"] + grp["caliper_cm"]) / 2
        d = grp["estimated_cm"] - grp["caliper_cm"]
        ax.scatter(m, d, color=STAGE_COLORS.get(stage, "grey"),
                   label=f"Stage {stage}", alpha=0.7, s=40, edgecolors="none")

    ax.axhline(bias, color="black", linewidth=1.5, label=f"Bias = {bias:.3f} cm")
    ax.axhline(loa_upper, color="red", linewidth=1, linestyle="--",
               label=f"+1.96 SD = {loa_upper:.3f} cm")
    ax.axhline(loa_lower, color="red", linewidth=1, linestyle="--",
               label=f"−1.96 SD = {loa_lower:.3f} cm")
    ax.fill_between([mean.min() - 0.5, mean.max() + 0.5], loa_lower, loa_upper,
                    alpha=0.05, color="red")
    ax.set_xlabel("Mean of estimated and caliper (cm)")
    ax.set_ylabel("Estimated − Caliper (cm)")
    ax.set_title("Bland-Altman Plot — Sizing Agreement")
    ax.legend(fontsize=8, loc="upper right")
    ax.grid(True, linestyle="--", alpha=0.3)
    plt.tight_layout()
    _save(fig, "bland_altman.png")
    print(f"  Bias={bias:.4f} cm  LoA=[{loa_lower:.4f}, {loa_upper:.4f}] cm")


def plot_error_by_stage(df: pd.DataFrame):
    fig, ax = plt.subplots(figsize=(6, 4))
    data_by_stage = [
        df[df["growth_stage_gt"] == s]["error_cm"].values for s in range(1, 5)
    ]
    bp = ax.boxplot(data_by_stage, patch_artist=True, medianprops={"color": "black"})
    for patch, stage in zip(bp["boxes"], range(1, 5)):
        patch.set_facecolor(STAGE_COLORS[stage])
        patch.set_alpha(0.7)
    ax.axhline(0, color="black", linewidth=0.8, linestyle="--")
    ax.set_xticks(range(1, 5))
    ax.set_xticklabels([f"Stage {s}" for s in range(1, 5)])
    ax.set_ylabel("Error (estimated − caliper, cm)")
    ax.set_title("Size Estimation Error by Growth Stage")
    ax.grid(True, axis="y", linestyle="--", alpha=0.3)
    plt.tight_layout()
    _save(fig, "error_by_stage.png")


def _save(fig, filename: str):
    os.makedirs(FIGURES_DIR, exist_ok=True)
    path = os.path.join(FIGURES_DIR, filename)
    fig.savefig(path, dpi=300)
    plt.close(fig)
    print(f"  Figure saved → {path}")


def main(input_csv: str):
    if not os.path.exists(input_csv):
        raise SystemExit(f"File not found: {input_csv}\nRun run_pipeline.py first.")

    df = pd.read_csv(input_csv)
    df = df[df["status"] == "ok"].copy()
    df["estimated_cm"] = df["estimated_cm"].astype(float)
    df["caliper_cm"] = df["caliper_cm"].astype(float)
    df["error_cm"] = df["estimated_cm"] - df["caliper_cm"]
    df["growth_stage_gt"] = df["growth_stage_gt"].astype("Int64")

    overall = compute_errors(df)
    per_stage = {}
    for stage, grp in df.groupby("growth_stage_gt"):
        if len(grp) >= 5:
            per_stage[int(stage)] = compute_errors(grp)

    print_table(overall, per_stage)

    # Save metrics CSV
    os.makedirs(RESULTS_DIR, exist_ok=True)
    out_path = os.path.join(RESULTS_DIR, "sizing_metrics.csv")
    rows = [{"group": "overall", **overall}]
    for s, m in per_stage.items():
        rows.append({"group": f"stage-{s}", **m})
    pd.DataFrame(rows).round(4).to_csv(out_path, index=False)
    print(f"\nMetrics saved → {out_path}")

    # Figures
    print("\nGenerating figures...")
    plot_scatter(df)
    plot_bland_altman(df)
    plot_error_by_stage(df)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        default=os.path.join(RESULTS_DIR, "pipeline_output.csv"),
    )
    args = parser.parse_args()
    main(args.input)
