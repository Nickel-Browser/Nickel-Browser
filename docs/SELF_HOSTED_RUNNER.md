# 🏗️ Self-Hosted Runner Setup for Nickel Browser

This guide describes how to set up a self-hosted GitHub Actions runner capable of performing full Chromium source compilations for Nickel Browser.

> **Why you need this:** Standard GitHub-hosted runners (including those available under GitHub Education and GitHub Pro) provide ~14 GB RAM and ~84 GB disk — not enough for a Chromium source build (requires 32+ GB RAM and 150+ GB disk). A self-hosted runner on your own hardware bypasses this limitation entirely.

---

## Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **CPU** | 8-core x86_64 | 16+ cores (AMD Ryzen 9 / Intel Core i9) |
| **RAM** | 16 GB | 32–64 GB |
| **Storage** | 150 GB free SSD | 300 GB+ NVMe SSD |
| **Bandwidth** | Any broadband | High-speed (downloads ~35 GB) |
| **Swap** | 32 GB | 64 GB (critical with 16 GB RAM) |

---

## Operating System

- **Ubuntu 22.04 LTS** — recommended and most tested
- Ubuntu 24.04 LTS — also works
- Debian 12 — should work with minor adjustments
- macOS / Windows source builds are not yet supported

---

## Step-by-Step Setup

### 1. Install System Dependencies

```bash
sudo apt-get update
sudo apt-get install -y \
  git curl wget python3 python3-pip \
  ninja-build pkg-config build-essential \
  clang lld binutils \
  libglib2.0-dev libgtk-3-dev libpulse-dev libasound2-dev libdbus-1-dev \
  libx11-dev libxcomposite-dev libxcursor-dev libxdamage-dev libxext-dev \
  libxfixes-dev libxi-dev libxrandr-dev libxss-dev libxtst-dev \
  libatk1.0-dev libcups2-dev libdrm-dev \
  mesa-common-dev libgbm-dev libssl-dev libnss3-dev libffi-dev \
  gperf bison flex dpkg-dev fakeroot xz-utils tar jq elfutils shellcheck
```

### 2. Configure Swap (Essential for 16–32 GB RAM Machines)

```bash
# Create a 64 GB swap file
sudo fallocate -l 64G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make it persistent across reboots
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify
free -h
```

### 3. Install depot_tools

```bash
git clone --depth=1 \
  https://chromium.googlesource.com/chromium/tools/depot_tools.git \
  "$HOME/depot_tools"

# Add to PATH permanently
echo 'export PATH="$HOME/depot_tools:$PATH"' >> ~/.bashrc
source ~/.bashrc

# Verify
which gclient && echo "✅ depot_tools ready"
```

### 4. Register the GitHub Actions Runner

1. Go to your repository on GitHub: **Settings → Actions → Runners**
2. Click **New self-hosted runner**
3. Select **Linux** and **x64**
4. Follow the on-screen instructions to download and configure the runner agent:

```bash
# Example (version numbers will differ — use the exact commands shown on GitHub):
mkdir -p "$HOME/actions-runner" && cd "$HOME/actions-runner"

# Download runner (use the URL shown by GitHub)
curl -o actions-runner-linux-x64.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.xxx.x/actions-runner-linux-x64-2.xxx.x.tar.gz

tar xzf ./actions-runner-linux-x64.tar.gz

# Configure runner — replace TOKEN and REPO_URL with values shown by GitHub
./config.sh \
  --url https://github.com/Nickel-Browser/Nickel-Browser \
  --token YOUR_TOKEN_FROM_GITHUB
```

5. When prompted for **additional labels**, enter:
   ```
   self-hosted,linux,x64,nickel-builder
   ```

6. When prompted for **work folder**, enter a path on a disk with 150+ GB free:
   ```
   /data/nickel-runner/_work
   ```
   (create this directory first: `sudo mkdir -p /data/nickel-runner/_work && sudo chown $USER /data/nickel-runner/_work`)

### 5. Start the Runner as a systemd Service (Recommended)

Running as a service ensures the runner restarts automatically after a reboot:

```bash
# Install the service (from inside $HOME/actions-runner)
sudo ./svc.sh install

# Start the service
sudo ./svc.sh start

# Check status
sudo ./svc.sh status
```

Alternatively, for quick testing, run interactively:
```bash
./run.sh
```

---

## Triggering a Source Build

Once your runner shows as **Idle** in GitHub → Settings → Actions → Runners:

1. Go to the **Actions** tab in your GitHub repository
2. Select workflow: **🛡️ Nickel Browser — Source Build (Linux)**
3. Click **Run workflow**
4. Optionally specify a custom `uc_version` (default: reads from `.chromium_version`)
5. Click **Run workflow** to start

The workflow will automatically route to your runner because it has the `nickel-builder` label.

**Expected build time:** 3–8 hours depending on CPU core count and RAM.

---

## Alternative: GitHub Large Runners (Paid)

If you upgrade to **GitHub Team** ($4/user/month) or **GitHub Enterprise**, you get access to [larger GitHub-hosted runners](https://docs.github.com/en/actions/using-github-hosted-runners/using-larger-runners):

| Runner | CPU | RAM | Disk | Est. Build Time |
|--------|-----|-----|------|-----------------|
| `ubuntu-22.04-8-core` | 8 cores | 32 GB | 300 GB | ~4 hours |
| `ubuntu-22.04-16-core` | 16 cores | 64 GB | 600 GB | ~2 hours |
| `ubuntu-22.04-32-core` | 32 cores | 128 GB | 1200 GB | ~1 hour |

To use a large runner, change the `runs-on` line in `.github/workflows/nickel-source-build.yml`:

```yaml
# Change this:
runs-on: ubuntu-22.04

# To this (for example):
runs-on: ubuntu-22.04-32-core
```

---

## Troubleshooting

| Problem | Solution |
|---------|---------|
| **Disk full during build** | Ensure 150+ GB free before starting. Clean old build artifacts: `rm -rf ungoogled-chromium/chromium/out` |
| **OOM (Out of Memory) during linking** | Increase swap (see Step 2). Reduce ninja jobs: edit workflow `NINJA_JOBS` input to `4`. |
| **Permission denied** | Ensure the runner user has write access to the work folder. Check with `ls -la /data/nickel-runner/` |
| **Runner offline / not picked up** | Check the runner service: `sudo ./svc.sh status`. Ensure labels match exactly: `self-hosted,linux,x64,nickel-builder` |
| **depot_tools not found** | Confirm `$HOME/depot_tools` is in PATH: `echo $PATH`. Re-source: `source ~/.bashrc` |
| **gclient sync hangs** | Network issue. Check internet access from the runner machine. Some corporate firewalls block `googlesource.com`. |
| **Patch apply fails** | The patch was written for a specific Chromium version. Ensure `.chromium_version` matches the UC tag you're building. |
