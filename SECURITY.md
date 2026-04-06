# Nickel Browser Security Policy

## 🛡️ Our Security Commitment

Nickel Browser is built on the foundation of **Security through Transparency**. As a community-driven fork of ungoogled-chromium, we prioritize user safety by eliminating all proprietary Google components and applying rigorous hardening patches.

---

## 🔍 Supply Chain Security

We implement several modern security standards to ensure the integrity of our builds:

### 1. SBOM (Software Bill of Materials)
Every Nickel Browser production release includes a machine-readable **SBOM (SPDX JSON)** file. This allows security professionals and automated tools to:
- Inventory all included libraries and dependencies.
- Track known vulnerabilities (CVEs) across the entire stack.
- Verify license compliance.

### 2. Binary Integrity
To prevent tampering during transit, we provide:
- **SHA256 Checksums**: Included for every release asset.
- **Digital Signatures**:
  - **Linux**: GPG-signed detached signatures (`.sig`).
  - **macOS**: Apple Developer-signed DMG with Gatekeeper notarization.
  - **Windows**: EV Code Signed executables to ensure SmartScreen trust.

---

## 🐛 Reporting a Vulnerability

If you discover a security vulnerability in Nickel Browser, please help us fix it by reporting it responsibly.

### 📧 Reporting Process
- **Email**: Send your findings to [sho.islam0311@proton.me](mailto:sho.islam0311@proton.me).
- **Format**: Please include:
  - A clear description of the vulnerability.
  - Steps to reproduce (POC).
  - Potential impact.
  - Recommended fix (if known).

### ⏳ Response Timeline
1. **Acknowledgement**: We aim to acknowledge your report within **24 hours**.
2. **Triaging**: We will confirm the vulnerability and assess its severity within **48 hours**.
3. **Resolution**: We strive to fix critical vulnerabilities within **7 days** and issue a security advisory.

---

## 🔒 Security Features

Nickel Browser includes several native security enhancements:

- **NickelShield**: Our high-performance, C++ based ad-blocking engine that stops malicious scripts before they execute.
- **NickelVault**: Advanced fingerprinting protection that introduces noise into WebGL, Canvas, and Audio APIs to prevent cross-site tracking.
- **Zero-Google Policy**: No Google Safe Browsing, no Metrics, no Field Trials, and no Google Update. We use locally-hosted or community-vetted alternatives.
- **HTTPS-Only**: Forced secure connections for all websites by default.

---

## 📜 Acknowledgments

Nickel Browser relies on the incredible work of the security community:
- [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium)
- [Tor Project](https://torproject.org)
- [GnuPG](https://gnupg.org)
- [uBlock Origin](https://github.com/gorhill/uBlock)

---

<p align="center">
  <em>For more details on building securely from source, see our [BUILD.md](docs/BUILD.md).</em>
</p>
