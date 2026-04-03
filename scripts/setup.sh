#!/bin/bash
# Nickel Browser Setup Script
# Installs all dependencies for building Nickel Browser on Zorin OS / Ubuntu

set -e

echo "🪙 Nickel Browser - Setup Script"
echo "================================="
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
   echo "❌ Please do not run as root"
   exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
else
    echo "❌ Cannot detect OS"
    exit 1
fi

echo "📋 Detected OS: $OS $VER"
echo ""

# Update system
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install essential build tools
echo "🔧 Installing build tools..."
sudo apt install -y \
    git \
    python3 \
    python3-pip \
    python3-venv \
    curl \
    wget \
    build-essential \
    clang \
    lld \
    llvm \
    cmake \
    ninja-build \
    pkg-config

# Install Chromium dependencies
echo "🌐 Installing Chromium dependencies..."
sudo apt install -y \
    libgtk-3-dev \
    libglib2.0-dev \
    libnss3-dev \
    libnspr4-dev \
    libatk1.0-dev \
    libatk-bridge2.0-dev \
    libcups2-dev \
    libdrm-dev \
    libxkbcommon-dev \
    libxcomposite-dev \
    libxdamage-dev \
    libxrandr-dev \
    libgbm-dev \
    libpango1.0-dev \
    libcairo2-dev \
    libasound2-dev \
    libpulse-dev \
    libxss-dev \
    gperf \
    bison \
    flex \
    nodejs \
    npm \
    libdbus-1-dev \
    libkrb5-dev \
    re2c \
    subversion \
    uuid-dev \
    xz-utils \
    zstd

# Install additional tools for Nickel features
echo "🔒 Installing Nickel feature dependencies..."
sudo apt install -y \
    tor \
    wireguard-tools \
    openvpn \
    aria2 \
    hunspell-en-us \
    libre2-dev

# Install tmux for build sessions
echo "🖥️ Installing tmux..."
sudo apt install -y tmux

# Install depot_tools
echo "📥 Installing depot_tools..."
if [ ! -d "$HOME/depot_tools" ]; then
    cd ~
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    echo 'export PATH="$HOME/depot_tools:$PATH"' >> ~/.bashrc
    echo "✅ depot_tools installed"
else
    echo "✅ depot_tools already installed"
fi

# Source the updated PATH
export PATH="$HOME/depot_tools:$PATH"

# Verify installations
echo ""
echo "✅ Verifying installations..."
echo ""

echo "Git version: $(git --version)"
echo "Python version: $(python3 --version)"
echo "Node version: $(node --version)"
echo "Ninja version: $(ninja --version)"
echo "CMake version: $(cmake --version | head -1)"
echo "Clang version: $(clang --version | head -1)"

if command -v gclient &> /dev/null; then
    echo "depot_tools: ✅"
else
    echo "depot_tools: ❌ (Please restart your terminal)"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.bashrc"
echo "  2. Run: ./scripts/create-swap.sh (if <32GB RAM)"
echo "  3. Run: ./scripts/fetch-chromium.sh"
echo "  4. Run: ./scripts/build.sh"
echo ""
echo "For help, visit: https://github.com/nickel-browser/nickel/blob/main/docs/BUILD.md"
