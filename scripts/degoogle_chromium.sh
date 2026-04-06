#!/bin/bash
# Nickel Browser - Degoogle Chromium Script
# Targeted removals of Google-specific services

set -e

echo "🪙 Nickel Browser - Degoogle Chromium"
echo "====================================="
echo ""

SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"

if [ ! -d "$SRC_DIR" ]; then
    echo "❌ Error: Chromium source not found at $SRC_DIR"
    exit 1
fi

cd "$SRC_DIR"

echo "🗑️  Hard-disabling Google API keys..."
find . -type f \( -name "*.gn" -o -name "*.gni" -o -name "*.cc" \) -exec sed -i 's/use_official_google_api_keys = true/use_official_google_api_keys = false/g' {} + 2>/dev/null || true
find . -type f \( -name "*.gn" -o -name "*.gni" \) -exec sed -i 's/google_api_key = ".*"/google_api_key = ""/g' {} + 2>/dev/null || true

echo "🚫 Disabling Safe Browsing & Metrics..."
find components/safe_browsing -type f -name "*.cc" -exec sed -i 's/kSafeBrowsingEnabledByDefault = true/kSafeBrowsingEnabledByDefault = false/g' {} + 2>/dev/null || true
find components/metrics -type f -name "*.cc" -exec sed -i 's/kMetricsReportingEnabledByDefault = true/kMetricsReportingEnabledByDefault = false/g' {} + 2>/dev/null || true

echo "🔎 Localizing search defaults..."
find components/search_engines -type f -name "*.cc" -exec sed -i 's/kSearchSuggestEnabledByDefault = true/kSearchSuggestEnabledByDefault = false/g' {} + 2>/dev/null || true

echo "🛡️  Disabling Domain Reliability..."
find components/domain_reliability -type f \( -name "*.gn" -o -name "*.gni" \) -exec sed -i 's/enable_domain_reliability = true/enable_domain_reliability = false/g' {} + 2>/dev/null || true

echo "🔗 Disabling Preconnect..."
find components/navigation_preconnect -type f -name "*.cc" -exec sed -i 's/kPreconnectEnabledByDefault = true/kPreconnectEnabledByDefault = false/g' {} + 2>/dev/null || true

echo "✅ Degoogling complete!"
