# Self-Hosted Runner Guide for Nickel Browser

Building Nickel Browser from source requires a significant amount of computing resources. While our production workflow uses pre-built binaries for fast delivery, the full source build requires a self-hosted runner.

## 📋 Minimum Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 32 GB | 64 GB+ |
| CPU | 8 Cores (x86_64) | 16-32 Cores |
| Disk | 150 GB Free (SSD) | 300 GB+ NVMe |
| OS | Ubuntu 22.04 / 24.04 | Ubuntu 24.04 |

---

## 🏗️ Setting up the Runner

### 1. Register the Runner
Follow the official GitHub instructions to [add a self-hosted runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners) to your repository.

- **Label**: Ensure the runner has the `self-hosted` label.
- **Name**: You can name it `nickel-builder-01`.

### 2. Install Build Dependencies
Nickel Browser's build scripts will attempt to install dependencies, but it's recommended to pre-install them:

```bash
sudo apt update
sudo apt install -y git curl wget python3 python3-pip python3-venv \
    ninja-build pkg-config build-essential \
    libglib2.0-dev libgtk-3-dev libpulse-dev libasound2-dev \
    libdbus-1-dev libx11-dev libxcomposite-dev libxcursor-dev \
    libxdamage-dev libxfixes-dev libxi-dev libxrandr-dev \
    libxss-dev libxtst-dev libatk1.0-dev libcups2-dev \
    libdrm-dev mesa-common-dev libgbm-dev \
    libssl-dev libnss3-dev libffi-dev jq gperf bison
```

### 3. Setup depot_tools
The builder must have `depot_tools` in its path:

```bash
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git $HOME/depot_tools
echo 'export PATH="$HOME/depot_tools:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## 🚀 Running the Workflow

Once your runner is online and configured:

1. Navigate to the **Actions** tab in your GitHub repository.
2. Select the **🛡️ Nickel Browser Full Source Build** workflow.
3. Click **Run workflow**.
4. (Optional) Provide a custom Chromium version.
5. Click **Run workflow** again.

The runner will pull the Chromium source (~35GB), apply Nickel's privacy and branding patches, and compile the entire browser.

---

## 🛠️ Troubleshooting

### Disk Space
Chromium builds can consume up to 100GB of disk space during the compilation process. Ensure the partition where the runner is installed has sufficient headroom.

### Out of Memory
If the build fails with an "OOM" (Out of Memory) error, ensure you have a swap file of at least 32GB:

```bash
sudo fallocate -l 32G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Build Time
A full build can take anywhere from 2 to 12 hours depending on your CPU. Ensure your machine has adequate cooling.

---

<p align="center">
  <em>Nickel Browser — The browser you always deserved.</em> 🐅
</p>
