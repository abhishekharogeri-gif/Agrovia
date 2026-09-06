"""Validate converted TFLite model against PyTorch model on test samples."""
import json
import time
import shutil
import numpy as np
import torch
import torch.nn as nn
from torchvision import models, transforms
from PIL import Image
from pathlib import Path

BASE_DIR    = Path(r"E:\Agrovia V 0.1")
TRAIN_DIR   = BASE_DIR / "app" / "training"
TEST_DIR    = BASE_DIR / "datasets" / "Plant Village Dataset" / "test"
ASSETS_DIR  = BASE_DIR / "app" / "assets" / "models"
PTH_PATH    = TRAIN_DIR / "best_model.pth"
TFLITE_PATH = TRAIN_DIR / "model.tflite"
LABELS_PATH = TRAIN_DIR / "labels.txt"
OUT_REPORT  = TRAIN_DIR / "tflite_validation_report.json"

def get_tflite_interpreter(tflite_path):
    try:
        from ai_edge_litert.interpreter import Interpreter
        interp = Interpreter(model_path=str(tflite_path))
    except Exception:
        import tensorflow as tf
        interp = tf.lite.Interpreter(model_path=str(tflite_path))
    interp.allocate_tensors()
    return interp

def main():
    print(f"Validating TFLite model: {TFLITE_PATH}")
    assert PTH_PATH.exists(), f"{PTH_PATH} not found"
    assert TFLITE_PATH.exists(), f"{TFLITE_PATH} not found"

    # PyTorch Model
    with open(LABELS_PATH, "r", encoding="utf-8") as f:
        class_names = [line.strip() for line in f if line.strip()]
    num_classes = len(class_names)

    py_model = models.mobilenet_v2(weights=None)
    py_model.classifier[1] = nn.Linear(py_model.classifier[1].in_features, num_classes)
    py_model.load_state_dict(torch.load(PTH_PATH, map_location="cpu"))
    py_model.eval()

    # TFLite Interpreter
    interp = get_tflite_interpreter(TFLITE_PATH)
    in_details = interp.get_input_details()
    out_details = interp.get_output_details()
    in_shape = in_details[0]["shape"] # [1, 224, 224, 3] or [1, 3, 224, 224]
    print(f"TFLite input tensor shape: {in_shape}, dtype: {in_details[0]['dtype']}")
    print(f"TFLite output tensor shape: {out_details[0]['shape']}, dtype: {out_details[0]['dtype']}")

    # Collect test images
    img_paths = list(TEST_DIR.rglob("*.JPG")) + list(TEST_DIR.rglob("*.jpg")) + list(TEST_DIR.rglob("*.png"))
    print(f"Total test images found: {len(img_paths)}")

    # Sample up to 300 test images for validation parity check
    sample_paths = img_paths[:300] if len(img_paths) > 300 else img_paths

    py_tf = transforms.Compose([
        transforms.Resize((224, 224)),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225]),
    ])

    matches = 0
    total = 0
    max_abs_diff = 0.0
    latencies = []

    for img_p in sample_paths:
        try:
            img = Image.open(img_p).convert("RGB")
        except Exception:
            continue

        # PyTorch forward
        tensor = py_tf(img).unsqueeze(0) # [1, 3, 224, 224]
        with torch.no_grad():
            py_logits = py_model(tensor).squeeze(0).numpy()
            py_probs = np.exp(py_logits) / np.sum(np.exp(py_logits))
            py_pred = int(np.argmax(py_probs))

        # TFLite forward
        # Determine whether input is NCHW or NHWC
        if in_shape[1] == 3: # NCHW
            tflite_in = tensor.numpy().astype(np.float32)
        else: # NHWC
            # Rearrange NCHW -> NHWC
            tflite_in = tensor.permute(0, 2, 3, 1).numpy().astype(np.float32)

        # Resize interpreter if needed
        interp.set_tensor(in_details[0]["index"], tflite_in)
        t0 = time.perf_counter()
        interp.invoke()
        t1 = time.perf_counter()
        latencies.append((t1 - t0) * 1000) # ms

        tf_logits = interp.get_tensor(out_details[0]["index"]).squeeze()
        tf_probs = np.exp(tf_logits) / np.sum(np.exp(tf_logits))
        tf_pred = int(np.argmax(tf_probs))

        if py_pred == tf_pred:
            matches += 1
        diff = float(np.max(np.abs(py_probs - tf_probs)))
        if diff > max_abs_diff:
            max_abs_diff = diff
        total += 1

    parity = matches / total if total > 0 else 0
    avg_latency = float(np.mean(latencies)) if latencies else 0

    print(f"Validation finished: {matches}/{total} matches ({parity*100:.2f}%)")
    print(f"Max absolute probability diff: {max_abs_diff:.6f}")
    print(f"Average TFLite CPU inference latency: {avg_latency:.2f} ms")

    report = {
        "status": "PASS" if parity >= 0.95 else "WARN",
        "total_validated_samples": total,
        "parity_with_pytorch": parity,
        "max_prob_diff": max_abs_diff,
        "avg_latency_ms": avg_latency,
        "tflite_file_size_mb": TFLITE_PATH.stat().st_size / 1024 / 1024,
        "input_shape": in_shape.tolist(),
        "input_dtype": str(in_details[0]["dtype"]),
        "num_classes": num_classes
    }

    with open(OUT_REPORT, "w", encoding="utf-8") as f:
        json.dump(report, f, indent=2)
    print(f"Report saved to: {OUT_REPORT}")

    # Copy to Flutter assets
    ASSETS_DIR.mkdir(parents=True, exist_ok=True)
    dst_tflite = ASSETS_DIR / "model.tflite"
    dst_labels = ASSETS_DIR / "labels.txt"
    shutil.copy(str(TFLITE_PATH), str(dst_tflite))
    shutil.copy(str(LABELS_PATH), str(dst_labels))
    print(f"Deployed model to Flutter assets: {dst_tflite} ({dst_tflite.stat().st_size / 1024 / 1024:.2f} MB)")
    print(f"Deployed labels to Flutter assets: {dst_labels}")

if __name__ == "__main__":
    main()
