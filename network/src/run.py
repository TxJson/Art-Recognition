import sys
import lib.files as files

from train import train
from setup import setup

REQUIREMENTS=["./datasets", "./modules"]
MODULE_CONFIG = rf"settings/modules.json"

# This is a very easy cli, might need to write a better one at some point...
def cli(args):
    arg = ''
    if args:
        arg = args[0]

    if arg == '-s': # If s is passed, assume we only want to run setup
        setup()
    elif arg == '-sr' or arg == '-rs':
        setup('-r')
    else:
        run()

def run():    
    if not (files.pathsExist(REQUIREMENTS)):
        print('Missing requirements...')
        setup()

    train("art_detection", "./modules/art_detection/module.json")

cli(sys.argv[1:])
