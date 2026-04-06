#!/bin/bash
# Nickel Browser - Package (Linux)
set -e

echo "=== STEP START: Package (Linux) ==="

SRC_DIR="${SRC_DIR:-/home/runner/nickel-src/src}"
NICKEL_DIR="${NICKEL_DIR:-/home/runner/work/Nickel-Browser/Nickel-Browser}"
DIST_DIR="$NICKEL_DIR/dist"

cd "$SRC_DIR"
export NICKEL_VERSION="${NICKEL_VERSION:-1.0.0-alpha}"

echo "🔨 Building .deb package..."
bash "$NICKEL_DIR/scripts/build-deb.sh"

echo "🔨 Building AppImage..."
bash "$NICKEL_DIR/scripts/build-appimage.sh"

mkdir -p "$DIST_DIR"
cp out/Release/chrome "$DIST_DIR/nickel-browser"
mv *.deb *.AppImage "$DIST_DIR/" 2>/dev/null || true

cd "$DIST_DIR"
echo "🔍 Verifying artifacts..."
if [ ! -f "nickel-browser" ]; then
    echo "❌ Error: nickel-browser binary not found"
    exit 1
fi

SIZE=$(stat -c%s "nickel-browser")
if [ "$SIZE" -lt 1000000 ]; then
    echo "❌ Error: nickel-browser binary is too small ($SIZE bytes)"
    exit 1
fi

echo "📝 Generating checksums..."
sha256sum * > checksums-linux.sha256

echo "=== STEP END: Package (Linux) ==="
