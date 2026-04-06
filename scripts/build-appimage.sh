#!/bin/bash
# scripts/build-appimage.sh
# Creates a portable AppImage for Nickel Browser

set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BINARY_DIR="${BINARY_DIR:-$NICKEL_DIR/uc-binary}"

echo "📦 Building AppImage from binary $BINARY_DIR..."

# Download appimagetool if not present
if [ ! -f ./appimagetool ]; then
    echo "⬇️  Downloading appimagetool..."
    wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
    chmod +x appimagetool
fi

# Create AppDir structure
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps

# Copy binary files
# Find the Chromium root in the binary dir
CHROME_ROOT=$(find "$BINARY_DIR" -maxdepth 2 -name "chrome" -type f | xargs dirname | head -n 1)

if [ -z "$CHROME_ROOT" ]; then
    echo "❌ Error: Could not find 'chrome' binary in $BINARY_DIR"
    exit 1
fi

echo "📍 CHROME_ROOT: $CHROME_ROOT"
cp -rv "$CHROME_ROOT"/* AppDir/usr/bin/

# Rename the main binary to nickel-browser for consistency
if [ -f "AppDir/usr/bin/chrome" ]; then
    mv "AppDir/usr/bin/chrome" "AppDir/usr/bin/nickel-browser"
fi

# Copy icon
if [ -f "$NICKEL_DIR/src/nickel/branding/product_logo_256.png" ]; then
    cp "$NICKEL_DIR/src/nickel/branding/product_logo_256.png" AppDir/usr/share/icons/hicolor/256x256/apps/nickel-browser.png
fi

# Create desktop entry
cat > AppDir/nickel-browser.desktop << 'EOF'
[Desktop Entry]
Name=Nickel Browser
Exec=nickel-browser
Icon=nickel-browser
Type=Application
Categories=Network;WebBrowser;
Comment=Block Everything. Leak Nothing. Own Your Web.
EOF

cp AppDir/nickel-browser.desktop AppDir/usr/share/applications/

# Create AppRun
cat > AppDir/AppRun << 'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="${HERE}/usr/bin:${PATH}"
cd "${HERE}/usr/bin"
exec ./nickel-browser "$@"
EOF
chmod +x AppDir/AppRun

# Build AppImage
# Fix for running in some environments: --appimage-extract-and-run
ARCH=x86_64 ./appimagetool AppDir "NickelBrowser-${VERSION}-x86_64.AppImage"

echo "✅ AppImage created: NickelBrowser-${VERSION}-x86_64.AppImage"
