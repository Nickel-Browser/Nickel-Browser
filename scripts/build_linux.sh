#!/bin/bash
# Nickel Browser - Build Linux Script (Production Grade)
# Author: FimuFixer CI Engine for Showaib Islam

set -euo pipefail

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL BUILD LINUX START ==="

# Directories and Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"
OUT_DIR="$SRC_DIR/out/Nickel"

echo "DEBUG: SCRIPT_DIR=$SCRIPT_DIR"
echo "DEBUG: NICKEL_DIR=$NICKEL_DIR"
echo "DEBUG: SRC_DIR=$SRC_DIR"
echo "DEBUG: OUT_DIR=$OUT_DIR"

# Validation
if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: Chromium source not found at $SRC_DIR. Fatal."
    exit 1
fi

cd "$SRC_DIR"

# Ensure depot_tools is in PATH
if [ -d "$HOME/depot_tools" ]; then
    export PATH="$HOME/depot_tools:$PATH"
fi

# Configure build
echo "LOG: Configuring build..."
mkdir -p "$OUT_DIR"

cat > "$OUT_DIR/args.gn" << 'EOF'
is_official_build = true
is_debug = false
symbol_level = 0
enable_nacl = false
proprietary_codecs = true
ffmpeg_branding = "Chrome"
use_sysroot = true
treat_warnings_as_errors = false
enable_reporting = false
google_api_key = ""
google_default_client_id = ""
google_default_client_secret = ""
use_lld = true
v8_enable_backtrace = true
use_ozone = true
ozone_auto_platform = true
EOF

echo "LOG: Running gn gen..."
gn gen "$OUT_DIR"

# Build Nickel
echo "LOG: Starting build..."
JOBS=$(nproc)
echo "LOG: Using $JOBS parallel jobs."

autoninja -C "$OUT_DIR" chrome -j$JOBS

# Packaging
echo "LOG: Packaging Linux artifacts..."
export NICKEL_VERSION="${NICKEL_VERSION:-1.0.0-alpha}"

# Build .deb
if [ -f "$NICKEL_DIR/scripts/build-deb.sh" ]; then
    echo "LOG: Building .deb package..."
    bash "$NICKEL_DIR/scripts/build-deb.sh"
fi

# Build .rpm
if [ -f "$NICKEL_DIR/scripts/build-rpm.sh" ]; then
    echo "LOG: Building .rpm package..."
    bash "$NICKEL_DIR/scripts/build-rpm.sh"
fi

# Build AppImage
if [ -f "$NICKEL_DIR/scripts/build-appimage.sh" ]; then
    echo "LOG: Building AppImage..."
    bash "$NICKEL_DIR/scripts/build-appimage.sh"
fi

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL BUILD LINUX COMPLETE ==="
