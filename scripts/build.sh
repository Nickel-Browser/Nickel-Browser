#!/bin/bash
# Nickel Browser - Build Script
# Builds Nickel Browser from source

set -e

echo "🪙 Nickel Browser - Build Script"
echo "================================="
echo ""

NICKEL_DIR="$HOME/nickel-build"
SRC_DIR="$NICKEL_DIR/src"

# Check if source exists
if [ ! -d "$SRC_DIR" ]; then
    echo "❌ Error: Chromium source not found at $SRC_DIR"
    echo "   Please run: ./scripts/fetch-chromium.sh"
    exit 1
fi

cd "$SRC_DIR"

# Check for patches
if [ ! -d "$NICKEL_DIR/nickel" ]; then
    echo "❌ Error: Nickel patches not found"
    echo "   Please clone nickel-browser repository to $NICKEL_DIR/nickel"
    exit 1
fi

# Apply patches if not already applied
if [ ! -f "$SRC_DIR/.nickel_patches_applied" ]; then
    echo "🔧 Applying Nickel patches..."
    # If NICKEL_DIR is not set, assume standard location
    NICKEL_DIR="${NICKEL_DIR:-$HOME/nickel-build/nickel}"
    bash "$NICKEL_DIR/scripts/apply_patches.sh"
    bash "$NICKEL_DIR/scripts/apply_nickel_branding.sh"
else
    echo "✅ Patches already applied"
fi

cd "$SRC_DIR"

# Configure build
echo ""
echo "⚙️  Configuring build..."

mkdir -p out/Nickel

cat > out/Nickel/args.gn << 'EOF'
# Nickel Browser Build Configuration
is_official_build = true
is_debug = false
target_cpu = "x64"
symbol_level = 0

# Disable unnecessary features for smaller/faster build
enable_nacl = false
is_component_build = false
use_official_google_api_keys = false
google_api_key = ""
google_default_client_id = ""
google_default_client_secret = ""
enable_hangout_services_extension = false
enable_reporting = false
enable_service_discovery = false
safe_browsing_mode = 0
use_unofficial_version_number = false
chrome_pgo_phase = 0
enable_js_type_check = false
treat_warnings_as_errors = false
blink_enable_generated_code_formatting = false

# Enable media codecs
enable_widevine = true
proprietary_codecs = true
ffmpeg_branding = "Chrome"

# Optimizations for low RAM
clang_use_chrome_plugins = false
use_lld = true
use_thin_lto = true

# Nickel-specific flags (would be defined in build config)
# nickel_enable_adblock = true
# nickel_enable_tor = true
# nickel_enable_vpn = true
# nickel_enable_fingerprint = true
EOF

gn gen out/Nickel

echo ""
echo "🔨 Starting build..."
echo "   This will take 4-8 hours depending on your hardware."
echo ""

# Determine number of parallel jobs
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
CPU_CORES=$(nproc)

if [ "$TOTAL_RAM" -lt 8192 ]; then
    JOBS=1
    echo "💾 Low RAM detected (${TOTAL_RAM}MB). Using -j1 for stability."
elif [ "$TOTAL_RAM" -lt 16384 ]; then
    JOBS=2
    echo "💾 Moderate RAM detected (${TOTAL_RAM}MB). Using -j2."
else
    JOBS=4
    echo "💾 Good RAM detected (${TOTAL_RAM}MB). Using -j4."
fi

echo "   CPU cores: $CPU_CORES"
echo "   Parallel jobs: $JOBS"
echo ""

# Use tmux for build session (disabled in CI)
if command -v tmux &> /dev/null && [ -z "$GITHUB_ACTIONS" ]; then
    if tmux has-session -t nickel-build 2>/dev/null; then
        echo "⚠️  tmux session 'nickel-build' already exists"
        echo "   Attach with: tmux attach -t nickel-build"
        exit 1
    fi
    
    echo "💡 Using tmux session 'nickel-build'"
    echo "   To detach: Ctrl+B then D"
    echo "   To reattach: tmux attach -t nickel-build"
    echo ""
    
    tmux new-session -d -s nickel-build "
        cd '$SRC_DIR'
        echo '🔨 Building Nickel Browser...'
        echo 'Started at: \$(date)'
        echo ''
        ninja -C out/Nickel chrome -j$JOBS
        echo ''
        echo '✅ Build complete!'
        echo 'Finished at: \$(date)'
        echo ''
        echo 'Binary location: out/Nickel/chrome'
        echo ''
        echo 'Next steps:'
        echo '  1. Test: ./out/Nickel/chrome'
        echo '  2. Package: ./scripts/package.sh'
        read -p 'Press Enter to exit...'
    "
    
    tmux attach -t nickel-build
else
    # Build without tmux
    echo "🔨 Building with autoninja -j$JOBS..."
    # Use autoninja if available (standard for Chromium)
    if command -v autoninja &> /dev/null; then
        autoninja -C out/Nickel chrome -j$JOBS
    else
        ninja -C out/Nickel chrome -j$JOBS
    fi
fi

echo ""
echo "✅ Build complete!"
echo ""
echo "Binary location: $SRC_DIR/out/Nickel/chrome"
echo ""
echo "Next steps:"
echo "  1. Test: ./out/Nickel/chrome"
echo "  2. Package: ./scripts/package.sh"
echo ""
