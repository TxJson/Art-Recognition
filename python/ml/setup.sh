#!/bin/bash'

SRCDIR="src"
DEPDIR="$SRCDIR/dependencies"

SCRIPT_PATH="${BASH_SOURCE:-$0}"
ABS_SCRIPT_PATH="$(realpath "${SCRIPT_PATH}")"
BASEDIR="$(dirname "${ABS_SCRIPT_PATH}")"

version=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
min="3.7.0" # Minimum python version

parsedVersion=$(echo "${version//./}")
minParsed=$(echo "${min//./}")

install_dependencies()
{
    echo "Installing Dependencies"

    echo "Installing local dependencies"
    pip3 install -r $BASEDIR/requirements.txt --no-warn-script-location

    # Download and install datasets
    # Install YOLOv5
    echo "Installing YOLOv5"
    if [[ ! -d "$DEPDIR/yolov5" ]]; then
        cd $DEPDIR

        echo "Dependency Missing: YOLOv5 - Installing" 
        git clone https://github.com/ultralytics/yolov5 yolov5 # Clone

        cd $BASEDIR
    fi

    if [[ -d "$DEPDIR/yolov5" ]]; then        
        cd $DEPDIR/yolov5
        pip3 install -r requirements.txt --no-warn-script-location # Install pip dependencies
        cd $BASEDIR
    else
        echo "Unable to locate $DEPDIR/yolov5, skipping dependency installation step"
    fi

    cd $BASEDIR
    echo "Dependency Installation Complete"
}

setup_dependencies()
{
    mkdir -p $DEPDIR

    if [[ -d "$DEPDIR" ]]; then    
        install_dependencies

        cd $BASEDIR
    else
        echo "Unable to locate $DEPDIR, skipping dependency installation step"
    fi
}

setup_modules()
{   
    # Need to run from correct dir to ensure that generated files are in correct place
    cd $SRCDIR

    py run.py -sr

    cd $BASEDIR
}

setupForce()
{
    if [[ "$parsedVersion" -gt minParsed || "$parsedVersion" -eq minParsed ]]
    then 
        clean
        setup_dependencies
        setup_modules        
    else
        echo "Invalid Python version"
        echo "Expected minimum $min, found $parsedVersion"
    fi
}

setup()
{
    if [[ "$parsedVersion" -gt minParsed || "$parsedVersion" -eq minParsed ]]
    then 
        setup_dependencies
        setup_modules        
    else
        echo "Invalid Python version"
        echo "Expected minimum $min"
    fi
}

removeifexists()
{
    dir=$1
    args=${*:2}

    if [[ -d "$dir" ]]; then
        cd $dir

        echo "Removing files [$args] in $dir"
        for var in $args
        do
            rm -fr $var
        done

        cd $BASEDIR
    else
        echo "Unable to locate $dir, skipping this step"
    fi
}

clean()
{
    # Remove generated modules and datasets
    removeifexists $SRCDIR "datasets" "modules" "dependencies"
}

if [[ "$VIRTUAL_ENV" -eq "" ]]
then
    echo "Not in venv, cannot proceed with ML installation"
    exit
fi

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