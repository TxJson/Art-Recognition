from lib.files import getFiles

files = getFiles('./datasets', directories=['train'])
print(files)