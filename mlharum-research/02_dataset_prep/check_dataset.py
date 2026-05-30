"""
Validate the annotated dataset before training.

Usage:
    python 02_dataset_prep/check_dataset.py
    python 02_dataset_prep/check_dataset.py --data ../mlharum-model/datasets/labeled
"""
import os
import argparse
from collections import defaultdict

CLASSES = ["stage-1", "stage-2", "stage-3", "stage-4"]
SPLITS = ["train", "val", "test"]


def check_split(split_dir: str, split_name: str) -> dict:
    img_dir = os.path.join(split_dir, "images")
    lbl_dir = os.path.join(split_dir, "labels")

    if not os.path.isdir(img_dir):
        print(f"  [MISSING] {img_dir}")
        return {}

    image_files = [f for f in os.listdir(img_dir) if f.lower().endswith((".jpg", ".jpeg", ".png"))]
    counts = defaultdict(int)
    missing_labels = []
    empty_labels = []
    invalid_boxes = []

    for img_file in image_files:
        stem = os.path.splitext(img_file)[0]
        lbl_path = os.path.join(lbl_dir, stem + ".txt")

        if not os.path.exists(lbl_path):
            missing_labels.append(img_file)
            continue

        with open(lbl_path) as f:
            lines = [l.strip() for l in f if l.strip()]

        if not lines:
            empty_labels.append(img_file)
            continue

        for line in lines:
            parts = line.split()
            if len(parts) != 5:
                invalid_boxes.append(f"{img_file}: malformed line '{line}'")
                continue
            cls_id = int(parts[0])
            cx, cy, bw, bh = map(float, parts[1:])
            if not (0 <= cx <= 1 and 0 <= cy <= 1 and 0 < bw <= 1 and 0 < bh <= 1):
                invalid_boxes.append(f"{img_file}: out-of-range bbox {parts[1:]}")
            if cls_id < len(CLASSES):
                counts[CLASSES[cls_id]] += 1

    result = {
        "split": split_name,
        "images": len(image_files),
        "counts": counts,
        "missing_labels": missing_labels,
        "empty_labels": empty_labels,
        "invalid_boxes": invalid_boxes,
    }
    return result


def main(data_dir: str):
    print(f"\nDataset: {data_dir}")
    print("─" * 60)

    header = f"{'Split':<8} {'Images':>7}  " + "  ".join(f"{c:>9}" for c in CLASSES)
    print(header)

    all_ok = True
    for split in SPLITS:
        r = check_split(os.path.join(data_dir, split), split)
        if not r:
            continue
        row = f"{r['split']:<8} {r['images']:>7}  " + "  ".join(
            f"{r['counts'].get(c, 0):>9}" for c in CLASSES
        )
        print(row)

        for issue, items in [
            ("Missing label", r["missing_labels"]),
            ("Empty label", r["empty_labels"]),
            ("Invalid bbox", r["invalid_boxes"]),
        ]:
            for item in items:
                print(f"  [WARN] {issue}: {item}")
                all_ok = False

    print("─" * 60)

    # Class balance check
    train_dir = os.path.join(data_dir, "train")
    train = check_split(train_dir, "train")
    if train:
        counts = [train["counts"].get(c, 0) for c in CLASSES]
        if max(counts) > 0 and min(counts) > 0:
            ratio = max(counts) / min(counts)
            if ratio > 3:
                print(f"  [WARN] Class imbalance ratio {ratio:.1f}:1 — consider augmenting minority classes.")
                all_ok = False
            else:
                print(f"  Class balance ratio: {ratio:.1f}:1  ✓")

    if all_ok:
        print("✓ Dataset looks good. Proceed to Step 3.")
    else:
        print("✗ Fix warnings above before training.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--data",
        default=os.path.join(os.path.dirname(__file__), "..", "..", "mlharum-model", "datasets", "labeled"),
    )
    args = parser.parse_args()
    main(os.path.abspath(args.data))
