#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TABLE_DIR = ROOT / "data" / "grammar_pdfs"
OUT_PATH = ROOT / "apps" / "mobile" / "assets" / "data" / "grammar_hsk.json"


def clean(text: str) -> str:
    text = text.replace("\u200b", " ").replace("\n", " ").strip()
    text = re.sub(r"\s+", " ", text)
    return text


def parse_examples(raw: str) -> list[dict[str, str]]:
    raw = clean(raw)
    matches = re.findall(r"([^/]+)/([^/]+)/\s*->\s*([^\.。!?]+)", raw)
    examples: list[dict[str, str]] = []
    for cn, py, vi in matches[:3]:
        cn = clean(cn)
        py = clean(py)
        vi = clean(vi)
        if not cn:
            continue
        examples.append({"cn": cn, "py": py, "vi": vi})
    if not examples and raw:
        examples.append({"cn": raw, "py": "", "vi": ""})
    return examples


def extract_pattern(title: str) -> str:
    t = clean(title)
    # remove leading index patterns and quotes
    t = re.sub(r"^\d+[\).:-]*\s*", "", t)
    t = t.replace('“', '"').replace('”', '"')
    return t


def load_table(level: int) -> list[dict]:
    path = TABLE_DIR / f"hsk{level}_tables.json"
    rows = json.loads(path.read_text(encoding="utf-8"))
    lessons: list[dict] = []

    for i, row in enumerate(rows, start=1):
        if not isinstance(row, list) or len(row) < 4:
            continue
        title = clean(str(row[1]))
        explanation = clean(str(row[2]))
        raw_examples = clean(str(row[3]))
        if not title:
            continue

        lessons.append(
            {
                "id": f"h{level}_g{i}",
                "level": f"HSK {level}",
                "title": title,
                "pattern": extract_pattern(title),
                "explanation": explanation,
                "examples": parse_examples(raw_examples),
                "note": "",
            }
        )
    return lessons


def main() -> None:
    all_lessons: list[dict] = []
    for level in [1, 2, 3, 4]:
        all_lessons.extend(load_table(level))

    # Keep lessons with at least one example sentence
    all_lessons = [x for x in all_lessons if x.get("examples")]

    OUT_PATH.write_text(json.dumps(all_lessons, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Wrote {len(all_lessons)} lessons")


if __name__ == "__main__":
    main()
