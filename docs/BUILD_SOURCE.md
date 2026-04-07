# Building Nickel Browser from Source

Complete step-by-step guide for building Nickel Browser on Zorin OS 18 Pro and other Linux distributions.

---

## 📋 Prerequisites

### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 8 GB | 16–32 GB |
| Disk Space | 100 GB free | 250 GB+ SSD |
| CPU | 4-core x86_64 | 8+ cores |
| Swap | 16 GB | 32 GB |
| Internet | Stable connection | Fast connection |

### Software Requirements

- Zorin OS 18 Pro (or Ubuntu 22.04+)
- Git 2.30+
- Python 3.9+
- Node.js 18+

## 📝 Step-by-Step Build

### Step 1: System Preparation

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install essential build tools
sudo apt install -y \
  git python3 python3-pip curl wget build-essential \
  clang lld llvm cmake ninja-build pkg-config \
  libgtk-3-dev libglib2.0-dev libnss3-dev libnspr4-dev \
  libatk1.0-dev libatk-bridge2.0-dev libcups2-dev \
  libdrm-dev libxkbcommon-dev libxcomposite-dev \
  libxdamage-dev libxrandr-dev libgbm-dev \
  libpango1.0-dev libcairo2-dev libasound2-dev \
  libpulse-dev libxss-dev gperf bison flex \
  nodejs npm libdbus-1-dev libkrb5-dev re2c \
  subversion uuid-dev xz-utils zstd tmux

# Install additional tools
sudo apt install -y tor wireguard-tools aria2 hunspell
```

### Step 2: Create Swap (Critical for <32GB RAM)

```bash
# Check current RAM
free -h

# Create 32GB swap file
sudo fallocate -l 32G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify
free -h
```

### Step 3: Install depot_tools

```bash
cd ~
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git

# Add to PATH
echo 'export PATH="$HOME/depot_tools:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
gclient --version
```

### Step 4: Fetch Chromium Source

```bash
# Create working directory
mkdir ~/nickel-build && cd ~/nickel-build

# Fetch Chromium (this downloads ~35GB, takes 30-60 minutes)
fetch --nohooks --no-history chromium

# Enter source directory
cd src

# Install build dependencies
./build/install-build-deps.sh

# Run hooks
gclient runhooks
```

> ☕ **Take a break!** This step takes a while. Use `tmux` to prevent interruption.

### Step 5: Clone Nickel Browser

```bash
cd ~/nickel-build

# Clone Nickel Browser repository
git clone https://github.com/nickel-browser/nickel.git

# Copy Nickel files to Chromium source
cp -r nickel/src/nickel src/
cp nickel/patches/*.patch src/
```

### Step 6: Apply Ungoogled-Chromium Patches

```bash
cd ~/nickel-build

# Clone ungoogled-chromium
git clone https://github.com/ungoogled-software/ungoogled-chromium.git

# Get target Chromium version
CHROME_VERSION=$(cat ungoogled-chromium/chromium_version.txt)
echo "Target Chromium version: $CHROME_VERSION"

# Checkout matching version
cd src
git checkout tags/$CHROME_VERSION
gclient sync --with_branch_heads --with_tags -D

# Apply ungoogled patches
cd ~/nickel-build

# Prune Google binaries
python3 ungoogled-chromium/utils/prune_binaries.py ./src \
  ungoogled-chromium/pruning.list

# Apply domain substitution
python3 ungoogled-chromium/utils/domain_substitution.py apply \
  -r ungoogled-chromium/domain_regex.list \
  -f ungoogled-chromium/domain_substitution.list \
  -c domsubcache.tar.gz \
  ./src

# Apply patches
for patch in ungoogled-chromium/patches/*.patch; do
  echo "Applying: $patch"
  git -C src apply ../$patch || echo "Skipped: $patch"
done
```

### Step 7: Apply Nickel Patches

```bash
cd ~/nickel-build/src

# Apply Nickel branding patches
git apply nickel/patches/nickel-branding.patch
git apply nickel/patches/nickel-privacy-defaults.patch
git apply nickel/patches/nickel-adblock.patch
git apply nickel/patches/nickel-fingerprint.patch
git apply nickel/patches/nickel-webrtc.patch
git apply nickel/patches/nickel-tor.patch
git apply nickel/patches/nickel-vpn.patch
git apply nickel/patches/nickel-ui.patch

# Verify all patches applied
git status
```

### Step 8: Copy Logo Files

```bash
cd ~/nickel-build/src

# Copy Nickel logos to replace Chromium icons
cp nickel/branding/product_logo_16.png chrome/app/theme/chromium/product_logo_16.png
cp nickel/branding/product_logo_32.png chrome/app/theme/chromium/product_logo_32.png
cp nickel/branding/product_logo_48.png chrome/app/theme/chromium/product_logo_48.png
cp nickel/branding/product_logo_128.png chrome/app/theme/chromium/product_logo_128.png
cp nickel/branding/product_logo_256.png chrome/app/theme/chromium/product_logo_256.png

# Copy SVG logo if available
cp nickel/branding/Nickel.png chrome/app/theme/chromium/product_logo.png
```

### Step 9: Configure Build

```bash
cd ~/nickel-build/src

# Create build output directory
mkdir -p out/Nickel

# Generate build configuration
cat > out/Nickel/args.gn << 'EOF'
# Nickel Browser Build Configuration
is_official_build = true
is_debug = false
target_cpu = "x64"
symbol_level = 0

# Disable unnecessary features
enable_nacl = false
is_component_build = false
use_official_google_api_keys = false
google_api_key = ""
google_default_client_id = ""
google_default_client_secret = ""
enable_hangout_services_extension = false
enable_reporting = false
enable_service_discovery = false
safe_browsing_mode = 0
use_unofficial_version_number = false
chrome_pgo_phase = 0
enable_js_type_check = false
treat_warnings_as_errors = false
blink_enable_generated_code_formatting = false

# Enable media codecs
enable_widevine = true
proprietary_codecs = true
ffmpeg_branding = "Chrome"

# Optimizations for low RAM
clang_use_chrome_plugins = false
use_lld = true
use_thin_lto = true

# Nickel-specific flags
nickel_enable_adblock = true
nickel_enable_tor = true
nickel_enable_vpn = true
nickel_enable_fingerprint = true
EOF

# Generate build files
gn gen out/Nickel
```

### Step 10: Build Nickel Browser

```bash
cd ~/nickel-build/src

# Start build with tmux (prevents interruption)
tmux new -s nickel-build

# Build (this takes 4-8 hours depending on hardware)
ninja -C out/Nickel chrome -j2

# Detach from tmux: Press Ctrl+B, then D
# Reattach later: tmux attach -t nickel-build
```

> ⏱️ **Build time estimates:**
> - 8-core CPU + 32GB RAM: ~2-3 hours
> - 4-core CPU + 16GB RAM: ~4-6 hours
> - 2-core CPU + 8GB RAM: ~8-12 hours

### Step 11: Test the Build

```bash
cd ~/nickel-build/src

# Run Nickel Browser
./out/Nickel/chrome

# Verify:
# - DuckDuckGo should be default search
# - WebRTC should be disabled
# - HTTPS-only mode should be enabled
# - Third-party cookies should be blocked
```

### Step 12: Package for Distribution

#### Linux .deb Package

```bash
cd ~/nickel-build/src

# Create package structure
mkdir -p nickel-deb/DEBIAN
mkdir -p nickel-deb/opt/nickel-browser
mkdir -p nickel-deb/usr/share/applications
mkdir -p nickel-deb/usr/share/icons/hicolor/256x256/apps

# Copy build output
cp -r out/Nickel/* nickel-deb/opt/nickel-browser/

# Create control file
cat > nickel-deb/DEBIAN/control << 'EOF'
Package: nickel-browser
Version: 1.0.0
Section: web
Priority: optional
Architecture: amd64
Depends: libnss3, libgtk-3-0, libasound2, libxss1, libgbm1, libgl1
Maintainer: Nickel Browser Team <team@nickel-browser.org>
Description: Nickel Browser - Privacy-First Web Browser
 Nickel Browser is a privacy-first, community-driven browser
 built on ungoogled-chromium with nuclear-grade ad blocking,
 built-in Tor & VPN, and comprehensive fingerprint protection.
EOF

# Create desktop entry
cat > nickel-deb/usr/share/applications/nickel-browser.desktop << 'EOF'
[Desktop Entry]
Name=Nickel Browser
Comment=Privacy-First Web Browser
Exec=/opt/nickel-browser/chrome %U
Icon=nickel-browser
Type=Application
Categories=Network;WebBrowser;
MimeType=text/html;text/xml;application/xhtml+xml;x-scheme-handler/http;x-scheme-handler/https;
StartupNotify=true
EOF

# Copy icon
cp nickel/branding/product_logo_256.png \
  nickel-deb/usr/share/icons/hicolor/256x256/apps/nickel-browser.png

# Build package
dpkg-deb --build nickel-deb ../nickel-browser_1.0.0_amd64.deb
```

#### AppImage

```bash
# Install appimage-builder
sudo apt install appimage-builder

# Create AppImage
cd ~/nickel-build/src
appimage-builder --recipe nickel/packaging/appimage-builder.yml
```

---

## 🔧 Troubleshooting

### Out of Memory

```bash
# Increase swap
sudo swapoff -a
sudo rm /swapfile
sudo fallocate -l 64G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Reduce parallel jobs
ninja -C out/Nickel chrome -j1
```

### Build Failures

```bash
# Clean and rebuild
rm -rf out/Nickel
gn gen out/Nickel
ninja -C out/Nickel chrome -j2
```

### Patch Failures

```bash
# Check patch status
cd ~/nickel-build/src
git status

# Reset and retry
git checkout -- .
git clean -fd
git apply nickel/patches/nickel-branding.patch
```

---

## 🐛 Debug Build

For development/debugging:

```bash
cat > out/Nickel-Debug/args.gn << 'EOF'
is_debug = true
is_official_build = false
symbol_level = 2
enable_nacl = false
EOF

gn gen out/Nickel-Debug
ninja -C out/Nickel-Debug chrome -j2
```

---

## 📦 Cross-Platform Builds

### Windows Build

Requires Windows machine or VM:

```bash
# On Windows with depot_tools
fetch --nohooks chromium
cd src
gclient runhooks
gn gen out/Nickel --args="..."
ninja -C out/Nickel chrome
```

### macOS Build

Requires macOS machine (Apple requirement):

```bash
# On macOS with depot_tools
fetch --nohooks chromium
cd src
gclient runhooks
gn gen out/Nickel --args="..."
ninja -C out/Nickel "Chromium.app"
```

---

## 🚀 CI/CD Build (GitHub Actions)

See `.github/workflows/build.yml` for automated builds.

---

## 📚 Additional Resources

- [Chromium Build Instructions](https://chromium.googlesource.com/chromium/src/+/main/docs/linux/build_instructions.md)
- [ungoogled-chromium Wiki](https://github.com/ungoogled-software/ungoogled-chromium/wiki)
- [GN Build Configuration](https://gn.googlesource.com/gn/+/main/docs/quick_start.md)

---

## 💬 Need Help?

- [GitHub Discussions](https://github.com/Nickel-Browser/Nickel-Browser/discussions)
- [Discord](https://discord.gg/fBebZDbEhH)
- [Matrix](https://matrix.to/#/#nickel-browser:matrix.org)

---

**Happy Building!** 🪙🐅🔨
