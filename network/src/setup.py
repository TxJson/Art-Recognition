import json, requests, sys
from zipfile import ZipFile
import ruamel.yaml
from lib.files import *

DATASETS = "datasets"
DATASET_CONFIG = rf"settings/{DATASETS}.json"

MODULES = "modules"
MODULE_CONFIG = rf"settings/{MODULES}.json"

DEPENDENCIES = "dependencies"

def download_dataset(url, zipname, dir, name, extract=True, regen=False):
    dirpath = rf"{dir}/{name}"
    if not pathExists(dirpath):
        zipfile = rf"{dir}/{zipname}.zip"

        if regen and pathExists(zipfile):
            removeFile(zipfile)

        if not pathExists(zipfile):
            print(rf"Downloading dataset {name}...")    
            data = requests.get(url)
            with open(zipfile, "wb") as file:
                file.write(data.content)
                file.close()
        
        if extract:
            if pathExists(zipfile):
                print(rf"Extracting {zipname}.zip")
                createPathIfNotExists(dirpath)
                with ZipFile(zipfile, "r") as zobj:
                    zobj.extractall(path=dirpath)
                
                # Once unzipped, remove zipfile
                print(rf"Removing {zipname}.zip")
                removeFile(zipfile)
            else:
                print(rf"Tried extracting a file that does not exist: {zipname}.zip")
        else:
            print(rf"Extraction of {zipname}.zip averted")
    else:
        print(rf"Directory for dataset {name} already exists, skipping download.") 

def get_datasets(regen=False):
    createPathIfNotExists(DATASETS)
    sets = getJson(DATASET_CONFIG)
    for attribute, value in sets.items():    
        download_dataset(value["path"], value["zip"], dir=DATASETS, name=attribute, regen=regen)

# Adapted from: https://stackoverflow.com/questions/29518833/editing-yaml-file-by-python
def create_dataset_yaml(path, framework, datasets, dataset_config):
    createPathIfNotExists(rf"{path}/datasets")
    yaml = ruamel.yaml.YAML()
    yaml.preserve_quotes = True

    for dataset in datasets:
        defaultDatasetPath = rf"{DATASETS}/{dataset}"
        yamlFile = dataset_config.get(rf"{dataset}").get("datafile")
        with open(rf"{defaultDatasetPath}/{yamlFile}") as fp:
            data = yaml.load(fp)
        
        trainPath = getPathBetween(rf"{DATASETS}/{dataset}/train/images", rf"{DEPENDENCIES}/{framework}")
        if not data["train"] == trainPath:
            data["train"] = trainPath
        
        validPath = getPathBetween(rf"{DATASETS}/{dataset}/valid/images", rf"{DEPENDENCIES}/{framework}")
        if not data["val"] == validPath:
            data["val"] = validPath
        
        newDatafile = rf"{path}/datasets/{dataset}.yaml"
        writeToFile(newDatafile, content="", newFile=True) # Create empty file
        with open(newDatafile, "w") as f:
            yaml.dump(data, f)



def create_modules():
    print("Generating Modules")
    createPathIfNotExists(MODULES)
    module_config = getJson(MODULE_CONFIG)
    dataset_config = getJson(DATASET_CONFIG)

    for attribute, value in module_config.items():
        print(rf"Generating module {attribute}")
        path = rf"{MODULES}/{attribute}"
        createPathIfNotExists(path)

        moduleStruct = rf"{path}/module.json"
        writeToFile(moduleStruct, content=json.dumps(value), newFile=True)   
        create_dataset_yaml(path, value.get("framework"), value.get("datasets"), dataset_config)


def cli(args):
    arg = ''
    if args:
        arg = args[0]

    if arg == '-r': # Regenerate datasets
        get_datasets(True)
    else:
        get_datasets(False)

    create_modules()

def setup(args = []):
    cli(args)