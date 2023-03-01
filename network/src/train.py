import lib.files as f
import subprocess

import exports as exp

def get_dataset_yamls(module):
    return f.getFiles(rf"modules/{module}/datasets", exactKey=[".yaml"])

def start_subprocess(*args):
    syscall = " ".join(args)
    print(syscall) # Print syscall to show that it is being called in the log
    # subprocess.run(syscall)

# https://github.com/ultralytics/yolov5/wiki/Train-Custom-Data
def train(module, moduleConfig):
    # yolov5.train()
    data = f.getJson(moduleConfig)
    settings = f.getJson("./settings/settings.json")
    accepted_frameworks = settings.get("accepted_frameworks")
    exports_path = settings.get("exports_path")

    module_settings = data.get("settings")
    training_settings = module_settings.get("training")
    export_settings = module_settings.get("export")
    args = ""

    if not training_settings:
        print("Training settings missing")
        return

    for arg in training_settings:
        args += rf" --{arg} {training_settings.get(arg)}"

    framework = data.get("framework")

    dependency_path = rf"./dependencies/{framework}/train.py"
    if accepted_frameworks:
        if f.pathExists(dependency_path) and framework in accepted_frameworks:
            start_subprocess("python", dependency_path, args, rf"--name {module}")
            exp.convert_tflite("./dependencies/yolov5/runs/train/results/weights", module, "./hello")

    else:
        print("Unable to initialize accepted frameworks")

    