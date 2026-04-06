#!/bin/bash
# Nickel Browser - Fetch Chromium Source (Production Grade)
# Author: FimuFixer CI Engine for Showaib Islam

set -euo pipefail

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] FETCH CHROMIUM START ==="

# Directories and Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${ROOT_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
NICKEL_DIR="${NICKEL_DIR:-$HOME/nickel-src}"
SRC_DIR="$NICKEL_DIR/src"

echo "DEBUG: SCRIPT_DIR=$SCRIPT_DIR"
echo "DEBUG: ROOT_DIR=$ROOT_DIR"
echo "DEBUG: NICKEL_DIR=$NICKEL_DIR"
echo "DEBUG: SRC_DIR=$SRC_DIR"

# Check depot_tools
if ! command -v fetch &> /dev/null; then
    echo "ERROR: depot_tools not found in PATH. Fatal."
    exit 1
fi

mkdir -p "$NICKEL_DIR"
cd "$NICKEL_DIR"

# Check available disk space
AVAILABLE_KB=$(df -k "$NICKEL_DIR" | awk 'NR==2 {print $4}')
AVAILABLE_GB=$((AVAILABLE_KB / 1024 / 1024))
echo "LOG: Available disk space: ${AVAILABLE_GB}GB"

# Handle existing source
if [ -d "$SRC_DIR" ]; then
    echo "LOG: Chromium source already exists at $SRC_DIR"
    if [ -n "${CI:-}" ]; then
        echo "LOG: CI environment detected. Using existing source."
    else
        read -p "Re-fetch? This will delete the existing source. (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "LOG: Removing existing source..."
            rm -rf "$SRC_DIR"
        else
            echo "LOG: Using existing source."
            exit 0
        fi
    fi
fi

# Fetch Chromium
if [ ! -d "$SRC_DIR" ]; then
    echo "LOG: Fetching Chromium source code..."
    # In CI, we definitely don't want tmux or interactivity
    if [ -n "${CI:-}" ]; then
        fetch --nohooks --no-history chromium
    else
        # Use tmux if available to prevent interruption (local only)
        if command -v tmux &> /dev/null; then
            echo "LOG: Using tmux session 'nickel-fetch'..."
            tmux new-session -d -s nickel-fetch "fetch --nohooks --no-history chromium && echo 'Fetch complete!'"
            tmux attach -t nickel-fetch
        else
            fetch --nohooks --no-history chromium
        fi
    fi
fi

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] FETCH CHROMIUM COMPLETE ==="
