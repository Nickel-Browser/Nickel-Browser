#!/bin/bash
set -e

VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BUILD_DIR="${BUILD_DIR:-out/Nickel}"
PACKAGE_DIR="packaging/deb"

echo "📦 Building .deb package..."

mkdir -p "$PACKAGE_DIR/DEBIAN"
mkdir -p "$PACKAGE_DIR/opt/nickel-browser"
mkdir -p "$PACKAGE_DIR/usr/share/applications"
mkdir -p "$PACKAGE_DIR/usr/share/icons/hicolor/256x256/apps"
mkdir -p "$PACKAGE_DIR/usr/bin"

# Copy binary
cp -r "$BUILD_DIR"/* "$PACKAGE_DIR/opt/nickel-browser/"

# Create desktop entry
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
cp src/nickel/branding/product_logo_256.png "$PACKAGE_DIR/usr/share/icons/hicolor/256x256/apps/nickel-browser.png" 2>/dev/null || true

# Create symlink
ln -sf /opt/nickel-browser/chrome "$PACKAGE_DIR/usr/bin/nickel-browser"

# Control file
cat > "$PACKAGE_DIR/DEBIAN/control" << EOF
Package: nickel-browser
Version: $VERSION
Section: web
Priority: optional
Architecture: amd64
Depends: libgtk-3-0, libnss3, libxss1, libasound2, libxtst6, libatk1.0-0, libxcomposite1, libxdamage1, libxrandr2, libxfixes3
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
