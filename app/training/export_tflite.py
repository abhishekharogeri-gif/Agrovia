"""Convert ONNX to TFLite via onnx2tf."""
import os
import shutil
from pathlib import Path
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

OUTPUT_DIR  = Path(r"E:\Agrovia V 0.1\app\training")
ONNX_PATH   = OUTPUT_DIR / "model.onnx"
TF_DIR      = OUTPUT_DIR / "tf_model"
TFLITE_PATH = OUTPUT_DIR / "model.tflite"

def main():
    if TF_DIR.exists():
        shutil.rmtree(TF_DIR)
    print("Converting ONNX -> Keras SavedModel + TFLite via onnx2tf")
    from onnx2tf import convert
    model = convert(
        input_onnx_file_path=str(ONNX_PATH),
        output_folder_path=str(TF_DIR),
        copy_onnx_input_output_names_to_tflite=True,
        not_use_onnxsim=True,
        non_verbose=True,
    )

    # Find the tflite file onnx2tf wrote next to the saved_model
    candidates = list(TF_DIR.rglob("*.tflite"))
    if candidates:
        shutil.copy(str(candidates[0]), str(TFLITE_PATH))
        print(f"TFLite copied to: {TFLITE_PATH}")
    else:
        print("No .tflite found — attempting TFLiteConverter from Keras model")
        import tensorflow as tf
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.optimizations = [tf.lite.Optimize.DEFAULT]
        tflite_content = converter.convert()
        TFLITE_PATH.write_bytes(tflite_content)
        print(f"TFLite converted directly: {TFLITE_PATH}")

    print(f"Size MB: {TFLITE_PATH.stat().st_size / 1024 / 1024:.2f}")

if __name__ == "__main__":
    main()
