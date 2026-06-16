#!/usr/bin/env python3
"""Import timed YouTube captions into the mobile video lesson catalog.

Requirements:
    python -m pip install youtube-transcript-api pypinyin

Example:
    python tools/youtube_transcript_import.py TlW4x4ExAws --lesson-id new_vid_2
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

from pypinyin import Style, lazy_pinyin
from youtube_transcript_api import YouTubeTranscriptApi


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CATALOG = ROOT / "apps" / "mobile" / "assets" / "data" / "video_lessons.json"


def sentence_pinyin(text: str) -> str:
    parts = lazy_pinyin(
        text,
        style=Style.TONE,
        neutral_tone_with_five=False,
        errors=lambda value: list(value),
    )
    result = " ".join(part for part in parts if part.strip())
    result = re.sub(r"\s+([，。！？；：,.!?;:])", r"\1", result)
    return result[:1].upper() + result[1:] if result else ""


def fetch_lines(video_id: str, language: str):
    api = YouTubeTranscriptApi()
    return list(api.fetch(video_id, languages=[language]))


def merge_captions(chinese, vietnamese, max_seconds: float = 8.0):
    merged = []
    current = None
    for index, item in enumerate(chinese):
        vi = vietnamese[index].text if index < len(vietnamese) else ""
        start = float(item.start)
        end = start + float(item.duration)
        if current is None:
            current = {"cn": item.text.strip(), "vi": vi.strip(), "start": start, "end": end}
        else:
            current["cn"] += item.text.strip()
            current["vi"] = f'{current["vi"]} {vi.strip()}'.strip()
            current["end"] = end

        complete = bool(re.search(r"[。！？!?]$", current["cn"]))
        too_long = current["end"] - current["start"] >= max_seconds
        if complete or too_long:
            current["py"] = sentence_pinyin(current["cn"])
            merged.append(current)
            current = None

    if current:
        current["py"] = sentence_pinyin(current["cn"])
        merged.append(current)
    return merged


def main():
    parser = argparse.ArgumentParser(description="Import timed YouTube captions")
    parser.add_argument("video_id")
    parser.add_argument("--lesson-id", required=True)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--zh", default="zh")
    parser.add_argument("--vi", default="vi")
    parser.add_argument("--max-seconds", type=float, default=8.0)
    args = parser.parse_args()

    catalog = json.loads(args.catalog.read_text(encoding="utf-8"))
    lesson = next((item for item in catalog if item.get("id") == args.lesson_id), None)
    if lesson is None:
        raise SystemExit(f"Lesson not found: {args.lesson_id}")

    chinese = fetch_lines(args.video_id, args.zh)
    vietnamese = fetch_lines(args.video_id, args.vi)
    lesson["youtubeId"] = args.video_id
    lesson["subtitles"] = merge_captions(chinese, vietnamese, args.max_seconds)
    lesson["transcriptStatus"] = "timed"
    lesson["transcriptSource"] = "YouTube captions"
    args.catalog.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f'Imported {len(lesson["subtitles"])} timed lines into {args.lesson_id}')


if __name__ == "__main__":
    main()
