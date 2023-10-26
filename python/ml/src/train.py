import lib.files as f
import subprocess
import os

import exports as exp

def get_dataset_yamls(module):
    return f.getFiles(rf"modules/{module}/datasets", exactKey=[".yaml"])

def start_subprocess(*args):
    syscall = " ".join(args)
    print(syscall) # Print syscall to show that it is being called in the log
    subprocess.run(syscall, shell=True)

def train(module, moduleConfig, export=False):
    # yolov5.train()
    # settings = f.getJson("./settings/settings.json")
    # exports_path = settings.get("exports_path")


    data = f.getJson(moduleConfig)
    settings = f.getJson("./settings/settings.json")
    module_settings = data.get("settings")
    training_settings = module_settings.get("training")
    datasets = data.get("datasets")
    accepted_frameworks = settings.get("accepted_frameworks")
    args = []

    if not training_settings:
        print("Training settings missing")
        return

    for arg in training_settings:
        args.append(rf"--{arg} {training_settings.get(arg)}")

    if datasets:
        # Only allow one dataset... for now
        del datasets[1:]

        dataset_args = []
        for dataset in datasets:
            dataset_args.append(rf"modules/{module}/datasets/{dataset}.yaml")
        if dataset_args:
            dataset_args_str = " ".join(dataset_args)
            arg = rf"--data {dataset_args_str}"
            args.append(arg)

    framework = data.get("framework")

    dependency_path = rf"./dependencies/{framework}/train.py"
    if accepted_frameworks:
        if f.pathExists(dependency_path) and framework in accepted_frameworks:
            start_subprocess("py", rf"{dependency_path}", " ".join(args), rf"--name {module}")
            if export:
                exp.convert_tflite(rf"./dependencies/{framework}/runs/train", module, "./output")
    else:
        print("Unable to initialize accepted frameworks")

    