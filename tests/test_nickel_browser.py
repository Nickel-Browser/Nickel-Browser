#!/usr/bin/env python3
"""Post-build integration test for Nickel Browser."""

from __future__ import annotations

import http.server
import os
import shutil
import socket
import subprocess
import sys
import tempfile
import threading
from pathlib import Path
from typing import Iterable


def find_binary() -> Path:
    env_path = os.environ.get("NICKEL_BROWSER_BIN")
    if env_path:
        path = Path(env_path)
        if path.exists():
            return path

    candidates: Iterable[Path] = [
        Path("dist") / "nickel-browser",
        Path("packaging") / "deb" / "opt" / "nickel-browser" / "nickel-browser",
        Path("out") / "Nickel" / "nickel-browser",
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate

    raise FileNotFoundError("Nickel browser binary not found. Set NICKEL_BROWSER_BIN.")


def assert_executable(path: Path) -> None:
    if not os.access(path, os.X_OK):
        raise RuntimeError(f"Binary is not executable: {path}")


def run_version_check(binary: Path) -> None:
    result = subprocess.run([str(binary), "--version"], capture_output=True, text=True, check=False)
    if result.returncode != 0:
        raise RuntimeError(f"Version check failed: {result.stderr.strip()}")
    if not result.stdout.strip():
        raise RuntimeError("Version output was empty.")


class LoggingHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format: str, *args) -> None:
        return

    def do_GET(self) -> None:
        self.server.seen_paths.add(self.path)  # type: ignore[attr-defined]
        super().do_GET()


def find_free_port() -> int:
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]


def run_adblock_test(binary: Path) -> None:
    with tempfile.TemporaryDirectory() as temp_dir:
        temp_path = Path(temp_dir)
        web_root = temp_path / "site"
        ads_dir = web_root / "ads"
        ads_dir.mkdir(parents=True)

        (ads_dir / "ad-banner.png").write_bytes(b"fake-ad")
        html = """<!doctype html>
<html>
  <body>
    <div id=\"ad-banner\">ad</div>
    <img id=\"ad-image\" src=\"/ads/ad-banner.png\" />
  </body>
</html>
"""
        (web_root / "index.html").write_text(html, encoding="utf-8")

        port = find_free_port()
        handler = LoggingHandler
        server = http.server.ThreadingHTTPServer(("127.0.0.1", port), handler)
        server.seen_paths = set()  # type: ignore[attr-defined]
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()

        try:
            profile_dir = temp_path / "profile"
            screenshot_path = temp_path / "screenshot.png"
            url = f"http://127.0.0.1:{port}/index.html"
            cmd = [
                str(binary),
                "--headless=new",
                "--disable-gpu",
                "--no-first-run",
                "--no-default-browser-check",
                f"--user-data-dir={profile_dir}",
                f"--screenshot={screenshot_path}",
                "--virtual-time-budget=2000",
                url,
            ]
            subprocess.run(cmd, check=True, capture_output=True)

            if not screenshot_path.exists():
                raise RuntimeError("Screenshot was not produced by headless run.")

            if "/ads/ad-banner.png" in server.seen_paths:
                raise RuntimeError("Ad request was not blocked (ad-banner.png requested).")
        finally:
            server.shutdown()


def main() -> int:
    try:
        binary = find_binary()
        assert_executable(binary)
        run_version_check(binary)
        run_adblock_test(binary)
    except Exception as exc:  # noqa: BLE001
        print(f"❌ {exc}")
        return 1

    print("✅ Nickel Browser integration tests passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
