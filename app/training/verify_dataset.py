import os
import sys
import json
from pathlib import Path
from PIL import Image

DATASET_ROOT = Path(r"E:\Agrovia V 0.1\datasets\Plant Village Dataset")
OUTPUT_DIR = Path(r"E:\Agrovia V 0.1\app\training")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

splits = ["Train", "Val", "Test"]

print(f"=== 1. Checking Dataset Path: {DATASET_ROOT} ===")
if not DATASET_ROOT.exists():
    print(f"ERROR: Dataset path does not exist: {DATASET_ROOT}")
    sys.exit(1)

split_dirs = {}
for s in splits:
    d = DATASET_ROOT / s
    if not d.exists():
        print(f"ERROR: Split directory not found: {d}")
        sys.exit(1)
    split_dirs[s] = d

# Discover classes from Train
train_classes = sorted([d.name for d in split_dirs["Train"].iterdir() if d.is_dir()])
val_classes = sorted([d.name for d in split_dirs["Val"].iterdir() if d.is_dir()])
test_classes = sorted([d.name for d in split_dirs["Test"].iterdir() if d.is_dir()])

print(f"\nTotal Train classes found: {len(train_classes)}")
print(f"Total Val classes found: {len(val_classes)}")
print(f"Total Test classes found: {len(test_classes)}")

# Validate class consistency
if set(train_classes) != set(val_classes):
    print("WARNING: Train and Val classes differ!")
    print("In Train only:", set(train_classes) - set(val_classes))
    print("In Val only:", set(val_classes) - set(train_classes))

if set(train_classes) != set(test_classes):
    print("WARNING: Train and Test classes differ!")
    print("In Train only:", set(train_classes) - set(test_classes))
    print("In Test only:", set(test_classes) - set(train_classes))

canonical_classes = train_classes
print(f"\nCanonical classes count: {len(canonical_classes)}")

# Generate class-to-index mapping
class_to_idx = {cls_name: idx for idx, cls_name in enumerate(canonical_classes)}
idx_to_class = {idx: cls_name for idx, cls_name in enumerate(canonical_classes)}

# Save class mappings
with open(OUTPUT_DIR / "class_to_idx.json", "w") as f:
    json.dump(class_to_idx, f, indent=2)

with open(OUTPUT_DIR / "labels.txt", "w") as f:
    for cls_name in canonical_classes:
        f.write(f"{cls_name}\n")

# Also copy to app/assets/models if exists or prepare
assets_models = Path(r"E:\Agrovia V 0.1\app\assets\models")
assets_models.mkdir(parents=True, exist_ok=True)
with open(assets_models / "labels.txt", "w") as f:
    for cls_name in canonical_classes:
        f.write(f"{cls_name}\n")

print(f"Saved canonical labels to {OUTPUT_DIR / 'labels.txt'} and {assets_models / 'labels.txt'}")

# Verify images, corruption, counts
stats = {}
corrupted_files = []
non_image_files = []

for s in splits:
    stats[s] = {}
    total_split_images = 0
    print(f"\n--- Verifying {s} split ---")
    for cls_name in canonical_classes:
        cls_dir = split_dirs[s] / cls_name
        if not cls_dir.exists():
            stats[s][cls_name] = 0
            continue
        files = list(cls_dir.iterdir())
        valid_img_count = 0
        for p in files:
            if p.is_dir():
                continue
            ext = p.suffix.lower()
            if ext not in [".jpg", ".jpeg", ".png", ".bmp", ".webp"]:
                non_image_files.append(str(p))
                continue
            # Check if image can be opened and verified
            try:
                with Image.open(p) as img:
                    img.verify()
                valid_img_count += 1
            except Exception as e:
                corrupted_files.append((str(p), str(e)))
        stats[s][cls_name] = valid_img_count
        total_split_images += valid_img_count
    print(f"Total valid images in {s}: {total_split_images}")

print("\n=== Dataset Summary ===")
print(f"Total Train images: {sum(stats['Train'].values())}")
print(f"Total Val images: {sum(stats['Val'].values())}")
print(f"Total Test images: {sum(stats['Test'].values())}")
print(f"Total Images: {sum(stats['Train'].values()) + sum(stats['Val'].values()) + sum(stats['Test'].values())}")
print(f"Corrupted images count: {len(corrupted_files)}")
print(f"Non-image files count: {len(non_image_files)}")

if corrupted_files:
    print("Corrupted files found:", corrupted_files[:10])

# Save verification report
report = {
    "num_classes": len(canonical_classes),
    "classes": canonical_classes,
    "class_to_idx": class_to_idx,
    "stats": stats,
    "corrupted_files": corrupted_files,
    "non_image_files": non_image_files,
    "total_train": sum(stats['Train'].values()),
    "total_val": sum(stats['Val'].values()),
    "total_test": sum(stats['Test'].values()),
}

with open(OUTPUT_DIR / "dataset_verification_report.json", "w") as f:
    json.dump(report, f, indent=2)

print("\nVerification Complete! Report saved to dataset_verification_report.json")
