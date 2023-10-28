#!/bin/bash'

SRCDIR="src"

SCRIPT_PATH="${BASH_SOURCE:-$0}"
ABS_SCRIPT_PATH="$(realpath "${SCRIPT_PATH}")"
BASEDIR="$(dirname "${ABS_SCRIPT_PATH}")"

CURRENT_OS="$OSTYPE"
ALLOWED_OS=("msys")

min="3.7.0" # Minimum python version

install_dependencies()
{
    echo "Installing Dependencies: PYTHON"
    pip3 install -r $BASEDIR/requirements.txt --no-warn-script-location

    echo "Installing Dependencies: ML"
    cd ml && sh setup.sh -s
}

clean()
{
    # Clean ML Directory
    cd ml && sh setup.sh -c
}

check_os() 
{
    if [[ " ${ALLOWED_OS[*]} " =~ " ${CURRENT_OS} " ]]; then
        return 1
    fi

    return 0
}

setup_venv()
{
    enter_venv()
    {
        if [[ "$VIRTUAL_ENV" != "" ]]
        then
            echo "Already in venv"
        else
            echo "Entering venv"
            source $1
        fi
    }

    echo "Current OS: ${CURRENT_OS}"
    if [[ "$CURRENT_OS" -eq "msys" ]]
    then
        enter_venv "venv/Scripts/activate"
    fi
}

setup()
{
    setup_venv

    version=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
    parsedVersion=$(echo "${version//./}")
    minParsed=$(echo "${min//./}")

    if [[ "$parsedVersion" -gt minParsed || "$parsedVersion" -eq minParsed ]]
    then 
        install_dependencies
    else
        echo "Invalid Python version"
        echo "Received Version: $version"
        echo "Expected minimum Version: $min"
    fi
}

if [[ "$0" = "$BASH_SOURCE" ]] 
then
    echo "Needs to be executed using 'source setup.py'"
    exit
fi

# If we are using an unsupported OS, exit
if check_os 0
then
    echo "OS ${CURRENT_OS} is not allowed. This is only compatible with ${ALLOWED_OS}"
    return
fi

cleanParam="c"
setupParam="s"

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
            -*) echo "bad option $1"
                ;;
        esac
        shift
    done
fi