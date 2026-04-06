#!/bin/bash
# Nickel Browser - Create Swap File
# Creates a 32GB swap file for systems with less than 32GB RAM

set -e

echo "🪙 Nickel Browser - Swap Creation Script"
echo "========================================="
echo ""

# Check current RAM
TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
TOTAL_RAM_GB=$((TOTAL_RAM / 1024))

echo "💾 Detected RAM: ${TOTAL_RAM_GB}GB"

# Check if swap already exists
EXISTING_SWAP=$(free -m | awk '/^Swap:/{print $2}')
if [ "$EXISTING_SWAP" -gt 0 ]; then
    EXISTING_SWAP_GB=$((EXISTING_SWAP / 1024))
    echo "💾 Existing swap: ${EXISTING_SWAP_GB}GB"
fi

# Determine swap size needed
if [ "$TOTAL_RAM_GB" -ge 32 ]; then
    echo "✅ You have 32GB+ RAM. Swap is optional but recommended."
    read -p "Create 16GB swap anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping swap creation."
        exit 0
    fi
    SWAP_SIZE_GB=16
elif [ "$TOTAL_RAM_GB" -ge 16 ]; then
    echo "💡 Recommended: Create 32GB swap for 16GB RAM systems"
    SWAP_SIZE_GB=32
elif [ "$TOTAL_RAM_GB" -ge 8 ]; then
    echo "💡 Recommended: Create 32GB swap for 8GB RAM systems"
    SWAP_SIZE_GB=32
else
    echo "⚠️  Warning: You have less than 8GB RAM. Building may be very slow."
    echo "💡 Creating 32GB swap (minimum recommended)"
    SWAP_SIZE_GB=32
fi

# Check available disk space
AVAILABLE_KB=$(df -k / | awk 'NR==2 {print $4}')
AVAILABLE_GB=$((AVAILABLE_KB / 1024 / 1024))
NEEDED_GB=$((SWAP_SIZE_GB + 10))  # Swap + buffer

if [ "$AVAILABLE_GB" -lt "$NEEDED_GB" ]; then
    echo "❌ Error: Not enough disk space."
    echo "   Available: ${AVAILABLE_GB}GB"
    echo "   Needed: ${NEEDED_GB}GB"
    exit 1
fi

echo ""
echo "📊 Summary:"
echo "   RAM: ${TOTAL_RAM_GB}GB"
echo "   Swap to create: ${SWAP_SIZE_GB}GB"
echo "   Available disk: ${AVAILABLE_GB}GB"
echo ""

read -p "Proceed with swap creation? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]] && [ -n "$REPLY" ]; then
    echo "Cancelled."
    exit 0
fi

# Remove existing swap if present
if [ -f /swapfile ]; then
    echo "🗑️  Removing existing swap file..."
    sudo swapoff /swapfile 2>/dev/null || true
    sudo rm /swapfile
fi

# Create swap file
echo "📦 Creating ${SWAP_SIZE_GB}GB swap file..."
echo "   This may take a few minutes..."

if ! sudo fallocate -l ${SWAP_SIZE_GB}G /swapfile; then
    echo "⚠️  fallocate failed, trying dd (slower)..."
    sudo dd if=/dev/zero of=/swapfile bs=1G count=$SWAP_SIZE_GB status=progress
fi

# Set permissions
sudo chmod 600 /swapfile

# Format as swap
sudo mkswap /swapfile

# Enable swap
sudo swapon /swapfile

# Make permanent
echo "📝 Making swap permanent..."
if ! grep -q "/swapfile" /etc/fstab; then
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# Configure swappiness for better performance
echo "⚙️  Configuring swappiness..."
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo ""
echo "✅ Swap created successfully!"
echo ""
free -h
echo ""
echo "💡 Tip: The swap will be used automatically when needed."
echo "   You can monitor usage with: free -h"
