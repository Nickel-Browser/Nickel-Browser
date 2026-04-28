# Changelog

All notable changes to Nickel Browser are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

### Changed
- CI: Fixed broken heredoc syntax in `nickel-production-build.yml` changelog step that caused all workflow jobs to be skipped
- CI: Fixed `eval`-based `curl` call in `download-uc-binary.sh` — replaced with array-based argument passing for correctness and security
- CI: Fixed binary name detection in `build-deb.sh` and `apply-nickel-branding.sh` to find both `chrome` and `chromium` executables (ungoogled-chromium portable tarballs use `chromium`)
- CI: Fixed shell quoting in `build-windows-installer.sh` (`xargs dirname` → `xargs -r -0 dirname`)
- CI: Re-enabled `.chromium_version` commit-back in the prepare job by removing incorrect `persist-credentials: false`
- CI: Added shellcheck lint job to `nickel-production-build.yml` (runs before all build jobs)
- Source build: Added fallback to direct `gclient sync` when `utils/fetch_sync.py` is absent (compatibility with older ungoogled-chromium releases)
- Docs: Expanded `docs/SELF_HOSTED_RUNNER.md` with complete step-by-step setup instructions, swap configuration, systemd service setup, and a troubleshooting table
- Docs: Added GitHub Education / large-runner guidance to `docs/BUILD.md`
- Docs: Removed references to nonexistent `build/nickel-gn-args.gni` from `docs/BUILD.md`
- Docs: Removed references to nonexistent `build-appimage.sh` from `README.md` and `docs/BUILD.md`
- Docs: Updated Downloads table in `README.md` to accurately describe binary-repackaged releases
- Docs: Fixed broken Markdown link syntax in `README.md` (extra trailing `]`)
- Docs: Fixed version badge in `README.md` (`1.0.0.alpha` → `1.0.0-alpha`)
- Docs: Corrected misleading "identical end-user browser" claim in the build comparison table
- Cleanup: Removed `EMERGENCY_FIX_BASELINE.txt` (internal debugging artifact)

---

## [1.0.0-alpha] — Initial Release

### Added
- Project scaffold: branding, patches, scripts, workflows, docs
- Binary repackaging pipeline: downloads ungoogled-chromium, applies Nickel branding, packages as `.deb` / `.dmg` / `.exe`
- Source build pipeline: full Chromium compilation from ungoogled-chromium source with 10 Nickel patches
- Patch series (applied on top of ungoogled-chromium):
  - `0001` Nickel branding (product name, binary name, desktop entry)
  - `0002` Nickel user-agent token
  - `0003` Privacy defaults (DuckDuckGo, cookie policy, DNT, HTTPS-only)
  - `0004` WebRTC hardening (disable non-proxied UDP)
  - `0005` Custom new-tab page with privacy stats
  - `0006` Source-level ad-blocking engine (URLLoaderThrottle)
  - `0007` Fingerprint protection (canvas / AudioContext / Navigator noise)
  - `0008` Built-in Tor integration (per-tab Tor routing)
  - `0009` VPN proxy routing layer
  - `0010` BUILD.gn integration (wires all components into `chrome`)
- `docs/BUILD.md` — full build guide (binary repackaging + source build)
- `docs/SELF_HOSTED_RUNNER.md` — self-hosted runner setup guide
- `docs/PRIVACY_POLICY.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`
- GitHub Actions workflows:
  - `nickel-production-build.yml` — binary repackaging (Linux + macOS + Windows)
  - `nickel-source-build.yml` — source build (Linux x64, large runner required)

[Unreleased]: https://github.com/Nickel-Browser/Nickel-Browser/compare/v1.0.0-alpha...HEAD
[1.0.0-alpha]: https://github.com/Nickel-Browser/Nickel-Browser/releases/tag/v1.0.0-alpha
