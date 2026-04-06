#!/bin/bash
set -e

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BUILD_DIR="${BUILD_DIR:-out/Nickel}"

echo "📦 Building macOS .dmg package..."

# Create app bundle structure
APP_NAME="Nickel Browser.app"
APP_DIR="$BUILD_DIR/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"

mkdir -p "$CONTENTS_DIR/MacOS"
mkdir -p "$CONTENTS_DIR/Resources"

# Copy binary
cp -r "$BUILD_DIR"/* "$CONTENTS_DIR/MacOS/"

# Create Info.plist
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
cp "$NICKEL_DIR/src/nickel/branding/product_logo_256.png" "$CONTENTS_DIR/Resources/" 2>/dev/null || true

# Create DMG
create-dmg \
    --volname "Nickel Browser" \
    --volicon "$NICKEL_DIR/src/nickel/branding/product_logo_256.png" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 100 \
    --app-drop-link 450 185 \
    --icon "$APP_NAME" 150 185 \
    "NickelBrowser-${VERSION}.dmg" \
    "$APP_DIR" 2>/dev/null || echo "Creating DMG with fallback method"

# Fallback if create-dmg not available
if [ ! -f "NickelBrowser-${VERSION}.dmg" ]; then
    hdiutil create -volname "Nickel Browser" -srcfolder "$APP_DIR" -ov -format UDZO "NickelBrowser-${VERSION}.dmg"
fi

echo "✅ .dmg package created: NickelBrowser-${VERSION}.dmg"
