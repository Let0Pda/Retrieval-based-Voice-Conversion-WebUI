#!/bin/bash

# Function to display error message and exit
error_exit() {
    echo "$1" >&2
    exit 1
}

# Function to install Python 3.8 if not available
install_python3() {
    if [ "$(uname)" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
        brew install python@3.8 || error_exit "Failed to install Python 3.8 using Homebrew."
    elif [ "$(uname)" = "Linux" ] && command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y python3.8 || error_exit "Failed to install Python 3.8 using apt."
    else
        error_exit "Unsupported operating system or package manager. Please install Python 3.8 manually."
    fi
}

# Check if Python 3 is available
if ! command -v python3 >/dev/null 2>&1; then
    echo "Python 3 not found. Attempting to install Python 3.8..."
    install_python3
fi

# Check if virtual environment exists, otherwise create it
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv || error_exit "Failed to create virtual environment."
fi

# Activate virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate || error_exit "Failed to activate virtual environment."

# Install required packages
echo "Installing required packages..."
python3 -m pip install --upgrade -r requirements.txt || error_exit "Failed to install required packages."

# Download models
echo "Downloading models..."
./tools/dlmodels.sh || error_exit "Failed to download models."

# Run main script
echo "Running main script..."
python3 infer-web.py --pycmd python3 || error_exit "Failed to run main script."
