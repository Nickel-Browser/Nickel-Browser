#!/bin/bash
set -e

VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BUILD_DIR="${BUILD_DIR:-out/Nickel}"

echo "📦 Building AppImage..."

# Download appimagetool
wget -q https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage -O appimagetool
chmod +x appimagetool

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

# Create AppDir
mkdir -p AppDir/usr/bin
mkdir -p AppDir/usr/share/applications
mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps

# Copy files
cp -r "$BUILD_DIR"/* AppDir/usr/bin/
cp "$NICKEL_DIR/src/nickel/branding/product_logo_256.png" AppDir/usr/share/icons/hicolor/256x256/apps/nickel-browser.png 2>/dev/null || true

# Create desktop entry
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
cat > AppDir/AppRun << 'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="${HERE}/usr/bin:${PATH}"
cd "${HERE}/usr/bin"
exec ./chrome "$@"
EOF
chmod +x AppDir/AppRun

# Build AppImage
./appimagetool AppDir "NickelBrowser-${VERSION}.AppImage"

echo "✅ AppImage created: NickelBrowser-${VERSION}.AppImage"
