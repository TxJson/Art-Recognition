# File adapted and extended from https://github.com/TxJson/Converter

from pathlib import Path
import os

def getPath(*args):
    str = ''
    for arg in args:
        str += arg
    return str

def createPathsIfNotExist(*args):
    for arg in args:
        createPathIfNotExists(arg)

def pathExists(path):
    return os.path.exists(path)

def createPathIfNotExists(path):
    Path(path).mkdir(parents=True, exist_ok=True)

def writeToFile(path, content = None, newFile=False):
    mode = "w"
    if newFile:
        mode += "x"
    if content != None:
        file = open(path, 'w')
        file.write(content)
        file.close()

def getFileContents(path):
    if pathExists(path):
        openFile = open(path, "r")
        data = openFile.read()
        openFile.close()
        return data
    
    # If path doesn't exist, raise exception
    raise Exception(rf"Tried retrieving file from path that does not exist: {path}")

def removeFile(path):
    os.remove(path)

# This is a very inefficient way of getting the files but... it works...
def getFiles(path, directories=[], exactKey=[]):
    files = []

    def getFilesByExtension(fileNames, exactKey, path):
        files = []
        for f in fileNames:
            if exactKey:
                if any([x in f for x in exactKey]):
                    files.append(rf"{Path(rf'{Path(path)}/{f}')}")
        return files

    for (path, dirNames, fileNames) in os.walk(path):
        if not directories and not exactKey:
            for f in fileNames:
                files.append(rf"{Path(rf'{Path(path)}/{f}')}")
            continue
        
        # If directories is bigger than 0 and path contains string
        if directories and all([x in path for x in directories]):
            if exactKey:
                files.extend(getFilesByExtension(fileNames, exactKey, path))

                # for ext in exactKey:
                #     print(ext)
                    # for file in fnmatch.filter(fileNames, ext):
            else:
                for f in fileNames:
                    files.append(rf"{Path(rf'{Path(path)}/{f}')}")
        elif exactKey:
            files.extend(getFilesByExtension(fileNames, exactKey, path))
    
    return files