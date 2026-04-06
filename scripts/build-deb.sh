#!/bin/bash
# Nickel Browser - Build .deb Package (Production Grade)
# Author: FimuFixer CI Engine for Showaib Islam

set -euo pipefail

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL DEB BUILD START ==="

# Directories and Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"
BUILD_DIR="${BUILD_DIR:-$SRC_DIR/out/Nickel}"
VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
PACKAGE_DIR="packaging/deb"

echo "DEBUG: SCRIPT_DIR=$SCRIPT_DIR"
echo "DEBUG: NICKEL_DIR=$NICKEL_DIR"
echo "DEBUG: SRC_DIR=$SRC_DIR"
echo "DEBUG: BUILD_DIR=$BUILD_DIR"
echo "DEBUG: VERSION=$VERSION"
echo "DEBUG: PACKAGE_DIR=$PACKAGE_DIR"

# Validation
if [ ! -d "$BUILD_DIR" ]; then
    echo "ERROR: Build directory not found at $BUILD_DIR. Fatal."
    exit 1
fi

rm -rf "$PACKAGE_DIR"
mkdir -p "$PACKAGE_DIR/DEBIAN"
mkdir -p "$PACKAGE_DIR/opt/nickel-browser"
mkdir -p "$PACKAGE_DIR/usr/share/applications"
mkdir -p "$PACKAGE_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$PACKAGE_DIR/usr/bin"

# Copy binary
echo "LOG: Copying build artifacts to package dir..."
cp -r "$BUILD_DIR"/* "$PACKAGE_DIR/opt/nickel-browser/"

# Create desktop entry
echo "LOG: Creating desktop entry..."
cat > "$PACKAGE_DIR/usr/share/applications/nickel-browser.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Name=Nickel Browser
Comment=Block Everything. Leak Nothing. Own Your Web.
Exec=/opt/nickel-browser/chrome %U
Icon=nickel-browser
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Terminal=false
EOF

# Copy icon
LOGO_PATH="$NICKEL_DIR/src/nickel/branding/product_logo_256.png"
if [ -f "$LOGO_PATH" ]; then
    echo "LOG: Copying icon..."
    cp "$LOGO_PATH" "$PACKAGE_DIR/usr/share/icons/hicolor/256x256/apps/nickel-browser.png"
fi

# Create symlink
echo "LOG: Creating symlink..."
ln -sf /opt/nickel-browser/chrome "$PACKAGE_DIR/usr/bin/nickel-browser"

# Control file
echo "LOG: Creating control file..."
cat > "$PACKAGE_DIR/DEBIAN/control" << EOF
Package: nickel-browser
Version: $VERSION
Section: web
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libnss3, libxss1, libasound2, libxtst6, libatk1.0-0, libxcomposite1, libxdamage1, libxrandr2, libxfixes3, libdrm2, libgbm1
Maintainer: Nickel Browser Team <team@nickel-browser.org>
Description: Nickel Browser - Privacy-first Chromium fork
 Block Everything. Leak Nothing. Own Your Web.
 Nickel Browser is a privacy-first Chromium fork with native adblocking,
 built-in Tor, VPN integration, fingerprint protection, and zero telemetry.
EOF

# Postinst script
echo "LOG: Creating postinst script..."
cat > "$PACKAGE_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e
update-desktop-database /usr/share/applications 2>/dev/null || true
gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true
echo "✅ Nickel Browser installed successfully!"
EOF
chmod 755 "$PACKAGE_DIR/DEBIAN/postinst"

# Build package
echo "LOG: Building .deb package..."
dpkg-deb --build "$PACKAGE_DIR" "nickel-browser_${VERSION}_amd64.deb"

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL DEB BUILD COMPLETE ==="
