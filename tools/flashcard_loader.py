#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys
import io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8', errors='replace')
"""
flashcard_loader.py --- Script nap anh flashcard tu dong theo manifest.

Cach dung:
    python flashcard_loader.py
    python flashcard_loader.py --manifest path/to/manifest.json
    python flashcard_loader.py --source pexels   (mac dinh: unsplash)
    python flashcard_loader.py --quality high    (low / medium / high)

Yeu cau:
    pip install requests Pillow

Cau hinh API key (tuy chon, de tang rate limit):
    export UNSPLASH_ACCESS_KEY="your_key"   # https://unsplash.com/developers
    export PEXELS_API_KEY="your_key"        # https://www.pexels.com/api/
"""

import json
import os
import sys
import time
import argparse
import hashlib
from pathlib import Path
from typing import Optional
import urllib.request
import urllib.parse
import urllib.error

# ─── Cấu hình mặc định ────────────────────────────────────────────────────────

SCRIPT_DIR = Path(__file__).parent
PROJECT_ROOT = SCRIPT_DIR.parent
DEFAULT_MANIFEST = SCRIPT_DIR / "flashcard_manifest.json"
OUTPUT_DIR = PROJECT_ROOT / "apps" / "mobile" / "assets" / "images" / "flashcards"
TOPICS_DIR = PROJECT_ROOT / "apps" / "mobile" / "assets" / "images" / "topics"

# Kich thuoc anh xuat ra. Flashcard chi can anh gon, khong can anh goc 4K.
IMAGE_SIZES = {
    "low":    (320, 320),
    "medium": (512, 512),
    "high":   (768, 768),
}

# Nguồn ảnh
UNSPLASH_KEY = os.environ.get("UNSPLASH_ACCESS_KEY", "")
PEXELS_KEY   = os.environ.get("PEXELS_API_KEY",       "")


# ─── Hàm tải ảnh ──────────────────────────────────────────────────────────────

def search_unsplash(query: str, api_key: str) -> Optional[dict[str, str]]:
    """Tim anh tu Unsplash API, tra ve URL va metadata nguon."""
    if not api_key:
        return None
    q = urllib.parse.quote(query)
    url = f"https://api.unsplash.com/search/photos?query={q}&per_page=1&orientation=squarish"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Client-ID {api_key}",
        "Accept-Version": "v1",
        "User-Agent": "VNChineseFlashcards/1.0",
    })
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            data = json.loads(r.read().decode())
            results = data.get("results", [])
            if results:
                item = results[0]
                return {
                    "provider": "Unsplash",
                    "url": item["urls"].get("regular") or item["urls"]["small"],
                    "photo_url": item.get("links", {}).get("html", ""),
                    "photographer": item.get("user", {}).get("name", ""),
                    "photographer_url": item.get("user", {}).get("links", {}).get("html", ""),
                    "license": "Unsplash License",
                }
    except Exception as e:
        print(f"   ⚠ Unsplash error: {e}")
    return None


def search_pexels(query: str, api_key: str) -> Optional[dict[str, str]]:
    """Tim anh tu Pexels API, tra ve URL va metadata nguon."""
    if not api_key:
        return None
    q = urllib.parse.quote(query)
    url = f"https://api.pexels.com/v1/search?query={q}&per_page=1&orientation=square"
    req = urllib.request.Request(url, headers={
        "Authorization": api_key,
        "User-Agent": "VNChineseFlashcards/1.0",
    })
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            data = json.loads(r.read().decode())
            photos = data.get("photos", [])
            if photos:
                item = photos[0]
                src = item.get("src", {})
                return {
                    "provider": "Pexels",
                    "url": src.get("large2x") or src.get("large") or src.get("medium"),
                    "photo_url": item.get("url", ""),
                    "photographer": item.get("photographer", ""),
                    "photographer_url": item.get("photographer_url", ""),
                    "license": "Pexels License",
                }
    except Exception as e:
        print(f"   ⚠ Pexels error: {e}")
    return None


def download_with_fallback(query: str, word: str, source: str) -> tuple[Optional[bytes], dict[str, str]]:
    """Tai anh tu nguon chinh, fallback sang nguon phu neu that bai."""
    photo: Optional[dict[str, str]] = None

    if source == "pexels":
        photo = search_pexels(query, PEXELS_KEY)
        if not photo:
            photo = search_unsplash(query, UNSPLASH_KEY)
    else:  # unsplash (default)
        photo = search_unsplash(query, UNSPLASH_KEY)
        if not photo:
            photo = search_pexels(query, PEXELS_KEY)

    if not photo:
        # Fallback: placeholder tu placehold.co (khong can API key).
        word_enc = urllib.parse.quote(word)
        photo = {
            "provider": "placehold.co",
            "url": f"https://placehold.co/400x400/E53935/FFFFFF/png?text={word_enc}",
            "photo_url": "",
            "photographer": "",
            "photographer_url": "",
            "license": "Placeholder",
        }

    try:
        req = urllib.request.Request(photo["url"], headers={
            "User-Agent": "FlashcardLoader/1.0"
        })
        with urllib.request.urlopen(req, timeout=15) as r:
            return r.read(), photo
    except Exception as e:
        print(f"   ✗ Không thể tải ảnh ({photo['url'][:60]}...): {e}")
    return None, photo


def resize_image(data: bytes, target_size: tuple) -> bytes:
    """Resize ảnh về kích thước chuẩn (dùng PIL nếu có, fallback raw)."""
    try:
        from PIL import Image
        import io
        img = Image.open(io.BytesIO(data))
        img = img.convert("RGB")
        img = img.resize(target_size, Image.LANCZOS)
        output = io.BytesIO()
        img.save(output, format="JPEG", quality=85, optimize=True)
        return output.getvalue()
    except ImportError:
        # PIL không được cài — trả về ảnh gốc
        return data
    except Exception:
        return data


# ─── Logic chính ──────────────────────────────────────────────────────────────

def safe_filename(text: str) -> str:
    """Tạo tên file an toàn từ từ tiếng Trung bằng hash."""
    return hashlib.md5(text.encode()).hexdigest()[:10]


def load_manifest(path: Path) -> dict:
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def process_topic(topic: dict, output_dir: Path, quality: str, source: str,
                  dry_run: bool, delay: float, force: bool, summary: dict):
    topic_id = topic["id"]
    topic_dir = output_dir / topic_id
    topic_dir.mkdir(parents=True, exist_ok=True)

    print(f"\n[Topic] {topic['name']} ({topic['nameCn']}) [{len(topic['words'])} words]")

    # Tạo metadata.json cho topic
    meta = {
        "id": topic_id,
        "name": topic["name"],
        "nameCn": topic["nameCn"],
        "color": topic.get("color", "#D32F2F"),
        "words": [],
    }
    existing_words: dict[str, dict] = {}
    meta_path = topic_dir / "metadata.json"
    if meta_path.exists():
        try:
            existing_meta = json.loads(meta_path.read_text(encoding="utf-8"))
            existing_words = {
                item.get("word", ""): item
                for item in existing_meta.get("words", [])
                if isinstance(item, dict)
            }
        except Exception:
            existing_words = {}

    for i, word_entry in enumerate(topic["words"], 1):
        word   = word_entry["word"]
        pinyin = word_entry["pinyin"]
        meaning = word_entry["meaning"]
        query  = word_entry.get("query", f"{meaning} {word}")

        # Tên file ảnh
        fname = f"{safe_filename(word)}.jpg"
        fpath = topic_dir / fname

        print(f"  [{i:2d}/{len(topic['words'])}] {word} ({pinyin}) --- {meaning}")

        source_meta: dict[str, str] = {}

        if fpath.exists() and not force:
            source_meta = existing_words.get(word, {}).get("source", {})
            print(f"         [OK] Da co anh: {fname}")
            summary["skipped"] += 1
        elif dry_run:
            print(f"         [DRY RUN] se tai: {query}")
            summary["would_download"] += 1
        else:
            img_data, source_meta = download_with_fallback(query, word, source)
            if img_data:
                size = IMAGE_SIZES.get(quality, IMAGE_SIZES["medium"])
                img_data = resize_image(img_data, size)
                fpath.write_bytes(img_data)
                provider = source_meta.get("provider", source)
                print(f"         [OK] Da luu ({len(img_data)//1024} KB) tu {provider}")
                summary["downloaded"] += 1
            else:
                print(f"         [FAIL] That bai")
                summary["failed"] += 1
            time.sleep(delay)

        meta["words"].append({
            "word":    word,
            "pinyin":  pinyin,
            "meaning": meaning,
            "image":   fname if (dry_run or fpath.exists()) else "",
            "query":   query,
            "source":  source_meta,
        })

    # Lưu metadata.json
    with open(meta_path, "w", encoding="utf-8") as f:
        json.dump(meta, f, ensure_ascii=False, indent=2)
    print(f"  [meta] Da luu metadata: {meta_path.name}")


def generate_index(output_dir: Path, manifest: dict):
    """Tạo file index.json tổng hợp tất cả topics và words."""
    index = {
        "version": manifest.get("version", "1.0"),
        "topics": [],
    }
    for topic in manifest["topics"]:
        meta_path = output_dir / topic["id"] / "metadata.json"
        if meta_path.exists():
            with open(meta_path, encoding="utf-8") as f:
                index["topics"].append(json.load(f))

    index_path = output_dir / "index.json"
    with open(index_path, "w", encoding="utf-8") as f:
        json.dump(index, f, ensure_ascii=False, indent=2)
    print(f"\n[index] Da tao index.json tai: {index_path}")
    return index_path


def main():
    parser = argparse.ArgumentParser(
        description="Script nạp ảnh flashcard theo manifest JSON"
    )
    parser.add_argument(
        "--manifest", default=str(DEFAULT_MANIFEST),
        help="Đường dẫn tới file manifest JSON"
    )
    parser.add_argument(
        "--source", choices=["unsplash", "pexels"], default="unsplash",
        help="Nguồn ảnh (mặc định: unsplash, fallback tự động)"
    )
    parser.add_argument(
        "--quality", choices=["low", "medium", "high"], default="medium",
        help="Chất lượng / kích thước ảnh (mặc định: medium 400x400)"
    )
    parser.add_argument(
        "--output", default=str(OUTPUT_DIR),
        help="Thư mục xuất ảnh"
    )
    parser.add_argument(
        "--delay", type=float, default=0.5,
        help="Thời gian chờ giữa mỗi request (giây, mặc định: 0.5)"
    )
    parser.add_argument(
        "--topic", default=None,
        help="Chỉ xử lý một topic cụ thể (theo id)"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Chạy thử — chỉ hiển thị, không tải ảnh"
    )
    parser.add_argument(
        "--force", action="store_true",
        help="Tai lai va ghi de anh da co san"
    )
    args = parser.parse_args()

    manifest_path = Path(args.manifest)
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    print("=" * 60)
    print("  [Flashcard] Image Loader v1.0")
    print("=" * 60)
    print(f"  Manifest  : {manifest_path}")
    print(f"  Output    : {output_dir}")
    print(f"  Source    : {args.source}")
    print(f"  Quality   : {args.quality} {IMAGE_SIZES[args.quality]}")
    print(f"  Dry run   : {'Co' if args.dry_run else 'Khong'}")
    if not UNSPLASH_KEY and not PEXELS_KEY:
        print("\n  [!] Khong co API key -- se dung anh placeholder!")
        print("     Dat UNSPLASH_ACCESS_KEY hoac PEXELS_API_KEY de dung anh thuc.")
    print("=" * 60)

    if not manifest_path.exists():
        print(f"  [FAIL] Khong tim thay manifest: {manifest_path}")
        sys.exit(1)

    manifest = load_manifest(manifest_path)
    topics = manifest.get("topics", [])

    if args.topic:
        topics = [t for t in topics if t["id"] == args.topic]
        if not topics:
            print(f"  [FAIL] Khong tim thay topic: {args.topic}")
            sys.exit(1)

    summary = {
        "downloaded": 0,
        "skipped": 0,
        "failed": 0,
        "would_download": 0,
    }

    for topic in topics:
        process_topic(
            topic, output_dir, args.quality, args.source,
            args.dry_run, args.delay, args.force, summary
        )

    if not args.dry_run:
        generate_index(output_dir, manifest)

    print("\n" + "=" * 60)
    print("  [KET QUA]")
    if args.dry_run:
        print(f"     Se tai  : {summary['would_download']} anh")
    else:
        print(f"     Da tai  : {summary['downloaded']} anh")
        print(f"     Bo qua  : {summary['skipped']} (da co san)")
        print(f"     That bai: {summary['failed']} anh")
    print("=" * 60)

    if summary.get("downloaded", 0) > 0 or summary.get("skipped", 0) > 0:
        print("\n  [OK] Hoan tat! Them vao pubspec.yaml neu chua co:")
        print(f"     - assets/images/flashcards/")
        print(f"     - assets/images/flashcards/<topic_id>/")


if __name__ == "__main__":
    main()
