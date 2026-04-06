#!/bin/bash
# Nickel Browser - Apply Patches Script
# Applies all Nickel patches to Chromium source

set -e

echo "🪙 Nickel Browser - Apply Patches"
echo "=================================="
echo ""

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# Default SRC_DIR if not set
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"

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

# Apply ungoogled-chromium patches if present
echo "📋 Applying ungoogled-chromium patches..."
UNGOOGLED_DIR="${UNGOOGLED_DIR:-$HOME/nickel-src/ungoogled-chromium}"

if [ -d "$UNGOOGLED_DIR" ]; then
    echo "✅ Found ungoogled-chromium at $UNGOOGLED_DIR"
    
    # Prune binaries
    if [ -f "$UNGOOGLED_DIR/utils/prune_binaries.py" ]; then
        echo "🗑️  Pruning Google binaries..."
        python3 "$UNGOOGLED_DIR/utils/prune_binaries.py" ./ "$UNGOOGLED_DIR/pruning.list"
    fi
    
    # Apply domain substitution
    if [ -f "$UNGOOGLED_DIR/utils/domain_substitution.py" ]; then
        echo "🔄 Applying domain substitution..."
        python3 "$UNGOOGLED_DIR/utils/domain_substitution.py" apply \
            -r "$UNGOOGLED_DIR/domain_regex.list" \
            -f "$UNGOOGLED_DIR/domain_substitution.list" \
            -c "$HOME/nickel-src/domsubcache.tar.gz" ./
    fi
    
    # Apply patches
    if [ -d "$UNGOOGLED_DIR/patches" ]; then
        echo "🔧 Applying ungoogled patches..."
        for patch in "$UNGOOGLED_DIR/patches"/*.patch; do
            if [ -f "$patch" ]; then
                echo "  Applying: $(basename $patch)"
                git apply "$patch" || echo "    ⚠️  Skipped (may already be applied)"
            fi
        done
    fi
else
    echo "⚠️  ungoogled-chromium not found. Skipping ungoogled patches."
fi

echo ""
echo "🔧 Applying Nickel Browser patches..."

# Apply Nickel patches in order
NICKEL_PATCHES=(
    "0002-disable-safe-browsing-ping.patch"
    "0003-disable-webrtc-leak.patch"
    "0009-nickel-branding.patch"
    "0011-nickel-adblock-engine.patch"
    "0012-nickel-fingerprint-protection.patch"
    "0013-nickel-tor-private-window.patch"
    "0014-nickel-vpn-layer.patch"
    "0019-nickel-community-features.patch"
)

for patch in "${NICKEL_PATCHES[@]}"; do
    patch_path="$NICKEL_DIR/patches/$patch"
    if [ -f "$patch_path" ]; then
        echo "  Applying: $patch"
        if git apply "$patch_path"; then
            echo "    ✅ Applied successfully"
        else
            echo "    ⚠️  Failed to apply (may already be applied or conflict)"
        fi
    else
        echo "  ⚠️  Patch not found: $patch"
    fi
done

# Copy Nickel source files
echo ""
echo "📁 Copying Nickel source files..."

if [ -d "$NICKEL_DIR/src/nickel" ]; then
    echo "  Copying nickel/ directory..."
    cp -r "$NICKEL_DIR/src/nickel" ./
    echo "    ✅ Done"
fi

# Mark patches as applied
touch "$SRC_DIR/.nickel_patches_applied"

echo ""
echo "✅ Patches applied!"
echo ""
echo "You can now build with: gn gen out/Nickel && autoninja -C out/Nickel chrome"
