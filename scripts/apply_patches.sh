#!/bin/bash
# Nickel Browser - Apply Patches Script (Production Grade)
# Author: FimuFixer CI Engine for Showaib Islam

set -euo pipefail

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL PATCHES START ==="

# Directories and Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NICKEL_DIR="${NICKEL_DIR:-$(cd "$SCRIPT_DIR/.." && pwd)}"
SRC_DIR="${SRC_DIR:-$HOME/nickel-src/src}"
UNGOOGLED_DIR="${UNGOOGLED_DIR:-$(cd "$SRC_DIR/.." && pwd)/ungoogled-chromium}"

echo "DEBUG: SCRIPT_DIR=$SCRIPT_DIR"
echo "DEBUG: NICKEL_DIR=$NICKEL_DIR"
echo "DEBUG: SRC_DIR=$SRC_DIR"
echo "DEBUG: UNGOOGLED_DIR=$UNGOOGLED_DIR"

# Validation
if [ ! -d "$SRC_DIR" ]; then
    echo "ERROR: Chromium source not found at $SRC_DIR. Fatal."
    exit 1
fi

cd "$SRC_DIR"

# Ensure we are in a git repository to use git apply
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "WARNING: $SRC_DIR is not a git repository. Initializing..."
    git init
    git config user.name "Nickel CI"
    git config user.email "ci@nickel-browser.org"
    git add .
    git commit -m "Initial commit of Chromium source" || true
fi

# Clone Ungoogled-Chromium if missing
if [ ! -d "$UNGOOGLED_DIR" ]; then
    echo "LOG: Ungoogled-chromium not found. Cloning..."
    git clone --depth=1 https://github.com/ungoogled-software/ungoogled-chromium.git "$UNGOOGLED_DIR"
fi

# Apply Ungoogled-Chromium patches
if [ -d "$UNGOOGLED_DIR" ]; then
    echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] APPLYING UNGOOGLED PATCHES ==="
    
    # Binary Pruning
    if [ -f "$UNGOOGLED_DIR/utils/prune_binaries.py" ]; then
        echo "LOG: Pruning binaries..."
        python3 "$UNGOOGLED_DIR/utils/prune_binaries.py" "$SRC_DIR" "$UNGOOGLED_DIR/pruning.list"
    fi
    
    # Patches
    if [ -d "$UNGOOGLED_DIR/patches" ]; then
        echo "LOG: Applying ungoogled-chromium patches..."
        python3 "$UNGOOGLED_DIR/utils/patches.py" apply "$SRC_DIR" "$UNGOOGLED_DIR/patches" || echo "WARNING: Some ungoogled patches failed to apply."
    fi

    # Domain Substitution
    if [ -f "$UNGOOGLED_DIR/utils/domain_substitution.py" ]; then
        echo "LOG: Applying domain substitution..."
        python3 "$UNGOOGLED_DIR/utils/domain_substitution.py" apply \
            -r "$UNGOOGLED_DIR/domain_regex.list" \
            -f "$UNGOOGLED_DIR/domain_substitution.list" \
            "$SRC_DIR"
    fi
fi

# Apply Nickel-specific Patches
if [ -d "$NICKEL_DIR/patches" ]; then
    echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] APPLYING NICKEL PATCHES ==="

    # Get sorted list of patches
    PATCHES=$(find "$NICKEL_DIR/patches" -name "*.patch" | sort)

    for patch in $PATCHES; do
        patch_name=$(basename "$patch")
        echo "LOG: Applying patch: $patch_name"

        if git apply --check "$patch" > /dev/null 2>&1; then
            if git apply "$patch"; then
                echo "SUCCESS: $patch_name applied."
            else
                echo "ERROR: Failed to apply $patch_name."
                exit 1
            fi
        else
            echo "SKIP: $patch_name already applied or conflicts."
        fi
    done
else
    echo "ERROR: Nickel patches directory not found. Fatal."
    exit 1
fi

# Copy Nickel source files
if [ -d "$NICKEL_DIR/src/nickel" ]; then
    echo "LOG: Merging Nickel source files..."
    cp -rv "$NICKEL_DIR/src/nickel" "$SRC_DIR/"
fi

echo "=== [$(date +'%Y-%m-%dT%H:%M:%S')] NICKEL PATCHES COMPLETE ==="
touch "$SRC_DIR/.nickel_patches_applied"
