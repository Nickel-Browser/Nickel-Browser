# Building Nickel Browser

> **Choose your adventure:** Quick binary repagging (10 minutes, any laptop) OR advanced source build (8 hours, workstation required).

---

## 🎯 Decision Guide: Which Build Method?

```
Need to modify Chromium C++ internals?
│
├── YES → Method B: Source Build (Section below)
│         Requires: 16GB+ RAM, 250GB SSD, 8+ hours
│         For: Core developers, patch authors, security auditors
│
└── NO  → Method A: Binary Repagging (Recommended)
           Requires: 4GB RAM, 5GB disk, 10 minutes
           For: 99% of users, packagers, testers, translators
           ↓
           Continue reading below ↓
```

---

## ⚡ Method A: Binary Repagging (Recommended)

### What Is Binary Repagging?

Instead of compiling Chromium from source (which takes hours and requires massive resources), we **download pre-built ungoogled-chromium binaries** and apply Nickel's branding, patches, and packaging on top.

**Why this is brilliant:**
- ✅ **Fast:** 10 minutes vs 8 hours
- ✅ **Lightweight:** 200MB download vs 35GB source tree
- ✅ **Accessible:** Works on any laptop (4GB RAM minimum)
- ✅ **Identical Results:** End-user gets same browser as source build
- ✅ **Reproducible:** Anyone can verify our builds match upstream UC binaries + our branding

### System Requirements (Binary Build)

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **RAM** | 4 GB | 8 GB |
| **Disk Space** | 5 GB free | 10 GB |
| **CPU** | Any modern x86_64 | 2+ cores (faster extraction) |
| **OS** | Linux / macOS / Windows | Any modern distribution |
| **Internet** | Broadband (200MB download) | Fast connection |
| **Time Required** | ~15 minutes | ~5 minutes |

### Prerequisites

#### Common (All Platforms)
- Git 2.30+
- curl or wget
- tar/xz utilities (usually pre-installed)
- jq (JSON processor, for version parsing)

#### Platform-Specific

<details>
<summary><b>🐧 Linux (Debian/Ubuntu/Zorin)</b></summary>

```bash
# Install dependencies
sudo apt update
sudo apt install -y git curl wget jq tar xz-utils dpkg-dev coreutils

# Optional: For AppImage building
sudo apt install -y appimage-builder 2>/dev/null || echo "AppImage builder optional"

# Optional: For DMG building on Linux (cross-compilation)
# sudo apt install -y genisoimage
```

**Note:** Tested on Ubuntu 22.04/24.04, Zorin OS 16/18, Linux Mint 21.x, Fedora 39+, Arch Linux.

</details>

<details>
<summary><b>🍎 macOS</b></summary>

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install jq coreutils
```

**Note:** Tested on macOS 13 (Ventura), macOS 14 (Sonoma), macOS 15 (Sequoia) on both Intel and Apple Silicon.

</details>

<details>
<summary><b>🪟 Windows (WSL2 or Git Bash)</b></summary>

**Using Git Bash (recommended):**
```bash
# Install via Chocolatey (run as admin)
choco install jq nsis zip -y
```

**Using PowerShell:**
```powershell
winget install jq.NSIS
```

**Note:** WSL2 also works perfectly. Use Linux instructions inside WSL.

</details>

### Step-by-Step Binary Build

#### Step 1: Clone Repository

```bash
git clone https://github.com/Nickel-Browser/Nickel-Browser.git
cd Nickel-Browser
```

#### Step 2: Make Scripts Executable

```bash
# Make all build scripts executable
chmod +x scripts/*.sh
```

#### Step 3: Download Ungoogled-Chromium Binary

The `download-uc-binary.sh` script automatically detects the correct binary repository for each platform:

```bash
# Syntax: ./scripts/download-uc-binary.sh <platform> <version> <target_directory>

# Download latest stable version for Linux
GITHUB_TOKEN=${GITHUB_TOKEN:-} ./scripts/download-uc-binary.sh linux latest ./uc-binary

# Or specify exact version (e.g., 124.0.6367.82-1)
# GITHUB_TOKEN=${GITHUB_TOKEN:-} ./scripts/download-uc-binary.sh linux "124.0.6367.82-1" ./uc-binary
```

**Available platforms:** `linux`, `windows`, `macos`

**Where binaries come from:**
| Platform | Repository | Binary Format |
|----------|-----------|-------------|
| Linux | [ungoogled-chromium-portablelinux](https://github.com/ungoogled-software/ungoogled-chromium-portablelinux) | tar.xz (~150MB) |
| Windows | [ungoogled-chromium-windows](https://github.com/ungoogled-software/ungoogled-chromium-windows) | zip (~160MB) |
| macOS | [ungoogled-chromium-macos](https://github.com/ungoogled-software/ungoogled-chromium-macos) | dmg (~200MB) |

**About GITHUB_TOKEN:** Optional but recommended. Without it, you're limited to 60 GitHub API requests/hour. With a Personal Access Token, you get 5,000/hour. Get one here: [GitHub Settings > Developer Settings > Personal Access Tokens](https://github.com/settings/tokens) (only need `public_repo` scope).

#### Step 4: Apply Nickel Branding

```bash
# Set environment variables
export NICKEL_DIR=$(pwd)
export BINARY_DIR=./uc-binary
export NICKEL_VERSION="1.0.0-alpha"  # Or read from .version file

# Apply branding (copies logos, creates version info, stages files)
./scripts/apply-nickel-branding.sh
```

**What this step does:**
1. Copies Nickel tiger logos to replace Chromium icons
2. Creates `NICKEL_VERSION` file with version info
3. Stages branding assets in `uc-binary/branding/` directory
4. Verifies binary integrity (checks chrome binary exists)

#### Step 5: Package for Distribution

Choose your target platform(s):

**Linux (.deb package):**
```bash
export DIST_DIR=./dist
./scripts/build-deb.sh
# Output: dist/nickel-browser_<version>_amd64.deb
```

**Linux (AppImage - universal portable):**
```bash
./scripts/build-appimage.sh
# Output: dist/Nickel-Browser-<version>.AppImage
```

**macOS (.dmg disk image):**
```bash
export DIST_DIR=./dist
./scripts/build-dmg.sh
# Output: dist/Nickel-Browser-<version>.dmg
```

**Windows (.exe installer):**
```bash
export DIST_DIR=./dist
./scripts/build-windows-installer.sh
# Output: dist/Nickel-Browser-<version>.exe
```

#### Step 6: Verify Artifacts

```bash
cd dist

# List files with sizes
ls -lh

# Generate checksums (important for verification!)
sha256sum * > checksums.sha256

# Display checksums
cat checksums.sha256
```

**Expected output:**
```
-rw-r--r-- 1 user user 153M Apr  7 12:00 nickel-browser_1.0.0-alpha_amd64.deb
-rw-r--r-- 1 user user 178M Apr  7 12:01 Nickel-Browser-1.0.0-alpha.AppImage
sha256sum * > checksums.sha256
abc123...  nickel-browser_1.0.0-alpha_amd64.deb
def456...  Nickel-Browser-1.0.0-alpha.AppImage
```

> 🎉 **Congratulations!** Your Nickel Browser build is ready in the `dist/` directory!

---

## 🔧 Method B: Advanced Source Build (For Core Developers Only)

> ⚠️ **WARNING:** This method compiles Chromium from source. It requires significant resources and is intended ONLY for developers who need to:
> - Modify Chromium C++ code
> - Test custom patches that affect compilation
> - Perform security audits of the build system
> - Create custom Chromium builds for research
>
> **99% of contributors should use Method A above.**

### System Requirements (Source Build)

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **RAM** | 16 GB | 32–64 GB |
| **Disk Space** | 150 GB free | 300 GB+ SSD |
| **CPU** | 8-core x86_64 | 12+ cores |
| **Swap File** | 32 GB | 64 GB |
| **OS** | Linux (Zorin/Ubuntu 22.04+) | Ubuntu 24.04 LTS |
| **Time Required** | 6–10 hours | 2–4 hours |
| **Skill Level** | Advanced Linux developer | Expert |

### Source Build Overview

1. **Fetch Chromium** via Google's `depot_tools` (~35GB initial download)
2. **Apply ungoogled-chromium patches** (remove Google telemetry, binaries, domains)
3. **Apply Nickel-specific patches** (privacy defaults, UI changes, feature additions)
4. **Configure build** with GN args (optimize for privacy and performance)
5. **Compile** with Ninja (4-8 hours depending on hardware)
6. **Package** for distribution

[See detailed source-build walkthrough →](BUILD_SOURCE.md)

> 💡 **Tip:** The binary repagging method (Method A) produces functionally identical end-user results for testing UI changes, branding updates, and packaging modifications. Only use source build if you absolutely must modify Chromium internals.

---

## 🔄 CI/CD Automation (How GitHub Actions Builds It)

Our production workflow ([`.github/workflows/nickel-production-build.yml`](../.github/workflows/nickel-production-build.yml)) uses **Method A (Binary Repagging)** automatically:

- **Triggers:** Tags (`v*`), weekly schedule, manual dispatch
- **Process:** Downloads latest UC binaries → Applies branding across all 3 platforms → Creates signed GitHub releases with SBOM
- **Duration:** ~15 minutes total (vs. 8+ hours for source build)
- **Platforms:** Linux (ubuntu-24.04), macOS (macos-14), Windows (windows-latest)

**To trigger a manual build:**
1. Go to **Actions** → **Nickel Browser Production Build**
2. Click **Run workflow**
3. Optionally specify custom Chromium version
4. Monitor progress in real-time

---

## 🐛 Troubleshooting

### Binary Build Issues

| Problem | Solution |
|--------|----------|
| **"Could not find matching release"** | Check version format. Use `latest` or exact tag like `124.0.6367.82-1` |
| **Download fails (rate limited)** | Set `GITHUB_TOKEN` env var with GitHub PAT (see Step 3 above) |
| **"chrome binary not found"** | Ensure download completed successfully; check `uc-binary/` directory contents |
| **Permission denied running scripts** | Run `chmod +x scripts/*.sh` before executing |
| **dpkg-deb errors** | Check `DEBIAN/control` file formatting (no trailing spaces, proper newlines) |
| **AppImage build fails** | Install `appimage-builder`: `sudo apt install appimage-builder` |
| **Wrong architecture** | Ensure you're using x86_64 system (ARM64 not yet supported for binary builds) |

### Source Build Issues

| Problem | Solution |
|--------|----------|
| **Out of memory during compile** | Increase swap to 64GB, reduce ninja jobs (`-j1`) |
| **Patch application failures** | Ensure Chromium version matches patch target exactly; check `patches/` directory |
| **depot_tools not found** | Add `$HOME/depot_tools` to PATH permanently in `~/.bashrc` |
| **GN configuration errors** | Check `args.gn` for typos; ensure booleans are `true`/`false` not strings |
| **Build takes forever** | Use `tmux` to prevent interruption; ensure sufficient swap space |

---

## 📚 Additional Resources

- [ungoogled-chromium Documentation](https://github.com/ungoogled-software/ungoogled-chromium#wiki) — Our foundation
- [Chromium Build Instructions (Official)](https://chromium.googlesource.com/chromium/src/+/main/docs/linux/build_instructions.md) — Upstream docs
- [GN Build Configuration Reference](https://gn.googlesource.com/gn/+/main/docs/reference.md) — Build system docs
- [Nickel Browser Issue Tracker](https://github.com/Nickel-Browser/Nickel-Browser/issues) — Report bugs
- [Nickel Browser Discussions](https://github.com/Nickel-Browser/Nickel-Browser/discussions) — Ask questions

---

**Happy Building!** Choose Method A for speed, Method B for complete control. 🪙🔨