#!/bin/bash
# Nickel Browser - Install Dependencies (Windows)
set -e

echo "=== STEP START: Install Dependencies (Windows) ==="

choco install ninja jq nsis -y
pip install pillow pyyaml

echo "=== STEP END: Install Dependencies (Windows) ==="
