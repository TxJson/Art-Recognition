import os
import lib.files as f
import dependencies.yolov5.train as yolov5

def get_dataset_yamls(module):
    return f.getFiles(rf"modules/{module}/datasets", exactKey=[".yaml"])

# https://github.com/ultralytics/yolov5/wiki/Train-Custom-Data
def train(module, moduleConfig):
    # yolov5.train()
    data = f.getJson(moduleConfig)
    datasets = " ".join(get_dataset_yamls(module))

    settings = data.get("settings")
    weights = settings.get("model")
    random = settings.get("random")
    img = settings.get("imgsize")
    epochs = settings.get("epochs")
    batch = settings.get("batch")

    syscall = rf"python ./dependencies/yolov5/train.py --img {img} --batch {batch} --epochs {epochs} --data {datasets} --weights {weights}"
    print(syscall)
    os.system(syscall)
    # yolov5.train(datasets[0], opt={ weights, batch, epochs, img })

    