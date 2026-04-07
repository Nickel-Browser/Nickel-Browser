#!/bin/bash
# Nickel Browser - Fetch Chromium Source
# Downloads the Chromium source code (~35GB)

set -e

echo "🪙 Nickel Browser - Fetch Chromium Source"
echo "========================================="
echo ""

# Check depot_tools
if ! command -v fetch &> /dev/null; then
    echo "❌ Error: depot_tools not found in PATH"
    echo "   Please run: source ~/.bashrc"
    echo "   Or add to PATH: export PATH=\"\$HOME/depot_tools:\$PATH\""
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Nickel directory is the parent of the scripts directory
ROOT_DIR="${ROOT_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
# Default NICKEL_DIR if not set (where Chromium source will live)
NICKEL_DIR="${NICKEL_DIR:-$HOME/nickel-src}"

mkdir -p "$NICKEL_DIR"
cd "$NICKEL_DIR"

echo "📁 Working directory: $NICKEL_DIR"
echo ""

# Check available disk space
AVAILABLE_KB=$(df -k "$NICKEL_DIR" | awk 'NR==2 {print $4}')
AVAILABLE_GB=$((AVAILABLE_KB / 1024 / 1024))

echo "💾 Available disk space: ${AVAILABLE_GB}GB"
echo "📦 Required: ~100GB"
echo ""

if [ "$AVAILABLE_GB" -lt 100 ]; then
    echo "⚠️  Warning: You may not have enough disk space."
    echo "   Recommended: 100GB+ for Chromium source + build"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if already fetched
if [ -d "$NICKEL_DIR/src" ]; then
    echo "📂 Chromium source already exists at $NICKEL_DIR/src"
    read -p "Re-fetch? This will delete the existing source. (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing existing source..."
        rm -rf "$NICKEL_DIR/src"
    else
        echo "Using existing source."
        exit 0
    fi
fi

# Fetch Chromium
echo ""
echo "📥 Fetching Chromium source code..."
echo "   This will download ~35GB and may take 30-60 minutes."
echo "   Time for a coffee break! ☕"
echo ""

# Use tmux if available to prevent interruption
if command -v tmux &> /dev/null; then
    echo "💡 Tip: Using tmux to prevent interruption on disconnect"
    echo "   To detach: Ctrl+B then D"
    echo "   To reattach: tmux attach -t nickel-fetch"
    echo ""
    
    # Check if session already exists
    if tmux has-session -t nickel-fetch 2>/dev/null; then
        echo "⚠️  tmux session 'nickel-fetch' already exists"
        echo "   Attach with: tmux attach -t nickel-fetch"
        exit 1
    fi
    
    # Create new tmux session
    tmux new-session -d -s nickel-fetch "
        echo '📥 Starting fetch in tmux session...'
        fetch --nohooks --no-history chromium
        echo ''
        echo '✅ Fetch complete!'
        echo 'Next steps:'
        echo '  1. cd src'
        echo '  2. ./build/install-build-deps.sh'
        echo '  3. gclient runhooks'
        read -p 'Press Enter to exit...'
    "
    
    echo "🖥️  tmux session 'nickel-fetch' created"
    echo "   Attaching now..."
    echo ""
    tmux attach -t nickel-fetch
else
    # Fetch without tmux
    fetch --nohooks --no-history chromium
fi

echo ""
echo "✅ Fetch complete!"
echo ""
echo "Next steps:"
echo "  1. cd $NICKEL_DIR/src"
echo "  2. ./build/install-build-deps.sh"
echo "  3. gclient runhooks"
echo "  4. cd .. && ./scripts/apply-patches.sh"
echo ""
