#!/bin/bash
# Nickel Browser - Build AppImage (Production Grade)
# Author: FimuFixer CI Engine for Showaib Islam

set -euo pipefail

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL APPIMAGE START ==="

# Directories and Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"
BUILD_DIR="${BUILD_DIR:-$SRC_DIR/out/Nickel}"
VERSION="${NICKEL_VERSION:-1.0.0-alpha}"

echo "DEBUG: SCRIPT_DIR=$SCRIPT_DIR"
echo "DEBUG: NICKEL_DIR=$NICKEL_DIR"
echo "DEBUG: SRC_DIR=$SRC_DIR"
echo "DEBUG: BUILD_DIR=$BUILD_DIR"
echo "DEBUG: VERSION=$VERSION"

# Validation
if [ ! -d "$BUILD_DIR" ]; then
    echo "ERROR: Build directory not found at $BUILD_DIR. Fatal."
    exit 1
fi

# Download appimagetool if not present
if [ ! -f ./appimagetool ]; then
    echo "LOG: Downloading appimagetool..."
    wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
    chmod +x appimagetool
fi

# Create AppDir
rm -rf AppDir
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps

# Copy build artifacts
echo "LOG: Copying build artifacts to AppDir..."
cp -r "$BUILD_DIR"/* AppDir/usr/bin/

# Copy logo
LOGO_PATH="$NICKEL_DIR/src/nickel/branding/product_logo_256.png"
if [ -f "$LOGO_PATH" ]; then
    echo "LOG: Copying logo..."
    cp "$LOGO_PATH" AppDir/usr/share/icons/hicolor/256x256/apps/nickel-browser.png
else
    echo "WARNING: Logo not found at $LOGO_PATH."
fi

# Create desktop entry
echo "LOG: Creating desktop entry..."
cat > AppDir/nickel-browser.desktop << 'EOF'
[Desktop Entry]
Name=Nickel Browser
Exec=chrome
Icon=nickel-browser
Type=Application
Categories=Network;WebBrowser;
Comment=Block Everything. Leak Nothing. Own Your Web.
EOF

cp AppDir/nickel-browser.desktop AppDir/usr/share/applications/

# Create AppRun
echo "LOG: Creating AppRun..."
cat > AppDir/AppRun << 'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="${HERE}/usr/bin:${PATH}"
cd "${HERE}/usr/bin"
exec ./chrome "$@"
EOF
chmod +x AppDir/AppRun

# Build AppImage
echo "LOG: Running appimagetool..."
# Disable FUSE requirement for building in CI
export APPIMAGE_EXTRACT_AND_RUN=1
./appimagetool AppDir "NickelBrowser-${VERSION}.AppImage"

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL APPIMAGE COMPLETE ==="
