# Nickel Browser Privacy Policy

**Effective Date:** April 07, 2026
**Last Updated:** April 07, 2026

---

## 🔒 In Short: We Collect NOTHING. Period.

Nickel Browser is designed from the ground up with a **Zero Telemetry** and **Local-First** architecture. We have no servers tracking you, no analytics packages, no crash report pingbacks, and no cloud-based dependencies.

---

## 🚫 What We Do NOT Collect

Unlike most browsers, Nickel explicitly does **NOT** collect:

| Data Category | **Nickel Browser** | Most Other Browsers |
|---------------|-------------------|----------------------|
| **Browsing History** | ❌ Never | ✅ Often collected |
| **Search Queries** | ❌ Never | ✅ Often collected |
| **Crash Reports** | ❌ Never | ✅ Usually collected |
| **Usage Statistics** | ❌ Never | ✅ Usually collected |
| **Performance Metrics** | ❌ Never | ✅ Often collected |
| **IP Addresses** | ❌ Never | ✅ Sometimes collected |
| **Device Identifiers** | ❌ Never | ✅ Often collected |
| **Location Data** | ❌ Never | ✅ Sometimes collected |

---

## ✅ How We Protect Your Privacy

### 🏠 Local-First Architecture

Everything happens on your device:
- **Passwords**: Stored locally and encrypted (no cloud sync).
- **Bookmarks**: Stored locally in a simple file format.
- **History**: Stored locally (if you enable it) and cleared easily.
- **Settings**: Stored locally in your browser's profile directory.
- **Filter Lists**: Cached locally and updated from trusted sources.

### 🌐 Network Request Audit

Nickel Browser makes network connections **ONLY** for:
1. **Web Browsing**: To the websites you explicitly visit.
2. **Filter List Updates**: From trusted sources like EasyList or uBlock Origin.
3. **HTTPS Certificate Validation**: A standard security requirement.
4. **DNS Queries**: via your configured DNS (default: Quad9 DoH).
5. **Manual Update Checks**: When you click "Check for Updates," it contacts GitHub API.

### 🛡️ Optional Privacy-Preserving Features

Some optional features may connect to external networks:

| Feature | External Connection | Data Shared |
|---------|---------------------|-------------|
| **Tor Private Tab** | Tor network | Your traffic is routed through three layers of encryption. |
| **Built-in VPN** | Your chosen VPN provider | Per your VPN configuration and their privacy policy. |
| **SponsorBlock** | `sponsor.ajay.app` | A hash of the YouTube video ID only (anonymous). |
| **Filter Updates** | List maintainers | Anonymous request to download a file; no identifiers sent. |

---

## 🕵️‍♂️ Network Request Audit Table

You can verify our privacy claims using network analysis tools (e.g., Wireshark or tcpdump). You will find that Nickel makes zero unexpected connections.

| Domain | Purpose | Required? | Can You Disable? |
|--------|---------|-----------|------------------|
| `api.github.com` | Manual/Auto update checks | Optional | ✅ Yes, fully disableable. |
| `update.nickel-browser.org` | Future auto-update system | Optional | ✅ Yes, fully disableable. |
| `*.google.com` | ❌ **BLOCKED BY DEFAULT** | Never | N/A |
| `*.brave.com` | ❌ **NEVER CONTACTS** | Never | N/A |
| `*.doubleclick.net` | ❌ **BLOCKED BY uBlock** | Never | N/A |

---

## 🎮 Your Control

You have absolute control over your browsing data:
- **Clear Everything**: Clear all browsing data with a single click.
- **Data Portability**: Export and import your data anytime.
- **Feature Control**: Disable any feature you don't want or need.
- **Open Source**: Don't trust our words — audit the source code yourself.

---

## 🚫 No Third-Party Data Sharing

Nickel Browser does not use:
- Google Analytics or any other cloud-based tracking.
- Microsoft telemetry services.
- Advertising or data-selling networks.
- Social media tracking pixels or beacons.

---

## 🧒 Children's Privacy

Nickel Browser does not knowingly collect data from anyone, including children under 13.

---

## 📢 Changes to This Policy

If we ever update this policy (unlikely), we will:
1. Post the changes prominently on our GitHub repository.
2. Require your explicit consent for any change that affects data collection.
3. Never retroactively apply changes to existing versions or users.

---

## 📞 Contact

For any privacy-related questions or concerns, please contact: **sho.islam0311@proton.me**

---

**TL;DR: We know nothing about you, and we like it that way. 🐯🔒🪙**
*Block Everything. Leak Nothing. Own Your Web.*