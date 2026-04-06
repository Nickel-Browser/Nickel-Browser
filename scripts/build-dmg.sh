#!/bin/bash
# Nickel Browser - Build macOS .dmg Package
set -e

echo "=== STEP START: Build macOS .dmg Package ==="

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# Default SRC_DIR if not set
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"

VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BUILD_DIR="${SRC_DIR}/out/Release"

if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ Error: Nickel build not found at $BUILD_DIR"
    exit 1
fi

cd "$SRC_DIR"

echo "📂 Creating macOS .dmg package structure..."
APP_NAME="Nickel Browser.app"
APP_DIR="$BUILD_DIR/$APP_NAME"
CONTENTS_DIR="$APP_DIR/Contents"

mkdir -p "$CONTENTS_DIR/MacOS"
mkdir -p "$CONTENTS_DIR/Resources"

echo "📁 Copying binaries..."
cp -r "$BUILD_DIR"/* "$CONTENTS_DIR/MacOS/"

echo "📝 Creating Info.plist..."
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

echo "🎨 Copying branding..."
cp "$NICKEL_DIR/src/nickel/branding/product_logo_256.png" "$CONTENTS_DIR/Resources/" 2>/dev/null || true

echo "📦 Creating .dmg package..."
# Fallback method
hdiutil create -volname "Nickel Browser" -srcfolder "$APP_DIR" -ov -format UDZO "NickelBrowser-${VERSION}.dmg"

echo "✅ .dmg package created: NickelBrowser-${VERSION}.dmg"
echo "=== STEP END: Build macOS .dmg Package ==="
