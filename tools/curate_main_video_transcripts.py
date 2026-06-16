#!/usr/bin/env python3
"""Curate the main timed video lessons used by the learner app.

The ASR importer intentionally marks generated captions for review. This script
applies the verified corrections for the four main lessons and keeps unfinished
or mismatched lessons in draft status so they never appear to learners.
"""

from __future__ import annotations

import json
from pathlib import Path

from pypinyin import Style, lazy_pinyin


ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "apps" / "mobile" / "assets" / "data" / "video_lessons.json"
PUBLISHED_IDS = {
    "lf_hsk1_hello",
    "new_vid_1",
    "new_vid_2",
    "lf_hsk4_kids_central_12",
}


def sentence_pinyin(text: str) -> str:
    parts = lazy_pinyin(
        text,
        style=Style.TONE,
        neutral_tone_with_five=False,
        errors=lambda value: list(value),
    )
    result = " ".join(part for part in parts if part.strip())
    for mark in "，。！？；：,.!?;:":
        result = result.replace(f" {mark}", mark)
    return result[:1].upper() + result[1:] if result else ""


def subtitle(start: float, end: float, cn: str, vi: str) -> dict:
    return {
        "start": start,
        "end": end,
        "cn": cn,
        "py": sentence_pinyin(cn),
        "vi": vi,
    }


HELLO_SONG = [
    subtitle(8.30, 9.98, "你好，你好。", "Xin chào, xin chào."),
    subtitle(10.10, 11.10, "你好吗？", "Bạn có khỏe không?"),
    subtitle(11.42, 13.80, "早上好，早上好。", "Chào buổi sáng, chào buổi sáng."),
    subtitle(13.84, 16.34, "你好，你好，你好吗？", "Xin chào, xin chào, bạn có khỏe không?"),
    subtitle(16.74, 19.18, "晚上好，晚上好。", "Chào buổi tối, chào buổi tối."),
    subtitle(30.00, 32.44, "你好，你好，你好吗？", "Xin chào, xin chào, bạn có khỏe không?"),
    subtitle(32.44, 35.12, "早上好，早上好。", "Chào buổi sáng, chào buổi sáng."),
    subtitle(35.12, 37.78, "你好，你好，你好吗？", "Xin chào, xin chào, bạn có khỏe không?"),
    subtitle(37.78, 40.60, "晚上好，晚上好。", "Chào buổi tối, chào buổi tối."),
]


BOOKSTORE = [
    subtitle(27.90, 31.40, "一个女人正在书店向店员问问题。", "Một người phụ nữ đang hỏi nhân viên trong hiệu sách."),
    subtitle(32.64, 34.80, "女人想看哪本书？", "Người phụ nữ muốn xem cuốn sách nào?"),
    subtitle(38.12, 41.78, "不好意思，我想看一下那个书架上的书。", "Xin lỗi, tôi muốn xem cuốn sách trên giá kia."),
    subtitle(42.60, 43.94, "您想看哪本？", "Chị muốn xem cuốn nào?"),
    subtitle(44.76, 46.56, "那本关于汽车的书。", "Cuốn sách về ô tô kia."),
    subtitle(47.32, 49.02, "请等一下，是这本吗？", "Xin chờ một chút, có phải cuốn này không?"),
    subtitle(49.76, 50.14, "是的。", "Đúng rồi."),
    subtitle(51.14, 51.58, "给您。", "Của chị đây."),
    subtitle(55.22, 57.12, "女人想看哪本书？", "Người phụ nữ muốn xem cuốn sách nào?"),
    subtitle(62.87, 66.23, "一个女人正在书店向店员问问题。", "Một người phụ nữ đang hỏi nhân viên trong hiệu sách."),
    subtitle(67.65, 69.65, "女人想看哪本书？", "Người phụ nữ muốn xem cuốn sách nào?"),
    subtitle(70.95, 74.69, "不好意思，我想看一下那个书架上的书。", "Xin lỗi, tôi muốn xem cuốn sách trên giá kia."),
    subtitle(75.45, 76.83, "您想看哪本？", "Chị muốn xem cuốn nào?"),
    subtitle(77.53, 79.45, "那本关于汽车的书。", "Cuốn sách về ô tô kia."),
    subtitle(80.09, 81.89, "请等一下，是这本吗？", "Xin chờ một chút, có phải cuốn này không?"),
    subtitle(82.63, 83.01, "是的。", "Đúng rồi."),
    subtitle(83.95, 84.41, "给您。", "Của chị đây."),
]


KIDS_CENTRAL_CORRECTIONS = {
    1: ("莉琪躺在雪地上。", "Lizzie đang nằm trên tuyết."),
    2: ("她和妮娜在做雪天使。", "Cô bé và Nina đang làm hình thiên thần tuyết."),
    5: ("莉琪看到一只红色的小鸟停在树枝上。", "Lizzie thấy một chú chim đỏ đậu trên cành cây."),
    6: ("叽叽叽。", "Chíp chíp chíp."),
    7: ("莉琪对小鸟叫。", "Lizzie gọi chú chim nhỏ."),
    8: ("妮娜，", "Nina,"),
    9: ("鸟儿是不是吃蚯蚓和昆虫？", "Chim có ăn giun đất và côn trùng không?"),
    10: ("莉琪问。", "Lizzie hỏi."),
    13: ("那下雪时它们吃什么呢？", "Vậy khi trời có tuyết chúng ăn gì?"),
    15: ("她们决定去问问雪莉老师。", "Hai bạn quyết định đi hỏi cô Shirley."),
    19: ("莉琪问。", "Lizzie hỏi."),
    21: ("杰森和波比停止打雪仗。", "Jason và Bobby dừng ném tuyết."),
    29: ("莉琪说。", "Lizzie nói."),
    31: ("今天我们要在操场上为鸟儿做喂食器。", "Hôm nay chúng ta sẽ làm máng ăn cho chim ở sân chơi."),
    33: ("莉琪说。", "Lizzie nói."),
    39: ("我的最大！", "Của em là lớn nhất!"),
    48: ("杰森说。", "Jason nói."),
    54: ("妮娜问。", "Nina hỏi."),
    57: ("波比咧嘴笑了。", "Bobby nhe răng cười."),
    60: ("“哇！好黏呀！”莉琪大喊。", "“Oa! Dính quá!” Lizzie hét lên."),
    63: ("这样就可以让鸟食粘到上面。", "Như vậy thức ăn cho chim có thể dính lên trên."),
    67: ("莉琪拿起她的松果说。", "Lizzie cầm quả thông của mình lên và nói."),
    76: ("“那棵。”莉琪指着刚才红色小鸟停过的树。", "“Cây kia.” Lizzie chỉ vào cây mà chú chim đỏ vừa đậu."),
    79: ("她说。", "Cô giáo nói."),
    86: ("大家看着树。", "Mọi người nhìn lên cây."),
    87: ("“它来了！”莉琪开心地小声说。", "“Nó đến rồi!” Lizzie vui vẻ nói nhỏ."),
    88: ("莉琪指着树上的一只红鸟。", "Lizzie chỉ vào một chú chim đỏ trên cây."),
    89: ("它跳到一根树枝上。", "Nó nhảy lên một cành cây."),
    90: ("然后飞下来啄莉琪的松果。", "Sau đó nó bay xuống mổ quả thông của Lizzie."),
    91: ("“我要叫你樱桃。”", "“Mình sẽ gọi bạn là Anh Đào.”"),
    92: ("她说。", "Cô bé nói."),
}


def main() -> None:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    lessons = {item["id"]: item for item in catalog}

    hello = lessons["lf_hsk1_hello"]
    hello["subtitles"] = HELLO_SONG
    hello["transcriptStatus"] = "timed"
    hello["transcriptSource"] = "Verified audio timing"
    hello["reviewStatus"] = "reviewed"

    bookstore = lessons["new_vid_1"]
    bookstore["title"] = "Bookstore Listening Practice"
    bookstore["titleCn"] = "书店听力练习"
    bookstore["subtitles"] = BOOKSTORE
    bookstore["transcriptStatus"] = "timed"
    bookstore["transcriptSource"] = "Verified audio timing"
    bookstore["reviewStatus"] = "reviewed"

    kids = lessons["lf_hsk4_kids_central_12"]
    for index, (cn, vi) in KIDS_CENTRAL_CORRECTIONS.items():
        row = kids["subtitles"][index]
        row["cn"] = cn
        row["py"] = sentence_pinyin(cn)
        row["vi"] = vi
    kids["transcriptStatus"] = "timed"
    kids["transcriptSource"] = "Faster Whisper ASR + burned-in subtitle review"
    kids["reviewStatus"] = "reviewed"

    travel = lessons["new_vid_2"]
    travel["reviewStatus"] = "reviewed"

    for lesson in catalog:
        lesson["status"] = "published" if lesson["id"] in PUBLISHED_IDS else "draft"

    CATALOG.write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(
        "Curated 4 published lessons: "
        f"{len(HELLO_SONG)} + {len(BOOKSTORE)} + "
        f"{len(travel['subtitles'])} + {len(kids['subtitles'])} timed captions."
    )


if __name__ == "__main__":
    main()
