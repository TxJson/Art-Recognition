# File adapted and extended from https://github.com/TxJson/Converter

import os
from termcolor import colored
from datetime import datetime

# Libraries
import files as fb

logDir = f'{os.getcwd()}/log'

filePath = f'{logDir}/{datetime.now():%Y%m%d-%H%M%S%z}.log'

class headers():
    DEFAULT = ''
    INFO = '[Info]'
    ERROR = '[Error]'
    WARNING = '[Warning]'
    TRACE = '[Trace]'

def log(msg, hType, color, default = 'Something went wrong'):
    message = msg if msg != None else default
    print(composeMsg(message, color, hType))
    fb.writeToFile(logDir, f"{hType} {message}")
    

def composeMsg(msg, color = 'white', hType = headers.DEFAULT):
    return colored(f"{hType} {msg}", color)

def warning(msg = None):
    log(msg, headers.WARNING, 'yellow')

def error(msg = None):
    log(msg, headers.ERROR, 'red')

def info(msg = None):
    log(msg, headers.INFO, 'white')

def trace(msg = None):
    log(msg, headers.TRACE, 'blue')