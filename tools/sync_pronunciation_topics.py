#!/usr/bin/env python3
"""Assign speaking situations to the bundled pronunciation corpus."""

from __future__ import annotations

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
DATA_PATH = ROOT / "apps" / "mobile" / "assets" / "data" / "reading_hsk.json"

TOPIC_RANGES = {
    "HSK 1": [
        (1, 3, "Chào hỏi và phép lịch sự"),
        (4, 9, "Giới thiệu bản thân"),
        (10, 11, "Ngày giờ và lịch hẹn"),
        (12, 16, "Ăn uống và mua sắm"),
        (17, 20, "Nhà cửa và trường học"),
    ],
    "HSK 2": [
        (21, 23, "Học tập và du lịch"),
        (24, 25, "Mặc cả khi mua sắm"),
        (26, 30, "Sinh hoạt và thời tiết"),
        (31, 34, "Gia đình và nhà hàng"),
        (35, 40, "Công việc và thi cử"),
    ],
    "HSK 3": [
        (41, 44, "Giao tiếp và văn hóa"),
        (45, 49, "Họp và xử lý công việc"),
        (50, 54, "Giải trí và mua sắm"),
        (55, 57, "Học tập và nhờ giúp đỡ"),
        (58, 60, "Thành phố và đồng nghiệp"),
    ],
    "HSK 4": [
        (61, 64, "Kỹ năng học và giải quyết vấn đề"),
        (65, 70, "Tin tức, du lịch và văn hóa"),
        (71, 74, "Kế hoạch và trình bày quan điểm"),
        (75, 78, "Công nghệ và truyền thông"),
        (79, 80, "Thành công và ra quyết định"),
    ],
}


def numeric_id(value: str) -> int:
    return int(value.rsplit("_", 1)[-1])


def topic_for(level: str, item_id: str) -> str:
    number = numeric_id(item_id)
    for start, end, topic in TOPIC_RANGES[level]:
        if start <= number <= end:
            return topic
    return "Giao tiếp hằng ngày"


def main() -> None:
    rows = json.loads(DATA_PATH.read_text(encoding="utf-8"))
    for row in rows:
        row["topic"] = topic_for(row["level"], row["id"])
        row.setdefault("status", "published")
    DATA_PATH.write_text(
        json.dumps(rows, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    topics = sorted({row["topic"] for row in rows})
    print(f"Updated {len(rows)} speaking sentences across {len(topics)} topics.")


if __name__ == "__main__":
    main()
