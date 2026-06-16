#!/usr/bin/env python3
"""Create timed Chinese study subtitles from a YouTube video's audio.

This is the fallback for videos that disable YouTube captions. The output is
marked as ASR-generated so an admin can review it before publishing.

Requirements:
    python -m pip install yt-dlp imageio-ffmpeg faster-whisper pypinyin \
        opencc-python-reimplemented

Example:
    python tools/transcribe_youtube_audio.py rYeGfLwkK08 \
        --lesson-id new_vid_1 --model small
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

import imageio_ffmpeg
from faster_whisper import WhisperModel
from opencc import OpenCC
from pypinyin import Style, lazy_pinyin


ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CATALOG = ROOT / "apps" / "mobile" / "assets" / "data" / "video_lessons.json"
DEFAULT_CACHE = ROOT / "artifacts" / "video-audio"
CHINESE = re.compile(r"[\u3400-\u9fff]")
SIMPLIFY = OpenCC("t2s")

COMMON_FIXES = {
    "妳": "你",
    "學歷老師": "雪莉老师",
    "学历老师": "雪莉老师",
    "學習老師": "雪莉老师",
    "衛食器": "喂食器",
    "卫食器": "喂食器",
    "卫士器": "喂食器",
    "鳥石": "鸟食",
    "鸟石": "鸟食",
    "松鼠下": "松树下",
    "牛扭棒": "扭扭棒",
    "昏虫": "昆虫",
    "秋饮": "蚯蚓",
    "秋叶和昆虫": "蚯蚓和昆虫",
}


def clean_chinese(text: str) -> str:
    value = SIMPLIFY.convert(text.strip())
    for source, target in COMMON_FIXES.items():
        value = value.replace(source, target)
    value = re.sub(r"\s+", "", value)
    value = value.replace(",", "，").replace("?", "？").replace("!", "！")
    if value and value[-1] not in "。！？；：":
        value += "。"
    return value


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


def translate_vi(text: str) -> str:
    query = urllib.parse.urlencode(
        {
            "client": "gtx",
            "sl": "zh-CN",
            "tl": "vi",
            "dt": "t",
            "q": text,
        }
    )
    request = urllib.request.Request(
        f"https://translate.googleapis.com/translate_a/single?{query}",
        headers={"User-Agent": "VNChinese-Subtitle-Builder/1.0"},
    )
    for attempt in range(3):
        try:
            with urllib.request.urlopen(request, timeout=20) as response:
                payload = json.loads(response.read().decode("utf-8"))
            return "".join(part[0] for part in payload[0] if part and part[0]).strip()
        except Exception:
            if attempt == 2:
                return ""
            time.sleep(1.5 * (attempt + 1))
    return ""


def download_audio(video_id: str, cache_dir: Path) -> Path:
    cache_dir.mkdir(parents=True, exist_ok=True)
    output = cache_dir / f"{video_id}.wav"
    if output.exists():
        return output
    command = [
        sys.executable,
        "-m",
        "yt_dlp",
        "--js-runtimes",
        "node",
        "--remote-components",
        "ejs:github",
        "--ffmpeg-location",
        imageio_ffmpeg.get_ffmpeg_exe(),
        "-x",
        "--audio-format",
        "wav",
        "--audio-quality",
        "5",
        "-o",
        str(cache_dir / "%(id)s.%(ext)s"),
        f"https://www.youtube.com/watch?v={video_id}",
    ]
    subprocess.run(command, cwd=ROOT, check=True)
    if not output.exists():
        raise RuntimeError(f"Audio was not created: {output}")
    return output


def transcribe(audio: Path, model_name: str, prompt: str):
    model = WhisperModel(model_name, device="cpu", compute_type="int8")
    segments, _ = model.transcribe(
        str(audio),
        language="zh",
        beam_size=5,
        vad_filter=True,
        condition_on_previous_text=False,
        initial_prompt=prompt or "这是中文学习视频，请准确识别普通话。",
    )
    rows = []
    for segment in segments:
        text = clean_chinese(segment.text)
        if not text or not CHINESE.search(text):
            continue
        rows.append(
            {
                "start": round(float(segment.start), 2),
                "end": round(max(float(segment.end), float(segment.start) + 0.8), 2),
                "cn": text,
                "py": sentence_pinyin(text),
                "vi": translate_vi(text),
            }
        )
        print(f'{rows[-1]["start"]:7.2f}-{rows[-1]["end"]:7.2f} {text}')
    return rows


def main() -> None:
    parser = argparse.ArgumentParser(description="Transcribe YouTube audio into timed subtitles")
    parser.add_argument("video_id")
    parser.add_argument("--lesson-id", required=True)
    parser.add_argument("--catalog", type=Path, default=DEFAULT_CATALOG)
    parser.add_argument("--cache-dir", type=Path, default=DEFAULT_CACHE)
    parser.add_argument("--model", default="small")
    parser.add_argument("--prompt", default="")
    args = parser.parse_args()

    catalog = json.loads(args.catalog.read_text(encoding="utf-8"))
    lesson = next((item for item in catalog if item.get("id") == args.lesson_id), None)
    if lesson is None:
        raise SystemExit(f"Lesson not found: {args.lesson_id}")

    audio = download_audio(args.video_id, args.cache_dir)
    subtitles = transcribe(audio, args.model, args.prompt)
    if not subtitles:
        raise SystemExit("No Chinese speech was detected.")

    lesson["youtubeId"] = args.video_id
    lesson["subtitles"] = subtitles
    lesson["transcriptStatus"] = "timed"
    lesson["transcriptSource"] = f"Faster Whisper {args.model} ASR"
    lesson["reviewStatus"] = "needs-review"
    args.catalog.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Imported {len(subtitles)} timed ASR lines into {args.lesson_id}.")


if __name__ == "__main__":
    main()
