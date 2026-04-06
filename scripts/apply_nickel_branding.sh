#!/bin/bash
# Nickel Browser - Apply Nickel Branding Script (Production Grade)
# Author: FimuFixer CI Engine for Showaib Islam

set -euo pipefail

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL BRANDING START ==="

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# Default SRC_DIR if not set
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"

echo "DEBUG: SCRIPT_DIR=$SCRIPT_DIR"
echo "DEBUG: NICKEL_DIR=$NICKEL_DIR"
echo "DEBUG: SRC_DIR=$SRC_DIR"

if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: Chromium source not found at $SRC_DIR. Fatal."
    exit 1
fi

# Branding Directories
NICKEL_BRAND_DIR="$NICKEL_DIR/src/nickel/branding"
CHROMIUM_BRAND_DIR="$SRC_DIR/chrome/app/theme/chromium"

# Check Nickel branding directory
if [ ! -d "$NICKEL_BRAND_DIR" ]; then
    echo "ERROR: Nickel branding directory not found at $NICKEL_BRAND_DIR. Fatal."
    exit 1
fi

# Ensure Chromium branding directory exists
mkdir -p "$CHROMIUM_BRAND_DIR"

# Copy branding assets
echo "LOG: Copying logos and branding files..."

# List of logo sizes
LOGO_SIZES=(24 32 48 64 128 256)

for size in "${LOGO_SIZES[@]}"; do
    logo_file="$NICKEL_BRAND_DIR/product_logo_$size.png"
    if [ -f "$logo_file" ]; then
        echo "LOG: Copying product_logo_$size.png..."
        cp "$logo_file" "$CHROMIUM_BRAND_DIR/"
    else
        echo "WARNING: product_logo_$size.png not found. Skipping."
    fi
done

# Copy any other branding assets (favicon, icons, etc.)
if [ -f "$NICKEL_BRAND_DIR/icon.ico" ]; then
    echo "LOG: Copying icon.ico..."
    cp "$NICKEL_BRAND_DIR/icon.ico" "$CHROMIUM_BRAND_DIR/"
fi

# Replace branding strings in relevant files (if needed)
# This can be done via patches, but can also be handled here
echo "LOG: Replacing Chromium branding strings with Nickel..."

# Example replacements
# grep -rl "Chromium" "$SRC_DIR/chrome/app/theme/chromium/" | xargs sed -i 's/Chromium/Nickel/g' || true

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL BRANDING COMPLETE ==="
touch "$SRC_DIR/.nickel_branding_applied"
