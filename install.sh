#!/bin/bash

# Define variables
URL_LINUX="https://github.com/slick-lab/.anv/releases/download/v0.2.1/anv-linux"
URL_MACOS="https://github.com/slick-lab/.anv/releases/download/v0.2.1/anv-macos"
DEST="/usr/local/bin/anv"

# Detect OS
OS_TYPE=$(uname -s)

if [ "$OS_TYPE" == "Linux" ]; then
    echo "Detected Linux. Downloading..."
    curl -L "$URL_LINUX" -o anv
elif [ "$OS_TYPE" == "Darwin" ]; then
    echo "Detected macOS. Downloading..."
    curl -L "$URL_MACOS" -o anv
else
    echo "Unsupported OS: $OS_TYPE"
    exit 1
fi

# Make executable
chmod +x anv

# Move to /usr/local/bin
echo "Moving 'anv' to /usr/local/bin (may require password)..."
sudo mv anv "$DEST"

if [ $? -eq 0 ]; then
    echo "Installation complete! You can now run 'anv' from your terminal."
else
    echo "Installation failed during the move to /usr/local/bin."
    exit 1
fi