```bash
#!/usr/bin/env bash

set -u

clear

echo "////////////////////////////////////////////////////////////////////"
echo "Titimousse Project Building Tool"
echo "--- Building: DesktopMeMer ---"
echo "////////////////////////////////////////////////////////////////////"
echo

read -rp "The build will begin. Press Enter to continue..."

# Get the project root directory
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# Check required directories/files
if [[ ! -d "$ROOT_DIR/src" ]]; then
    echo "Error: Could not find the source directory."
    exit 1
fi

if [[ ! -d "$ROOT_DIR/Output" ]]; then
    echo "Error: Could not find the Output directory."
    exit 1
fi

if [[ ! -f "$ROOT_DIR/Output/nw" ]]; then
    echo "Error: Could not find Output/nw."
    exit 1
fi

# Check that zip is installed
if ! command -v zip >/dev/null 2>&1; then
    echo "Error: 'zip' is not installed."
    echo "Install it with: sudo pacman -S zip"
    exit 1
fi

# Create app.nw
echo "Creating the app.nw archive..."

cd "$ROOT_DIR/src" || exit 1

rm -f "$ROOT_DIR/Output/app.nw"

zip -r "$ROOT_DIR/Output/app.nw" . || {
    echo "Error: Failed to create app.nw."
    exit 1
}

# Copy node_modules
echo "Copying node_modules..."

rm -rf "$ROOT_DIR/Output/node_modules"

if [[ -d "$ROOT_DIR/src/node_modules" ]]; then
    cp -a "$ROOT_DIR/src/node_modules" "$ROOT_DIR/Output/node_modules" || {
        echo "Error: Failed to copy node_modules."
        exit 1
    }
fi

# Build the executable
echo "Combining nw and app.nw to create app..."

cd "$ROOT_DIR/Output" || exit 1

rm -f app

cat nw app.nw > app || {
    echo "Error: Failed to combine nw and app.nw."
    exit 1
}

chmod +x app || {
    echo "Error: Failed to make app executable."
    exit 1
}

# Rename the clean NW.js executable
echo "Renaming nw to cleanNW.old..."

mv nw cleanNW.old || {
    echo "Error: Failed to rename nw."
    exit 1
}

echo
echo "Project Setup Completed."
echo "Executable: $ROOT_DIR/Output/app"
echo

read -rp "Press Enter to exit..."
```
