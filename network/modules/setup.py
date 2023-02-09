import json, requests, sys, getopt
from filelink import *
from zipfile import ZipFile

DATASETS = "datasets"
MODULES = "modules"

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

    

def getJson(path):
    jsonData = getFileContents(path)
    return json.loads(jsonData)   

def get_datasets(regen=False):
    createPathIfNotExists(DATASETS)
    sets = getJson(rf"./{DATASETS}.json")
    for attribute, value in sets.items():    
        download_dataset(value["path"], value["zip"], dir=DATASETS, name=attribute, regen=regen)

def create_modules():
    print("Generating Modules")
    createPathIfNotExists(MODULES)
    modules = getJson(rf"./{MODULES}.json")

    for attribute, value in modules.items():
        print(rf"Generating module {attribute}")
        path = rf"{MODULES}/{attribute}"
        createPathIfNotExists(path)

        moduleStruct = rf"{path}/moduleStructure.json"
        writeToFile(moduleStruct, content=json.dumps(value), newFile=True)        


def cli(args):
    arg = args[0]
    if arg == '-r': # Regenerate datasets
        get_datasets(True)
    else:
        get_datasets(False)

    create_modules()

cli(sys.argv[1:])