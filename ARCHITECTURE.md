# Nickel Browser Architecture

Nickel Browser is a privacy-hardened fork of Ungoogled-Chromium.

## Components

- **NickelCore**: Base browser logic and preference defaults.
- **NickelAdBlock**: Integration with Chromium's `subresource_filter`.
- **NickelTor**: Tab-level routing through a bundled Tor daemon.
- **NickelFingerprint**: Per-session noise injection for Canvas, Audio, and Hardware APIs.

## Data Flow

1. Browser starts, `NickelFingerprintService` generates a per-session noise seed.
2. User opens a Tor tab, `NickelTorController` ensures the Tor daemon is running.
3. Network requests are intercepted by `AdBlockURLLoaderThrottle` and evaluated against filter rules.
4. Renderer frames receive the noise seed via `NickelFingerprintShield` and apply JS shims.
