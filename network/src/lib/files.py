# File adapted and extended from https://github.com/TxJson/Converter

from pathlib import Path
from os import walk

def getPath(*args):
    str = ''
    for arg in args:
        str += arg
    return str

def createPathsIfNotExist(*args):
    for arg in args:
        createIfNotExists(arg)

def createIfNotExists(path):
    Path(path).mkdir(parents=True, exist_ok=True)

def writeToFile(path, txt = None):
    createIfNotExists(path)
    if txt != None:
        file = open(path, 'w')
        file.write(txt)
        file.close()

# This is a very inefficient way of getting the files but... it works...
def getFiles(path, directories=[], extensions=[]):
    files = []

    def getFilesByExtension(fileNames, extensions, path):
        files = []
        for f in fileNames:
            if extensions:
                if any([x in f for x in extensions]):
                    files.append(rf"{Path(rf'{Path(path)}/{f}')}")
        return files

    for (path, dirNames, fileNames) in walk(path):
        if not directories and not extensions:
            for f in fileNames:
                files.append(rf"{Path(rf'{Path(path)}/{f}')}")
            continue
        
        # If directories is bigger than 0 and path contains string
        if directories and all([x in path for x in directories]):
            if extensions:
                files.extend(getFilesByExtension(fileNames, extensions, path))

                # for ext in extensions:
                #     print(ext)
                    # for file in fnmatch.filter(fileNames, ext):
            else:
                for f in fileNames:
                    files.append(rf"{Path(rf'{Path(path)}/{f}')}")
        elif extensions:
            files.extend(getFilesByExtension(fileNames, extensions, path))
    
    return files