# Nickel Browser Privacy Policy

**Effective Date:** April 12, 2026

**Last Updated:** January 1, 2026

---

## In Short

> **We collect NOTHING. Period.**

Nickel Browser is designed from the ground up to collect zero data about you. We have no servers tracking you, no analytics, no telemetry, and no cloud dependencies.

---

## What We Don't Collect

Unlike most browsers, Nickel Browser explicitly does NOT collect:

| Data Type | Nickel | Typical Browsers |
|-----------|--------|------------------|
| Browsing history | ❌ Never | ✅ Often |
| Search queries | ❌ Never | ✅ Often |
| Crash reports | ❌ Never | ✅ Usually |
| Usage statistics | ❌ Never | ✅ Usually |
| Performance metrics | ❌ Never | ✅ Often |
| IP addresses | ❌ Never | ✅ Sometimes |
| Device identifiers | ❌ Never | ✅ Often |
| Location data | ❌ Never | ✅ Sometimes |

## What We Do

### Local-First Architecture

Everything happens on your device:
- ✅ Passwords stored locally (encrypted)
- ✅ Bookmarks stored locally
- ✅ History stored locally (if enabled)
- ✅ Settings stored locally
- ✅ Filter lists cached locally

### Network Connections

Nickel Browser makes network connections ONLY for:
1. **Web browsing** — to sites you visit
2. **Filter list updates** — from trusted sources (EasyList, etc.)
3. **HTTPS certificate validation** — standard security
4. **DNS queries** — via your configured DNS (default: Quad9 DoH)

### Optional Features

Some optional features may connect to external services:

| Feature | External Connection | Data Shared |
|---------|---------------------|-------------|
| Tor Private Tab | Tor network | Routed through Tor |
| VPN | Your VPN provider | Per your VPN config |
| SponsorBlock | sponsor.ajay.app | Video ID hash only |
| Filter updates | List maintainers | None (anonymous) |

All these are **opt-in** or use privacy-preserving methods.

## Your Control

You have complete control over your data:

- Clear all data with one click
- Export/import your data anytime
- Disable any feature you don't want
- Verify our claims — we're open source

## Third-Party Services

We don't use:
- Google services
- Microsoft services
- Cloud analytics
- Advertising networks
- Social media trackers

## Updates

Update checks (if enabled):
- Contact GitHub releases API
- No identifying information sent
- Can be disabled entirely

## Children's Privacy

Nickel Browser does not knowingly collect data from anyone, including children under 13.

## Changes to This Policy

If we ever change this policy (unlikely), we will:
1. Post the changes prominently
2. Require explicit user consent
3. Never retroactively apply to existing users

## Verification

Don't trust us — verify:
- Source code: https://github.com/Nickel-Browser/Nickel-Browser
- Network monitoring: Use Wireshark to verify our claims
- Build yourself: Follow BUILD.md

## Contact

Privacy questions: privacy@nickel-browser.org

---

**TL;DR: We know nothing about you, and we like it that way.** 🪙🔒
