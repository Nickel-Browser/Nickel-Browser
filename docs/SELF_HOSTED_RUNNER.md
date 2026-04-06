# 🏗️ Self-Hosted Runner Setup for Nickel Browser

This guide describes how to set up a self-hosted GitHub Actions runner capable of performing full Chromium source compilations for Nickel Browser.

## Hardware Requirements

Compiling Chromium from source is an extremely resource-intensive task. For a stable build within a reasonable time, the following hardware is recommended:

- **CPU**: 8+ cores (AMD Ryzen 7/9 or Intel Core i7/i9 recommended)
- **RAM**: 32GB minimum (64GB preferred)
- **Storage**: 250GB+ SSD (NVMe preferred for high I/O performance)
- **Bandwidth**: High-speed internet (initial fetch downloads ~35GB)

## Operating System

- **Ubuntu 22.04 LTS** (Recommended and most tested)
- Other modern Linux distributions (Debian, Fedora) may work but may require manual dependency resolution.

## Initial Setup

### 1. Install System Dependencies

```bash
sudo apt-get update
sudo apt-get install -y git curl wget python3 ninja-build pkg-config build-essential \
  libglib2.0-dev libgtk-3-dev libpulse-dev libasound2-dev libdbus-1-dev \
  libx11-dev libxcomposite-dev libxcursor-dev libxdamage-dev libxfixes-dev \
  libxi-dev libxrandr-dev libxss-dev libxtst-dev libatk1.0-dev libcups2-dev \
  libdrm-dev mesa-common-dev libgbm-dev libssl-dev libnss3-dev jq gperf bison
```

### 2. Install Depot Tools

```bash
git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git $HOME/depot_tools
echo 'export PATH="$HOME/depot_tools:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### 3. Register GitHub Actions Runner

1. Go to your repository on GitHub: **Settings > Actions > Runners**.
2. Click **New self-hosted runner** and select **Linux**.
3. Follow the provided instructions to download and configure the runner.
4. When prompted for labels, add: `self-hosted`, `linux`, `nickel-builder`.
5. Start the runner using `./run.sh`.

## Running the Source Build

Once the runner is online:

1. Go to the **Actions** tab in your GitHub repository.
2. Select the workflow: **🏗️ Nickel Browser Source Build (Manual)**.
3. Click **Run workflow**.
4. Specify the Chromium version (e.g., `124.0.6367.82`).
5. Click **Run workflow** again.

The build will take several hours depending on your hardware. Successful builds will produce `.deb` and `.AppImage` artifacts.

## Troubleshooting

- **Disk Full**: Ensure you have at least 150GB of free space before starting.
- **OOM (Out of Memory)**: If the build fails during linking, ensure you have sufficient swap space or increase physical RAM.
- **Permission Denied**: Ensure the user running the GitHub runner has write permissions to `/opt/nickel-src` or change the `NICKEL_DIR` environment variable in the workflow.
