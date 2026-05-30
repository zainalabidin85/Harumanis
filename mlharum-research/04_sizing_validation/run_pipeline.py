"""
Run the full sizing pipeline (MediaPipe + YOLO + size estimator) on a folder of
validation images and save estimated sizes alongside caliper ground truth.

Usage:
    python 04_sizing_validation/run_pipeline.py \
        --images path/to/validation_images/ \
        --ground_truth 01_data_collection/ground_truth_template.csv \
        --weights ../mlharum-model/weights/mango_yolov8.pt

Output: 04_sizing_validation/results/pipeline_output.csv
"""
import os
import sys
import argparse
import csv
import math
import glob

import cv2
import numpy as np

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
API_DIR = os.path.join(SCRIPT_DIR, "..", "..", "mlharum-api")
sys.path.insert(0, API_DIR)

RESULTS_DIR = os.path.join(SCRIPT_DIR, "results")
AVG_KNUCKLE_WIDTH_CM = 1.8

# Knuckle span: index MCP (landmark 5) to pinky MCP (landmark 17)
_INDEX_MCP = 5
_PINKY_MCP = 17


def load_ground_truth(csv_path: str) -> dict:
    gt = {}
    with open(csv_path) as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row["caliper_length_cm"]:
                gt[row["image_id"]] = {
                    "growth_stage": int(row["growth_stage"]) if row["growth_stage"] else None,
                    "caliper_cm": float(row["caliper_length_cm"]),
                }
    return gt


def detect_knuckle_width(image_bgr: np.ndarray, detector) -> float | None:
    import mediapipe as mp
    image_rgb = cv2.cvtColor(image_bgr, cv2.COLOR_BGR2RGB)
    mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=image_rgb)
    result = detector.detect(mp_image)
    if not result.hand_landmarks:
        return None
    landmarks = result.hand_landmarks[0]
    h, w = image_bgr.shape[:2]
    index_x = landmarks[_INDEX_MCP].x * w
    pinky_x = landmarks[_PINKY_MCP].x * w
    return abs(index_x - pinky_x)


def detect_mango(image_bgr: np.ndarray, model):
    results = model.predict(image_bgr, verbose=False)[0]
    if not results.boxes:
        return None, None
    best_box = max(results.boxes, key=lambda b: float(b.conf[0]))
    x1, y1, x2, y2 = best_box.xyxy[0].tolist()
    growth_stage = int(best_box.cls[0].item()) + 1
    return y2 - y1, growth_stage  # return bbox height in px


def estimate_size(bbox_h_px: float, knuckle_px: float, knuckle_cm: float) -> float:
    return (bbox_h_px / knuckle_px) * knuckle_cm


def run(images_dir: str, gt_path: str, weights_path: str, knuckle_cm: float, output_csv: str):
    from ultralytics import YOLO
    import mediapipe as mp
    from mediapipe.tasks import python as mp_python
    from mediapipe.tasks.python import vision

    hand_model_path = os.path.join(API_DIR, "weights", "hand_landmarker.task")
    if not os.path.exists(hand_model_path):
        sys.exit(f"Hand landmarker not found: {hand_model_path}")
    if not os.path.exists(weights_path):
        sys.exit(f"YOLO weights not found: {weights_path}")

    base_options = mp_python.BaseOptions(model_asset_path=hand_model_path)
    options = vision.HandLandmarkerOptions(
        base_options=base_options, num_hands=1,
        min_hand_detection_confidence=0.7, min_hand_presence_confidence=0.7,
    )
    detector = vision.HandLandmarker.create_from_options(options)
    yolo_model = YOLO(weights_path)

    gt = load_ground_truth(gt_path)
    images = sorted(glob.glob(os.path.join(images_dir, "*.jpg"))
                    + glob.glob(os.path.join(images_dir, "*.jpeg"))
                    + glob.glob(os.path.join(images_dir, "*.png")))

    os.makedirs(os.path.dirname(output_csv), exist_ok=True)

    results = []
    skipped = 0

    for img_path in images:
        image_id = os.path.splitext(os.path.basename(img_path))[0]
        if image_id not in gt:
            skipped += 1
            continue

        image_bgr = cv2.imread(img_path)
        if image_bgr is None:
            print(f"  [skip] cannot read {img_path}")
            continue

        knuckle_px = detect_knuckle_width(image_bgr, detector)
        if knuckle_px is None:
            results.append({
                "image_id": image_id, "status": "no_hand",
                "estimated_cm": None, "caliper_cm": gt[image_id]["caliper_cm"],
                "growth_stage_gt": gt[image_id]["growth_stage"],
                "growth_stage_pred": None, "error_cm": None,
            })
            continue

        bbox_h_px, stage_pred = detect_mango(image_bgr, yolo_model)
        if bbox_h_px is None:
            results.append({
                "image_id": image_id, "status": "no_mango",
                "estimated_cm": None, "caliper_cm": gt[image_id]["caliper_cm"],
                "growth_stage_gt": gt[image_id]["growth_stage"],
                "growth_stage_pred": None, "error_cm": None,
            })
            continue

        estimated_cm = estimate_size(bbox_h_px, knuckle_px, knuckle_cm)
        caliper_cm = gt[image_id]["caliper_cm"]
        results.append({
            "image_id": image_id, "status": "ok",
            "estimated_cm": round(estimated_cm, 3),
            "caliper_cm": caliper_cm,
            "growth_stage_gt": gt[image_id]["growth_stage"],
            "growth_stage_pred": stage_pred,
            "error_cm": round(estimated_cm - caliper_cm, 3),
        })

    with open(output_csv, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(results[0].keys()))
        writer.writeheader()
        writer.writerows(results)

    ok = [r for r in results if r["status"] == "ok"]
    print(f"\nProcessed : {len(images)} images")
    print(f"Skipped (no GT): {skipped}")
    print(f"No hand   : {sum(1 for r in results if r['status'] == 'no_hand')}")
    print(f"No mango  : {sum(1 for r in results if r['status'] == 'no_mango')}")
    print(f"Successful: {len(ok)}")
    print(f"Output    : {output_csv}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--images", required=True)
    parser.add_argument("--ground_truth", required=True)
    parser.add_argument(
        "--weights",
        default=os.path.join(SCRIPT_DIR, "..", "..", "mlharum-model", "weights", "mango_yolov8.pt"),
    )
    parser.add_argument("--knuckle_cm", type=float, default=AVG_KNUCKLE_WIDTH_CM)
    parser.add_argument(
        "--output",
        default=os.path.join(RESULTS_DIR, "pipeline_output.csv"),
    )
    args = parser.parse_args()
    run(args.images, args.ground_truth, args.weights, args.knuckle_cm, args.output)
