#!/usr/bin/env bash

set -u

clear

echo "////////////////////////////////////////////////////////////////////"
echo "Titimousse Project Building Tool Setup"
echo "--- Building: DesktopMeMer ---"
echo "////////////////////////////////////////////////////////////////////"
echo

read -rp "The setup process will begin. Press Enter to continue..."
echo

# Get the project root directory
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

NW_VERSION="0.117.0"
NW_DIR_NAME="nwjs-sdk-v${NW_VERSION}-linux-x64"
NW_ARCHIVE="${NW_DIR_NAME}.zip"
NW_URL="https://dl.nwjs.io/v${NW_VERSION}/${NW_ARCHIVE}"

# ------------------------------------------------------------
# Check required commands
# ------------------------------------------------------------

for command in git python3 npm; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Error: '$command' is not installed."
        exit 1
    fi
done

# curl or wget is required
if command -v curl >/dev/null 2>&1; then
    DOWNLOAD_COMMAND="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOAD_COMMAND="wget"
else
    echo "Error: Neither curl nor wget is installed."
    exit 1
fi

# ------------------------------------------------------------
# Create Output directory
# ------------------------------------------------------------

if [[ -d "$ROOT_DIR/Output" ]]; then
    echo "Cleaning existing Output directory..."

    rm -rf "$ROOT_DIR/Output" || {
        echo "Error: Failed to clean existing Output directory."
        exit 1
    }
fi

mkdir -p "$ROOT_DIR/Output" || {
    echo "Error: Failed to create Output directory."
    exit 1
}

echo "Output directory created."
echo

# ------------------------------------------------------------
# Download NW.js SDK
# ------------------------------------------------------------

cd "$ROOT_DIR/Output" || {
    echo "Error: Could not enter Output directory."
    exit 1
}

echo "Downloading NW.js SDK ${NW_VERSION}..."
echo "$NW_URL"
echo

if [[ "$DOWNLOAD_COMMAND" == "curl" ]]; then
    curl -fL --progress-bar "$NW_URL" -o "$NW_ARCHIVE"
else
    wget "$NW_URL" -O "$NW_ARCHIVE"
fi

if [[ $? -ne 0 ]]; then
    echo
    echo "Error: Failed to download NW.js."
    echo "URL:"
    echo "$NW_URL"
    exit 1
fi

echo
echo "NW.js downloaded successfully."
echo

# ------------------------------------------------------------
# Extract NW.js SDK
# ------------------------------------------------------------

echo "Extracting NW.js..."

python3 - "$NW_ARCHIVE" <<'PY'
import sys
import zipfile

archive = sys.argv[1]

try:
    with zipfile.ZipFile(archive, "r") as zip_file:
        zip_file.extractall(".")
except Exception as error:
    print(f"Error: Failed to extract NW.js: {error}")
    sys.exit(1)
PY

if [[ $? -ne 0 ]]; then
    exit 1
fi

echo "NW.js extracted successfully."
echo

# ------------------------------------------------------------
# Move NW.js contents into Output
# ------------------------------------------------------------

if [[ -d "$NW_DIR_NAME" ]]; then
    echo "Moving NW.js files to Output..."

    cp -a "$NW_DIR_NAME"/. . || {
        echo "Error: Failed to move NW.js files."
        exit 1
    }

    rm -rf "$NW_DIR_NAME"

    echo "Files moved successfully."
else
    echo "Error: Extracted NW.js directory not found:"
    echo "$NW_DIR_NAME"
    exit 1
fi

# ------------------------------------------------------------
# Remove downloaded archive
# ------------------------------------------------------------

rm -f "$NW_ARCHIVE"

echo "Removed NW.js archive."
echo

# ------------------------------------------------------------
# Verify NW.js executable
# ------------------------------------------------------------

if [[ ! -f "$ROOT_DIR/Output/nw" ]]; then
    echo "Error: NW.js executable was not found."
    exit 1
fi

chmod +x "$ROOT_DIR/Output/nw"

echo "NW.js executable ready."
echo

# ------------------------------------------------------------
# Return to project root
# ------------------------------------------------------------

cd "$ROOT_DIR" || {
    echo "Error: Failed to return to project root."
    exit 1
}

# ------------------------------------------------------------
# Install npm dependencies
# ------------------------------------------------------------

if [[ -d "$ROOT_DIR/src" ]]; then
    echo "Installing npm dependencies..."
    echo

    cd "$ROOT_DIR/src" || {
        echo "Error: Could not enter src directory."
        exit 1
    }

    npm install || {
        echo "Error: npm install failed."
        exit 1
    }

    echo
    echo "npm install completed successfully."
else
    echo "Error: src directory not found."
    exit 1
fi

# ------------------------------------------------------------
# Return to project root
# ------------------------------------------------------------

cd "$ROOT_DIR" || exit 1

# ------------------------------------------------------------
# Rename temporary build script
# ------------------------------------------------------------

if [[ -f "$ROOT_DIR/BuildProject.temp" ]]; then
    mv "$ROOT_DIR/BuildProject.temp" "$ROOT_DIR/BuildProject.sh" || {
        echo "Error: Failed to rename BuildProject.temp."
        exit 1
    }

    chmod +x "$ROOT_DIR/BuildProject.sh"

    echo "BuildProject.sh file created."
else
    echo "Warning: BuildProject.temp file not found. Skipping rename."
fi

# ------------------------------------------------------------
# Finished
# ------------------------------------------------------------

echo
echo "////////////////////////////////////////////////////////////////////"
echo "Project Setup Completed"
echo "////////////////////////////////////////////////////////////////////"
echo

read -rp "Press Enter to exit..."
