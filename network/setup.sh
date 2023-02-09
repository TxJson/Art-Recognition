#!/bin/bash

install_dependencies()
{
    echo "Installing Dependencies"

    pip3 install -r dependencies.txt --user --no-warn-script-location

    # Install YOLOv5
    git clone https://github.com/ultralytics/yolov5  # Clone
    cd yolov5
    pip3 install -r requirements.txt --user --no-warn-script-location # Install
    cd ..
    rm -fr yolov5

    echo "Installation Complete"
}

setup_modules()
{   
    cd modules
    py setup.py
    
    cd ..
}

setupForce()
{
    if [[ "$parsedVersion" -gt minParsed ]]
    then 
        install_dependencies
        clean
        setup_modules        
    else
        echo "Invalid Python version"
        echo "Expected minimum $min"
    fi
}

setup()
{
    if [[ "$parsedVersion" -gt minParsed ]]
    then 
        install_dependencies
        setup_modules        
    else
        echo "Invalid Python version"
        echo "Expected minimum $min"
    fi
}

clean()
{
    cd modules

    # Remove datasets
    echo "Removing Datasets"
    rm -fr datasets

    echo "Removing Modules"
    rm -fr modules

    cd ..
}

version=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
min="3.7.0" # Minimum python version

parsedVersion=$(echo "${version//./}")
minParsed=$(echo "${min//./}")

cleanParam="c"
setupParam="s"
forceParam="fs"

if [ "$#" -eq  "0" ]
then
    echo "No arguments supplied"
else
    arg="$1"
    # idiomatic parameter and option handling in sh
    while test $# -gt 0
    do
        case $arg in
            -$cleanParam) clean
                ;;
            -$setupParam) setup
                ;;
            -$forceParam) setupForce
                ;;
            -*) echo "bad option $1"
                ;;
        esac
        shift
    done
fi