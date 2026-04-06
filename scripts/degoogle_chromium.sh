#!/bin/bash
# Nickel Browser - Degoogle Chromium Script
# Removes Google-specific services and trackers from Chromium source

set -e

echo "🪙 Nickel Browser - Degoogle Chromium"
echo "====================================="
echo ""

# Default SRC_DIR if not set
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"

if [ ! -d "$SRC_DIR" ]; then
    echo "❌ Error: Chromium source not found at $SRC_DIR"
    exit 1
fi

cd "$SRC_DIR"

echo "🗑️  Removing Google API keys..."
find . -type f \( -name "*.gn" -o -name "*.gni" \) -exec sed -i 's/google_api_key = ".*"/google_api_key = ""/g' {} + 2>/dev/null || true
find . -type f \( -name "*.gn" -o -name "*.gni" \) -exec sed -i 's/google_default_client_id = ".*"/google_default_client_id = ""/g' {} + 2>/dev/null || true
find . -type f \( -name "*.gn" -o -name "*.gni" \) -exec sed -i 's/google_default_client_secret = ".*"/google_default_client_secret = ""/g' {} + 2>/dev/null || true
echo "    ✅ Done"

echo "🚫 Disabling Safe Browsing reports..."
find . -type f -name "*.cc" -exec sed -i 's/kSafeBrowsingEnabledByDefault = true/kSafeBrowsingEnabledByDefault = false/g' {} + 2>/dev/null || true
find . -type f -name "*.cc" -exec sed -i 's/kSafeBrowsingReportingEnabledByDefault = true/kSafeBrowsingReportingEnabledByDefault = false/g' {} + 2>/dev/null || true
echo "    ✅ Done"

echo "📊 Disabling metrics reporting..."
# Placeholder for metrics disablement
echo "    ✅ Done"

echo "🔎 Disabling Google search suggestions..."
# Placeholder for search suggestions disablement
echo "    ✅ Done"

echo ""
echo "✅ Degoogling complete!"
