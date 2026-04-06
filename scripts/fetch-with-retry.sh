#!/bin/bash
# Nickel Browser - Fetch Source with Retries
set -e

PLATFORM=$1
VERSION=$2
NICKEL_DIR=$3

echo "=== STEP START: Fetch Chromium Source ($PLATFORM) ==="

MAX_RETRIES=3
RETRY_DELAY=10

fetch_with_retry() {
    local attempt=1
    while [ $attempt -le $MAX_RETRIES ]; do
        echo "Attempt $attempt of $MAX_RETRIES..."
        if "$@"; then
            return 0
        fi
        echo "Attempt $attempt failed. Retrying in $RETRY_DELAY seconds..."
        sleep $RETRY_DELAY
        attempt=$((attempt + 1))
        RETRY_DELAY=$((RETRY_DELAY * 2))
    done
    return 1
}

mkdir -p "$NICKEL_DIR"
cd "$NICKEL_DIR"

if [ ! -d "src" ]; then
    echo "📥 Fetching Chromium source..."
    # If a previous attempt left a .gclient file but no src, fetch will fail
    if [ -f ".gclient" ]; then
        echo "🗑️  Removing stale .gclient file..."
        rm .gclient
    fi
    # Also remove any partial src if it exists
    rm -rf src
    fetch_with_retry fetch --nohooks --no-history chromium
fi

cd src
echo "🔄 Syncing source..."
fetch_with_retry gclient sync --with_branch_heads --with_tags -D --no-history
echo "🔧 Running hooks..."
fetch_with_retry gclient runhooks

echo "=== STEP END: Fetch Chromium Source ($PLATFORM) ==="
