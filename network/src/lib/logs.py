# File adapted and extended from https://github.com/TxJson/Converter

import os
from termcolor import colored
from datetime import datetime

# Libraries
import lib.files as fb

logDir = f'{os.getcwd()}/log'

filePath = f'{logDir}/{datetime.now():%Y%m%d-%H%M%S%z}.log'

class headers():
    DEFAULT = ''
    INFO = '[INFO]'
    ERROR = '[ERROR]'
    WARNING = '[WARNING]'
    TRACE = '[TRACE]'

def log(msg, headerType, color = 'white', default = 'Something went wrong'):
    message = msg if msg != None else default
    print(composeMsg(message, color, headerType))
    # fb.writeToFile(logDir, f"{headerType} {message}")
    

def composeMsg(msg, color = 'white', headerType = headers.DEFAULT):
    return colored(f"[{datetime.now()}] {headerType} {msg}", color)

def warning(msg = None):
    log(msg, headerType=headers.WARNING, color='yellow')

def error(msg = None):
    log(msg, headerType=headers.ERROR, color='red')

def info(msg = None):
    log(msg, headerType=headers.INFO, color='white')

def trace(msg = None):
    log(msg, headerType=headers.TRACE, color='blue')