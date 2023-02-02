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

download_datasets()
{
    echo "Downloading Datasets"

    [ -d "/datasets" ] && rm -fr datasets
    mkdir datasets
    cd datasets

    # Download Roboflow Dataset
    # https://universe.roboflow.com/raya-al/french-paintings-raya/dataset/2#
    mkdir roboflow
    cd roboflow
    curl -L "https://universe.roboflow.com/ds/kSrrrhVV5h?key=twBHoIOrE4" > roboflow.zip; unzip roboflow.zip; rm roboflow.zip

    cd ..
    echo "Download Complete"
}

setup()
{
    if [[ "$parsedVersion" -gt minParsed ]]
    then 
        install_dependencies
        # download_datasets        
    else
        echo "Invalid Python version"
        echo "Expected minimum $min"
    fi
}

clean()
{
    # Remove datasets
    echo "Removing Datasets"
    rm -fr datasets
}

version=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
min="3.7.0" # Minimum python version

parsedVersion=$(echo "${version//./}")
minParsed=$(echo "${min//./}")

cleanParam="c"
setupParam="s"
datasetsParam="d"

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
            -$datasetsParam) download_datasets
                ;;
            -*) echo "bad option $1"
                ;;
        esac
        shift
    done
fi