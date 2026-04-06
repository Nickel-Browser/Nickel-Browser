#!/bin/bash
# Nickel Browser - Build Windows Script (Production Grade)
# Author: FimuFixer CI Engine for Showaib Islam

set -euo pipefail

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL BUILD WINDOWS START ==="

# Directories and Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
SRC_DIR="${SRC_DIR:-C:/nickel-src/src}"
OUT_DIR="$SRC_DIR/out/Nickel"
DEPOT_TOOLS_PATH="${DEPOT_TOOLS_PATH:-C:/depot_tools}"

echo "DEBUG: SCRIPT_DIR=$SCRIPT_DIR"
echo "DEBUG: NICKEL_DIR=$NICKEL_DIR"
echo "DEBUG: SRC_DIR=$SRC_DIR"
echo "DEBUG: OUT_DIR=$OUT_DIR"
echo "DEBUG: DEPOT_TOOLS_PATH=$DEPOT_TOOLS_PATH"

# Validation
if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: Chromium source not found at $SRC_DIR. Fatal."
    exit 1
fi

cd "$SRC_DIR"

# Ensure depot_tools is in PATH
export PATH="$DEPOT_TOOLS_PATH:$PATH"

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
visual_studio_version = "2022"
EOF

echo "LOG: Running gn gen..."
gn gen "$OUT_DIR"

# Build Nickel
echo "LOG: Starting build..."
# Windows might have limited resources on GitHub Runners
JOBS=${NUMBER_OF_PROCESSORS:-4}
echo "LOG: Using $JOBS parallel jobs."

# Use autoninja (standard for Chromium)
autoninja -C "$OUT_DIR" chrome -j$JOBS

# Packaging
echo "LOG: Packaging Windows artifacts..."
export NICKEL_VERSION="${NICKEL_VERSION:-1.0.0-alpha}"

# Build Windows installer
if [ -f "$NICKEL_DIR/scripts/build-windows-installer.sh" ]; then
    echo "LOG: Building Windows installer..."
    bash "$NICKEL_DIR/scripts/build-windows-installer.sh"
fi

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL BUILD WINDOWS COMPLETE ==="
