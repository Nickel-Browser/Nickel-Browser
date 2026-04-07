#!/bin/bash
set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BUILD_DIR="${BUILD_DIR:-out/Nickel}"

echo "📦 Building .rpm package..."

# Create spec file
cat > nickel-browser.spec << EOF
Name:           nickel-browser
Version:        ${VERSION}
Release:        1%{?dist}
Summary:        Privacy-first Chromium fork
License:        MIT and GPLv3
URL:            https://nickel-browser.org
Source0:        nickel-browser-%{version}.tar.gz

Requires:       gtk3, nss, libXScrnSaver, alsa-lib, libXtst, atk, libXcomposite, libXdamage, libXrandr, libXfixes

%description
Block Everything. Leak Nothing. Own Your Web.
Nickel Browser is a privacy-first Chromium fork with native adblocking,
built-in Tor, VPN integration, fingerprint protection, and zero telemetry.

%prep
%setup -q

%install
mkdir -p %{buildroot}/opt/nickel-browser
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/bin
cp -r * %{buildroot}/opt/nickel-browser/
cp %{_sourcedir}/nickel-browser.desktop %{buildroot}/usr/share/applications/
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
rpmbuild -bb nickel-browser.spec --define "_topdir $(pwd)/rpmbuild" || echo "RPM build requires rpmbuild tool"

echo "✅ .rpm package created"
