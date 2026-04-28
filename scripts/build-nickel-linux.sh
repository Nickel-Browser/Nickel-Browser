#!/usr/bin/env bash
# scripts/build-nickel-linux.sh
# ==============================================================================
# Nickel Browser — Linux Source Build Script
# ==============================================================================
#
# Usage:
#   ./scripts/build-nickel-linux.sh [--version <uc_version>] [--jobs <n>]
#                                   [--debug] [--no-package]
#
# This script automates the full Nickel Browser Linux build:
#   1. Install system dependencies
#   2. Install depot_tools
#   3. Clone ungoogled-chromium at the pinned version
#   4. Fetch Chromium source (gclient sync via UC utils)
#   5. Apply ungoogled-chromium patches
#   6. Apply Nickel patches (from ./patches/series)
#   7. Generate GN build configuration
#   8. Build with ninja
#   9. Package as .deb and .tar.xz
#
# Requirements:
#   - Ubuntu 20.04 / 22.04 / 24.04 (Debian variants)
#   - ~100 GB free disk space
#   - 16+ GB RAM (32 GB recommended)
#   - Internet access for source downloads
#
# ==============================================================================

set -euo pipefail

# --------------------------------------------------------------------------
# Defaults
# --------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NICKEL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

UC_VERSION="${UC_VERSION:-$(cat "$NICKEL_DIR/.chromium_version" 2>/dev/null || echo '146.0.7680.177-1')}"
NICKEL_VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BUILD_TYPE="release"
NINJA_JOBS=0       # 0 = auto
DO_PACKAGE=true
DEPOT_TOOLS_DIR="${DEPOT_TOOLS_DIR:-$HOME/depot_tools}"
UC_DIR="${UC_DIR:-$NICKEL_DIR/build/ungoogled-chromium}"
SRC_DIR="$UC_DIR/chromium"
OUT_DIR="$SRC_DIR/out/Nickel"

# --------------------------------------------------------------------------
# Argument parsing
# --------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)   UC_VERSION="$2"; shift 2 ;;
    --jobs|-j)   NINJA_JOBS="$2"; shift 2 ;;
    --debug)     BUILD_TYPE="debug"; shift ;;
    --no-package) DO_PACKAGE=false; shift ;;
    -h|--help)
      grep '^#' "$0" | head -30 | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

CHROMIUM_VERSION="${UC_VERSION%-*}"

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------
step() { echo ""; echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"; echo "▶ $*"; echo ""; }
ok()   { echo "✅ $*"; }
err()  { echo "❌ $*" >&2; exit 1; }

# --------------------------------------------------------------------------
step "Check prerequisites"
# --------------------------------------------------------------------------
if [[ "$(uname)" != "Linux" ]]; then
  err "This script only runs on Linux"
fi
if ! command -v python3 &>/dev/null; then
  err "python3 is required"
fi
PYTHON_VER=$(python3 -c 'import sys; print(sys.version_info.major*10+sys.version_info.minor)')
if [[ $PYTHON_VER -lt 38 ]]; then
  err "Python 3.8+ required (found: $(python3 --version))"
fi
DISK_FREE=$(df -BG "$NICKEL_DIR" | awk 'NR==2{print $4}' | tr -d G)
if [[ $DISK_FREE -lt 80 ]]; then
  echo "⚠️  Warning: Only ${DISK_FREE} GB free. A full Chromium build needs 100+ GB."
  echo "   Continue anyway? [y/N]"
  read -r confirm
  [[ "$confirm" =~ ^[Yy]$ ]] || exit 1
fi
ok "Prerequisites check passed"

# --------------------------------------------------------------------------
step "Install system dependencies (requires sudo)"
# --------------------------------------------------------------------------
if command -v apt-get &>/dev/null; then
  sudo apt-get update -qq
  sudo apt-get install -y --no-install-recommends \
    python3 python3-pip git curl wget \
    build-essential clang lld \
    pkg-config binutils \
    ninja-build \
    libglib2.0-dev libgtk-3-dev \
    libpulse-dev libasound2-dev libdbus-1-dev \
    libx11-dev libxcomposite-dev libxdamage-dev libxext-dev \
    libxfixes-dev libxi-dev libxrandr-dev libxss-dev libxtst-dev \
    libatk1.0-dev libcups2-dev libdrm-dev \
    mesa-common-dev libgbm-dev libssl-dev \
    libnss3-dev libffi-dev \
    gperf bison flex \
    dpkg-dev fakeroot xz-utils tar jq elfutils
  ok "Dependencies installed"
else
  echo "⚠️  Non-Debian system: please install dependencies manually (see docs/BUILD.md)"
fi

# --------------------------------------------------------------------------
step "Install depot_tools"
# --------------------------------------------------------------------------
if [[ ! -d "$DEPOT_TOOLS_DIR" ]]; then
  git clone --depth=1 \
    https://chromium.googlesource.com/chromium/tools/depot_tools.git \
    "$DEPOT_TOOLS_DIR"
fi
export PATH="$DEPOT_TOOLS_DIR:$PATH"
ok "depot_tools ready at $DEPOT_TOOLS_DIR"

# --------------------------------------------------------------------------
step "Clone ungoogled-chromium $UC_VERSION"
# --------------------------------------------------------------------------
if [[ ! -d "$UC_DIR/.git" ]]; then
  mkdir -p "$(dirname "$UC_DIR")"
  git clone --depth=1 --branch "$UC_VERSION" \
    "https://github.com/ungoogled-software/ungoogled-chromium.git" \
    "$UC_DIR"
  ok "Cloned ungoogled-chromium"
else
  ok "ungoogled-chromium already cloned at $UC_DIR (skipping)"
fi

# --------------------------------------------------------------------------
step "Fetch Chromium $CHROMIUM_VERSION source (~30 GB)"
# --------------------------------------------------------------------------
if [[ ! -d "$SRC_DIR/chrome" ]]; then
  cd "$UC_DIR"
  git config --global core.compression 0
  git config --global http.postBuffer 2097152000
  python3 utils/fetch_sync.py \
    --chromium-version "$CHROMIUM_VERSION" \
    --output-directory chromium
  ok "Chromium source fetched"
else
  ok "Chromium source already present at $SRC_DIR (skipping)"
fi

# --------------------------------------------------------------------------
step "Apply ungoogled-chromium patches"
# --------------------------------------------------------------------------
cd "$UC_DIR"
python3 utils/patches/apply_patches.py chromium patches/
ok "ungoogled-chromium patches applied"

# --------------------------------------------------------------------------
step "Apply Nickel patches"
# --------------------------------------------------------------------------
cd "$SRC_DIR"
SERIES="$NICKEL_DIR/patches/series"
if [[ ! -f "$SERIES" ]]; then
  err "patches/series not found at $SERIES"
fi
while IFS= read -r line || [[ -n "$line" ]]; do
  [[ -z "$line" || "$line" == \#* ]] && continue
  PATCH="$NICKEL_DIR/patches/$line"
  echo "  → $line"
  git apply \
    --ignore-whitespace \
    --whitespace=nowarn \
    "$PATCH"
done < "$SERIES"
ok "All Nickel patches applied"

# --------------------------------------------------------------------------
step "Generate GN build config"
# --------------------------------------------------------------------------
mkdir -p "$OUT_DIR"

# Base args from ungoogled-chromium
cd "$UC_DIR"
python3 utils/gn_args.py > "$OUT_DIR/args.gn"

# Append Nickel overrides
cat >> "$OUT_DIR/args.gn" << NICKEL_ARGS

# Nickel Browser overrides
is_official_build = true
is_debug = $([ "$BUILD_TYPE" = "debug" ] && echo true || echo false)
symbol_level = $([ "$BUILD_TYPE" = "debug" ] && echo 1 || echo 0)
blink_symbol_level = 0
enable_nacl = false
enable_widevine = false
fieldtrial_testing_like_official_build = true
is_clang = true
use_lld = true
defines = ["NICKEL_BROWSER=1","NICKEL_ADBLOCK_ENABLED=1","NICKEL_FINGERPRINT_PROTECTION=1","NICKEL_TOR_INTEGRATION=1"]
NICKEL_ARGS

cd "$SRC_DIR"
gn gen "$OUT_DIR"
ok "GN config generated"

# --------------------------------------------------------------------------
step "Build Nickel Browser with ninja"
# --------------------------------------------------------------------------
if [[ "$NINJA_JOBS" == "0" ]]; then
  CPUS=$(nproc)
  # Cap at 8 to avoid OOM on low-RAM machines; increase if you have 32+ GB
  JOBS=$(( CPUS > 8 ? 8 : CPUS ))
  echo "Using $JOBS ninja jobs (nproc=$CPUS)"
else
  JOBS=$NINJA_JOBS
  echo "Using $JOBS ninja jobs (manual)"
fi

START_TIME=$(date +%s)

ninja -C "$OUT_DIR" -j "$JOBS" \
  chrome \
  chrome_sandbox \
  chromedriver

END_TIME=$(date +%s)
ELAPSED=$(( (END_TIME - START_TIME) / 60 ))
ok "Build complete in ${ELAPSED} minutes"

# --------------------------------------------------------------------------
if [[ "$DO_PACKAGE" == "true" ]]; then
step "Create .deb package"
# --------------------------------------------------------------------------
STAGING=$(mktemp -d)
PKG_ROOT="$STAGING/nickel-browser"
CHROMIUM_VER="$CHROMIUM_VERSION"

install -d "$PKG_ROOT/DEBIAN"
install -d "$PKG_ROOT/opt/nickel-browser"
install -d "$PKG_ROOT/usr/bin"
install -d "$PKG_ROOT/usr/share/applications"
install -d "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps"

cp "$OUT_DIR/chrome"         "$PKG_ROOT/opt/nickel-browser/nickel-browser"
cp "$OUT_DIR/chrome_sandbox" "$PKG_ROOT/opt/nickel-browser/chrome-sandbox"
chmod 4755                   "$PKG_ROOT/opt/nickel-browser/chrome-sandbox"

for f in icudtl.dat resources.pak \
          chrome_100_percent.pak chrome_200_percent.pak \
          snapshot_blob.bin v8_context_snapshot.bin \
          libEGL.so libGLESv2.so; do
  [[ -f "$OUT_DIR/$f" ]] && cp "$OUT_DIR/$f" "$PKG_ROOT/opt/nickel-browser/"
done
[[ -d "$OUT_DIR/locales" ]] && cp -r "$OUT_DIR/locales" "$PKG_ROOT/opt/nickel-browser/"

ln -sf /opt/nickel-browser/nickel-browser "$PKG_ROOT/usr/bin/nickel-browser"

if [[ -f "$NICKEL_DIR/src/nickel/branding/product_logo_256.png" ]]; then
  cp "$NICKEL_DIR/src/nickel/branding/product_logo_256.png" \
     "$PKG_ROOT/usr/share/icons/hicolor/256x256/apps/nickel-browser.png"
fi

cat > "$PKG_ROOT/usr/share/applications/nickel-browser.desktop" << 'DESKTOP'
[Desktop Entry]
Version=1.0
Name=Nickel Browser
GenericName=Web Browser
Comment=Block Everything. Leak Nothing. Own Your Web.
Exec=/opt/nickel-browser/nickel-browser %U
Icon=nickel-browser
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Terminal=false
DESKTOP

DEB_SIZE=$(du -sk "$PKG_ROOT/opt" | cut -f1)
cat > "$PKG_ROOT/DEBIAN/control" << EOF
Package: nickel-browser
Version: ${NICKEL_VERSION}+chromium${CHROMIUM_VER}
Architecture: amd64
Section: web
Priority: optional
Installed-Size: ${DEB_SIZE}
Depends: libgtk-3-0 (>= 3.24), libnss3 (>= 3.26), libxss1, libasound2, libxtst6, libatk1.0-0, libxcomposite1, libxdamage1, libxrandr2, libxfixes3, libdrm2, libgbm1, libpulse0
Recommends: xdg-utils
Maintainer: Nickel Browser Team <team@nickel-browser.org>
Homepage: https://github.com/Nickel-Browser/Nickel-Browser
Description: Nickel Browser — Privacy-first Chromium fork
 Block Everything. Leak Nothing. Own Your Web.
 .
 Built on ungoogled-chromium with source-level ad blocking, built-in
 Tor private tabs, fingerprint protection, and zero telemetry.
EOF

cat > "$PKG_ROOT/DEBIAN/postinst" << 'POSTINST'
#!/bin/sh
set -e
update-desktop-database /usr/share/applications 2>/dev/null || true
gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true
echo "✅ Nickel Browser installed!"
POSTINST
chmod 755 "$PKG_ROOT/DEBIAN/postinst"

DEB_NAME="nickel-browser_${NICKEL_VERSION}+chromium${CHROMIUM_VER}_amd64.deb"
dpkg-deb --build "$PKG_ROOT" "$NICKEL_DIR/$DEB_NAME"
ok ".deb package: $NICKEL_DIR/$DEB_NAME"

# --------------------------------------------------------------------------
step "Create portable .tar.xz"
# --------------------------------------------------------------------------
TAR_NAME="nickel-browser_${NICKEL_VERSION}+chromium${CHROMIUM_VER}_linux-x64.tar.xz"
TMP_BUNDLE=$(mktemp -d)
BUNDLE_DIR="$TMP_BUNDLE/nickel-browser-${NICKEL_VERSION}"
mkdir -p "$BUNDLE_DIR"
cp "$OUT_DIR/chrome"         "$BUNDLE_DIR/nickel-browser"
cp "$OUT_DIR/chrome_sandbox" "$BUNDLE_DIR/chrome-sandbox"
chmod 4755                   "$BUNDLE_DIR/chrome-sandbox"
for f in icudtl.dat resources.pak chrome_100_percent.pak chrome_200_percent.pak \
          snapshot_blob.bin v8_context_snapshot.bin libEGL.so libGLESv2.so; do
  [[ -f "$OUT_DIR/$f" ]] && cp "$OUT_DIR/$f" "$BUNDLE_DIR/"
done
[[ -d "$OUT_DIR/locales" ]] && cp -r "$OUT_DIR/locales" "$BUNDLE_DIR/"
cat > "$BUNDLE_DIR/nickel-browser.sh" << 'LAUNCHER'
#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$DIR/nickel-browser" "$@"
LAUNCHER
chmod +x "$BUNDLE_DIR/nickel-browser.sh"
tar -C "$TMP_BUNDLE" -cJf "$NICKEL_DIR/$TAR_NAME" "nickel-browser-${NICKEL_VERSION}"
ok ".tar.xz: $NICKEL_DIR/$TAR_NAME"

# --------------------------------------------------------------------------
step "SHA256 checksums"
# --------------------------------------------------------------------------
cd "$NICKEL_DIR"
sha256sum "$DEB_NAME" "$TAR_NAME" | tee SHA256SUMS.txt
ok "Checksums written to SHA256SUMS.txt"
fi  # DO_PACKAGE

# --------------------------------------------------------------------------
echo ""
echo "🎉 Nickel Browser build complete!"
echo ""
echo "   Binary   : $OUT_DIR/nickel-browser"
if [[ "$DO_PACKAGE" == "true" ]]; then
echo "   .deb     : $NICKEL_DIR/$DEB_NAME"
echo "   .tar.xz  : $NICKEL_DIR/$TAR_NAME"
fi
echo ""
echo "   To install locally:"
echo "     sudo dpkg -i $DEB_NAME"
echo ""
