#!/bin/bash
# scripts/build-dmg.sh
# Creates a macOS DMG from the downloaded ungoogled-chromium binary

set -euo pipefail

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"

VERSION="${NICKEL_VERSION:-1.0.0-alpha}"
BINARY_DIR="${BINARY_DIR:-$NICKEL_DIR/uc-binary}"
DIST_DIR="${DIST_DIR:-$NICKEL_DIR/dist}"

echo "📦 Building macOS DMG..."

mkdir -p "$DIST_DIR"

# Find the Chromium DMG file downloaded
DMG_FILE=$(find "$BINARY_DIR" -name "*.dmg" -type f | head -n 1)

if [ -z "$DMG_FILE" ]
then
    echo "❌ Error: Could not find a .dmg file in $BINARY_DIR"
    exit 1
fi

echo "📍 Found DMG: $DMG_FILE"

# Extract the DMG content to modify
# We'll use hdiutil to mount it, copy it, and then modify it
MOUNT_POINT="/Volumes/Chromium"
hdiutil attach "$DMG_FILE" -mountpoint "$MOUNT_POINT" -quiet

# Create a temporary directory for the app
TMP_DIR=$(mktemp -d)
cp -R "$MOUNT_POINT/"*.app "$TMP_DIR/Nickel Browser.app"
hdiutil detach "$MOUNT_POINT" -quiet

# Perform basic branding on the app bundle
INFO_PLIST="$TMP_DIR/Nickel Browser.app/Contents/Info.plist"
if [ -f "$INFO_PLIST" ]
then
    echo "🎨 Updating Info.plist..."
    /usr/libexec/PlistBuddy -c "Set :CFBundleName 'Nickel Browser'" "$INFO_PLIST"
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName 'Nickel Browser'" "$INFO_PLIST"
    /usr/libexec/PlistBuddy -c "Set :CFBundleExecutable 'nickel-browser'" "$INFO_PLIST"
fi

# Rename the executable
if [ -f "$TMP_DIR/Nickel Browser.app/Contents/MacOS/Chromium" ]
then
    mv "$TMP_DIR/Nickel Browser.app/Contents/MacOS/Chromium" "$TMP_DIR/Nickel Browser.app/Contents/MacOS/nickel-browser"
fi

# Replace the icon if it exists
# Typically it's app.icns
if [ -f "$NICKEL_DIR/src/nickel/branding/nickel.icns" ]
then
    echo "🎨 Replacing app icon..."
    cp "$NICKEL_DIR/src/nickel/branding/nickel.icns" "$TMP_DIR/Nickel Browser.app/Contents/Resources/app.icns"
fi

# Create a new DMG from the modified app
echo "📦 Creating final DMG..."
hdiutil create -volname "Nickel Browser" -srcfolder "$TMP_DIR" -ov -format UDZO "$DIST_DIR/Nickel-Browser-${VERSION}-macos.dmg"

# Cleanup
rm -rf "$TMP_DIR"

echo "✅ DMG prepared: Nickel-Browser-${VERSION}-macos.dmg"
