"""
CLI training script — alternative to running notebook 02.
Useful for running on a remote server without Jupyter.

Usage:
    python scripts/train.py
    python scripts/train.py --model yolov8s.pt --epochs 150 --batch 8
"""
import os
import argparse
import shutil
import torch
from ultralytics import YOLO

WEIGHTS_DIR = os.path.join(os.path.dirname(__file__), '..', 'weights')
DATA_YAML   = os.path.join(os.path.dirname(__file__), '..', 'datasets', 'labeled', 'data.yaml')


def train(model_base: str, epochs: int, batch: int, img_size: int):
    os.makedirs(WEIGHTS_DIR, exist_ok=True)

    print(f'PyTorch {torch.__version__}  CUDA={torch.cuda.is_available()}')
    if torch.cuda.is_available():
        print(f'GPU: {torch.cuda.get_device_name(0)}')

    model = YOLO(model_base)
    model.train(
        data=DATA_YAML,
        epochs=epochs,
        imgsz=img_size,
        batch=batch,
        name='mango_yolov8',
        project=WEIGHTS_DIR,
        patience=20,
        augment=True,
        degrees=15,
        flipud=0.3,
        fliplr=0.5,
        hsv_h=0.02,
        hsv_s=0.5,
        hsv_v=0.4,
    )

    src = os.path.join(WEIGHTS_DIR, 'mango_yolov8', 'weights', 'best.pt')
    dst = os.path.join(WEIGHTS_DIR, 'mango_yolov8.pt')
    shutil.copy(src, dst)

    size_mb = os.path.getsize(dst) / 1024 / 1024
    print(f'\nDeployed weights: {dst}  ({size_mb:.1f} MB)')
    print('Copy to mlharum-api/weights/mango_yolov8.pt to deploy.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--model',   default='yolov8n.pt', help='Base YOLOv8 model')
    parser.add_argument('--epochs',  type=int, default=100)
    parser.add_argument('--batch',   type=int, default=16)
    parser.add_argument('--imgsz',   type=int, default=640)
    args = parser.parse_args()
    train(args.model, args.epochs, args.batch, args.imgsz)
