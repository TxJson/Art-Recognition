#!/bin/bash

install_windows() 
{
    mkdir flutter_installation; cd flutter_installation
    curl -L "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.7.1-stable.zip" > flutter_installation.zip; unzip flutter_installation.zip; rm flutter_installation.zip
    cd ..
    rm -fr flutter_installation
}

# install_linux()
# {}

# install_darwin()
# {}

install_dependencies()
{
    echo "Installing Dependencies"

    # Windows
    if [[ "$OSTYPE" =~ ^msys ]]; then
        install_windows
    fi

    # # Linux
    # if [[ "$OSTYPE" =~ ^linux ]]; then
    #     install_linux
    # fi

    # # MacOS
    # if [[ "$OSTYPE" =~ ^darwin ]]; then
    #     install_darwin
    # fi

    echo "Installation Complete"
}

# cleanParam="c"
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
            #-$cleanParam) clean
            #    ;;
            -$setupParam) install_dependencies
                ;;
            -*) echo "bad option $1"
                ;;
        esac
        shift
    done
fi
