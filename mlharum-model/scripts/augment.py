"""
Offline augmentation script — supplements the built-in YOLOv8 augmentations.
Run this only if class distribution is imbalanced after labeling.

Usage:
    python scripts/augment.py --class_name early --multiplier 3
"""
import os
import cv2
import numpy as np
import argparse
import shutil

LABELED_DIR = os.path.join(os.path.dirname(__file__), '..', 'datasets', 'labeled')
AUG_DIR     = os.path.join(os.path.dirname(__file__), '..', 'datasets', 'augmented')


def augment_image(image: np.ndarray) -> list[np.ndarray]:
    augmented = []
    h, w = image.shape[:2]

    # Horizontal flip
    augmented.append(cv2.flip(image, 1))

    # Brightness variations
    for beta in [-40, 40]:
        augmented.append(np.clip(image.astype(np.int16) + beta, 0, 255).astype(np.uint8))

    # Slight rotation
    for angle in [-10, 10]:
        M = cv2.getRotationMatrix2D((w // 2, h // 2), angle, 1.0)
        augmented.append(cv2.warpAffine(image, M, (w, h)))

    return augmented


def flip_bbox(bbox_line: str, img_w: int) -> str:
    parts = bbox_line.strip().split()
    cls_id, cx, cy, bw, bh = parts[0], float(parts[1]), float(parts[2]), float(parts[3]), float(parts[4])
    cx_flipped = 1.0 - cx
    return f"{cls_id} {cx_flipped:.6f} {cy:.6f} {bw:.6f} {bh:.6f}"


def augment_class(class_name: str, multiplier: int, split: str = 'train'):
    img_dir = os.path.join(LABELED_DIR, split, 'images')
    lbl_dir = os.path.join(LABELED_DIR, split, 'labels')
    out_img = os.path.join(AUG_DIR, split, 'images')
    out_lbl = os.path.join(AUG_DIR, split, 'labels')
    os.makedirs(out_img, exist_ok=True)
    os.makedirs(out_lbl, exist_ok=True)

    # Copy originals first
    for f in os.listdir(img_dir):
        shutil.copy(os.path.join(img_dir, f), os.path.join(out_img, f))
    for f in os.listdir(lbl_dir):
        shutil.copy(os.path.join(lbl_dir, f), os.path.join(out_lbl, f))

    count = 0
    for img_file in os.listdir(img_dir):
        stem = os.path.splitext(img_file)[0]
        lbl_file = stem + '.txt'
        lbl_path = os.path.join(lbl_dir, lbl_file)
        if not os.path.exists(lbl_path):
            continue

        with open(lbl_path) as f:
            lines = f.readlines()

        image = cv2.imread(os.path.join(img_dir, img_file))
        augmented_images = augment_image(image)

        for i, aug_img in enumerate(augmented_images[:multiplier - 1]):
            new_stem = f"{stem}_aug{i}"
            cv2.imwrite(os.path.join(out_img, new_stem + '.jpg'), aug_img)

            aug_lines = []
            for line in lines:
                if i == 0:  # horizontal flip — adjust bbox
                    aug_lines.append(flip_bbox(line, image.shape[1]))
                else:
                    aug_lines.append(line.strip())

            with open(os.path.join(out_lbl, new_stem + '.txt'), 'w') as f:
                f.write('\n'.join(aug_lines))
            count += 1

    print(f"Generated {count} augmented images for split='{split}'")
    print(f"Output: {AUG_DIR}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--class_name', default='early', help='Class to augment')
    parser.add_argument('--multiplier', type=int, default=3, help='How many times to multiply images')
    parser.add_argument('--split', default='train', help='Dataset split to augment')
    args = parser.parse_args()
    augment_class(args.class_name, args.multiplier, args.split)
