#!/bin/bash
# anv installer - fetches the latest binary from GitHub Releases
# deepseek v4-pro gave me this btw
set -e

REPO="slick-lab/.anv"
BINARY_NAME="anv"

# Detect OS
detect_os() {
  case "$(uname -s)" in
    Linux*)   echo "linux" ;;
    Darwin*)  echo "darwin" ;;
    *)        echo "unsupported" ;;
  esac
}

# Detect architecture
detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64) echo "amd64" ;;
    aarch64|arm64) echo "arm64" ;;
    *) echo "unsupported" ;;
  esac
}

OS=$(detect_os)
ARCH=$(detect_arch)

if [ "$OS" = "unsupported" ] || [ "$ARCH" = "unsupported" ]; then
  echo "❌ Unsupported OS/architecture: $(uname -s) / $(uname -m)"
  echo "   anv currently supports Linux and macOS on x86_64 and arm64."
  exit 1
fi

# Set the target binary name from release
if [ "$OS" = "linux" ]; then
  RELEASE_BIN="anv-linux"
elif [ "$OS" = "darwin" ]; then
  RELEASE_BIN="anv-macos"
fi

echo "📦 Fetching latest anv release for $OS/$ARCH..."

# Get download URL from GitHub API
DOWNLOAD_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep "browser_download_url.*$RELEASE_BIN" | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
  echo "❌ Could not find download URL for $RELEASE_BIN"
  echo "   Check if the release exists at: https://github.com/$REPO/releases"
  exit 1
fi

# Create temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

echo "⬇️  Downloading $RELEASE_BIN..."
curl -L -o "$BINARY_NAME" "$DOWNLOAD_URL"

chmod +x "$BINARY_NAME"

# Install to /usr/local/bin
INSTALL_PATH="/usr/local/bin/$BINARY_NAME"

if [ -w "/usr/local/bin" ]; then
  mv "$BINARY_NAME" "$INSTALL_PATH"
else
  echo "🔒 Need sudo to install to /usr/local/bin"
  sudo mv "$BINARY_NAME" "$INSTALL_PATH"
fi

# Clean up
cd /
rm -rf "$TMP_DIR"

echo "✅ anv installed successfully to $INSTALL_PATH"
echo ""
echo "Run 'anv --help' to get started."
