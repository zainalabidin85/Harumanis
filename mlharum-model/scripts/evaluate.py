"""
Evaluate a trained model on the test set and print per-class metrics.
Run after training to get final test set performance.

Usage:
    python scripts/evaluate.py
    python scripts/evaluate.py --weights ../weights/mango_yolov8.pt
"""
import os
import argparse
from ultralytics import YOLO

WEIGHTS_DIR = os.path.join(os.path.dirname(__file__), '..', 'weights')
DATA_YAML   = os.path.join(os.path.dirname(__file__), '..', 'datasets', 'labeled', 'data.yaml')


def evaluate(weights_path: str, split: str):
    if not os.path.exists(weights_path):
        print(f'Weights not found: {weights_path}')
        print('Run train.py first.')
        return

    model = YOLO(weights_path)
    metrics = model.val(data=DATA_YAML, split=split)

    print(f'\nEvaluation results ({split} split)')
    print(f'{"─"*40}')
    print(f'mAP@0.5      : {metrics.box.map50:.4f}')
    print(f'mAP@0.5-0.95 : {metrics.box.map:.4f}')
    print(f'Precision    : {metrics.box.mp:.4f}')
    print(f'Recall       : {metrics.box.mr:.4f}')
    print()
    print('Per-class AP@0.5:')
    for name, ap in zip(metrics.names.values(), metrics.box.ap50):
        bar = chr(9608) * int(ap * 30)
        print(f'  {name:15s}: {ap:.4f}  {bar}')

    if metrics.box.map50 < 0.5:
        print('\nWarning: mAP@0.5 < 0.5 — model needs improvement before deployment.')
        print('Check class balance in notebook 01 and annotation quality in Roboflow.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--weights', default=os.path.join(WEIGHTS_DIR, 'mango_yolov8.pt'))
    parser.add_argument('--split',   default='test', choices=['train', 'val', 'test'])
    args = parser.parse_args()
    evaluate(args.weights, args.split)
