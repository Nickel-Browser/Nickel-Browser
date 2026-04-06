#!/bin/bash
# Nickel Browser - Build .rpm Package (Production Grade)
# Author: FimuFixer CI Engine for Showaib Islam

set -euo pipefail

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL RPM BUILD START ==="

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# Default SRC_DIR if not set
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

# Create RPM build structure
RPM_ROOT="$(pwd)/rpmbuild"
mkdir -p "$RPM_ROOT"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Create desktop entry file
cat > "$RPM_ROOT/SOURCES/nickel-browser.desktop" << 'EOF'
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

# Create spec file
echo "LOG: Creating spec file..."
cat > "$RPM_ROOT/SPECS/nickel-browser.spec" << EOF
Name:           nickel-browser
Version:        ${VERSION//-/_}
Release:        1%{?dist}
Summary:        Privacy-first Chromium fork
License:        MIT and GPLv3
URL:            https://nickel-browser.org

Requires:       gtk3, nss, libXScrnSaver, alsa-lib, libXtst, atk, libXcomposite, libXdamage, libXrandr, libXfixes

%description
Block Everything. Leak Nothing. Own Your Web.
Nickel Browser is a privacy-first Chromium fork with native adblocking,
built-in Tor, VPN integration, fingerprint protection, and zero telemetry.

%install
mkdir -p %{buildroot}/opt/nickel-browser
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/bin
cp -r ${BUILD_DIR}/* %{buildroot}/opt/nickel-browser/
cp ${RPM_ROOT}/SOURCES/nickel-browser.desktop %{buildroot}/usr/share/applications/
ln -sf /opt/nickel-browser/chrome %{buildroot}/usr/bin/nickel-browser

%files
/opt/nickel-browser/
/usr/share/applications/nickel-browser.desktop
/usr/bin/nickel-browser

%post
update-desktop-database /usr/share/applications 2>/dev/null || true

%changelog
* $(date +"%a %b %d %Y") Nickel Browser Team <team@nickel-browser.org> - ${VERSION}-1
- Initial RPM release
EOF

# Build with rpmbuild
echo "LOG: Running rpmbuild..."
if command -v rpmbuild &> /dev/null; then
    rpmbuild -bb "$RPM_ROOT/SPECS/nickel-browser.spec" --define "_topdir $RPM_ROOT"
    cp "$RPM_ROOT"/RPMS/x86_64/*.rpm .
else
    echo "WARNING: rpmbuild not available. Skipping RPM creation."
fi

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL RPM BUILD COMPLETE ==="
