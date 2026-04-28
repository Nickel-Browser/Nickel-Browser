# Building Nickel Browser

> **Choose your path:**
> - **Method A — Source Build (Brave-style):** Compiles real Nickel Browser binaries from the ungoogled-chromium source tree. Requires a large machine (100 GB disk, 32 GB RAM) or GitHub Actions large runners. Produces real, auditable binaries.
> - **Method B — Binary Repackaging:** Downloads pre-built ungoogled-chromium and applies Nickel branding. Fast (10 min, any laptop) but does not include Nickel's C++ patches.

---

## 🎯 Decision Guide: Which Build Method?

```
Do you want the full Nickel feature set (ad blocking engine, Tor, fingerprint protection)?
│
├── YES → Method A: Source Build (Section 2 below)   ← THE REAL NICKEL BROWSER
│         Requires: 100 GB disk, 16+ GB RAM, 4–8 hours  (or GitHub Actions large runner)
│         For: All users who want real Nickel features
│         CI:  .github/workflows/nickel-source-build.yml
│
└── NO  → Method B: Binary Repackaging (Section 4 below)  ← FAST / TESTING ONLY
           Requires: 4 GB RAM, 5 GB disk, 10 minutes
           For: Branding / packaging testing only
           CI:  .github/workflows/nickel-production-build.yml
```

---

## ⚡ Method A: Source Build (Real Nickel Browser)

### What Is a Source Build?

We compile Chromium directly from the ungoogled-chromium source tree, then apply Nickel's patches on top. This is exactly how **Brave Browser**, **Vivaldi**, and **ungoogled-chromium** work.

**Why this is the right approach:**
- ✅ **Real features:** Nickel's ad-blocking engine, fingerprint protection, and Tor integration are compiled as C++ Chromium patches — they cannot be disabled or bypassed
- ✅ **Auditable:** Every line of code is reviewable; no binary blobs
- ✅ **True privacy:** Privacy features are architectural (not policy-based)
- ✅ **Upstream compatible:** Stays in sync with ungoogled-chromium security patches automatically

### System Requirements (Source Build)

| Component | Minimum | Recommended | Notes |
|-----------|---------|-------------|--------|
| **RAM** | 16 GB | 32–64 GB | Less will OOM during linking |
| **Disk Space** | 100 GB free | 150 GB+ SSD | Source ~30 GB, build artifacts ~60 GB |
| **CPU** | 8-core x86_64 | 16+ cores | More cores = faster |
| **Swap** | 16 GB | 32 GB | Essential for 16 GB RAM machines |
| **OS** | Ubuntu 22.04+ | Ubuntu 22.04 LTS | Tested platform |
| **Time** | 4–8 hours | 2–4 hours | On 16+ cores with 64 GB RAM |

### Quick Start (Linux)

```bash
git clone https://github.com/Nickel-Browser/Nickel-Browser.git
cd Nickel-Browser
chmod +x scripts/build-nickel-linux.sh

# Full build (interactive — asks before proceeding if disk is low)
./scripts/build-nickel-linux.sh

# Specify a specific ungoogled-chromium version
./scripts/build-nickel-linux.sh --version 146.0.7680.177-1

# Debug build with 16 ninja jobs
./scripts/build-nickel-linux.sh --debug --jobs 16
```

The script will:
1. Install system dependencies (`apt-get`)
2. Clone depot_tools
3. Clone ungoogled-chromium at the pinned version
4. Fetch Chromium source via `python3 utils/fetch_sync.py` (falls back to `gclient sync` on older UC releases)
5. Apply ungoogled-chromium's own patches
6. Apply Nickel's patches (`patches/series`)
7. Generate GN build config (ungoogled-chromium's curated GN args + Nickel overrides appended inline)
8. Compile with ninja
9. Package as `.deb` and `.tar.xz`

### GitHub Actions Source Build

```
.github/workflows/nickel-source-build.yml
```

Trigger manually:
1. Go to **Actions** → **Nickel Browser — Source Build (Linux)**
2. Click **Run workflow**
3. Optionally specify a custom `uc_version`
4. The workflow validates patches, fetches the full source, builds, and uploads `.deb` / `.tar.xz` as artifacts

> **⚠️ Runner note:** Standard GitHub-hosted runners (`ubuntu-22.04`) have only ~14 GB RAM and 84 GB disk — **not enough for a Chromium source build**. This includes the free runners provided by GitHub Education/Pro.
>
> To run a source build you need one of:
> - **Self-hosted runner** on a machine with 32+ GB RAM and 150+ GB free disk (see [SELF_HOSTED_RUNNER.md](SELF_HOSTED_RUNNER.md))
> - **GitHub Large Runner** (`ubuntu-22.04-32-core`) — available on GitHub Team/Enterprise plans

### Patch System

Nickel's patches live in `patches/` and are applied in the order listed in `patches/series`:

| Patch | What it does |
|-------|-------------|
| `0001-nickel-branding` | Product name: `Nickel Browser`, binary: `nickel-browser` |
| `0002-nickel-user-agent` | Adds `Nickel/1.0` product token to UA string |
| `0003-nickel-default-prefs` | DuckDuckGo default, cookie policy, DNT, HTTPS-Only |
| `0004-nickel-webrtc-defaults` | Forces `disable_non_proxied_udp` WebRTC policy |
| `0005-nickel-new-tab-page` | Custom Nickel NTP with privacy stats |
| `0006-nickel-adblock-engine` | Source-level ad-blocking engine + URLLoaderThrottle |
| `0007-nickel-fingerprint-protection` | Canvas/AudioContext/Navigator noise injection |
| `0008-nickel-tor-integration` | Tor daemon controller + per-tab Tor routing |
| `0009-nickel-vpn-layer` | VPN proxy routing service |
| `0010-nickel-build-integration` | BUILD.gn files to wire all components into chrome |

Patches that add **new files** (`--- /dev/null`) always apply cleanly. Patches that modify existing files depend on exact source content — always verify with `git apply --check` after a Chromium update.

---

## 🔧 Method B: Binary Repackaging (Branding / Testing Only)

### Prerequisites

#### Common (All Platforms)

```bash
# Required tools
Git 2.30+
curl or wget
tar (with xz support)
jq 1.6+ (JSON processor)
```

**Installing Prerequisites:**

<details>
<summary><b>🐧 Linux (Debian/Ubuntu/Zorin/Linux Mint/Fedora/Arch)</b></summary>

```bash
# Debian/Ubuntu/Zorin/Mint
sudo apt update
sudo apt install -y git curl wget jq tar gzip coreutils

# Optional: For DMG building on Linux (cross-compilation)
# sudo apt install -y genisoimage
```

**Verified on:** Ubuntu 22.04/24.04, Zorin OS 16/18, Linux Mint 21.x, Fedora 39+, Arch Linux (rolling)

</details>

<details>
<summary><b>🍎 macOS (Intel & Apple Silicon)</b></summary>

```bash
# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install jq coreutils
```

**Verified on:** macOS 13 (Ventura), macOS 14 (Sonoma), macOS 15 (Sequoia), both Intel and Apple Silicon (M1/M2/M3)

**Note:** Apple Silicon (M1/M2/M3) works perfectly. Rosetta 2 handles x86_64 tools transparently.

</details>

<details>
<summary><b>🪟 Windows (Windows 11/10, WSL2, Git Bash)</b></summary>

**Option A: Git Bash (Recommended - native Windows)**
```powershell
# Using Chocolatey (run as Administrator once)
choco install jq nsis zip -y
```

**Option B: WSL2 (Windows Subsystem for Linux)**
```bash
# Inside WSL2 Ubuntu/Debian
sudo apt update
sudo apt install -y git curl wget jq tar gzip
```

**Option C: PowerShell (native)**
```powershell
winget install jq.NSIS
```

**Verified on:** Windows 11 (23H2), Windows 10 (22H2), WSL2 with Ubuntu 22.04/24.04

</details>

### Step-by-Step Binary Build Instructions

#### Step 1: Clone Repository

```bash
git clone https://github.com/Nickel-Browser/Nickel-Browser.git
cd Nickel-Browser
ls -la
```

**Expected output:** You should see directories: `.github`, `docs`, `patches`, `scripts`, `src`, `web`, and files: `README.md`, `LICENSE`, `.gitignore`, etc.

#### Step 2: Make Scripts Executable

```bash
# Make all shell scripts executable
chmod +x scripts/*.sh

# Verify
ls -la scripts/*.sh
# Expected: -rwxr-xr-x for all .sh files
```

#### Step 3: Download Ungoogled-Chromium Binary

The `download-uc-binary.sh` script automates downloading the correct pre-built ungoogled-chromium binary for your platform.

**Syntax:**
```bash
./scripts/download-uc-binary.sh <platform> <version> <target_directory>
```

**Parameters:**
| Parameter | Required | Description | Examples |
|-----------|----------|-------------|----------|
| `platform` | ✅ Yes | Target OS: `linux`, `windows`, `macos` |
| `version` | ✅ Yes | Version string: `latest` (auto-detect newest) or specific tag like `124.0.6367.82-1` |
| `target_directory` | No (default: `./uc-binary`) | Where to extract the binary |

**Examples:**

```bash
# Example 1: Download latest stable Linux binary
GITHUB_TOKEN=${GITHUB_TOKEN:-} ./scripts/download-uc-binary.sh linux latest ./uc-binary

# Example 2: Download specific version for macOS
GITHUB_TOKEN=${GITHUB_TOKEN:-} ./scripts/download-uc-binary.sh macos "124.0.6367.82-1" ./uc-macos-binary

# Example 3: Download latest for Windows (for later packaging)
GITHUB_TOKEN=${GITHUB_TOKEN:-} ./scripts/download-uc-binary.sh windows latest ./uc-windows-binary
```

**About GITHUB_TOKEN (Optional but Recommended):**
- **Without token:** Limited to 60 GitHub API requests per hour (fine for personal use)
- **With token:** 5,000 requests per hour (needed for CI/CD or frequent builds)
- **Get token here:** [GitHub Settings > Developer Settings > Personal Access Tokens > Tokens (classic)](https://github.com/settings/tokens)
- **Required scope:** `public_repo` (read access to public repos only)

**Where Binaries Come From:**

| Platform | Repository | Binary Format | Approx Size |
|----------|-----------|-------------|-------------|
| **Linux** | [ungoogled-chromium-portablelinux](https://github.com/ungoogled-software/ungoogled-chromium-portablelinux) | tar.xz | ~150 MB |
| **Windows** | [ungoogled-chromium-windows](https://github.com/ungoogled-software/ungoogled-chromium-windows) | zip | ~160 MB |
| **macOS** | [ungoogled-chromium-macos](https://github.com/ungoogled-software/ungoogled-chromium-macos) | dmg | ~200 MB |

These are official builds from the ungoogled-chromium project. They are:
- Compiled from clean Chromium source with all Google components removed
- Optimized for each platform (Linux uses GTK/Ozone, macOS uses Cocoa, Windows uses Win32)
- Signed (where applicable) and reproducible
- Updated within 24-48 hours of upstream Chromium security patches

**What happens during download:**
1. Script queries GitHub API for latest release matching your platform
2. Downloads the asset (tar.xz/zip/dmg) to target directory
3. Extracts archive contents
4. Verifies file integrity (checksum validation)
5. Reports success/failure with clear error messages

#### Step 4: Apply Nickel Branding

Now we take the vanilla ungoogled-chromium binary and transform it into Nickel Browser:

```bash
# Set environment variables (required by branding script)
export NICKEL_DIR=$(pwd)
export BINARY_DIR=./uc-binary  # Or custom path: ./my-custom-dir
export NICKEL_VERSION="1.0.0-alpha"  # Or read from file: export NICKEL_VERSION=$(cat .version 2>/dev/null || echo "1.0.0-alpha")

# Apply branding (this does the magic)
./scripts/apply-nickel-branding.sh
```
**What this step does:**
1. Validates that `BINARY_DIR` exists and contains chrome/chromium binary
2. Copies Nickel tiger logos to replace Chromium icons (various sizes: 16px to 512px)
3. Creates `NICKEL_VERSION` file with version info and build date
4. Stages branding assets in `BINARY_DIR/branding/` subdirectory
5. Modifies user agent string to identify as Nickel Browser
6. Sets default search engine to DuckDuckGo (privacy-respecting)
7. Disables any remaining telemetry hooks (belt and suspenders)
8. Prints success message with summary of changes

**Expected output:**
```
🪙 Nickel Browser - Apply Branding to Binary
==========================================
📍 NICKEL_DIR: /home/user/Nickel-Browser
📍 BINARY_DIR: ./uc-binary
📍 Version: 1.0.0-alpha

✅ Found chrome binary at ./uc-binary/opt/chromium/chrome
✅ Copying branding assets...
   🎨 product_logo_16.png → ./uc-binary/branding/
   🎨 product_logo_32.png → ./uc-binary/branding/
   🎨 product_logo_256.png → ./uc-binary/branding/
   🎨 Nickel.png → ./uc-binary/branding/
✅ Created NICKEL_VERSION file
✅ Set user agent to: Mozilla/5.0 (X11; Linux x86_64) NickelBrowser/1.0.0-alpha Chromium/124.0.6367.82
✅ Default search engine: DuckDuckGo
✅ Branding applied successfully!
```

#### Step 5: Package for Distribution

Choose your target platform(s):

**Option A: Linux .deb Package (Debian/Ubuntu/Zorin/Mint compatible)**

```bash
# Set output directory
export DIST_DIR=./dist
mkdir -p $DIST_DIR

# Build DEB package
./scripts/build-deb.sh

# Verify
ls -lh $DIST_DIR/
# Expected: nickel-browser_1.0.0-alpha_amd64.deb (~150MB)
```

**Option B: macOS .dmg Disk Image**

```bash
# Set output directory
export DIST_DIR=./dist
mkdir -p $DIST_DIR

# Build DMG
./scripts/build-dmg.sh

# Verify
ls -lh $DIST_DIR/
# Expected: Nickel-Browser-1.0.0-alpha.dmg (~200MB)
```

**Option C: Windows .exe Installer**

```bash
# Set output directory
export DIST_DIR=./dist
mkdir -p $DIST_DIR

# Build NSIS installer
./scripts/build-windows-installer.sh

# Verify
ls -lh $DIST_DIR/
# Expected: Nickel-Browser-1.0.0-alpha.exe (~160MB)
```

**Option D: Multiple Platforms (Build All At Once)**

```bash
# Build everything!
export DIST_DIR=./dist
mkdir -p $DIST_DIR

./scripts/build-deb.sh                   && echo "✅ DEB done"  || echo "❌ DEB failed"
./scripts/build-dmg.sh                   && echo "✅ DMG done"  || echo "❌ DMG failed"
./scripts/build-windows-installer.sh     && echo "✅ EXE done"  || echo "❌ EXE failed"

# Show results
echo "=== Build Artifacts ==="
ls -lh $DIST_DIR/*
```

#### Step 6: Verify Artifacts

```bash
cd ${DIST_DIR:-./dist} || cd dist

# List files with human-readable sizes
echo "=== Final Artifacts ==="
ls -lh

# Generate checksums (IMPORTANT for security verification!)
sha256sum * > checksums.sha256

# Display checksums
echo "=== Checksums ==="
cat checksums.sha256
```

**Expected final output:**
```
=== Final Artifacts ===
-rw-r--r-- 1 user user 153M Apr  7 12:34 nickel-browser_1.0.0-alpha_amd64.deb
-rw-r--r-- 1 user user 200M Apr  7 12:36 Nickel-Browser-1.0.0-alpha.dmg
-rw-r--r-- 1 user user 160M Apr  7 12:37 Nickel-Browser-1.0.0-alpha.exe

=== Checksums ===
abc123def456...  nickel-browser_1.0.0-alpha_amd64.deb
mno345pqr678...  Nickel-Browser-1.0.0-alpha.dmg
stu901uvw234...  Nickel-Browser-1.0.0-alpha.exe
```

> 🎉 **Congratulations!** Your Nickel Browser builds are ready in the `dist/` directory!
> Test them: install the `.deb` with `sudo dpkg -i *.deb` (Linux) or double-click the `.dmg`/`.exe`.

---

## 🔧 Method B: Advanced Source Build (For Core Developers Only)

> ⚠️ **WARNING: EXPERTS ONLY** ⚠️
>
> This method compiles Chromium from source. It requires significant resources and is intended ONLY for developers who need to:
> - Modify Chromium C++ code
> - Test custom patches that affect compilation
> - Perform security audits of the build system
> - Create custom Chromium builds for research
>
> **99% of contributors should use Method A above.**

### System Requirements (Source Build)

| Component | Minimum | Recommended | Notes |
|-----------|---------|-------------|--------|
| **RAM** | 16 GB | 32–64 GB | More = faster compilation |
| **Disk Space** | 150 GB free | 300 GB+ SSD | Chromium source + build artifacts + obj files |
| **CPU** | 8-core x86_64 | 12+ cores | More cores = faster parallel compilation |
| **Swap File** | 32 GB | 64 GB | Essential for 16GB RAM systems |
| **OS** | Linux (Zorin/Ubuntu 22.04+) | Ubuntu 24.04 LTS | macOS and Windows possible but harder |
| **Time Required** | 6–10 hours | 2–4 hours | Depends heavily on hardware |
| **Skill Level** | Advanced Linux developer | Expert | Familiarity with GN, Ninja, Chromium build system |

### Source Build Overview

The source build process:

1. **Fetch Chromium** via Google's `depot_tools` (~35GB initial download, 30-60 minutes)
2. **Apply ungoogled-chromium patches** (remove Google telemetry, binaries, domains)
3. **Apply Nickel-specific patches** (privacy defaults, UI changes, feature additions)
4. **Configure build** with GN args (optimize for privacy and performance)
5. **Compile** with Ninja (4-8 hours depending on hardware)
6. **Package** for distribution (`.deb`, `.tar.xz`)

[**See detailed source-build walkthrough →**](docs/BUILD_SOURCE.md)

> 💡 **Tip:** The binary repackaging method (Method B) is useful for testing UI changes, branding updates, and packaging modifications quickly. Use source build if you need Nickel's native privacy features (ad-blocking engine, Tor, fingerprint protection) compiled in.

---

## 🔄 CI/CD Automation

### Source Build CI (`nickel-source-build.yml`) — Primary
Builds real Nickel Browser binaries from source.
- **Triggers:** Tags (`v*`), manual dispatch
- **Process:** `gclient sync` → UC patches → Nickel patches → `gn gen` → `ninja` → `.deb` + `.tar.xz`
- **Duration:** 4–8 hours (large runner)
- **Platform:** Linux x64 (macOS/Windows builds in future)

### Binary Repackaging CI (`nickel-production-build.yml`) — Testing/Branding
Downloads pre-built UC binaries and applies Nickel branding.
- **Triggers:** Tags (`v*`), weekly schedule, manual dispatch
- **Process:** Download UC binary → Apply branding → Package
- **Duration:** ~15 minutes
- **Platforms:** Linux, macOS, Windows

---

## 🐛 Troubleshooting

### Binary Build Issues (Method A)

| Problem | Solution |
|--------|----------|
| **"Could not find matching release"** | Check version format. Use `latest` or exact tag like `124.0.6367.82-1`. Check [UC releases](https://github.com/ungoogled-software/ungoogled-chromium-binaries/releases) for valid tags. |
| **Download fails (rate limited)** | Set `GITHUB_TOKEN` environment variable with GitHub PAT. Get token [here](https://github.com/settings/tokens) (needs `public_repo` scope only). |
| **"chrome binary not found"** | Ensure download completed successfully. Check `uc-binary/` or your custom target directory exists and contains `chrome` or `chromium` executable. |
| **Permission denied running scripts** | Run `chmod +x scripts/*.sh` before executing. Ensure scripts have Unix line endings (LF, not CRLF). |
| **dpkg-deb errors** | Check `DEBIAN/control` file in build-deb.sh: no trailing spaces, proper newlines between fields, `Architecture: amd64` correct. |
| **Wrong architecture error** | Binary builds are x86_64 only currently. ARM64 support planned for a future release. |
| **Checksum mismatch** | Re-download binary. File may have been corrupted during transfer. |

### Source Build Issues (Method B)

| Problem | Solution |
|--------|----------|
| **Out of memory during compile** | Increase swap to 64GB: `sudo fallocate -l 64G /swapfile && sudo mkswap /swapfile && sudo swapon /swapfile`. Reduce ninja jobs: `ninja -C out/Release chrome -j1`. |
| **Patch application failures** | Ensure Chromium version matches patch target exactly. Check `patches/` directory. Use `git apply --check` to test before applying. |
| **depot_tools not found** | Add `$HOME/depot_tools` to PATH permanently: `echo 'export PATH="$HOME/depot_tools:$PATH"' >> ~/.bashrc`. |
| **GN configuration errors** | Check `args.gn` for typos. Booleans must be `true`/`false` (not strings). Strings must be quoted. |
| **Build takes forever** | Use `tmux` to prevent terminal disconnection kills. Ensure sufficient swap space. Consider using ccache/sccache for incremental builds. |
| **Linker errors** | Missing library? Run `./build/install-build-deps.sh` (from depot_tools). Check `args.gn` for `use_sysroot` setting. |

---

## 📚 Additional Resources

- **[ungoogled-chromium Documentation](https://github.com/ungoogled-software/ungoogled-chromium#wiki)** — Our foundation. Comprehensive guides on building, patching, and maintaining.
- **[Chromium Build Instructions (Official)](https://chromium.googlesource.com/chromium/src/+/main/docs/linux/build_instructions.md)** — Upstream build reference.
- **[GN Build Configuration Reference](https://gn.googlesource.com/gn/+/main/docs/reference.md)** — Build system documentation.
- **[Nickel Browser Issue Tracker](https://github.com/Nickel-Browser/Nickel-Browser/issues)** — Report bugs here.
- **[Nickel Browser Discussions](https://github.com/Nickel-Browser/Nickel-Browser/discussions)** — Ask questions here.

---

**Happy Building!** Choose Method A for speed, Method B for complete control. 🪙🔨