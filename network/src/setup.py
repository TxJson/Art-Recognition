import json, requests
from zipfile import ZipFile
import ruamel.yaml
import lib.files as f

DATASETS = "datasets"
DATASET_CONFIG = rf"settings/{DATASETS}.json"

MODULES = "modules"
MODULE_CONFIG = rf"settings/{MODULES}.json"

DEPENDENCIES = "dependencies"

def extract_dataset(zipfile, zipname, dirpath, remove=True):
    if f.pathExists(zipfile):
        print(rf"Extracting {zipname}.zip")
        f.createPathIfNotExists(dirpath)
        print(zipfile, zipname, dirpath)
        with ZipFile(zipfile, "r") as zobj:
            zobj.extractall(path=dirpath)
        
        # Once unzipped, remove zipfile
        if remove:
            print(rf"Removing {zipname}.zip")
            f.removeFile(zipfile)
    else:
        print(rf"Tried extracting a file that does not exist: {zipname}.zip")



def download_dataset(url, zipname, dir, name, extract=True, regen=False):
    dirpath = rf"{dir}/{name}"
    if not f.pathExists(dirpath):
        zipfile = rf"{dir}/{zipname}.zip"

        if regen and f.pathExists(zipfile):
            f.removeFile(zipfile)

        if not f.pathExists(zipfile):
            print(rf"Downloading dataset {name}...")    
            data = requests.get(url)
            with open(zipfile, "wb") as file:
                file.write(data.content)
                file.close()
        
        if extract:
            extract_dataset(zipfile, zipname, dirpath)
        else:
            print(rf"Extraction of {zipname}.zip averted")
    else:
        print(rf"Directory for dataset {name} already exists, skipping download.") 

def get_datasets(regen=False):
    f.createPathIfNotExists(DATASETS)
    sets = f.getJson(DATASET_CONFIG)
    for attribute, value in sets.items():    
        download_dataset(value["path"], value["zip"], dir=DATASETS, name=attribute, regen=regen)

# TODO: Make adaptable to more than just YOLOv5
# Adapted from: https://stackoverflow.com/questions/29518833/editing-yaml-file-by-python
def create_dataset_yaml(path, framework, datasets, dataset_config):
    f.createPathIfNotExists(rf"{path}/datasets")
    yaml = ruamel.yaml.YAML()
    yaml.preserve_quotes = True

    names = [];
    for dataset in datasets:
        defaultDatasetPath = rf"{DATASETS}/{dataset}"
        yamlFile = dataset_config.get(rf"{dataset}").get("datafile")
        with open(rf"{defaultDatasetPath}/{yamlFile}") as fp:
            data = yaml.load(fp)
        
        trainPath = f.getPathBetween(rf"{DATASETS}/{dataset}/train/images", rf"{DEPENDENCIES}/{framework}")
        if not data["train"] == trainPath:
            data["train"] = trainPath
        
        validPath = f.getPathBetween(rf"{DATASETS}/{dataset}/valid/images", rf"{DEPENDENCIES}/{framework}")
        if not data["val"] == validPath:
            data["val"] = validPath
        
        _names = data['names']
        if _names:
            names.extend(_names)

        newDatafile = rf"{path}/datasets/{dataset}.yaml"
        f.writeToFile(newDatafile, content="", newFile=True) # Create empty file
        with open(newDatafile, "w") as _file:
            yaml.dump(data, _file)

    f.writeToFile(rf"{path}/labels.txt", "\n".join(names), True)



def create_modules():
    print("Generating Modules")
    f.createPathIfNotExists(MODULES)
    module_config = f.getJson(MODULE_CONFIG)
    dataset_config = f.getJson(DATASET_CONFIG)

    for attribute, value in module_config.items():
        print(rf"Generating module {attribute}")
        path = rf"{MODULES}/{attribute}"
        f.createPathIfNotExists(path)

        moduleStruct = rf"{path}/module.json"
        f.writeToFile(moduleStruct, content=json.dumps(value), newFile=True)   
        create_dataset_yaml(path, value.get("framework"), value.get("datasets"), dataset_config)

def setup():
    get_datasets()
    create_modules()

def force_setup():
    get_datasets(True)
    create_modules()