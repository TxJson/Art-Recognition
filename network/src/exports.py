import tensorflow as tf
import lib.files as f

def convert_tflite(model_dir, model_name, export_path):
    converter = tf.lite.TFLiteConverter.from_saved_model(model_dir)
    tflite_model = converter.convert

    f.createPathIfNotExists(export_path)

    if f.pathExists(export_path):
        file_count = len(f.getFiles(export_path, exactKey=[model_name]))
        version = rf"_{file_count}" if file_count > 0 else ""
        new_file = rf"{model_name}{version}"

        f.createPathIfNotExists(rf"{export_path}/{new_file}/")
        f.writeToFile(rf"{export_path}/{new_file}/{new_file}", content=tflite_model, newFile=True)