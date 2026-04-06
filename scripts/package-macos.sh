#!/bin/bash
# Nickel Browser - Package (macOS)
set -e

echo "=== STEP START: Package (macOS) ==="

SRC_DIR="${SRC_DIR:-/Users/runner/nickel-src/src}"
NICKEL_DIR="${NICKEL_DIR:-/Users/runner/work/Nickel-Browser/Nickel-Browser}"
DIST_DIR="$NICKEL_DIR/dist"

cd "$SRC_DIR"
export NICKEL_VERSION="${NICKEL_VERSION:-1.0.0-alpha}"

echo "🔨 Building .dmg package..."
bash "$NICKEL_DIR/scripts/build-dmg.sh"

mkdir -p "$DIST_DIR"
mv out/Release/*.dmg "$DIST_DIR/" 2>/dev/null || true

cd "$DIST_DIR"
echo "🔍 Verifying artifacts..."
if [ -z "$(ls -A .)" ]; then
    echo "❌ Error: No artifacts found in $DIST_DIR"
    exit 1
fi

echo "📝 Generating checksums..."
sha256sum * > checksums-macos.sha256

echo "=== STEP END: Package (macOS) ==="
