#!/bin/bash
# Nickel Browser - Build .dmg Package (Production Grade)
# Author: FimuFixer CI Engine for Showaib Islam

set -euo pipefail

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL DMG BUILD START ==="

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

# Create app bundle structure
APP_NAME="Nickel Browser.app"
APP_DIR="$BUILD_DIR/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"

echo "LOG: Creating app bundle structure..."
rm -rf "$APP_DIR"
mkdir -p "$CONTENTS_DIR/MacOS"
mkdir -p "$CONTENTS_DIR/Resources"

# Copy binary and resources
echo "LOG: Copying build artifacts to app bundle..."
cp -r "$BUILD_DIR"/* "$CONTENTS_DIR/MacOS/"

# Create Info.plist
echo "LOG: Creating Info.plist..."
cat > "$CONTENTS_DIR/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDisplayName</key>
    <string>Nickel Browser</string>
    <key>CFBundleExecutable</key>
    <string>chrome</string>
    <key>CFBundleIdentifier</key>
    <string>org.nickel-browser.app</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Nickel Browser</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$VERSION</string>
    <key>CFBundleVersion</key>
    <string>$VERSION</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Copy icon if exists
LOGO_PATH="$NICKEL_DIR/src/nickel/branding/product_logo_256.png"
if [ -f "$LOGO_PATH" ]; then
    echo "LOG: Copying icon..."
    cp "$LOGO_PATH" "$CONTENTS_DIR/Resources/app.png"
fi

# Create DMG
echo "LOG: Creating DMG..."
DMG_FILE="NickelBrowser-${VERSION}-macos.dmg"

# Use hdiutil for standard DMG creation
hdiutil create -volname "Nickel Browser" -srcfolder "$APP_DIR" -ov -format UDZO "$DMG_FILE"

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL DMG BUILD COMPLETE ==="
