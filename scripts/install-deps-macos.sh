#!/bin/bash
# Nickel Browser - Install Dependencies (macOS)
set -e

echo "=== STEP START: Install Dependencies (macOS) ==="

brew install ninja python@3.11 jq
pip3 install pillow pyyaml

echo "=== STEP END: Install Dependencies (macOS) ==="
