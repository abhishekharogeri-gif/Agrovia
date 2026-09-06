"""Export best_model.pth to ONNX format."""
import torch
import torch.nn as nn
from torchvision import models
from pathlib import Path

OUTPUT_DIR = Path(r"E:\Agrovia V 0.1\app\training")
MODEL_PATH = OUTPUT_DIR / "best_model.pth"
ONNX_PATH  = OUTPUT_DIR / "model.onnx"

def main():
    print(f"Loading checkpoint from: {MODEL_PATH}")
    model = models.mobilenet_v2(weights=None)
    model.classifier[1] = nn.Linear(model.classifier[1].in_features, 29)
    model.load_state_dict(torch.load(MODEL_PATH, map_location="cpu"))
    model.eval()

    dummy_input = torch.randn(1, 3, 224, 224)
    print(f"Exporting to ONNX at: {ONNX_PATH}")
    torch.onnx.export(
        model,
        dummy_input,
        str(ONNX_PATH),
        export_params=True,
        opset_version=13,
        do_constant_folding=True,
        input_names=["input"],
        output_names=["output"],
        dynamic_axes={"input": {0: "batch_size"}, "output": {0: "batch_size"}},
    )
    print("ONNX export succeeded!")

if __name__ == "__main__":
    main()
