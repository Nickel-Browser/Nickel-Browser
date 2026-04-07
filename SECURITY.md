# Security Policy

## 🔒 Our Security Commitment

Nickel Browser is built with security as a foundational principle. We believe in:
- **Transparency**: Open source means anyone can audit our code
- **Rapid Response**: Security issues are addressed with highest priority
- **No Secrets**: No security through obscurity
- **User First**: User safety over convenience

## 🛡️ Security Features

Nickel Browser includes these security protections by default:
- HTTPS-Only Mode
- DNS-over-HTTPS (Quad9)
- Certificate Transparency enforcement
- First-party isolation
- Site isolation
- WebRTC leak protection
- Fingerprint randomization
- Tor private tabs
- Built-in ad/malware blocking

## 📢 Reporting Security Vulnerabilities

**Please DO NOT open public issues for security vulnerabilities.**

Instead, report privately to: **sho.islam0311@proton.me**

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)
- Your contact information for follow-up

## ⏱️ Response Timeline

| Stage | Timeline |
|-------|----------|
| Initial response | Within 48 hours |
| Vulnerability assessment | Within 7 days |
| Patch development | Based on severity |
| Public disclosure | After patch release |

## 📦 Supported Versions

| Version | Status | Security Update |
|---------|--------|-----------------|
| v1.0.x  | Current | ✅ Active       |
| < v1.0  | Legacy  | ❌ Not Supported |

## 🏆 Security Hall of Fame

We publicly acknowledge security researchers who responsibly disclose vulnerabilities.

## 🔄 Security Update Process

1. **Critical**: Emergency release within 48-72 hours.
2. **High**: Next scheduled release (within 7 days).
3. **Medium/Low**: Bundled with regular updates.

## 🧪 Security Testing

We encourage:
- Penetration testing
- Code audits
- Fuzzing
- Static analysis

## 📋 Security Checklist for Contributors

When contributing code, ensure:
- [ ] No hardcoded secrets or API keys
- [ ] Input validation on all user inputs
- [ ] No unnecessary network requests
- [ ] Proper memory management (no leaks)
- [ ] No bypass of security policies
- [ ] Tests include security scenarios

---

Thank you for helping keep Nickel Browser and its users secure! 🪙🛡️