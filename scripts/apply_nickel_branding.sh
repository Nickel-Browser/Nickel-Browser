#!/bin/bash
# Nickel Browser - Apply Nickel Branding Script
# Copies Nickel logos and branding files to Chromium source

set -e

echo "🪙 Nickel Browser - Apply Branding"
echo "==================================="
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# Default SRC_DIR if not set
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"

if [ ! -d "$SRC_DIR" ]; then
    echo "❌ Error: Chromium source not found at $SRC_DIR"
    exit 1
fi

# Copy branding files
echo "🎨 Copying branding files..."

if [ -d "$NICKEL_DIR/src/nickel/branding" ]; then
    echo "  Copying logos to chrome/app/theme/..."
    mkdir -p "$SRC_DIR/chrome/app/theme/chromium/"
    cp "$NICKEL_DIR/src/nickel/branding/product_logo_"*.png \
        "$SRC_DIR/chrome/app/theme/chromium/" 2>/dev/null || true
    echo "    ✅ Done"
fi

echo ""
echo "✅ Branding applied!"
