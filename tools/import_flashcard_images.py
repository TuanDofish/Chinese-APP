#!/usr/bin/env python3
"""
Import flashcard images from a manifest.

Usage:
  python tools/import_flashcard_images.py --manifest tools/manifests/flashcard_image_manifest.sample.json

Manifest item supports:
- source_url: download image from web
- local_path: copy from local filesystem
"""

from __future__ import annotations

import argparse
import json
import shutil
import urllib.request
from pathlib import Path
from typing import Any


def ensure_parent(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)


def download_file(url: str, dest: Path) -> None:
    ensure_parent(dest)
    with urllib.request.urlopen(url, timeout=30) as response:
        data = response.read()
    dest.write_bytes(data)


def copy_file(src: Path, dest: Path) -> None:
    ensure_parent(dest)
    shutil.copy2(src, dest)


def run(manifest_path: Path) -> dict[str, Any]:
    payload = json.loads(manifest_path.read_text(encoding="utf-8"))
    base_output = Path(payload.get("base_output", "apps/mobile/assets/images/flashcards"))
    items = payload.get("items", [])

    report: dict[str, Any] = {
        "manifest": str(manifest_path),
        "base_output": str(base_output),
        "total": len(items),
        "success": 0,
        "failed": 0,
        "results": [],
    }

    for item in items:
        item_id = item.get("id", "unknown")
        target = item.get("target")
        source_url = (item.get("source_url") or "").strip()
        local_path = (item.get("local_path") or "").strip()

        if not target:
            report["failed"] += 1
            report["results"].append({
                "id": item_id,
                "status": "failed",
                "reason": "missing target",
            })
            continue

        dest = base_output / target

        try:
            if local_path:
                src = Path(local_path)
                if not src.exists():
                    raise FileNotFoundError(f"local file not found: {src}")
                copy_file(src, dest)
            elif source_url:
                download_file(source_url, dest)
            else:
                raise ValueError("either local_path or source_url must be provided")

            report["success"] += 1
            report["results"].append({
                "id": item_id,
                "status": "ok",
                "target": str(dest),
                "source": source_url or local_path,
                "license": item.get("license", ""),
                "author": item.get("author", ""),
            })
        except Exception as exc:  # noqa: BLE001
            report["failed"] += 1
            report["results"].append({
                "id": item_id,
                "status": "failed",
                "target": str(dest),
                "source": source_url or local_path,
                "reason": str(exc),
            })

    report_path = manifest_path.with_suffix(".report.json")
    report_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    return report


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", required=True, help="Path to flashcard image manifest")
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    if not manifest_path.exists():
        raise SystemExit(f"Manifest not found: {manifest_path}")

    report = run(manifest_path)
    print(f"Imported: {report['success']}/{report['total']}")
    print(f"Failed:   {report['failed']}")
    print(f"Report:   {manifest_path.with_suffix('.report.json')}")


if __name__ == "__main__":
    main()
