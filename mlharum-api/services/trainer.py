import json
import os
import random
import shutil
import threading
from datetime import datetime

from config import settings

# ── Paths ────────────────────────────────────────────────────────────────────
_API_DIR      = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_TRAINING_DIR = os.path.join(os.path.abspath(settings.image_storage_path), "training")
_IMAGE_DIR    = os.path.join(_TRAINING_DIR, "images")
_LABEL_DIR    = os.path.join(_TRAINING_DIR, "labels")
_DATASET_DIR  = os.path.join(_TRAINING_DIR, "dataset")
_WEIGHTS_DIR  = os.path.join(_API_DIR, "weights")
_STATUS_FILE  = os.path.join(_TRAINING_DIR, "training_status.json")

DEPLOY_PATH       = os.path.abspath(settings.yolo_model_path)
DEFAULT_BASE_MODEL = os.path.join(_WEIGHTS_DIR, os.path.basename(settings.yolo_base_model_path))
MIN_BOXES         = 50   # minimum labeled boxes required before training is allowed
TOTAL_EPOCHS  = 100

_lock = threading.Lock()

# ── Status helpers ────────────────────────────────────────────────────────────

def _default_status() -> dict:
    return {
        "state": "idle",
        "started_at": None,
        "finished_at": None,
        "total_images": 0,
        "total_boxes": 0,
        "epochs_done": 0,
        "total_epochs": TOTAL_EPOCHS,
        "base_model": None,
        "model_deployed": False,
        "error": None,
    }


def get_status() -> dict:
    if not os.path.exists(_STATUS_FILE):
        return _default_status()
    with open(_STATUS_FILE) as f:
        return json.load(f)


def _write_status(data: dict):
    os.makedirs(_TRAINING_DIR, exist_ok=True)
    with open(_STATUS_FILE, "w") as f:
        json.dump(data, f, indent=2)


# ── Dataset preparation ───────────────────────────────────────────────────────

def _count_boxes() -> int:
    total = 0
    if not os.path.isdir(_LABEL_DIR):
        return 0
    for lf in os.listdir(_LABEL_DIR):
        path = os.path.join(_LABEL_DIR, lf)
        if os.path.isfile(path):
            with open(path) as f:
                total += sum(1 for line in f if line.strip())
    return total


def _count_images() -> int:
    if not os.path.isdir(_IMAGE_DIR):
        return 0
    return sum(1 for f in os.listdir(_IMAGE_DIR) if os.path.isfile(os.path.join(_IMAGE_DIR, f)))


def _prepare_dataset() -> str:
    """Split images/labels 80/20 into dataset/train and dataset/val. Returns data.yaml path."""
    # Collect paired samples (image + label must both exist)
    label_stems = {
        os.path.splitext(f)[0]
        for f in os.listdir(_LABEL_DIR)
        if os.path.isfile(os.path.join(_LABEL_DIR, f))
    }
    image_map = {}
    for f in os.listdir(_IMAGE_DIR):
        stem = os.path.splitext(f)[0]
        if stem in label_stems:
            image_map[stem] = f

    samples = list(image_map.items())
    random.shuffle(samples)

    split = max(1, int(len(samples) * 0.8))
    train_samples = samples[:split]
    val_samples   = samples[split:] if len(samples) > 1 else samples[:1]

    # Clear and recreate dataset dirs
    if os.path.exists(_DATASET_DIR):
        shutil.rmtree(_DATASET_DIR)

    for subset, items in [("train", train_samples), ("val", val_samples)]:
        img_out = os.path.join(_DATASET_DIR, subset, "images")
        lbl_out = os.path.join(_DATASET_DIR, subset, "labels")
        os.makedirs(img_out, exist_ok=True)
        os.makedirs(lbl_out, exist_ok=True)
        for stem, img_file in items:
            shutil.copy(os.path.join(_IMAGE_DIR, img_file), os.path.join(img_out, img_file))
            lbl_file = stem + ".txt"
            shutil.copy(os.path.join(_LABEL_DIR, lbl_file), os.path.join(lbl_out, lbl_file))

    yaml_path = os.path.join(_DATASET_DIR, "data.yaml")
    with open(yaml_path, "w") as f:
        f.write(f"path: {_DATASET_DIR}\n")
        f.write("train: train/images\n")
        f.write("val: val/images\n")
        f.write("nc: 1\n")
        f.write("names: ['mango']\n")

    return yaml_path


# ── Training thread ───────────────────────────────────────────────────────────

def _run_training(status: dict, base_model: str):
    try:
        from ultralytics import YOLO

        yaml_path = _prepare_dataset()

        # Epoch progress callback
        def _on_epoch_end(trainer):
            status["epochs_done"] = trainer.epoch + 1
            _write_status(status)

        runs_dir = os.path.join(_TRAINING_DIR, "runs")
        model = YOLO(base_model)
        model.add_callback("on_train_epoch_end", _on_epoch_end)

        results = model.train(
            data=yaml_path,
            epochs=TOTAL_EPOCHS,
            imgsz=640,
            batch=8,
            device=0,
            project=runs_dir,
            name="mango",
            exist_ok=True,
            verbose=False,
        )

        # Deploy best.pt
        best_pt = os.path.join(runs_dir, "mango", "weights", "best.pt")
        if not os.path.exists(best_pt):
            raise FileNotFoundError(f"best.pt not found at {best_pt}")

        os.makedirs(_WEIGHTS_DIR, exist_ok=True)
        prev = DEPLOY_PATH.replace(".pt", "_prev.pt")
        if os.path.exists(DEPLOY_PATH):
            shutil.copy(DEPLOY_PATH, prev)

        shutil.copy(best_pt, DEPLOY_PATH)

        # Reload live model
        import services.yolo_service as ys
        ys.load_model()

        if isinstance(results, dict):
            metrics = results
        else:
            metrics = getattr(results, "results_dict", {}) or {}
        status.update({
            "state": "done",
            "finished_at": datetime.utcnow().isoformat(),
            "model_deployed": True,
            "epochs_done": TOTAL_EPOCHS,
            "map50":     round(float(metrics.get("metrics/mAP50(B)",    0)), 4),
            "map50_95":  round(float(metrics.get("metrics/mAP50-95(B)", 0)), 4),
            "precision": round(float(metrics.get("metrics/precision(B)", 0)), 4),
            "recall":    round(float(metrics.get("metrics/recall(B)",    0)), 4),
        })

    except Exception as exc:
        status.update({
            "state": "failed",
            "finished_at": datetime.utcnow().isoformat(),
            "error": str(exc),
        })

    finally:
        _write_status(status)


# ── Public API ────────────────────────────────────────────────────────────────

def list_base_models() -> list[dict]:
    """Return all .pt files in weights/ dir so the caller can pick a base model."""
    if not os.path.isdir(_WEIGHTS_DIR):
        return []
    return [
        {"filename": f, "path": os.path.join(_WEIGHTS_DIR, f)}
        for f in sorted(os.listdir(_WEIGHTS_DIR))
        if f.endswith(".pt")
    ]


def start_training(base_model: str | None = None) -> dict:
    with _lock:
        current = get_status()
        if current["state"] == "running":
            return {"ok": False, "reason": "Training is already running."}

        boxes = _count_boxes()
        if boxes < MIN_BOXES:
            return {"ok": False, "reason": f"Need at least {MIN_BOXES} labeled boxes. Currently have {boxes}."}

        resolved_base = base_model or DEFAULT_BASE_MODEL
        if not os.path.exists(resolved_base):
            return {"ok": False, "reason": f"Base model not found: {os.path.basename(resolved_base)}. Place it in weights/ first."}

        status = {
            "state": "running",
            "started_at": datetime.utcnow().isoformat(),
            "finished_at": None,
            "total_images": _count_images(),
            "total_boxes": boxes,
            "epochs_done": 0,
            "total_epochs": TOTAL_EPOCHS,
            "base_model": os.path.basename(resolved_base),
            "model_deployed": False,
            "error": None,
        }
        _write_status(status)

        t = threading.Thread(target=_run_training, args=(status, resolved_base), daemon=True)
        t.start()

        return {"ok": True, "reason": f"Training started using {os.path.basename(resolved_base)}."}
