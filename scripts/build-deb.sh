#!/bin/bash
# scripts/build-deb.sh
# Creates a proper .deb package from the branded Nickel Browser binary

set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BINARY_DIR="${BINARY_DIR:-$NICKEL_DIR/uc-binary}"
# Target directory for package construction
PACKAGE_DIR="packaging/deb"

echo "📦 Building .deb package from binary $BINARY_DIR..."

mkdir -p "$PACKAGE_DIR/DEBIAN"
mkdir -p "$PACKAGE_DIR/opt/nickel-browser"
mkdir -p "$PACKAGE_DIR/usr/share/applications"
mkdir -p "$PACKAGE_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$PACKAGE_DIR/usr/bin"

# Copy binary files
# Find the Chromium root in the binary dir
# ungoogled-chromium portable tarballs may use 'chrome' or 'chromium' as the binary name
CHROME_ROOT=$(find "$BINARY_DIR" -maxdepth 3 \( -name "chrome" -o -name "chromium" \) -type f -print0 | xargs -r -0 dirname | head -n 1)

if [ -z "$CHROME_ROOT" ]
then
    echo "❌ Error: Could not find 'chrome' binary in $BINARY_DIR"
    exit 1
fi

echo "📍 CHROME_ROOT: $CHROME_ROOT"
cp -r "$CHROME_ROOT"/* "$PACKAGE_DIR/opt/nickel-browser/"

# Rename the main binary to nickel-browser for consistency
# ungoogled-chromium portable builds may use 'chrome' or 'chromium'
if [ -f "$PACKAGE_DIR/opt/nickel-browser/chromium" ]; then
    mv "$PACKAGE_DIR/opt/nickel-browser/chromium" "$PACKAGE_DIR/opt/nickel-browser/nickel-browser"
elif [ -f "$PACKAGE_DIR/opt/nickel-browser/chrome" ]; then
    mv "$PACKAGE_DIR/opt/nickel-browser/chrome" "$PACKAGE_DIR/opt/nickel-browser/nickel-browser"
fi

# Create desktop entry
cat > "$PACKAGE_DIR/usr/share/applications/nickel-browser.desktop" << 'EOF'
[Desktop Entry]
Version=1.0
Name=Nickel Browser
Comment=Block Everything. Leak Nothing. Own Your Web.
Exec=/opt/nickel-browser/nickel-browser %U
Icon=nickel-browser
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
Terminal=false
EOF

# Copy icon
if [ -f "$NICKEL_DIR/src/nickel/branding/product_logo_256.png" ]
then
    cp "$NICKEL_DIR/src/nickel/branding/product_logo_256.png" "$PACKAGE_DIR/usr/share/icons/hicolor/256x256/apps/nickel-browser.png"
fi

# Create symlink
ln -sf /opt/nickel-browser/nickel-browser "$PACKAGE_DIR/usr/bin/nickel-browser"

# Control file
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
cat > "$PACKAGE_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

# Update desktop database
update-desktop-database /usr/share/applications 2>/dev/null || true

# Update icon cache
gtk-update-icon-cache /usr/share/icons/hicolor 2>/dev/null || true

echo "✅ Nickel Browser installed successfully!"
EOF
chmod 755 "$PACKAGE_DIR/DEBIAN/postinst"

# Build package
dpkg-deb --build "$PACKAGE_DIR" "nickel-browser_${VERSION}_amd64.deb"

echo "✅ .deb package created: nickel-browser_${VERSION}_amd64.deb"
