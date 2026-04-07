# Nickel Browser Security Policy

## 🔒 Our Security Commitment

Nickel Browser is built with security as its foundational principle. We believe in:
- **Transparency**: Open source means anyone can audit our code and build process.
- **Rapid Response**: Security vulnerabilities are addressed with the highest priority.
- **No Secrets**: We do not rely on security through obscurity.
- **User First**: User safety and data integrity take precedence over convenience.

## 🛡️ Security Features

Nickel Browser includes several security protections by default:
- **HTTPS-Only Mode**: Automatically upgrades all connections to HTTPS.
- **DNS-over-HTTPS (Quad9)**: Uses encrypted DNS by default to prevent ISP surveillance.
- **Certificate Transparency**: Strict enforcement of certificate transparency.
- **First-Party Isolation**: Isolates cookies and storage per site to prevent cross-site tracking.
- **Site Isolation**: Ensures each site runs in its own process.
- **WebRTC Leak Protection**: Disables ICE candidates that could leak your real IP.
- **Fingerprint Randomization**: Adds noise to canvas, WebGL, and AudioContext APIs.
- **Tor Private Tabs**: Built-in anonymous browsing via the Tor network.
- **Source-Level Ad Blocking**: Compiled-in filtering that is undetectable by websites.

## 📢 Reporting Security Vulnerabilities

**Please DO NOT open public issues for security vulnerabilities.**

Instead, report them privately via email to: **sho.islam0311@proton.me**

When reporting, please include:
- A detailed description of the vulnerability.
- Steps to reproduce the issue.
- Potential impact and severity assessment.
- Any suggested fixes or mitigations.
- Your contact information for follow-up and recognition.

## ⏱️ Response Timeline

| Stage | Timeline |
|-------|----------|
| Initial response | Within 48 hours |
| Vulnerability assessment | Within 7 days |
| Patch development | Dependent on severity |
| Public disclosure | After a patch is released and users have updated |

## 📦 Supported Versions

| Version | Status | Security Update Support |
|---------|--------|-------------------------|
| **v1.0.x** | Current Alpha | ✅ Active Support |
| **< v1.0** | Legacy | ❌ No Longer Supported |

## 🏆 Security Hall of Fame

We publicly acknowledge security researchers who responsibly disclose vulnerabilities and help us make Nickel Browser more secure. Your name will be featured in our release notes and `CONTRIBUTORS.md`.

## 🔄 Security Update Process

1. **Critical Severity**: Emergency release within 48-72 hours.
2. **High Severity**: Inclusion in the next scheduled release (typically within 7 days).
3. **Medium/Low Severity**: Bundled with regular feature updates.

## 📋 Security Checklist for Contributors

When contributing code, please ensure:
- [ ] No hardcoded secrets, API keys, or tokens are included.
- [ ] Input validation is performed on all user-supplied data.
- [ ] No unnecessary or unauthorized network requests are made.
- [ ] Proper memory management is practiced (no buffer overflows or leaks).
- [ ] Security policies (like CSP) are not bypassed or weakened.
- [ ] Automated tests include security scenarios where applicable.

---

Thank you for helping keep Nickel Browser and its users secure! 🪙🛡️🐅