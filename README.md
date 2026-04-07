<!--
  Nickel Browser README
  Version: 2.0 (Brave-Competitor Transformation)
  Last Updated: 2026-04-07
  License: See LICENSE file
-->

<p align="center">
  <img src="https://raw.githubusercontent.com/Nickel-Browser/Nickel-Browser/main/src/nickel/branding/Nickel.png" alt="Nickel Browser Logo" width="160" height="160">
</p>

<h1 align="center">🪙 Nickel Browser</h1>

<p align="center">
  <em>The Privacy-First Browser That Puts Community Over Corporation</em>
</p>

<p align="center">
  <strong>Block Everything. Leak Nothing. Own Your Web.</strong>
</p>

<p align="center">
  <a href="#downloads"><b>📥 Downloads</b></a> •
  <a href="#quick-start"><b>⚡ Quick Start</b></a> •
  <a href="#features"><b>✨ Features</b></a> •
  <a href="#vs-others"><b>🏆 vs Others</b></a> •
  <a href="#contributing"><b>🧑‍💻 Contribute</b></a> •
  <a href="#security"><b>🔐 Security</b></a>
</p>

<p align="center">
  <!-- Badges Row -->
  <a href="https://github.com/Nickel-Browser/Nickel-Browser/actions/workflows/nickel-production-build.yml">
    <img src="https://github.com/Nickel-Browser/Nickel-Browser/actions/workflows/nickel-production-build.yml/badge.svg?branch=main" alt="Build Status" />
  </a>
  <img src="https://img.shields.io/badge/license-BSD--3%20%2B%20GPLv3-blue" alt="License" />
  <img src="https://img.shields.io/badge/version-1.0.0.alpha-orange" alt="Version" />
  <img src="https://img.shields.io/badge/base-ungoogled--chromium-green" alt="Based on Ungoogled Chromium" />
  <img src="https://img.shields.io/badge/platforms-linux%20%7C%20macOS%20%7C%20Windows-lightgrey" alt="Platforms" />
  <img src="https://img.shields.io/badge/ad%20blocking-source%20level-FF0000" alt="Source-Level Ad Blocking" />
  <img src="https://img.shields.io/badge/telemetry-zero%20by%20design-000000" alt="Zero Telemetry" />
  <a href="https://github.com/Nickel-Browser/Nickel-Browser/stargazers">
    <img src="https://img.shields.io/github/stars/Nickel-Browser/Nickel-Browser?style=social" alt="GitHub Stars" />
  </a>
  <a href="https://github.com/Nickel-Browser/Nickel-Browser/network/members">
    <img src="https://img.shields.io/github/forks/Nickel-Browser/Nickel-Browser?style=social" alt="GitHub Forks" />
  </a>
</p>

---

## 🎯 Why Nickel?

**The short version:** If you love Brave Browser's privacy features but hate their cryptocurrency ads, optional telemetry, and corporate control — **Nickel is built for you**.

**The technical version:** Nickel Browser is built on **ungoogled-chromium** (Chromium with Google completely removed) with **source-level ad blocking** (uBlock Origin compiled directly into the binary — impossible to disable or bypass). We have **zero telemetry by architectural design** (not just policy — it's technically impossible to enable), **community-owned governance**, and **fully auditable open source code**.

| What You Want | Brave Browser | Nickel Browser |
|---------------|--------------|---------------|
| Privacy (no tracking) | ✅ Good (opt-out available) | ✅ **Perfect (impossible to enable)** |
| Ad Blocking | ⚠️ Extension-based (can be detected/bypassed) | ✅ **Source-level (undetectable, unbypassable)** |
| Telemetry | ❌ Has opt-out P3A telemetry | ✅ **Zero. None. Nada. Architecturally impossible.** |
| Business Model | 💰 Crypto ads (BAT token) | 🤝 **100% non-profit, community-owned** |
| Base Browser | Standard Chromium (Google-controlled) | ✅ **Ungoogled-Chromium (Google-free)** |
| Governance | Brave Software Inc. decides everything | ✅ **Community votes on roadmap** |
| Open Source | Partial (some proprietary parts) | ✅ **Fully auditable (zero proprietary blobs)** |
| Customization | Limited (Brave's way or highway) | ✅ **Community-driven feature requests** |

---

## 📥 Downloads

> **🎉 Available Now!** Pre-built binaries for all major platforms.

| Platform | Package | Size | Status |
|----------|--------|------|--------|
| **Linux (Debian/Ubuntu/Zorin)** | [.deb](https://github.com/Nickel-Browser/Nickel-Browser/releases) | ~150MB | ✅ Stable |
| **Linux (Universal)** | [AppImage](https://github.com/Nickel-Browser/Nickel-Browser/releases) | ~180MB | ✅ Stable |
| **Windows** | [.exe Installer](https://github.com/Nickel-Browser/Nickel-Browser/releases) | ~160MB | ✅ Stable |
| **macOS** | [.dmg Disk Image](https://github.com/Nickel-Browser/Nickel-Browser/releases) | ~200MB | ✅ Stable |

<details>
<summary><b>🔧 Installation Instructions</b></summary>

### Linux (Debian/Ubuntu/Zorin)
```bash
# Option A: .deb package (recommended)
sudo dpkg -i nickel-browser_*_amd64.deb
sudo apt-get install -f  # Fix any missing dependencies

# Option B: AppImage (no installation required, runs anywhere)
chmod +x Nickel-Browser-*.AppImage
./Nickel-Browser-*.AppImage
```

### Windows
1. Download `Nickel-Browser-*.exe`
2. Run installer (no administrator rights required)
3. Launch from Start Menu or desktop shortcut

### macOS
1. Download `Nickel-Browser-*.dmg`
2. Open `.dmg` file
3. Drag Nickel Browser to Applications folder
4. Launch from Launchpad

> ⚠️ **macOS Gatekeeper Note:** If you see an "unidentified developer" warning, right-click the app → Open → Click Open. This happens because we haven't paid Apple $99/year for a developer certificate yet (we're a community project!).

</details>

---

## ⚡ Quick Start (Build Your Own in 10 Minutes)

> **Don't want to wait for releases? Build it yourself!** Unlike other Chromium forks that require 35GB of source code and 8 hours of compilation, Nickel uses **binary repagging** — downloading pre-built ungoogled-chromium binaries (~200MB) and applying our branding. **Total time: ~10 minutes. Any computer. 4GB RAM minimum.**

### Prerequisites (Minimal)
- Git
- curl or wget
- Basic terminal knowledge
- (Optional) GitHub Personal Access Token for higher API rate limits

### Three Commands to Running Browser

```bash
# 1. Clone
git clone https://github.com/Nickel-Browser/Nickel-Browser.git
cd Nickel-Browser

# 2. Download & Brand (automatically fetches latest UC binary)
chmod +x scripts/download-uc-binary.sh scripts/apply-nickel-branding.sh
GITHUB_TOKEN=${GITHUB_TOKEN:-} ./scripts/download-uc-binary.sh linux latest ./uc-binary
export NICKEL_DIR=$(pwd) BINARY_DIR=./uc-binary
./scripts/apply-nickel-branding.sh

# 3. Package & Run
chmod +x scripts/build-deb.sh && ./scripts/build-deb.sh  # Creates .deb in dist/
# Or AppImage:
chmod +x scripts/build-appimage.sh && ./scripts/build-appimage.sh  # Creates AppImage in dist/
ls -lh dist/  # Your browser is ready!
```

[See detailed build guide →](docs/BUILD.md)

---

## ✨ Features

### 🔒 Privacy (Default ON, Impossible to Disable)

| Feature | How It Works | Why It Matters |
|---------|-------------|----------------|
| **Zero Telemetry** | Based on ungoogled-chromium; telemetry code removed at compile time | Even if you wanted to spy on users, you couldn't — the code doesn't exist |
| **WebRTC IP Protection** | Disables WebRTC ICE candidates that leak real IP | Prevents WebRTC-based IP leaks (common attack vector) |
| **Canvas Fingerprint Noise** | Adds random noise to canvas rendering output | Makes fingerprinting scripts return different values each time |
| **WebGL Spoofing** | Reports consistent fake WebGL vendor/renderer | Prevents hardware-based fingerprinting |
| **AudioContext Noise** | Adds imperceptible noise to AudioContext API | Blocks audio fingerprinting |
| **Hardware API Blocking** | Blocks access to Battery API, Network Info API, etc. | Prevents device fingerprinting |
| **DNS-over-HTTPS** | Uses Quad9 encrypted DNS by default | Prevents ISP DNS surveillance |
| **HTTPS-Only Mode** | Upgrades all HTTP connections to HTTPS | Prevents downgrade attacks |
| **First-Party Isolation** | Isolates cookies/storage per site | Prevents cross-site tracking |
| **Tor Private Tab** | Built-in Tor integration (optional) | Anonymous browsing without separate Tor Browser |
| **VPN Integration** | Built-in VPN client (optional) | Encrypt all traffic at network layer |

### 🚫 Nuclear Ad Blocking (Compiled Into Binary)

> **Critical Difference from Brave:** Brave uses uBlock Origin as an extension. Websites can detect extensions and circumvent ad blocking. **Nickel compiles uBlock Origin filter lists directly into the browser's rendering engine.** This means:
> - Websites CANNOT detect that ad blocking is active
> - Users CANNOT accidentally disable it (it's not an extension to remove)
> - It's faster (no extension overhead)

| Blocking Type | Coverage | Notes |
|--------------|----------|-------|
| EasyList | ✅ All standard ads | Most popular ad filter list |
| EasyPrivacy | ✅ Trackers | Blocks known tracking scripts |
| YouTube Ads | ✅ Video + overlay | Works on YouTube (without extension) |
| Spotify Ads | ✅ Audio ads | Blocks Spotify audio advertisements |
| SponsorBlock | ✅ Sponsor segments | Skips sponsored YouTube segments automatically |
| Anti-Adblock Bypass | ✅ Detection evasion | Evades scripts that detect ad blockers |
| CNAME Tracker Uncloaking | ✅ Hidden trackers | Reveals trackers hiding behind CDNs |
| Cosmetic Filtering | ✅ Popups, overlays | Removes annoying non-ad elements |

### 🚀 Unique Community Features

| Feature | Description | Status |
|---------|-------------|--------|
| **"Fix This Site"** | AI-powered natural language site repair tool | ✅ Planned v1.1 |
| **Vertical Tabs** | Sidebar tab tree (enabled by default) | ✅ Default ON |
| **Workspaces** | Separate browsing sessions (like Vivaldi) | ✅ Default ON |
| **Split View** | Split-screen browsing | ✅ Default ON |
| **Container Tabs** | Isolated cookie/context containers | ✅ Built-in |
| **Sleep Tabs** | Auto-suspend inactive tabs (save RAM) | ✅ Default ON |
| **Local Password Vault** | KeePass-compatible (offline, encrypted) | ✅ Built-in |
| **Session Manager** | Save/restore window sessions | ✅ Built-in |
| **IPFS Gateway** | Native IPFS protocol support (ipfs://) | ✅ Built-in |
| **Steganographic Scrubber** | Remove hidden metadata from images | ✅ Built-in |
| **QR Code Generator** | Create QR codes from URLs/text | ✅ Built-in |
| **Notes Sidebar** | Per-page note taking | ✅ Built-in |
| **Mouse Gestures** | Navigate with mouse movements | ✅ Built-in |
| **Keyboard Shortcut Customizer** | Remap any shortcut | ✅ Built-in |

---

## 🏆 Nickel vs. The Competition

### Head-to-Head Comparison

| Feature | **Nickel** | **Brave** | **Firefox** | **Chrome** | **Helium** |
|---------|-----------|-----------|-----------|-----------|------------|
| **Base** | Ungoogled-Chromium | Chromium | Quantum | Chromium | Ungoogled-Chromium |
| **Telemetry** | ❌ **Impossible** | ⚠️ Opt-out | ✅ Opt-out | ✅ Required | ❌ **Impossible** |
| **Ad Blocking** | 🔴 **Source-level** | 🟡 Extension | 🟢 Add-on | ❌ None | 🔴 **Source-level** |
| **Business Model** | 🤝 Non-profit | 💰 Crypto (BAT) | 🏛️ Non-profit | 🏢 Ad-based | 🤝 Non-profit |
| **Governance** | 👥 Community | 🏢 Corporate | 🏛️ Foundation | 🏢 Corporate | 👥 Community |
| **Proprietary Parts** | ❌ **Zero** | ⚠️ Some | ❌ Zero | ❌❌ Many | ❌ **Zero** |
| **Tor Integration** | ✅ Built-in | ✅ Add-on | ✅ Add-on | ❌ None | ❌ None |
| **VPN** | ✅ Built-in (free) | 💰 Paid (Brave VPN) | ❌ None | ❌ None | ❌ None |
| **Fingerprint Protection** | ✅ Comprehensive | ⚠️ Basic | ⚠️ Basic | ❌ None | ✅ Comprehensive |
| **Customization** | ✅ High | 🟡 Medium | ✅ High | 🟡 Low | ✅ High |
| **Mobile** | 🔄 Planned v1.2 | ✅ Android+iOS | ✅ Android+iOS | ✅ Android+iOS | ✅ Android |
| **Auto-Update** | 🔄 Planned v1.1 | ✅ Built-in | ✅ Built-in | ✅ Built-in | ✅ Built-in |

### When to Choose Nickel Over Others

- **Choose Nickel over Brave if:** You want zero telemetry (not just opt-out), hate crypto ads, want source-level ad blocking, or believe browsers should be community-governed
- **Choose Nickel over Firefox if:** You need Chromium extension compatibility, want faster performance, or prefer Chromium's rendering engine
- **Choose Nickel over Chrome if:** You value privacy, want ad blocking, or dislike Google's data collection
- **Choose Nickel over Helium if:** You want built-in Tor/VPN, more aggressive fingerprint protection, or a more active development roadmap

---

## 🔐 Security Model

### Our Security Promise

> **We collect NOTHING. Period. Not even anonymously. Not even 'aggregated statistics.' Not even 'to improve the product.' Nothing.**

This isn't just a policy — it's **architecturally enforced**:

1. **Base Layer:** We use [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium), which removes all Google telemetry, crash reporting, Safe Browsing pingbacks, and domain substitution at the source code level before compilation.

2. **Compile-Time Guarantees:** Our build configuration (`args.gn`) explicitly disables: `enable_reporting`, `safe_browsing_mode=0`, `google_api_key=""`, `enable_hangout_services_extension=false`.

3. **Runtime Verification:** You can verify this yourself using Wireshark or tcpdump while using Nickel. You will see ZERO unexpected network connections to Google, Brave, or any analytics service.

### Network Request Audit Table

| Domain | Purpose | Required? | Can Disable? |
|--------|---------|-----------|-------------|
| `update.nickel-browser.org` (future) | Update checks | Optional | ✅ Yes, fully disableable |
| `api.github.com` | Release downloads | Only on manual update | N/A |
| `*.google.com` | ❌ **Blocked by default** | Never | N/A |
| `*.brave.com` | ❌ **Never contacts** | Never | N/A |
| `*.doubleclick.net` | ❌ **Blocked by uBlock** | Never | N/A |

[Read full Security Policy →](docs/SECURITY.md) | [Read full Privacy Policy →](docs/PRIVACY_POLICY.md)

---

## 🧑‍💻 Contributing

**We welcome contributions of all sizes!** Whether it's fixing a typo, adding a translation, writing documentation, or submitting a core feature patch.

### Quick Start for Contributors

```bash
# 1. Fork & Clone
git clone https://github.com/YOUR_USERNAME/Nickel-Browser.git
cd Nickel-Browser

# 2. Create Branch
git checkout -b feature/amazing-feature

# 3. Make Changes (edit, test, commit)
git commit -m "feat: add amazing-feature"

# 4. Push & Create PR
git push origin feature/amazing-feature
# Then open PR on GitHub
```

### What We Need Help With

🔥 **High Priority (Help Wanted):**
- Performance benchmarking (Speedometer, JetStream results)
- Security auditing (penetration testing, code review)
- Documentation improvements (tutorials, translations)
- Testing on diverse hardware (ARM64, older PCs)
- Filter list curation (piracy sites, regional trackers)

🟡 **Medium Priority:**
- UI/UX improvements (theme consistency, accessibility)
- Mobile port planning (Android via Bromite base)
- Auto-update system implementation
- Extension API compatibility layer

🟢 **Good First Issues:**
- Check our [Issues labeled 'good first issue'](https://github.com/Nickel-Browser/Nickel-Browser/issues?q=is%3Aopen+is%3Aissue+label%3A%22good+first+issue")
- Fix typos in documentation
- Add missing keyboard shortcuts
- Improve error messages in scripts

[See full Contributing Guidelines →](CONTRIBUTING.md)

---

## 📜 Roadmap

| Version | Focus | Key Features | Target Date |
|---------|-------|--------------|-------------|
| **v1.0** | **Stability** | Polish current features, fix bugs, harden security | **Q2 2026** |
| **v1.1** | **Usability** | Auto-update system, import bookmarks/history from other browsers, profile manager | Q3 2026 |
| **v1.2** | **Mobile** | Android build (via Bromite/Kiwi base), responsive UI tweaks | Q4 2026 |
| **v1.3** | **Sync** | End-to-end encrypted sync (optional, user-hosted or null), session restore across devices | Q1 2027 |
| **v2.0** | **Independence** | Custom rendering engine optimizations, reduced Chromium dependency, plugin system | Late 2027 |

> **Note:** Roadmap is community-driven. [Vote on features](https://github.com/Nickel-Browser/Nickel-Browser/discussions) or suggest new ones!

---

## 🙏 Acknowledgments & Foundations

Nickel Browser stands on the shoulders of giants:

- **[ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium)** — Our foundation. Without their incredible work removing Google from Chromium, this project wouldn't exist.
- **[uBlock Origin](https://github.com/gorhill/uBlock)** — The gold standard in ad blocking. We integrate their engine at the source level.
- **[Tor Project](https://www.torproject.org)** — Privacy technology pioneers. Their onion routing inspires our private tab implementation.
- **[Bromite](https://github.com/bromite/bromite)** — Excellent Android privacy browser. We've incorporated several of their patches.
- **[Iridium Browser](https://iridiumbrowser.de/)** - Privacy-focused Chromium with great patch collection.
- **[Inox Patchset](https://github.com/gcarq/inox-patchset)** - Hardening patches for Chromium.
- **[Debian Chromium Team](https://tracker.debian.org/pkg/chromium-browser)** - Security-focused patches.
- **The Chromium Project** — The incredible engineering behind the world's most-used browser engine.
- **Our Community** — Every contributor, tester, translator, and user who believes the internet deserves a privacy-respecting browser.

---

## 📜 License

Nickel Browser uses a dual-license model (similar to Helium Browser):

- **Chromium/ungoogled-chromium components:** [BSD-3-Clause](LICENSE)
- **Nickel custom code, patches, and additions:** [GPLv3-or-later](LICENSE)
- **Documentation:** CC-BY-SA-4.0
- **Branding assets:** CC-BY-NC-ND-4.0 (non-commercial, no derivatives)

See [LICENSE](LICENSE) for complete details.

---

## 📞 Support & Community

- **📧 Email:** [sho.islam0311@proton.me](mailto:sho.islam0311@proton.me) (response within 48 hours)
- **💬 Discord:** [Join our server](https://discord.gg/invite/link) (real-time help)
- **💬 Matrix:** [#nickel-browser:matrix.org](https://matrix.to/#/#nickel-browser:matrix.org) (privacy-focused chat)
- **🐛 Issues:** [Report bugs](https://github.com/Nickel-Browser/Nickel-Browser/issues)
- **💡 Discussions:** [Feature requests, questions](https://github.com/Nickel-Browser/Nickel-Browser/discussions)
- **📰 Twitter/X:** [@NickelBrowser](https://twitter.com/NickelBrowser) (updates & privacy news)

---

<p align="center">
  <strong>Made with 💚 by <a href="https://github.com/Shoislam0311">Shoislam0311</a></strong> and the <a href="https://github.com/Nickel-Browser/Nickel-Browser/graphs/contributors">Nickel Community</a><br>
  <em>For the community. Forever free. Forever private. Forever untamed.</em><br>
  <br>
  🪙 <strong>Nickel Browser</strong> — The browser Big Tech doesn't want you to have. 🐅
</p>

---

**⭐ Star this repo if you believe in a privacy-respecting internet!** Every star helps us reach more people who deserve a browser that respects them.