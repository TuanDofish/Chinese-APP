#!/usr/bin/env python3
"""Repair flashcard labels from the curated manifest without touching images."""

from __future__ import annotations

import json
from pathlib import Path

from pypinyin import Style, lazy_pinyin


ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "tools" / "flashcard_manifest.json"
FLASHCARD_DIR = ROOT / "apps" / "mobile" / "assets" / "images" / "flashcards"

VIETNAMESE_MEANINGS = {
    "xin chao": "xin chào", "cam on": "cảm ơn", "tam biet": "tạm biệt",
    "xin loi": "xin lỗi", "khong sao": "không sao", "xin moi": "xin mời",
    "ban": "bạn", "toi": "tôi", "anh ay": "anh ấy", "co ay": "cô ấy",
    "hoc tap": "học tập", "hoc sinh": "học sinh", "giao vien": "giáo viên",
    "truong hoc": "trường học", "sach": "sách", "tieng Trung": "tiếng Trung",
    "viet": "viết", "doc": "đọc", "chu": "chữ", "bai tap": "bài tập",
    "mua": "mua", "ban": "bán", "tien": "tiền", "dat": "đắt", "re": "rẻ",
    "cua hang": "cửa hàng", "do vat": "đồ vật", "giam gia": "giảm giá",
    "thanh toan": "thanh toán", "goi mon": "gọi món", "co the": "cơ thể",
    "mat": "mắt", "tai": "tai", "mui": "mũi", "tay": "tay", "chan": "chân",
    "bi benh": "bị bệnh", "benh vien": "bệnh viện", "bac si": "bác sĩ",
    "nghi ngoi": "nghỉ ngơi", "thoi tiet": "thời tiết", "nong": "nóng",
    "lanh": "lạnh", "tuyet": "tuyết", "gio": "gió", "troi nang": "trời nắng",
    "am u": "âm u", "mua xuan": "mùa xuân", "mua he": "mùa hè",
    "phong": "phòng", "cua": "cửa", "cua so": "cửa sổ", "cai ban": "cái bàn",
    "cai ghe": "cái ghế", "giuong": "giường", "coc": "cốc",
    "may tinh": "máy tính", "nha": "nhà", "quan ao": "quần áo",
    "quan": "quần", "giay": "giày", "mu": "mũ", "tat": "tất",
    "ao so mi": "áo sơ mi", "vay": "váy", "ao khoac": "áo khoác",
    "tui": "túi", "mau sac": "màu sắc", "nha hang": "nhà hàng",
    "cong ty": "công ty", "san bay": "sân bay", "ben ga": "bến ga",
    "cong vien": "công viên", "ngan hang": "ngân hàng", "cho": "chợ",
    "the thao": "thể thao", "chay bo": "chạy bộ", "boi loi": "bơi lội",
    "bong da": "bóng đá", "bong ro": "bóng rổ", "di bo": "đi bộ",
    "khoe manh": "khỏe mạnh", "tran dau": "trận đấu", "nhay mua": "nhảy múa",
    "nui": "núi", "song": "sông", "bien": "biển", "hoa": "hoa", "cay": "cây",
    "co": "cỏ", "bau troi": "bầu trời", "phong canh": "phong cảnh",
    "mat troi": "mặt trời", "am nhac": "âm nhạc", "hat": "hát",
    "anh": "ảnh", "tro choi": "trò chơi", "du lich": "du lịch",
    "tu hop": "tụ họp", "thuc day": "thức dậy", "ngu": "ngủ", "tam": "tắm",
    "nau an": "nấu ăn", "an com": "ăn cơm", "uong nuoc": "uống nước",
    "di lam": "đi làm", "tan lam": "tan làm", "mua do": "mua đồ",
    "goi dien": "gọi điện", "thanh pho": "thành phố", "duong pho": "đường phố",
    "giao thong": "giao thông", "tau dien ngam": "tàu điện ngầm",
    "moi truong": "môi trường", "dich vu": "dịch vụ", "van hoa": "văn hóa",
    "xa hoi": "xã hội", "kinh te": "kinh tế",
}

WORD_MEANINGS = {
    "你": "bạn",
    "买": "mua",
    "卖": "bán",
    "雨": "mưa",
    "下雨": "mưa",
}


def repair_manifest(manifest: dict):
    for topic in manifest["topics"]:
        for word in topic.get("words", []):
            word["pinyin"] = " ".join(
                lazy_pinyin(word["word"], style=Style.TONE, neutral_tone_with_five=False)
            )
            meaning = word.get("meaning", "")
            word["meaning"] = WORD_MEANINGS.get(
                word["word"],
                VIETNAMESE_MEANINGS.get(meaning, meaning),
            )


def main():
    manifest = json.loads(MANIFEST.read_text(encoding="utf-8"))
    repair_manifest(manifest)
    MANIFEST.write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    curated_topics = {topic["id"]: topic for topic in manifest["topics"]}

    for topic_id, curated in curated_topics.items():
        metadata_path = FLASHCARD_DIR / topic_id / "metadata.json"
        if not metadata_path.exists():
            continue
        metadata = json.loads(metadata_path.read_text(encoding="utf-8"))
        existing_words = {
            item.get("word"): item for item in metadata.get("words", [])
        }
        repaired_words = []
        for word in curated.get("words", []):
            existing = existing_words.get(word["word"], {})
            repaired_words.append(
                {
                    **existing,
                    **word,
                    "image": existing.get("image", ""),
                    "source": existing.get("source", {}),
                }
            )
        metadata.update(
            {
                "id": topic_id,
                "name": curated["name"],
                "nameCn": curated.get("nameCn", ""),
                "color": curated.get("color", metadata.get("color", "#D32F2F")),
                "words": repaired_words,
            }
        )
        metadata_path.write_text(
            json.dumps(metadata, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )

    index_path = FLASHCARD_DIR / "index.json"
    current_index = json.loads(index_path.read_text(encoding="utf-8"))
    indexed = {topic.get("id"): topic for topic in current_index.get("topics", [])}
    output_topics = []
    for topic_id in curated_topics:
        metadata_path = FLASHCARD_DIR / topic_id / "metadata.json"
        if metadata_path.exists():
            output_topics.append(json.loads(metadata_path.read_text(encoding="utf-8")))
    for topic_id, topic in indexed.items():
        if topic_id not in curated_topics:
            output_topics.append(topic)

    current_index["topics"] = output_topics
    index_path.write_text(
        json.dumps(current_index, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"Repaired {len(output_topics)} topics without replacing image files.")


if __name__ == "__main__":
    main()
