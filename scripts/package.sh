#!/bin/bash
# Nickel Browser - Package Script
# Creates distribution packages for Linux (.deb, AppImage)

set -e

echo "🪙 Nickel Browser - Package Script"
echo "==================================="
echo ""

NICKEL_DIR="$HOME/nickel-build"
SRC_DIR="$NICKEL_DIR/src"
VERSION="1.0.0"

# Check if built
if [ ! -f "$SRC_DIR/out/Nickel/chrome" ]; then
    echo "❌ Error: Nickel Browser not built yet"
    echo "   Please run: ./scripts/build.sh"
    exit 1
fi

cd "$SRC_DIR"

# Create output directory
mkdir -p "$NICKEL_DIR/packages"

echo "📦 Creating packages..."
echo ""

# ===== Linux .deb Package =====
echo "🔧 Creating .deb package..."

mkdir -p nickel-deb/DEBIAN
mkdir -p nickel-deb/opt/nickel-browser
mkdir -p nickel-deb/usr/share/applications
mkdir -p nickel-deb/usr/share/icons/hicolor/{16x16,32x32,48x48,128x128,256x256}/apps

# Copy build output
cp -r out/Nickel/* nickel-deb/opt/nickel-browser/

# Create control file
cat > nickel-deb/DEBIAN/control << EOF
Package: nickel-browser
Version: $VERSION
Section: web
Priority: optional
Architecture: amd64
Depends: libnss3, libgtk-3-0, libasound2, libxss1, libgbm1, libgl1, tor, wireguard-tools
Recommends: hunspell-en-us
Maintainer: Nickel Browser Team <team@nickel-browser.org>
Homepage: https://nickel-browser.org
Description: Nickel Browser - Privacy-First Web Browser
 Nickel Browser is a privacy-first, community-driven browser
 built on ungoogled-chromium with nuclear-grade ad blocking,
 built-in Tor & VPN, and comprehensive fingerprint protection.
 .
 Features:
  - Zero telemetry or data collection
  - Built-in ad and tracker blocking
  - Tor private tabs
  - VPN integration (WireGuard/OpenVPN)
  - Fingerprint protection
  - DuckDuckGo default search
EOF

# Create postinst script
cat > nickel-deb/DEBIAN/postinst << 'EOF'
#!/bin/bash
set -e

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f /usr/share/icons/hicolor
fi

# Set capabilities for sandbox (if supported)
if command -v setcap &> /dev/null; then
    setcap cap_sys_admin,cap_sys_chroot+ep /opt/nickel-browser/chrome 2>/dev/null || true
fi

echo "Nickel Browser $VERSION installed successfully!"
EOF
chmod 755 nickel-deb/DEBIAN/postinst

# Create prerm script
cat > nickel-deb/DEBIAN/prerm << 'EOF'
#!/bin/bash
set -e

# Clean up any running processes
pkill -f "nickel-browser" 2>/dev/null || true
EOF
chmod 755 nickel-deb/DEBIAN/prerm

# Create desktop entry
cat > nickel-deb/usr/share/applications/nickel-browser.desktop << EOF
[Desktop Entry]
Version=1.0
Name=Nickel Browser
GenericName=Web Browser
Comment=Privacy-First Web Browser
Exec=/opt/nickel-browser/chrome %U
Icon=nickel-browser
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;text/plain;text/mml;application/x-xpinstall;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
StartupWMClass=nickel-browser
Actions=NewWindow;NewPrivateWindow;NewTorWindow;

[Desktop Action NewWindow]
Name=New Window
Exec=/opt/nickel-browser/chrome --new-window

[Desktop Action NewPrivateWindow]
Name=New Private Window
Exec=/opt/nickel-browser/chrome --incognito

[Desktop Action NewTorWindow]
Name=New Tor Window
Exec=/opt/nickel-browser/chrome --tor
EOF

# Copy icons
if [ -d "nickel/branding" ]; then
    cp nickel/branding/product_logo_16.png nickel-deb/usr/share/icons/hicolor/16x16/apps/nickel-browser.png 2>/dev/null || true
    cp nickel/branding/product_logo_32.png nickel-deb/usr/share/icons/hicolor/32x32/apps/nickel-browser.png 2>/dev/null || true
    cp nickel/branding/product_logo_48.png nickel-deb/usr/share/icons/hicolor/48x48/apps/nickel-browser.png 2>/dev/null || true
    cp nickel/branding/product_logo_128.png nickel-deb/usr/share/icons/hicolor/128x128/apps/nickel-browser.png 2>/dev/null || true
    cp nickel/branding/product_logo_256.png nickel-deb/usr/share/icons/hicolor/256x256/apps/nickel-browser.png 2>/dev/null || true
fi

# Build .deb package
dpkg-deb --build nickel-deb "$NICKEL_DIR/packages/nickel-browser_${VERSION}_amd64.deb"

echo "  ✅ .deb package created"
echo ""

# ===== AppImage =====
echo "🔧 Creating AppImage..."

# Check for appimagetool
if command -v appimagetool &> /dev/null; then
    mkdir -p nickel-appimage/AppDir
    mkdir -p nickel-appimage/AppDir/usr/bin
    mkdir -p nickel-appimage/AppDir/usr/share/applications
    mkdir -p nickel-appimage/AppDir/usr/share/icons/hicolor/256x256/apps
    
    # Copy files
    cp -r out/Nickel/* nickel-appimage/AppDir/usr/bin/
    
    # Create desktop entry
    cat > nickel-appimage/AppDir/nickel-browser.desktop << EOF
[Desktop Entry]
Name=Nickel Browser
Exec=nickel-browser
Icon=nickel-browser
Type=Application
Categories=Network;WebBrowser;
EOF
    
    # Copy icon
    if [ -f "nickel/branding/product_logo_256.png" ]; then
        cp nickel/branding/product_logo_256.png nickel-appimage/AppDir/nickel-browser.png
    fi
    
    # Create AppRun
    cat > nickel-appimage/AppDir/AppRun << 'EOF'
#!/bin/bash
HERE="$(dirname "$(readlink -f "${0}")")"
export PATH="${HERE}/usr/bin:${PATH}"
cd "${HERE}/usr/bin"
exec ./chrome "$@"
EOF
    chmod +x nickel-appimage/AppDir/AppRun
    
    # Build AppImage
    cd nickel-appimage
    appimagetool AppDir "$NICKEL_DIR/packages/Nickel-Browser-${VERSION}-x86_64.AppImage"
    cd ..
    
    echo "  ✅ AppImage created"
else
    echo "  ⚠️  appimagetool not found, skipping AppImage"
    echo "     Install from: https://github.com/AppImage/AppImageKit"
fi

echo ""

# ===== Summary =====
echo "✅ Packaging complete!"
echo ""
echo "📦 Packages created:"
echo ""

for pkg in "$NICKEL_DIR/packages"/*; do
    if [ -f "$pkg" ]; then
        size=$(du -h "$pkg" | cut -f1)
        echo "  📄 $(basename $pkg) ($size)"
    fi
done

echo ""
echo "📁 Location: $NICKEL_DIR/packages/"
echo ""
echo "Next steps:"
echo "  - Test the package: sudo dpkg -i nickel-browser_${VERSION}_amd64.deb"
echo "  - Or run AppImage: ./Nickel-Browser-${VERSION}-x86_64.AppImage"
echo ""
