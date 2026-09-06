"""Evaluate trained MobileNetV2 on Test split."""
import json
from pathlib import Path

import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torchvision import transforms, models
from torchvision.datasets import ImageFolder

from sklearn.metrics import (
    accuracy_score,
    precision_recall_fscore_support,
    confusion_matrix,
    classification_report,
)

NUM_CLASSES  = 29
IMG_SIZE     = 224
BATCH_SIZE   = 64
DEVICE       = torch.device("cuda" if torch.cuda.is_available() else "cpu")
DATASET_ROOT = Path(r"E:\Agrovia V 0.1\datasets\Plant Village Dataset")
OUTPUT_DIR   = Path(r"E:\Agrovia V 0.1\app\training")
MODEL_PATH   = OUTPUT_DIR / "best_model.pth"

def main():
    print(f"Device: {DEVICE}")
    print(f"Loading checkpoint: {MODEL_PATH}")

    val_tf = transforms.Compose([
        transforms.Resize((IMG_SIZE, IMG_SIZE)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])

    test_ds = ImageFolder(str(DATASET_ROOT / "Test"), transform=val_tf)
    test_loader = DataLoader(test_ds, batch_size=BATCH_SIZE, shuffle=False, num_workers=0)
    print(f"Test samples: {len(test_ds)}")

    model = models.mobilenet_v2(weights=None)
    model.classifier[1] = nn.Linear(model.classifier[1].in_features, NUM_CLASSES)
    model.load_state_dict(torch.load(MODEL_PATH, map_location=DEVICE))
    model = model.to(DEVICE)
    model.eval()

    all_preds = []
    all_targets = []

    with torch.no_grad():
        for imgs, labels in test_loader:
            imgs = imgs.to(DEVICE)
            out = model(imgs)
            _, preds = out.max(1)
            all_preds.extend(preds.cpu().numpy().tolist())
            all_targets.extend(labels.numpy().tolist())

    acc = accuracy_score(all_targets, all_preds)
    p_macro, r_macro, f1_macro, _ = precision_recall_fscore_support(all_targets, all_preds, average="macro", zero_division=0)
    p_weighted, r_weighted, f1_weighted, _ = precision_recall_fscore_support(all_targets, all_preds, average="weighted", zero_division=0)

    p_per_class, r_per_class, f1_per_class, support = precision_recall_fscore_support(all_targets, all_preds, average=None, zero_division=0)
    cm = confusion_matrix(all_targets, all_preds).tolist()
    clf_report = classification_report(all_targets, all_preds, target_names=test_ds.classes, output_dict=True, zero_division=0)

    print("\n================ TEST SET EVALUATION ================")
    print(f"Overall Accuracy:  {acc * 100:.2f}%")
    print(f"Macro Precision:   {p_macro * 100:.2f}%")
    print(f"Macro Recall:      {r_macro * 100:.2f}%")
    print(f"Macro F1-Score:    {f1_macro * 100:.2f}%")
    print(f"Weighted F1-Score: {f1_weighted * 100:.2f}%")
    print("=====================================================\n")

    report = {
        "num_classes": NUM_CLASSES,
        "test_samples": len(test_ds),
        "overall_accuracy": acc,
        "macro_metrics": {
            "precision": p_macro,
            "recall": r_macro,
            "f1": f1_macro,
        },
        "weighted_metrics": {
            "precision": p_weighted,
            "recall": r_weighted,
            "f1": f1_weighted,
        },
        "per_class": {
            cls_name: {
                "precision": float(p_per_class[i]),
                "recall": float(r_per_class[i]),
                "f1": float(f1_per_class[i]),
                "support": int(support[i]),
            }
            for i, cls_name in enumerate(test_ds.classes)
        },
        "confusion_matrix": cm,
        "classification_report": clf_report,
    }

    with open(OUTPUT_DIR / "evaluation_report.json", "w") as f:
        json.dump(report, f, indent=2)

    print(f"Evaluation report saved to {OUTPUT_DIR / 'evaluation_report.json'}")

if __name__ == "__main__":
    main()
