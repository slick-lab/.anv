#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect OS
OS_TYPE=$(uname -s)
ARCH=$(uname -m)

echo -e "${YELLOW}Detecting OS...${NC}"
echo "System: $OS_TYPE ($ARCH)"

# Set variables based on OS
case "$OS_TYPE" in
  Linux)
    ARTIFACT_ID="6896595962"
    BINARY_NAME="anv-linux"
    ;;
  Darwin)
    ARTIFACT_ID="6896596357"
    BINARY_NAME="anv-macos"
    ;;
  *)
    echo -e "${RED}Error: Unsupported OS: $OS_TYPE${NC}"
    echo "Only Linux and macOS are supported."
    exit 1
    ;;
esac

echo -e "${YELLOW}Downloading $BINARY_NAME...${NC}"

# Check if curl is available
if ! command -v curl &> /dev/null; then
  echo -e "${RED}Error: curl is required but not installed.${NC}"
  exit 1
fi

# Check if unzip is available
if ! command -v unzip &> /dev/null; then
  echo -e "${RED}Error: unzip is required but not installed.${NC}"
  exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

cd "$TEMP_DIR"

# GitHub Actions artifact download URL
ARTIFACT_URL="https://github.com/slick-lab/.anv/actions/runs/25604543565/artifacts/$ARTIFACT_ID/download"

echo -e "${YELLOW}Downloading artifact from GitHub Actions...${NC}"

# Download the artifact (it will be a ZIP file)
if ! curl -L -o artifact.zip "$ARTIFACT_URL" 2>/dev/null; then
  echo -e "${RED}Error: Failed to download artifact from:${NC}"
  echo "$ARTIFACT_URL"
  echo ""
  echo "Make sure the artifact is still available and your internet connection is working."
  exit 1
fi

# Extract the artifact
if ! unzip -q artifact.zip; then
  echo -e "${RED}Error: Failed to extract artifact${NC}"
  exit 1
fi

# Find the binary (it might be in a subdirectory)
BINARY_PATH=$(find . -name "*anv*" -type f | head -n 1)

if [ -z "$BINARY_PATH" ]; then
  echo -e "${RED}Error: Could not find binary in artifact${NC}"
  exit 1
fi

# Make it executable
chmod +x "$BINARY_PATH"

# Determine install location
INSTALL_DIR="/usr/local/bin"
BINARY_DEST="$INSTALL_DIR/anv"

# Check if we need sudo
if [ ! -w "$INSTALL_DIR" ]; then
  echo -e "${YELLOW}Requesting sudo access to install to $INSTALL_DIR...${NC}"
  sudo cp "$BINARY_PATH" "$BINARY_DEST"
  sudo chmod +x "$BINARY_DEST"
else
  cp "$BINARY_PATH" "$BINARY_DEST"
  chmod +x "$BINARY_DEST"
fi

echo -e "${GREEN}✓ Installation successful!${NC}"
echo "Binary installed to: $BINARY_DEST"
echo ""
echo "Test it:"
echo "  anv --help"
