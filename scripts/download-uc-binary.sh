#!/bin/bash
# scripts/download-uc-binary.sh
# Downloads the correct ungoogled-chromium binary for the current platform and version

set -euo pipefail

PLATFORM=$1
VERSION=$2
TARGET_DIR=${3:-"uc-binary"}

if [ -z "$PLATFORM" ] || [ -z "$VERSION" ]
then
    echo "Usage: $0 <platform> <version> [target_dir]"
    echo "Platforms: linux, windows, macos"
    exit 1
fi

echo "🔍 Searching for ungoogled-chromium $VERSION for $PLATFORM..."

# Mapping for platform-specific repositories and asset patterns
case $PLATFORM in
    linux)
        REPO="ungoogled-software/ungoogled-chromium-portablelinux"
        ASSET_PATTERN="x86_64_linux.tar.xz"
        ;;
    windows)
        REPO="ungoogled-software/ungoogled-chromium-windows"
        ASSET_PATTERN="windows_x64.zip"
        ;;
    macos)
        REPO="ungoogled-software/ungoogled-chromium-macos"
        ASSET_PATTERN="x86_64-macos.dmg"
        ;;
    *)
        echo "❌ Unknown platform: $PLATFORM"
        exit 1
        ;;
esac

# Build curl auth flags (avoid eval — pass as an array for safety)
# Security: enforce HTTPS + fail-closed downloads (Secure Transport / Fail Safe).
CURL_AUTH=()
if [ -n "${GITHUB_TOKEN:-}" ]; then
    CURL_AUTH=(-H "Authorization: token ${GITHUB_TOKEN}")
fi

CURL_OPTS=(-sSL --fail --proto '=https' --retry 3 --connect-timeout 30 --max-time 600)

# Determine if we should use 'latest' or a specific tag
# Note: tags might slightly differ between repos (e.g. 146.0.7680.177-1 vs 146.0.7680.177-1.1)
# We'll try to find a release that starts with the base version.

echo "📡 Fetching releases from $REPO..."
RELEASES_URL="https://api.github.com/repos/$REPO/releases"
RELEASE_DATA=$(curl "${CURL_OPTS[@]}" ${CURL_AUTH:+"${CURL_AUTH[@]}"} "$RELEASES_URL")

# Check if RELEASE_DATA is a valid JSON array
if [ -z "$RELEASE_DATA" ] || ! echo "$RELEASE_DATA" | jq -e 'type == "array"' > /dev/null; then
    echo "❌ Error: Failed to fetch release data from $REPO (expected JSON array)"
    echo "Response snippet: $(echo "$RELEASE_DATA" | head -c 500)"
    exit 1
fi

# Find the best matching release tag
# If VERSION is 'latest', just get the first one.
# Otherwise, look for a tag that contains our version string.
if [ "$VERSION" = "latest" ]
then
    TARGET_TAG=$(echo "$RELEASE_DATA" | jq -r '.[0].tag_name')
else
    # Match version (e.g. 146.0.7680.177)
    BASE_VERSION=$(echo "$VERSION" | cut -d'-' -f1)
    TARGET_TAG=$(echo "$RELEASE_DATA" | jq -r ".[] | select(.tag_name | contains(\"$BASE_VERSION\")) | .tag_name" | head -n 1)
fi

if [ -z "$TARGET_TAG" ] || [ "$TARGET_TAG" = "null" ]
then
    echo "❌ Could not find a matching release for version $VERSION in $REPO"
    exit 1
fi

echo "✅ Found matching release: $TARGET_TAG"

# Get the specific release data
API_URL="https://api.github.com/repos/$REPO/releases/tags/$TARGET_TAG"
RELEASE_DATA=$(curl "${CURL_OPTS[@]}" ${CURL_AUTH:+"${CURL_AUTH[@]}"} "$API_URL")

if [ -z "$RELEASE_DATA" ] || [ "$(echo "$RELEASE_DATA" | jq '.assets')" = "null" ]; then
    echo "❌ Error: Failed to fetch assets for release $TARGET_TAG"
    exit 1
fi

# Extract asset URL
ASSET_URL=$(echo "$RELEASE_DATA" | jq -r ".assets[] | select(.name | contains(\"$ASSET_PATTERN\")) | .browser_download_url" | head -n 1)

if [ -z "$ASSET_URL" ] || [ "$ASSET_URL" = "null" ]
then
    echo "❌ Could not find asset matching $ASSET_PATTERN in release $TARGET_TAG"
    exit 1
fi

ASSET_NAME=$(basename "$ASSET_URL")
SUMS_URL=$(echo "$RELEASE_DATA" | jq -r '.assets[] | select(.name | test(\"SHA256SUMS|sha256sums\"; \"i\")) | .browser_download_url' | head -n 1)

if [ -z "$SUMS_URL" ] || [ "$SUMS_URL" = "null" ]; then
    echo "❌ Could not find SHA256SUMS in release assets (integrity verification required)."
    exit 1
fi
mkdir -p "$TARGET_DIR"

echo "⬇️  Downloading $ASSET_NAME..."
curl "${CURL_OPTS[@]}" --max-time 1800 "$ASSET_URL" -o "$TARGET_DIR/$ASSET_NAME"

echo "⬇️  Downloading SHA256SUMS..."
curl "${CURL_OPTS[@]}" --max-time 300 "$SUMS_URL" -o "$TARGET_DIR/SHA256SUMS"

# Verify download (check if file size > 0)
if [ ! -s "$TARGET_DIR/$ASSET_NAME" ]
then
    echo "❌ Download failed or file is empty."
    exit 1
fi

# Security: verify checksum before use (Integrity / Trust but Verify).
if command -v sha256sum >/dev/null 2>&1; then
    CHECKSUM_CMD="sha256sum"
else
    CHECKSUM_CMD="shasum -a 256"
fi

EXPECTED_SUM=$(grep " $ASSET_NAME\$" "$TARGET_DIR/SHA256SUMS" | head -n 1 | awk '{print $1}')
if [ -z "$EXPECTED_SUM" ]; then
    echo "❌ SHA256SUMS missing entry for $ASSET_NAME"
    exit 1
fi

ACTUAL_SUM=$($CHECKSUM_CMD "$TARGET_DIR/$ASSET_NAME" | awk '{print $1}')
if [ "$EXPECTED_SUM" != "$ACTUAL_SUM" ]; then
    echo "❌ Checksum verification failed for $ASSET_NAME"
    echo "Expected: $EXPECTED_SUM"
    echo "Actual:   $ACTUAL_SUM"
    exit 1
fi
echo "✅ SHA256 checksum verified for $ASSET_NAME"

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

echo "✅ Success: $PLATFORM binary for $VERSION downloaded and prepared in $TARGET_DIR"
