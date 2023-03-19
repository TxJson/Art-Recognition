import lib.files as f
import argparse
import torch

from train import train
from setup import setup, force_setup

REQUIREMENTS=["./datasets", "./modules"]
MODULE_CONFIG = rf"settings/modules.json"

def run(module="", export=False):    
    train(module, rf"./modules/{module}/module.json", export)


def run_setup(force=False):
    if force:
        return force_setup()
    return setup()

def gpu_recognition():
    torch.cuda.is_available()
    torch.cuda.get_device_properties(0).name

def set_parser():
    parser = argparse.ArgumentParser(description='CLI')
    modules = list(f.getJson('./settings/modules.json').keys())

    # GPU Arguments
    parser.add_argument("--gpu", help="GPU CUDA Check when training", dest="gpu_check", action="store_true")

    # Setup Arguments
    parser.add_argument("-s", "--setup", help="Run setup", dest="run_setup", action="store_true")
    parser.add_argument("-sr", "--setupr", help="Force run setup", dest="force_run_setup", action="store_true")

    # Execute Arguments
    parser.add_argument("-m", "--module",
                    nargs="?",
                    choices=modules,
                    dest="module",
                    help=rf"Select your dataset from the list of {', '.join(modules)}")
    # Export Argument
    parser.add_argument("-e", "--export", help="Export model", dest="export", action="store_true")

    
    return parser

def cli(parser):
    if parser:
        results = parser().parse_args()
        
        if results.run_setup or results.force_run_setup:
            print("\nRunning Setup")
            run_setup(results.force_run_setup)
            print("\nSetup Finished")
            return

        if results.module != None:
            if results.gpu_check:
                gpu_recognition()
            run(results.module, results.export)
            return

        if results.gpu_check:
            gpu_recognition()
            return
        
        print("No parameters passed. Do 'python run.py -h' to see options available.")
    else:
        print("Parser not defined")

parser = set_parser  
cli(parser)