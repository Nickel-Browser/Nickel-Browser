# 🪙 Nickel Browser

<p align="center">
  <img src="src/nickel/branding/Nickel.png" width="128" height="128" alt="Nickel Browser Logo">
</p>

<h3 align="center">The Browser The Community Always Deserved</h3>
<p align="center"><strong>Free. Fearless. Fortified.</strong></p>

<p align="center">
  <a href="#features">Features</a> •
  <a href="#download">Download</a> •
  <a href="#building">Building</a> •
  <a href="#privacy">Privacy</a> •
  <a href="#contributing">Contributing</a>
</p>

---

## 🛡️ What is Nickel Browser?

**Nickel Browser** is a privacy-first, community-driven web browser built on ungoogled-chromium. It combines the speed and compatibility of Chromium with nuclear-grade privacy protections, built-in ad-blocking, and features the community has been demanding for years.

> 🐅 **Powered by the Royal Bengal Tiger** — fierce, fast, and untamable.

---

## ✨ Features

### 🔒 Privacy & Security

| Feature | Nickel | Chrome | Brave | Firefox |
|---------|--------|--------|-------|---------|
| Zero Google Telemetry | ✅ Default | ❌ | ⚠️ Partial | ✅ |
| WebRTC IP Protection | ✅ Default | ❌ | ✅ | ⚠️ |
| Canvas Fingerprint Noise | ✅ Default | ❌ | ⚠️ | ❌ |
| WebGL Spoofing | ✅ Default | ❌ | ❌ | ❌ |
| AudioContext Noise | ✅ Default | ❌ | ❌ | ❌ |
| Hardware API Blocking | ✅ Default | ❌ | ❌ | ❌ |
| DNS-over-HTTPS (Quad9) | ✅ Default | ❌ | ⚠️ | ⚠️ |
| HTTPS-Only Mode | ✅ Default | ❌ | ✅ | ✅ |
| First-Party Isolation | ✅ Default | ❌ | ❌ | ✅ |
| Tor Private Tab | ✅ Built-in | ❌ | ✅ | ❌ |
| VPN Integration | ✅ Built-in | ❌ | 💰 Paid | ❌ |

### 🚫 Nuclear Ad Blocking

| Feature | Nickel | Others |
|---------|--------|--------|
| uBlock Origin Engine (MV2) | ✅ Source-level | ❌ Extension only |
| EasyList + EasyPrivacy | ✅ Bundled | ⚠️ |
| YouTube Ad Block | ✅ Built-in | ⚠️ Extension |
| Spotify Ad Block | ✅ Built-in | ❌ |
| SponsorBlock Integration | ✅ Built-in | ❌ Extension |
| Anti-Adblock Bypass | ✅ Default | ❌ |
| CNAME Uncloaking | ✅ Default | ❌ |
| Cosmetic Filtering | ✅ Native | ⚠️ |

### 🚀 Community-Demanded Features

| Feature | Status |
|---------|--------|
| **"Fix This Site"** — Natural language site repair | ✅ Unique to Nickel |
| Vertical Tabs | ✅ Default ON |
| Workspaces | ✅ Default ON |
| Split View | ✅ Default ON |
| Tab Groups + Colors | ✅ Default ON |
| Reader Mode | ✅ Built-in |
| RSS Feed Reader | ✅ Built-in |
| Screenshot Tool + Annotate | ✅ Built-in |
| Container Tabs | ✅ Built-in |
| Sleep Tabs (Auto-suspend) | ✅ Default ON |
| Session Manager | ✅ Built-in |
| Download Manager (aria2) | ✅ Built-in |
| Local Password Vault | ✅ KeePass-compatible |
| Picture-in-Picture | ✅ Global button |
| QR Code Generator | ✅ Built-in |
| JSON/XML Viewer | ✅ Built-in |
| Notes Sidebar | ✅ Per-page |
| Keyboard Shortcut Customizer | ✅ Built-in |
| Mouse Gestures | ✅ Built-in |

### 🌐 Network & Advanced

| Feature | Status |
|---------|--------|
| Torrent Magnet Handler | ✅ Built-in |
| IPFS Gateway Support | ✅ Native |
| URL Parameter Stripping | ✅ Auto |
| Cookie Auto-Delete | ✅ On tab close |
| Per-site JavaScript Toggle | ✅ One-click |
| Custom User-Agent Switcher | ✅ Built-in |
| Privacy Report Card | ✅ Per-site |
| Network Monitor Panel | ✅ Per-tab |
| Local Password Breach Check | ✅ HIBP offline |
| Anti-Phishing (Local ML) | ✅ ONNX model |
| Self-Destruct Tabs | ✅ Timer-based |
| Local File Encryption Vault | ✅ Built-in |
| One-Click Identity Rotation | ✅ Built-in |
| Steganographic Image Scrubber | ✅ Built-in |

---

## 📥 Download

| Platform | Download | Status |
|----------|----------|--------|
| Linux (.deb) | [Download](https://github.com/Nickel-Browser/Nickel-Browser/releases) | ✅ Coming Soon |
| Linux (AppImage) | [Download](https://github.com/Nickel-Browser/Nickel-Browser/releases) | ✅ Coming Soon |
| Windows (.exe) | [Download](https://github.com/Nickel-Browser/Nickel-Browser/releases) | ✅ Coming Soon |
| macOS (.dmg) | [Download](https://github.com/Nickel-Browser/Nickel-Browser/releases) | ✅ Coming Soon |

### Install on Linux

```bash
# Debian/Ubuntu/Zorin
sudo dpkg -i nickel-browser_1.0.0_amd64.deb

# Or use AppImage
chmod +x Nickel-Browser-1.0.0.AppImage
./Nickel-Browser-1.0.0.AppImage
```

### Install on Windows

Download and run `Nickel-Browser-1.0.0.exe` — no admin required.

### Install on macOS

Download and open `Nickel-Browser-1.0.0.dmg`, drag to Applications.

---

## 🏗️ Building from Source

### System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 8 GB | 16–32 GB |
| Disk | 100 GB free | 250 GB+ SSD |
| CPU | 4-core x86_64 | 8+ cores |
| Swap | 16 GB | 32 GB |
| OS | Linux (Zorin/Ubuntu) | Any Linux |

### Quick Build (Zorin OS 18 Pro)

```bash
# 1. Clone the repository
git clone https://github.com/Nickel-Browser/Nickel-Browser.git
cd nickel

# 2. Run setup (installs dependencies)
./scripts/setup.sh

# 3. Create swap (if <32GB RAM)
./scripts/create-swap.sh

# 4. Fetch Chromium source (~35GB)
./scripts/fetch-chromium.sh

# 5. Apply all patches
./scripts/apply-patches.sh

# 6. Build (4-8 hours on 4-core)
./scripts/build.sh

# 7. Package
./scripts/package.sh
```

### Detailed Build Guide

See [BUILD.md](docs/BUILD.md) for complete step-by-step instructions.

---

## 🔐 Privacy Policy

> **We collect NOTHING. Period.**

Nickel Browser is designed with absolute privacy in mind:

- ✅ Zero telemetry or metrics
- ✅ No data leaves your device
- ✅ No cloud services required
- ✅ No account needed
- ✅ No AI training on your data
- ✅ Local-first everything
- ✅ Open source — verify yourself

Read our full [Privacy Policy](docs/PRIVACY_POLICY.md).

---

## 🧑‍💻 Contributing

We welcome contributors! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Start for Developers

```bash
# Fork and clone
git clone https://github.com/Nickel-Browser/Nickel-Browser.git
cd nickel

# Create branch
git checkout -b feature/amazing-feature

# Make changes and commit
git commit -m "Add amazing feature"

# Push and PR
git push origin feature/amazing-feature
```

### Community

- 📧 [Email](mailto:sho.islam0311@proton.me)

---

## 📜 License

Nickel Browser is dual-licensed:

- **Chromium base**: BSD-3-Clause
- **Nickel additions**: GPLv3

See [LICENSE](LICENSE) for full details.

---

## 🙏 Acknowledgments

- [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium) — Privacy-focused Chromium base
- [uBlock Origin](https://github.com/gorhill/uBlock) — Ad-blocking engine
- [SponsorBlock](https://sponsor.ajay.app) — YouTube sponsor skipper
- [Tor Project](https://www.torproject.org) — Tor integration
- [Bromite/Cromite](https://github.com/bromite/bromite) — Fingerprinting patches

---

## 🗺️ Roadmap

| Version | Features | ETA |
|---------|----------|-----|
| v1.1 | Auto-update system, more filter lists | Maybe June/July, 2026 |
| v1.2 | Mobile Android build | Based On Response |
| v1.3 | Sync v2 (end-to-end encrypted) | Based On Community Response |
| v2.0 | Custom layout engine optimizations | Maybe Late 2026 |

---

<p align="center">
  <strong>Made with 💚 by [sho.islam0311](https://github.com/Shoislam0311), for the community.</strong>
</p>

<p align="center">
  🪙 <em>Nickel Browser — The browser you always deserved.</em> 🐅
</p>
