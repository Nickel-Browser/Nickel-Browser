#!/bin/bash
# scripts/apply_patches.sh
# Applies all Nickel patches to Chromium source

set -euo pipefail

echo "🪙 Nickel Browser - Apply Patches"
echo "=================================="

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# Default SRC_DIR if not set
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"

echo "📍 NICKEL_DIR: $NICKEL_DIR"
echo "📍 SRC_DIR: $SRC_DIR"

# Check directories
if [ ! -d "$NICKEL_DIR" ]; then
    echo "❌ Error: Nickel directory not found at $NICKEL_DIR"
    exit 1
fi

if [ ! -d "$SRC_DIR" ]; then
    echo "❌ Error: Chromium source not found at $SRC_DIR"
    exit 1
fi

cd "$SRC_DIR"

# Apply Nickel patches in order
echo "🔧 Applying Nickel Browser patches..."

NICKEL_PATCHES=(
    "0001-remove-google-api-keys.patch"
    "0002-disable-safe-browsing-ping.patch"
    "0003-disable-webrtc-leak.patch"
    "0004-disable-crash-reporter.patch"
    "0005-disable-metrics-upload.patch"
    "0006-disable-field-trials-seed.patch"
    "0007-spoof-useragent-nickel.patch"
    "0008-remove-google-update.patch"
    "0009-nickel-branding.patch"
    "0010-nickel-newtab.patch"
    "0011-nickel-adblock-engine.patch"
    "0012-nickel-fingerprint-protection.patch"
    "0013-nickel-tor-private-window.patch"
    "0014-nickel-vpn-layer.patch"
    "0015-nickel-natural-language-fixer.patch"
    "0016-nickel-autoupdate-chromium-sync.patch"
    "0017-nickel-youtube-deep-adblock.patch"
    "0018-nickel-keyboard-mouse-leak-block.patch"
    "0019-nickel-community-features.patch"
)

for patch in "${NICKEL_PATCHES[@]}"; do
    patch_path="$NICKEL_DIR/patches/$patch"
    if [ -f "$patch_path" ]; then
        echo "  Applying: $patch"
        # Check if patch is already applied
        if git apply --check "$patch_path" > /dev/null 2>&1; then
            if git apply "$patch_path"; then
                echo "    ✅ Applied successfully"
            else
                echo "    ❌ Failed to apply"
                exit 1
            fi
        else
            echo "    ⚠️  Already applied or conflict, skipping"
        fi
    else
        echo "  ⚠️  Patch not found: $patch"
    fi
done

# Copy Nickel source files
if [ -d "$NICKEL_DIR/src/nickel" ]; then
    echo "📁 Copying Nickel source files..."
    cp -rv "$NICKEL_DIR/src/nickel" ./
    echo "    ✅ Done"
fi

# Mark patches as applied
touch "$SRC_DIR/.nickel_patches_applied"

echo "✅ All Nickel patches applied successfully!"
