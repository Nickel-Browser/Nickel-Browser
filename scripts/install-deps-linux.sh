#!/bin/bash
# Nickel Browser - Install Dependencies (Linux)
set -e

echo "=== STEP START: Install Dependencies (Linux) ==="

sudo apt-get update
sudo apt-get install -y \
    git curl wget python3 python3-pip python3-venv \
    ninja-build pkg-config build-essential \
    libglib2.0-dev libgtk-3-dev libpulse-dev libasound2-dev \
    libdbus-1-dev libx11-dev libxcomposite-dev libxcursor-dev \
    libxdamage-dev libxfixes-dev libxi-dev libxrandr-dev \
    libxss-dev libxtst-dev libatk1.0-dev libcups2-dev \
    libdrm-dev mesa-common-dev libgbm-dev \
    libssl-dev libnss3-dev libffi-dev jq gperf bison

echo "=== STEP END: Install Dependencies (Linux) ==="
