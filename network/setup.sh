install_dependencies()
{
    pip3 install -r dependencies.txt --user --no-warn-script-location

    # Install YOLOv5
    git clone https://github.com/ultralytics/yolov5  # Clone
    cd yolov5
    pip3 install -r requirements.txt --user --no-warn-script-location # Install
    cd ..
    rm -fr yolov5
}


version=$(python -V 2>&1 | grep -Po '(?<=Python )(.+)')
min="3.7.0"

parsedVersion=$(echo "${version//./}")
minParsed=$(echo "${min//./}")

if [[ "$parsedVersion" -gt minParsed ]]
then 
    echo "Python is $version"
    install_dependencies
    echo "Installation Complete"
else
    echo "Invalid Python version"
    echo "Expected minimum $min"
fi