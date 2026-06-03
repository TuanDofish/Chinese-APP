import csv
import json
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MOBILE_DATA = ROOT / "apps" / "mobile" / "assets" / "data"
GRAMMAR_TABLES = ROOT / "data" / "grammar_pdfs"
API_SRC = ROOT / "api" / "src"


def clean_spaces(value: str) -> str:
    return re.sub(r"\s+", " ", (value or "").strip())


def strip_marks(value: str) -> str:
    value = clean_spaces(value)
    value = re.sub(r"^[\s.。?？!！、，,;；:：\-\d]+", "", value)
    return value.strip()


def parse_examples(raw: str) -> list[dict[str, str]]:
    raw = clean_spaces(raw.replace("->", " "))
    items: list[dict[str, str]] = []
    pattern = re.compile(
        r"([\u4e00-\u9fff][^/]*?[。！？?])\s*/([^/]{2,140})/\s*([^/\u4e00-\u9fff]{2,180})"
    )
    for match in pattern.finditer(raw):
        cn = strip_marks(match.group(1))
        py = strip_marks(match.group(2))
        vi = strip_marks(match.group(3))
        vi = re.split(r"\s{2,}|(?=\d+\.)", vi)[0].strip()
        if cn and py and vi:
            items.append({"cn": cn, "py": py, "vi": vi})
        if len(items) >= 3:
            break
    if not items:
        parts = [p.strip() for p in raw.split("/") if p.strip()]
        if len(parts) >= 3:
            items.append(
                {
                    "cn": strip_marks(parts[0]),
                    "py": strip_marks(parts[1]),
                    "vi": strip_marks(parts[2]),
                }
            )
    return items[:3]


def build_grammar() -> None:
    output: list[dict[str, object]] = []
    for level in range(1, 5):
        rows = json.loads((GRAMMAR_TABLES / f"hsk{level}_tables.json").read_text(encoding="utf-8"))
        for idx, row in enumerate(rows):
            if not row:
                continue
            if level in (3, 4) and idx == 0:
                continue
            if level in (1, 2):
                if len(row) < 4:
                    continue
                number, title, explanation, raw_examples = row[:4]
            else:
                if len(row) < 3:
                    continue
                number = str(idx)
                title, explanation, raw_examples = row[:3]
            title = strip_marks(str(title))
            if not title or "Điểm ngữ pháp" in title:
                continue
            examples = parse_examples(str(raw_examples))
            output.append(
                {
                    "id": f"h{level}_g{number}",
                    "level": f"HSK {level}",
                    "title": title,
                    "pattern": title,
                    "explanation": clean_spaces(str(explanation)),
                    "examples": examples,
                    "note": "",
                }
            )
    (MOBILE_DATA / "grammar_hsk14.json").write_text(
        json.dumps(output, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"grammar_hsk14.json: {len(output)} lessons")


def parse_sql_seed() -> None:
    text = (API_SRC / "dict_seed.sql").read_text(encoding="utf-8")
    tuple_re = re.compile(
        r"\('([^']*)','([^']*)','([^']*)','([^']*)','([^']*)',(\d+),'([^']*)'\)",
        re.DOTALL,
    )
    rows: list[dict[str, object]] = []
    seen = set()
    for match in tuple_re.finditer(text):
        simplified, traditional, pinyin, meaning_vi, meaning_en, level, examples_raw = match.groups()
        if simplified in seen:
            continue
        seen.add(simplified)
        try:
            examples = json.loads(examples_raw)
        except json.JSONDecodeError:
            examples = []
        rows.append(
            {
                "simplified": simplified,
                "traditional": traditional,
                "pinyin": pinyin,
                "meaningVi": meaning_vi,
                "meaningEn": meaning_en,
                "hskLevel": int(level),
                "wordType": "",
                "examples": examples,
            }
        )
    (MOBILE_DATA / "dictionary_seed_clean.json").write_text(
        json.dumps(rows, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"dictionary_seed_clean.json: {len(rows)} entries")


def build_hsk_compact() -> None:
    hsk_rows: dict[str, dict[str, object]] = {}
    with (MOBILE_DATA / "hsk30.csv").open(encoding="utf-8", newline="") as fh:
        for row in csv.DictReader(fh):
            level = row.get("Level", "")
            if level not in {"1", "2", "3", "4"}:
                continue
            simplified = row.get("Simplified", "").split("|")[0].strip()
            if not simplified:
                continue
            hsk_rows[simplified] = {
                "simplified": simplified,
                "traditional": row.get("Traditional", "").split("|")[0].strip(),
                "pinyin": row.get("Pinyin", "").split("|")[0].strip(),
                "hskLevel": int(level),
                "wordType": row.get("POS", ""),
                "meaningEn": "",
            }

    complete = json.loads((MOBILE_DATA / "hsk_complete.json").read_text(encoding="utf-8"))
    for item in complete:
        simplified = item.get("simplified", "")
        if simplified not in hsk_rows:
            continue
        forms = item.get("forms") or []
        if forms:
            form = forms[0]
            trans = form.get("transcriptions") or {}
            if trans.get("pinyin"):
                hsk_rows[simplified]["pinyin"] = trans["pinyin"]
            meanings = form.get("meanings") or []
            hsk_rows[simplified]["meaningEn"] = "; ".join(meanings[:3])

    rows = sorted(hsk_rows.values(), key=lambda x: (x["hskLevel"], str(x["simplified"])))
    (MOBILE_DATA / "dictionary_hsk14_compact.json").write_text(
        json.dumps(rows, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"dictionary_hsk14_compact.json: {len(rows)} entries")


def build_reading_news_seed() -> None:
    articles = [
        {
            "id": "news_h1_weather",
            "level": "HSK 1",
            "source": "VNChinese graded news",
            "title": "今天河内天气很好",
            "titleVi": "Hôm nay thời tiết Hà Nội đẹp",
            "content": "今天河内天气很好。早上有太阳，下午不太热。很多学生去学校，也有人去公园散步。",
            "summaryVi": "Bài đọc ngắn về thời tiết và sinh hoạt trong ngày.",
        },
        {
            "id": "news_h1_food",
            "level": "HSK 1",
            "source": "VNChinese graded news",
            "title": "一家新的中国餐厅开门了",
            "titleVi": "Một nhà hàng Trung Quốc mới mở cửa",
            "content": "一家新的中国餐厅今天开门了。这里有米饭、面条、饺子和茶。很多人说菜很好吃。",
            "summaryVi": "Bài đọc về ăn uống, nhà hàng và món ăn cơ bản.",
        },
        {
            "id": "news_h2_transport",
            "level": "HSK 2",
            "source": "VNChinese graded news",
            "title": "城市地铁越来越方便",
            "titleVi": "Tàu điện ngầm trong thành phố ngày càng tiện",
            "content": "这个城市的地铁越来越方便。上班的人可以坐地铁，也可以坐公共汽车。坐地铁比开车快一点。",
            "summaryVi": "Bài đọc luyện từ giao thông và so sánh.",
        },
        {
            "id": "news_h2_school",
            "level": "HSK 2",
            "source": "VNChinese graded news",
            "title": "学生参加中文比赛",
            "titleVi": "Học sinh tham gia cuộc thi tiếng Trung",
            "content": "星期六，很多学生参加中文比赛。他们听中文、读句子，也用中文介绍自己。老师说大家准备得很好。",
            "summaryVi": "Bài đọc về học tập và hoạt động ngoại khóa.",
        },
        {
            "id": "news_h3_tech",
            "level": "HSK 3",
            "source": "VNChinese graded news",
            "title": "手机应用帮助年轻人学习语言",
            "titleVi": "Ứng dụng điện thoại giúp người trẻ học ngoại ngữ",
            "content": "现在，很多年轻人用手机应用学习语言。应用可以安排每天的学习计划，也可以检查发音和语法。坚持练习的人进步很快。",
            "summaryVi": "Bài đọc về công nghệ học tập và thói quen luyện tập.",
        },
        {
            "id": "news_h4_economy",
            "level": "HSK 4",
            "source": "VNChinese graded news",
            "title": "旅游经济逐渐恢复",
            "titleVi": "Kinh tế du lịch dần phục hồi",
            "content": "随着交通更加方便，旅游经济逐渐恢复。许多城市开始介绍本地文化，并且提供更好的服务。虽然竞争很大，但是机会也很多。",
            "summaryVi": "Bài đọc HSK4 về kinh tế, du lịch và câu nối phức.",
        },
    ]
    (MOBILE_DATA / "reading_news_seed.json").write_text(
        json.dumps(articles, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    print(f"reading_news_seed.json: {len(articles)} articles")


def main() -> None:
    build_grammar()
    parse_sql_seed()
    build_hsk_compact()
    build_reading_news_seed()


if __name__ == "__main__":
    main()
