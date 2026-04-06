#!/bin/bash
# Nickel Browser - Install Dependencies (macOS)
set -e

echo "=== STEP START: Install Dependencies (macOS) ==="

brew install ninja python@3.11 jq

# Create a virtual environment to avoid externally-managed-environment error
python3.11 -m venv $HOME/venv
source $HOME/venv/bin/activate
pip install pillow pyyaml

echo "=== STEP END: Install Dependencies (macOS) ==="
