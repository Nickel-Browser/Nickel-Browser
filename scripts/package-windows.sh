#!/bin/bash
# Nickel Browser - Package (Windows)
set -e

echo "=== STEP START: Package (Windows) ==="

SRC_DIR="${SRC_DIR:-D:/nickel-src/src}"
NICKEL_DIR="${NICKEL_DIR:-D:/work/Nickel-Browser/Nickel-Browser}"
DIST_DIR="$NICKEL_DIR/dist"

cd "$SRC_DIR"
export NICKEL_VERSION="${NICKEL_VERSION:-1.0.0-alpha}"

echo "🔨 Building Windows installer..."
bash "$NICKEL_DIR/scripts/build-windows-installer.sh"

mkdir -p "$DIST_DIR"
mv out/Release/*.exe "$DIST_DIR/" 2>/dev/null || true

cd "$DIST_DIR"
echo "🔍 Verifying artifacts..."
if [ -z "$(ls -A .)" ]; then
    echo "❌ Error: No artifacts found in $DIST_DIR"
    exit 1
fi

echo "📝 Generating checksums..."
sha256sum * > checksums-windows.sha256

echo "=== STEP END: Package (Windows) ==="
