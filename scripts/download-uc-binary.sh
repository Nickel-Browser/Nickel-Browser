#!/bin/bash
# scripts/download-uc-binary.sh
# Downloads the correct ungoogled-chromium binary for the current platform and version

set -euo pipefail

PLATFORM=$1
VERSION=$2
TARGET_DIR=${3:-"uc-binary"}

if [ -z "$PLATFORM" ] || [ -z "$VERSION" ]; then
    echo "Usage: $0 <platform> <version> [target_dir]"
    echo "Platforms: linux, windows, macos"
    exit 1
fi

echo "🔍 Searching for ungoogled-chromium $VERSION for $PLATFORM..."

# Mapping for platform-specific asset patterns
case $PLATFORM in
    linux)
        ASSET_PATTERN="linux.tar.xz"
        ;;
    windows)
        ASSET_PATTERN="windows_x64.zip"
        ;;
    macos)
        ASSET_PATTERN="macos.dmg"
        ;;
    *)
        echo "❌ Unknown platform: $PLATFORM"
        exit 1
        ;;
esac

# Headers for API calls
AUTH_HEADER=""
if [ -n "${GITHUB_TOKEN:-}" ]; then
    AUTH_HEADER="-H \"Authorization: token $GITHUB_TOKEN\""
fi

# GitHub API to get release assets
API_URL="https://api.github.com/repos/ungoogled-software/ungoogled-chromium-binaries/releases/tags/$VERSION"
if [ "$VERSION" = "latest" ]; then
    API_URL="https://api.github.com/repos/ungoogled-software/ungoogled-chromium-binaries/releases/latest"
fi

# Execute curl with optional auth header
RELEASE_DATA=$(eval curl -sL $AUTH_HEADER "$API_URL")

# Check if release exists
if echo "$RELEASE_DATA" | jq -e '.message == "Not Found"' > /dev/null 2>&1; then
    echo "❌ Release $VERSION not found."
    exit 1
fi

# Extract asset URL
ASSET_URL=$(echo "$RELEASE_DATA" | jq -r ".assets[] | select(.name | contains(\"$ASSET_PATTERN\")) | .browser_download_url" | head -n 1)

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
    echo "❌ Could not find asset matching $ASSET_PATTERN for version $VERSION"
    # Fallback search if tag version is slightly different from asset filename
    echo "ℹ️  Attempting fallback search..."
    ASSET_URL=$(echo "$RELEASE_DATA" | jq -r ".assets[] | select(.name | test(\"ungoogled-chromium.*$PLATFORM\")) | .browser_download_url" | head -n 1)

    if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]; then
        echo "❌ Fallback search failed."
        exit 1
    fi
fi

ASSET_NAME=$(basename "$ASSET_URL")
mkdir -p "$TARGET_DIR"

echo "⬇️  Downloading $ASSET_NAME..."
curl -L "$ASSET_URL" -o "$TARGET_DIR/$ASSET_NAME"

# Verify download (check if file size > 0)
if [ ! -s "$TARGET_DIR/$ASSET_NAME" ]; then
    echo "❌ Download failed or file is empty."
    exit 1
fi

echo "📦 Extracting $ASSET_NAME..."
cd "$TARGET_DIR"
case $ASSET_NAME in
    *.tar.xz)
        tar -xJf "$ASSET_NAME"
        ;;
    *.zip)
        unzip -q "$ASSET_NAME"
        ;;
    *.dmg)
        echo "ℹ️  DMG downloaded. Extraction handled by platform-specific packaging script."
        ;;
esac

echo "✅ Success: $PLATFORM binary $VERSION downloaded and prepared in $TARGET_DIR"
