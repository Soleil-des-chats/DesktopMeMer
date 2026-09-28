```bash
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

# Check required commands
for command in git python3 npm; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "Error: '$command' is not installed."
        exit 1
    fi
done

# Create Output directory
if [[ -d "$ROOT_DIR/Output" ]]; then
    echo "Cleaning existing Output directory..."
    rm -rf "$ROOT_DIR/Output" || {
        echo "Error: Failed to clean Output directory."
        exit 1
    }
fi

mkdir -p "$ROOT_DIR/Output" || {
    echo "Error: Failed to create Output directory."
    exit 1
}

echo "Output directory created."

# Download NW.js SDK
cd "$ROOT_DIR/Output" || {
    echo "Error: Could not enter Output directory."
    exit 1
}

NW_VERSION="0.91.0"
NW_ARCHIVE="nwjs-sdk-v${NW_VERSION}-linux-x64.zip"
NW_URL="https://dl.nwjs.io/v${NW_VERSION}/${NW_ARCHIVE}"

echo "Downloading NW.js ${NW_VERSION}..."
echo "$NW_URL"

if command -v curl >/dev/null 2>&1; then
    curl -fL --progress-bar "$NW_URL" -o "$NW_ARCHIVE" || {
        echo "Error: Failed to download NW.js."
        exit 1
    }
elif command -v wget >/dev/null 2>&1; then
    wget "$NW_URL" -O "$NW_ARCHIVE" || {
        echo "Error: Failed to download NW.js."
        exit 1
    }
else
    echo "Error: Neither curl nor wget is installed."
    exit 1
fi

# Extract NW.js SDK
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

# Check if the extracted directory exists
NW_DIR="nwjs-sdk-v${NW_VERSION}-linux-x64"

if [[ -d "$NW_DIR" ]]; then
    echo "Moving files to Output..."

    # cp -a preserves permissions, symlinks, etc.
    cp -a "$NW_DIR"/. . || {
        echo "Error: Failed to move files."
        exit 1
    }

    # Delete extracted directory
    rm -rf "$NW_DIR"

    echo "Files moved and subfolder deleted successfully."
else
    echo "Error: Subfolder '$NW_DIR' not found."
    exit 1
fi

# Remove the original zip file
rm -f "$NW_ARCHIVE"

cd "$ROOT_DIR" || {
    echo "Error: Failed to return to project root."
    exit 1
}

# Install npm dependencies
if [[ -d "$ROOT_DIR/src" ]]; then
    echo "Installing npm dependencies..."

    cd "$ROOT_DIR/src" || exit 1

    npm install || {
        echo "Error: npm install failed."
        exit 1
    }

    echo "npm install completed successfully."

    cd "$ROOT_DIR" || exit 1
else
    echo "Error: src directory not found."
    exit 1
fi

# Rename temporary build script
if [[ -f "$ROOT_DIR/BuildProject.temp" ]]; then
    mv "$ROOT_DIR/BuildProject.temp" "$ROOT_DIR/BuildProject.sh"
    chmod +x "$ROOT_DIR/BuildProject.sh"

    echo "BuildProject.sh file created."
else
    echo "Warning: BuildProject.temp file not found. Skipping rename."
fi

echo
echo "Project Setup Completed."
echo
read -rp "Press Enter to exit..."
```
