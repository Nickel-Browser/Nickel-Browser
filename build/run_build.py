#!/usr/bin/env python3
"""Nickel Browser build pipeline (setup -> fetch -> patch -> gn -> compile -> package)."""

from __future__ import annotations

import argparse
import datetime
import hashlib
import json
import logging
import os
import subprocess
import sys
from pathlib import Path
from typing import Any, Dict, List

REPO_ROOT = Path(__file__).resolve().parents[1]
LOG_PATH = REPO_ROOT / "build.log"


def configure_logging() -> logging.Logger:
    logger = logging.getLogger("nickel-build")
    logger.setLevel(logging.INFO)

    formatter = logging.Formatter("%(asctime)s %(levelname)s %(message)s")

    file_handler = logging.FileHandler(LOG_PATH, mode="a", encoding="utf-8")
    file_handler.setFormatter(formatter)

    stream_handler = logging.StreamHandler(sys.stdout)
    stream_handler.setFormatter(formatter)

    logger.addHandler(file_handler)
    logger.addHandler(stream_handler)
    return logger


def parse_simple_yaml(text: str) -> Dict[str, Any]:
    data: Dict[str, Any] = {}
    current_key: str | None = None
    for raw_line in text.splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        if ":" in line and not raw_line.lstrip().startswith("-"):
            key, rest = raw_line.split(":", 1)
            key = key.strip()
            value = rest.strip()
            if value == "":
                data[key] = []
                current_key = key
            else:
                data[key] = value.strip("\"'")
                current_key = None
            continue
        if raw_line.lstrip().startswith("-") and current_key:
            item = raw_line.lstrip()[1:].strip().strip("\"'")
            data[current_key].append(item)
    return data


def load_config(path: Path) -> Dict[str, Any]:
    text = path.read_text(encoding="utf-8")
    try:
        import yaml  # type: ignore

        return yaml.safe_load(text) or {}
    except Exception:
        return parse_simple_yaml(text)


def run_command(
    logger: logging.Logger,
    command: List[str],
    env: Dict[str, str] | None = None,
    cwd: Path | None = None,
) -> None:
    logger.info("Running: %s", " ".join(command))
    subprocess.run(command, cwd=cwd or REPO_ROOT, check=True, env=env)


def step(logger: logging.Logger, name: str, func) -> None:
    logger.info("==> %s", name)
    func()


def write_checksums(artifacts: List[Path], output_file: Path) -> None:
    with output_file.open("w", encoding="utf-8") as handle:
        for artifact in artifacts:
            digest = hashlib.sha256()
            with artifact.open("rb") as src:
                for chunk in iter(lambda: src.read(8192), b""):
                    digest.update(chunk)
            handle.write(f"{digest.hexdigest()}  {artifact.name}\n")


def build_pipeline(config: Dict[str, Any], platform: str, logger: logging.Logger, chromium_version: str | None) -> None:
    build_mode = config.get("build_mode", "binary")
    chromium_version = chromium_version or config.get("chromium_version", "latest")
    uc_binary_dir = REPO_ROOT / config.get("uc_binary_dir", "uc-binary")
    dist_dir = REPO_ROOT / config.get("dist_dir", "dist")
    if build_mode != "binary" and platform != "linux":
        raise ValueError("Source builds are supported only on linux.")

    def setup() -> None:
        dist_dir.mkdir(parents=True, exist_ok=True)
        uc_binary_dir.mkdir(parents=True, exist_ok=True)

    def fetch() -> None:
        if build_mode == "binary":
            if any(uc_binary_dir.iterdir()):
                logger.info("UC binary cache already present, skipping download.")
                return
            run_command(
                logger,
                [
                    str(REPO_ROOT / "scripts" / "download-uc-binary.sh"),
                    platform,
                    chromium_version,
                    str(uc_binary_dir),
                ],
                env=os.environ.copy(),
            )
        else:
            run_command(
                logger,
                [str(REPO_ROOT / "scripts" / "build-nickel-linux.sh"), "--version", chromium_version, "--no-package"],
            )

    def apply_patches() -> None:
        if build_mode == "binary":
            env = os.environ.copy()
            env["BINARY_DIR"] = str(uc_binary_dir)
            env["NICKEL_DIR"] = str(REPO_ROOT)
            run_command(logger, [str(REPO_ROOT / "scripts" / "apply-nickel-branding.sh")], env=env)
        else:
            logger.info("Source build handles patch application inside build script.")

    def gn_gen() -> None:
        if build_mode == "binary":
            logger.info("Skipping gn gen for binary repackaging build.")
            return
        logger.info("GN args: %s", json.dumps(config.get("gn_args", [])))

    def compile_step() -> None:
        if build_mode == "binary":
            logger.info("Skipping compile step for binary repackaging build.")
            return
        logger.info("Compile handled by source build script.")

    def package() -> None:
        if build_mode == "binary":
            env = os.environ.copy()
            env["BINARY_DIR"] = str(uc_binary_dir)
            env["NICKEL_DIR"] = str(REPO_ROOT)
            if platform == "linux":
                run_command(logger, [str(REPO_ROOT / "scripts" / "build-deb.sh")], env=env)
                artifacts = list(REPO_ROOT.glob("*.deb"))
                if not artifacts:
                    raise RuntimeError("No .deb artifacts produced.")
                for artifact in artifacts:
                    artifact.replace(dist_dir / artifact.name)
                write_checksums(list(dist_dir.glob("*.deb")), dist_dir / "checksums-linux.sha256")
            elif platform == "macos":
                run_command(logger, [str(REPO_ROOT / "scripts" / "build-dmg.sh")], env=env)
                artifacts = list(REPO_ROOT.glob("*.dmg"))
                if not artifacts:
                    raise RuntimeError("No .dmg artifacts produced.")
                for artifact in artifacts:
                    artifact.replace(dist_dir / artifact.name)
                write_checksums(list(dist_dir.glob("*.dmg")), dist_dir / "checksums-macos.sha256")
            elif platform == "windows":
                run_command(logger, [str(REPO_ROOT / "scripts" / "build-windows-installer.sh")], env=env)
                artifacts = list(REPO_ROOT.glob("*.exe"))
                if not artifacts:
                    raise RuntimeError("No .exe artifacts produced.")
                for artifact in artifacts:
                    artifact.replace(dist_dir / artifact.name)
                write_checksums(list(dist_dir.glob("*.exe")), dist_dir / "checksums-windows.sha256")
            else:
                raise ValueError(f"Unsupported platform: {platform}")
        else:
            logger.info("Packaging handled by source build script.")

    step(logger, "setup", setup)
    step(logger, "fetch", fetch)
    step(logger, "patch", apply_patches)
    step(logger, "gn", gn_gen)
    step(logger, "compile", compile_step)
    step(logger, "package", package)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--config", default=str(REPO_ROOT / "build" / "config.yaml"))
    parser.add_argument("--platform", required=True, choices=["linux", "macos", "windows"])
    parser.add_argument("--chromium-version", default=None)
    args = parser.parse_args()

    logger = configure_logging()
    start = datetime.datetime.utcnow()
    logger.info("Nickel build started at %s", start.isoformat() + "Z")

    try:
        config = load_config(Path(args.config))
        build_pipeline(config, args.platform, logger, args.chromium_version)
    except subprocess.CalledProcessError as exc:
        logger.error("Build failed: %s", exc)
        logger.info("Build summary: failure")
        return 1
    except Exception as exc:  # noqa: BLE001 - provide clear error
        logger.error("Build failed: %s", exc)
        logger.info("Build summary: failure")
        return 1

    finish = datetime.datetime.utcnow()
    logger.info("Build summary: success")
    logger.info("Build duration: %s", finish - start)
    logger.info("Artifacts directory: %s", (REPO_ROOT / "dist").resolve())
    return 0


if __name__ == "__main__":
    sys.exit(main())
