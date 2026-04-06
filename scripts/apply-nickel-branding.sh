#!/bin/bash
# scripts/apply-nickel-branding.sh
# Applies Nickel Browser branding over an extracted ungoogled-chromium binary

set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# Default binary dir if not set
BINARY_DIR="${BINARY_DIR:-$NICKEL_DIR/uc-binary}"

echo "🪙 Nickel Browser - Apply Branding to Binary"
echo "==========================================="

if [ ! -d "$BINARY_DIR" ]; then
    echo "❌ Error: Binary directory not found at $BINARY_DIR"
    exit 1
fi

# Find the Chromium root in the binary dir (it often has a subdir)
CHROME_DIR=$(find "$BINARY_DIR" -maxdepth 2 -name "chrome" -o -name "chromium" -type f | xargs dirname | head -n 1)

if [ -z "$CHROME_DIR" ]; then
    echo "⚠️  Binary directory structure not recognized. Assuming $BINARY_DIR as root."
    CHROME_DIR="$BINARY_DIR"
fi

echo "📍 BRANDING_DIR: $NICKEL_DIR/src/nickel/branding"
echo "📍 BINARY_ROOT: $CHROME_DIR"

# Copy branding assets to the appropriate locations if they exist
# For a pre-built binary, we mainly replace icons and sidecar files

# Linux/Windows icon replacement (where applicable)
if [ -d "$NICKEL_DIR/src/nickel/branding" ]; then
    echo "🎨 Replacing branding assets..."
    # Replace resources.pak or specific icons if possible
    # In a binary-patch approach, we often replace the .desktop file and the main icons
    # but actual binary patching is more complex.
    # For now, we'll focus on replacing icons used by the packaging scripts.

    # Copy product_logo_*.png to a staging area for packaging
    mkdir -p "$CHROME_DIR/branding"
    cp "$NICKEL_DIR/src/nickel/branding/product_logo_"*.png "$CHROME_DIR/branding/" 2>/dev/null || true
    echo "    ✅ Branding assets staged in $CHROME_DIR/branding"
fi

# Optional: Add a custom about:nickel page or branding info
echo "Nickel Browser (Chromium fork)" > "$CHROME_DIR/NICKEL_VERSION"
echo "Base Chromium Version: $(cat $NICKEL_DIR/.chromium_version)" >> "$CHROME_DIR/NICKEL_VERSION"

echo "✅ Branding applied (staged for packaging)!"
