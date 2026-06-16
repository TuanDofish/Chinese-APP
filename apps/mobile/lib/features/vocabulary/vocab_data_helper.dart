import 'package:mobile/core/config/app_config.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/features/grammar/grammar_ai_service.dart';
import 'package:mobile/core/utils/pinyin_utils.dart';
import 'package:mobile/core/utils/text_sanitizer.dart';

class VocabDataHelper {
  // Cache for API translations to avoid repeated calls
  static final Map<String, String> _translationCache = {};
  static final RegExp _mojibakePattern = RegExp(r'[ÃÄÂðŸ]');
  static final Map<String, Map<String, dynamic>> _bundleIndex = {};
  static Future<void>? _bundleLoadFuture;
  static bool _bundleLoaded = false;

  // High-quality manual map for common HSK 1 & 2 words
  static final Map<String, Map<String, dynamic>> _manualMap = {
    // === HSK 1: Ã„ï¿½Ã¡ÂºÂ¡i tÃ¡Â»Â« ===
    "我": {
      "meaning": "Tôi",
      "examples": [
        {
          "cn": "我是学生。",
          "py": "Wǒ shì xuésheng.",
          "vi": "TÃƒÂ´i lÃƒÂ  hÃ¡Â»ï¿½c sinh.",
        },
        {
          "cn": "我喜欢中国。",
          "py": "WÃ‡â€™ xÃ‡ï¿½huÃ„ï¿½n ZhÃ…ï¿½ngguÃƒÂ³.",
          "vi": "Tôi thích Trung Quốc.",
        },
      ],
    },
    "你": {
      "meaning": "Bạn",
      "examples": [
        {
          "cn": "Ã¤Â½Â Ã¥Â¥Â½Ã¯Â¼ï¿½",
          "py": "NÃ‡ï¿½ hÃ‡Å½o!",
          "vi": "Xin chào!",
        },
        {
          "cn": "Ã¤Â½Â Ã¥ï¿½Â«Ã¤Â»â‚¬Ã¤Â¹Ë†Ã¥ï¿½ï¿½Ã¥Â­â€”Ã¯Â¼Å¸",
          "py": "NÃ‡ï¿½ jiÃƒÂ o shÃƒÂ©nme mÃƒÂ­ngzi?",
          "vi": "Bạn tên gì?",
        },
      ],
    },
    "他": {
      "meaning": "Anh ấy",
      "examples": [
        {
          "cn": "Ã¤Â»â€“Ã¦ËœÂ¯Ã¨â‚¬ï¿½Ã¥Â¸Ë†Ã£â‚¬â€š",
          "py": "TÃ„ï¿½ shÃƒÂ¬ lÃ‡Å½oshÃ„Â«.",
          "vi": "Anh ấy là giáo viên.",
        },
        {
          "cn": "他很高。",
          "py": "TÃ„ï¿½ hÃ„â€ºn gÃ„ï¿½o.",
          "vi": "Anh ấy rất cao.",
        },
      ],
    },
    "她": {
      "meaning": "Cô ấy",
      "examples": [
        {
          "cn": "她很漂亮。",
          "py": "TÃ„ï¿½ hÃ„â€ºn piÃƒÂ oliang.",
          "vi": "Cô ấy rất đẹp.",
        },
        {
          "cn": "Ã¥Â¥Â¹Ã¦ËœÂ¯Ã¦Ë†â€˜Ã¦Å“â€¹Ã¥ï¿½â€¹Ã£â‚¬â€š",
          "py": "TÃ„ï¿½ shÃƒÂ¬ wÃ‡â€™ pÃƒÂ©ngyou.",
          "vi": "Cô ấy là bạn tôi.",
        },
      ],
    },
    "我们": {
      "meaning": "Chúng tôi",
      "examples": [
        {
          "cn": "Ã¦Ë†â€˜Ã¤Â»Â¬Ã¥Å½Â»Ã¥ï¿½Æ’Ã©Â¥Â­Ã¥ï¿½Â§Ã£â‚¬â€š",
          "py": "Wǒmen qù chīfàn ba.",
          "vi": "Chúng ta đi ăn cơm đi.",
        },
      ],
    },
    "这": {
      "meaning": "Ã„ï¿½ÃƒÂ¢y, nÃƒÂ y",
      "examples": [
        {
          "cn": "这是什么?",
          "py": "Zhè shì shénme?",
          "vi": "Ã„ï¿½ÃƒÂ¢y lÃƒÂ  cÃƒÂ¡i gÃƒÂ¬?",
        },
      ],
    },
    "é'£": {
      "meaning": "Kia, đó",
      "examples": [
        {
          "cn": "Ã©â€šÂ£Ã¦ËœÂ¯Ã¨Â°ï¿½Ã¯Â¼Å¸",
          "py": "Nà shì shéi?",
          "vi": "Ã„ï¿½ÃƒÂ³ lÃƒÂ  ai?",
        },
      ],
    },
    "哪": {
      "meaning": "Nào, đâu",
      "examples": [
        {
          "cn": "你是哪国人?",
          "py": "NÃ‡ï¿½ shÃƒÂ¬ nÃ‡Å½ guÃƒÂ³ rÃƒÂ©n?",
          "vi": "BÃ¡ÂºÂ¡n lÃƒÂ  ngÃ†Â°Ã¡Â»ï¿½i nÃ†Â°Ã¡Â»â€ºc nÃƒÂ o?",
        },
      ],
    },
    "Ã¨Â°ï¿½": {
      "meaning": "Ai",
      "examples": [
        {
          "cn": "Ã¤Â»â€“Ã¦ËœÂ¯Ã¨Â°ï¿½Ã¯Â¼Å¸",
          "py": "TÃ„ï¿½ shÃƒÂ¬ shÃƒÂ©i?",
          "vi": "Anh ấy là ai?",
        },
      ],
    },
    "什么": {
      "meaning": "Cái gì",
      "examples": [
        {
          "cn": "这是什么?",
          "py": "Zhè shì shénme?",
          "vi": "Ã„ï¿½ÃƒÂ¢y lÃƒÂ  cÃƒÂ¡i gÃƒÂ¬?",
        },
      ],
    },
    "几": {
      "meaning": "Mấy",
      "examples": [
        {
          "cn": "Ã¤Â½Â Ã¥â€¡Â Ã¥Â²ï¿½Ã¯Â¼Å¸",
          "py": "NÃ‡ï¿½ jÃ‡ï¿½ suÃƒÂ¬?",
          "vi": "Bạn mấy tuổi?",
        },
      ],
    },
    "怎么": {
      "meaning": "Thế nào, sao",
      "examples": [
        {"cn": "你怎么了?", "py": "NÃ‡ï¿½ zÃ„â€ºnme le?", "vi": "Bạn làm sao vậy?"},
      ],
    },
    "怎么样": {
      "meaning": "Như thế nào",
      "examples": [
        {
          "cn": "天气怎么样？",
          "py": "TiÃ„ï¿½nqÃƒÂ¬ zÃ„â€ºnmeyÃƒÂ ng?",
          "vi": "ThÃ¡Â»ï¿½i tiÃ¡ÂºÂ¿t thÃ¡ÂºÂ¿ nÃƒÂ o?",
        },
      ],
    },
    // === HSK 1: Số đếm ===
    "一": {
      "meaning": "Một (1)",
      "examples": [
        {"cn": "一个苹果。", "py": "Yí ge píngguǒ.", "vi": "Một quả táo."},
      ],
    },
    "二": {
      "meaning": "Hai (2)",
      "examples": [
        {"cn": "二月。", "py": "Èryuè.", "vi": "Tháng hai."},
      ],
    },
    "三": {
      "meaning": "Ba (3)",
      "examples": [
        {"cn": "三天。", "py": "SÃ„ï¿½n tiÃ„ï¿½n.", "vi": "Ba ngày."},
      ],
    },
    "四": {
      "meaning": "Bốn (4)",
      "examples": [
        {"cn": "四年。", "py": "Sì nián.", "vi": "Bốn năm."},
      ],
    },
    "五": {
      "meaning": "Năm (5)",
      "examples": [
        {"cn": "五个人。", "py": "Wǔ ge rén.", "vi": "NÃ„Æ’m ngÃ†Â°Ã¡Â»ï¿½i."},
      ],
    },
    "六": {
      "meaning": "Sáu (6)",
      "examples": [
        {"cn": "星期六。", "py": "Xīngqīliù.", "vi": "Thứ bảy."},
      ],
    },
    "七": {
      "meaning": "Bảy (7)",
      "examples": [
        {"cn": "七点。", "py": "Qī diǎn.", "vi": "BÃ¡ÂºÂ£y giÃ¡Â»ï¿½."},
      ],
    },
    "Ã¥â€¦Â«": {
      "meaning": "Tám (8)",
      "examples": [
        {"cn": "八个月。", "py": "BÃ„ï¿½ ge yuÃƒÂ¨.", "vi": "Tám tháng."},
      ],
    },
    "Ã¤Â¹ï¿½": {
      "meaning": "Chín (9)",
      "examples": [
        {"cn": "Ã¤Â¹ï¿½Ã¦Å“Ë†Ã£â‚¬â€š", "py": "Jiǔyuè.", "vi": "Tháng chín."},
      ],
    },
    "Ã¥ï¿½ï¿½": {
      "meaning": "MÃ†Â°Ã¡Â»ï¿½i (10)",
      "examples": [
        {
          "cn": "Ã¥ï¿½ï¿½Ã¥ï¿½â€”Ã©â€™Â±Ã£â‚¬â€š",
          "py": "Shí kuài qián.",
          "vi": "MÃ†Â°Ã¡Â»ï¿½i Ã„â€˜Ã¡Â»â€œng.",
        },
      ],
    },
    "零": {
      "meaning": "Không (0)",
      "examples": [
        {"cn": "零度。", "py": "Líng dù.", "vi": "Không độ."},
      ],
    },
    // === HSK 1: Gia Ã„â€˜ÃƒÂ¬nh & Con ngÃ†Â°Ã¡Â»ï¿½i ===
    "人": {
      "meaning": "NgÃ†Â°Ã¡Â»ï¿½i",
      "examples": [
        {
          "cn": "中国人。",
          "py": "ZhÃ…ï¿½ngguÃƒÂ³ rÃƒÂ©n.",
          "vi": "NgÃ†Â°Ã¡Â»ï¿½i Trung QuÃ¡Â»â€˜c.",
        },
      ],
    },
    "Ã¥ï¿½ï¿½Ã¥Â­â€”": {
      "meaning": "Tên",
      "examples": [
        {
          "cn": "Ã¤Â½Â Ã¥ï¿½Â«Ã¤Â»â‚¬Ã¤Â¹Ë†Ã¥ï¿½ï¿½Ã¥Â­â€”Ã¯Â¼Å¸",
          "py": "NÃ‡ï¿½ jiÃƒÂ o shÃƒÂ©nme mÃƒÂ­ngzi?",
          "vi": "Bạn tên gì?",
        },
      ],
    },
    "爸": {
      "meaning": "Bố (thân mật)",
      "examples": [
        {
          "cn": "Ã§Ë†Â¸Ã¯Â¼Å’Ã¦Ë†â€˜Ã¥â€ºÅ¾Ã¦ï¿½Â¥Ã¤Âºâ€ Ã£â‚¬â€š",
          "py": "Bà, wǒ huílái le.",
          "vi": "BÃ¡Â»â€˜ Ã†Â¡i, con vÃ¡Â»ï¿½ rÃ¡Â»â€œi.",
        },
      ],
    },
    "爸爸": {
      "meaning": "Bố, cha",
      "examples": [
        {
          "cn": "爸爸去工作了。",
          "py": "BÃƒÂ ba qÃƒÂ¹ gÃ…ï¿½ngzuÃƒÂ² le.",
          "vi": "Bố đi làm rồi.",
        },
      ],
    },
    "妈": {
      "meaning": "Mẹ (thân mật)",
      "examples": [
        {
          "cn": "Ã¥Â¦Ë†Ã¯Â¼Å’Ã¥ï¿½Æ’Ã©Â¥Â­Ã¤Âºâ€ Ã£â‚¬â€š",
          "py": "MÃ„ï¿½, chÃ„Â«fÃƒÂ n le.",
          "vi": "Mẹ, ăn cơm rồi.",
        },
      ],
    },
    "妈妈": {
      "meaning": "Mẹ",
      "examples": [
        {
          "cn": "Ã¥Â¦Ë†Ã¥Â¦Ë†Ã¥ï¿½Å¡Ã©Â¥Â­Ã£â‚¬â€š",
          "py": "MÃ„ï¿½ma zuÃƒÂ² fÃƒÂ n.",
          "vi": "Mẹ nấu cơm.",
        },
      ],
    },
    "Ã¥â€žÂ¿Ã¥Â­ï¿½": {
      "meaning": "Con trai",
      "examples": [
        {
          "cn": "Ã¤Â»â€“Ã¦Å“â€°Ã¤Â¸â‚¬Ã¤Â¸ÂªÃ¥â€žÂ¿Ã¥Â­ï¿½Ã£â‚¬â€š",
          "py": "TÃ„ï¿½ yÃ‡â€™u yÃƒÂ­ ge ÃƒÂ©rzi.",
          "vi": "Anh ấy có một con trai.",
        },
      ],
    },
    "女儿": {
      "meaning": "Con gái",
      "examples": [
        {
          "cn": "Ã¥Â¥Â³Ã¥â€žÂ¿Ã¥Â¾Ë†Ã¥ï¿½Â¯Ã§Ë†Â±Ã£â‚¬â€š",
          "py": "Nǚ'ér hěn kě'ài.",
          "vi": "Con gái rất đáng yêu.",
        },
      ],
    },
    "Ã¦Å“â€¹Ã¥ï¿½â€¹": {
      "meaning": "Bạn bè",
      "examples": [
        {
          "cn": "Ã¦Ë†â€˜Ã¤Â»Â¬Ã¦ËœÂ¯Ã¥Â¥Â½Ã¦Å“â€¹Ã¥ï¿½â€¹Ã£â‚¬â€š",
          "py": "Wǒmen shì hǎo péngyou.",
          "vi": "Chúng ta là bạn tốt.",
        },
      ],
    },
    "先生": {
      "meaning": "Ông, ngài",
      "examples": [
        {
          "cn": "王先生你好。",
          "py": "WÃƒÂ¡ng xiÃ„ï¿½nsheng nÃ‡ï¿½ hÃ‡Å½o.",
          "vi": "Chào ông Vương.",
        },
      ],
    },
    "Ã¥Â°ï¿½Ã¥Â§ï¿½": {
      "meaning": "Cô, tiểu thư",
      "examples": [
        {
          "cn": "Ã¦ï¿½Å½Ã¥Â°ï¿½Ã¥Â§ï¿½Ã¨Â¯Â·Ã¥ï¿½ï¿½Ã£â‚¬â€š",
          "py": "LÃ‡ï¿½ xiÃ‡Å½ojiÃ„â€º qÃ‡ï¿½ng zuÃƒÂ².",
          "vi": "MÃ¡Â»ï¿½i cÃƒÂ´ LÃƒÂ½ ngÃ¡Â»â€œi.",
        },
      ],
    },
    "Ã¨â‚¬ï¿½Ã¥Â¸Ë†": {
      "meaning": "Thầy/cô giáo",
      "examples": [
        {
          "cn": "Ã¨â‚¬ï¿½Ã¥Â¸Ë†Ã¥Â¥Â½Ã¯Â¼ï¿½",
          "py": "Lǎoshī hǎo!",
          "vi": "Em chào thầy/cô!",
        },
      ],
    },
    "学生": {
      "meaning": "HÃ¡Â»ï¿½c sinh",
      "examples": [
        {
          "cn": "我是学生。",
          "py": "Wǒ shì xuésheng.",
          "vi": "TÃƒÂ´i lÃƒÂ  hÃ¡Â»ï¿½c sinh.",
        },
      ],
    },
    "Ã¥ï¿½Å’Ã¥Â­Â¦": {
      "meaning": "BÃ¡ÂºÂ¡n hÃ¡Â»ï¿½c",
      "examples": [
        {
          "cn": "Ã¤Â»â€“Ã¦ËœÂ¯Ã¦Ë†â€˜Ã¥ï¿½Å’Ã¥Â­Â¦Ã£â‚¬â€š",
          "py": "TÃ„ï¿½ shÃƒÂ¬ wÃ‡â€™ tÃƒÂ³ngxuÃƒÂ©.",
          "vi": "CÃ¡ÂºÂ­u Ã¡ÂºÂ¥y lÃƒÂ  bÃ¡ÂºÂ¡n hÃ¡Â»ï¿½c tÃƒÂ´i.",
        },
      ],
    },
    "医生": {
      "meaning": "Bác sĩ",
      "examples": [
        {
          "cn": "Ã¥Å’Â»Ã§â€Å¸Ã¨Â¯Â´Ã¥Â¤Å¡Ã¥â€“ï¿½Ã¦Â°Â´Ã£â‚¬â€š",
          "py": "YÃ„Â«shÃ„â€œng shuÃ…ï¿½ duÃ…ï¿½ hÃ„â€œ shuÃ‡ï¿½.",
          "vi": "BÃƒÂ¡c sÃ„Â© bÃ¡ÂºÂ£o uÃ¡Â»â€˜ng nhiÃ¡Â»ï¿½u nÃ†Â°Ã¡Â»â€ºc.",
        },
      ],
    },
    // === HSK 1: Ã„ï¿½Ã¡Â»â€œ vÃ¡ÂºÂ­t & Ã„ï¿½Ã¡Â»â€¹a Ã„â€˜iÃ¡Â»Æ’m ===
    "书": {
      "meaning": "Sách",
      "examples": [
        {"cn": "看书。", "py": "Kàn shū.", "vi": "Ã„ï¿½Ã¡Â»ï¿½c sÃƒÂ¡ch."},
      ],
    },
    "Ã¦Â¤â€¦Ã¥Â­ï¿½": {
      "meaning": "Ghế",
      "examples": [
        {
          "cn": "Ã¥ï¿½ï¿½Ã¦Â¤â€¦Ã¥Â­ï¿½Ã£â‚¬â€š",
          "py": "ZuÃƒÂ² yÃ‡ï¿½zi.",
          "vi": "Ngồi ghế.",
        },
      ],
    },
    "Ã¦Â¡Å’Ã¥Â­ï¿½": {
      "meaning": "Bàn",
      "examples": [
        {
          "cn": "Ã¤Â¹Â¦Ã¥Å“Â¨Ã¦Â¡Å’Ã¥Â­ï¿½Ã¤Â¸Å Ã£â‚¬â€š",
          "py": "ShÃ…Â« zÃƒÂ i zhuÃ…ï¿½zi shÃƒÂ ng.",
          "vi": "Sách ở trên bàn.",
        },
      ],
    },
    "Ã¦ï¿½Â¯Ã¥Â­ï¿½": {
      "meaning": "Cốc",
      "examples": [
        {
          "cn": "Ã¤Â¸â‚¬Ã¤Â¸ÂªÃ¦ï¿½Â¯Ã¥Â­ï¿½Ã£â‚¬â€š",
          "py": "Yí ge bēizi.",
          "vi": "Một cái cốc.",
        },
      ],
    },
    "电脑": {
      "meaning": "Máy tính",
      "examples": [
        {"cn": "用电脑。", "py": "Yòng diànnǎo.", "vi": "Dùng máy tính."},
      ],
    },
    "电视": {
      "meaning": "Ti vi",
      "examples": [
        {"cn": "看电视。", "py": "Kàn diànshì.", "vi": "Xem ti vi."},
      ],
    },
    "电影": {
      "meaning": "Phim",
      "examples": [
        {"cn": "看电影。", "py": "KÃƒÂ n diÃƒÂ nyÃ‡ï¿½ng.", "vi": "Xem phim."},
      ],
    },
    "Ã¨Â¡Â£Ã¦Å“ï¿½": {
      "meaning": "Quần áo",
      "examples": [
        {
          "cn": "Ã¤Â¹Â°Ã¨Â¡Â£Ã¦Å“ï¿½Ã£â‚¬â€š",
          "py": "Mǎi yīfu.",
          "vi": "Mua quần áo.",
        },
      ],
    },
    "东西": {
      "meaning": "Ã„ï¿½Ã¡Â»â€œ vÃ¡ÂºÂ­t",
      "examples": [
        {"cn": "买东西。", "py": "MÃ‡Å½i dÃ…ï¿½ngxi.", "vi": "Mua đồ."},
      ],
    },
    "é'±": {
      "meaning": "TiÃ¡Â»ï¿½n",
      "examples": [
        {
          "cn": "多少钱?",
          "py": "DuÃ…ï¿½shÃ‡Å½o qiÃƒÂ¡n?",
          "vi": "Bao nhiÃƒÂªu tiÃ¡Â»ï¿½n?",
        },
      ],
    },
    "家": {
      "meaning": "Nhà",
      "examples": [
        {"cn": "回家。", "py": "HuÃƒÂ­ jiÃ„ï¿½.", "vi": "VÃ¡Â»ï¿½ nhÃƒÂ ."},
      ],
    },
    "学校": {
      "meaning": "TrÃ†Â°Ã¡Â»ï¿½ng hÃ¡Â»ï¿½c",
      "examples": [
        {
          "cn": "去学校。",
          "py": "Qù xuéxiào.",
          "vi": "Ã„ï¿½i Ã„â€˜Ã¡ÂºÂ¿n trÃ†Â°Ã¡Â»ï¿½ng.",
        },
      ],
    },
    "饭店": {
      "meaning": "Nhà hàng",
      "examples": [
        {
          "cn": "Ã¥Å½Â»Ã©Â¥Â­Ã¥Âºâ€”Ã¥ï¿½Æ’Ã©Â¥Â­Ã£â‚¬â€š",
          "py": "Qù fàndiàn chīfàn.",
          "vi": "Ã„ï¿½i nhÃƒÂ  hÃƒÂ ng Ã„Æ’n cÃ†Â¡m.",
        },
      ],
    },
    "商店": {
      "meaning": "Cửa hàng",
      "examples": [
        {
          "cn": "去商店买东西。",
          "py": "QÃƒÂ¹ shÃ„ï¿½ngdiÃƒÂ n mÃ‡Å½i dÃ…ï¿½ngxi.",
          "vi": "Ã„ï¿½i cÃ¡Â»Â­a hÃƒÂ ng mua Ã„â€˜Ã¡Â»â€œ.",
        },
      ],
    },
    "医院": {
      "meaning": "Bệnh viện",
      "examples": [
        {
          "cn": "去医院。",
          "py": "Qù yīyuàn.",
          "vi": "Ã„ï¿½i bÃ¡Â»â€¡nh viÃ¡Â»â€¡n.",
        },
      ],
    },
    "Ã§ï¿½Â«Ã¨Â½Â¦Ã§Â«â„¢": {
      "meaning": "Ga tÃƒÂ u hÃ¡Â»ï¿½a",
      "examples": [
        {
          "cn": "Ã¥Å½Â»Ã§ï¿½Â«Ã¨Â½Â¦Ã§Â«â„¢Ã£â‚¬â€š",
          "py": "Qù huǒchēzhàn.",
          "vi": "Ã„ï¿½i ga tÃƒÂ u.",
        },
      ],
    },
    "中国": {
      "meaning": "Trung Quốc",
      "examples": [
        {
          "cn": "我爱中国。",
          "py": "WÃ‡â€™ ÃƒÂ i ZhÃ…ï¿½ngguÃƒÂ³.",
          "vi": "Tôi yêu Trung Quốc.",
        },
      ],
    },
    "北京": {
      "meaning": "Bắc Kinh",
      "examples": [
        {
          "cn": "北京是中国的首都。",
          "py": "BÃ„â€ºijÃ„Â«ng shÃƒÂ¬ ZhÃ…ï¿½ngguÃƒÂ³ de shÃ‡â€™udÃ…Â«.",
          "vi": "Bắc Kinh là thủ đô Trung Quốc.",
        },
        {
          "cn": "我想去北京。",
          "py": "Wǒ xiǎng qù Běijīng.",
          "vi": "Tôi muốn đi Bắc Kinh.",
        },
      ],
    },
    // === HSK 1: ThÃ¡Â»ï¿½i gian ===
    "今天": {
      "meaning": "Hôm nay",
      "examples": [
        {
          "cn": "今天星期一。",
          "py": "JÃ„Â«ntiÃ„ï¿½n xÃ„Â«ngqÃ„Â«yÃ„Â«.",
          "vi": "Hôm nay thứ hai.",
        },
      ],
    },
    "明天": {
      "meaning": "Ngày mai",
      "examples": [
        {
          "cn": "Ã¦ËœÅ½Ã¥Â¤Â©Ã¨Â§ï¿½Ã¯Â¼ï¿½",
          "py": "MÃƒÂ­ngtiÃ„ï¿½n jiÃƒÂ n!",
          "vi": "Ngày mai gặp!",
        },
      ],
    },
    "昨天": {
      "meaning": "Hôm qua",
      "examples": [
        {
          "cn": "昨天下雨了。",
          "py": "ZuÃƒÂ³tiÃ„ï¿½n xiÃƒÂ yÃ‡â€ le.",
          "vi": "HÃƒÂ´m qua trÃ¡Â»ï¿½i mÃ†Â°a.",
        },
      ],
    },
    "Ã¤Â¸Å Ã¥ï¿½Ë†": {
      "meaning": "Buổi sáng",
      "examples": [
        {
          "cn": "Ã¤Â¸Å Ã¥ï¿½Ë†Ã¥Â¥Â½Ã¯Â¼ï¿½",
          "py": "Shàngwǔ hǎo!",
          "vi": "Chào buổi sáng!",
        },
      ],
    },
    "Ã¤Â¸Â­Ã¥ï¿½Ë†": {
      "meaning": "Buổi trưa",
      "examples": [
        {
          "cn": "Ã¤Â¸Â­Ã¥ï¿½Ë†Ã¥ï¿½Æ’Ã©Â¥Â­Ã£â‚¬â€š",
          "py": "ZhÃ…ï¿½ngwÃ‡â€ chÃ„Â«fÃƒÂ n.",
          "vi": "Trưa ăn cơm.",
        },
      ],
    },
    "Ã¤Â¸â€¹Ã¥ï¿½Ë†": {
      "meaning": "BuÃ¡Â»â€¢i chiÃ¡Â»ï¿½u",
      "examples": [
        {
          "cn": "Ã¤Â¸â€¹Ã¥ï¿½Ë†Ã¦Å“â€°Ã¨Â¯Â¾Ã£â‚¬â€š",
          "py": "Xiàwǔ yǒu kè.",
          "vi": "ChiÃ¡Â»ï¿½u cÃƒÂ³ tiÃ¡ÂºÂ¿t hÃ¡Â»ï¿½c.",
        },
      ],
    },
    "年": {
      "meaning": "Năm",
      "examples": [
        {"cn": "明年。", "py": "Míngnián.", "vi": "Năm sau."},
      ],
    },
    "月": {
      "meaning": "Tháng",
      "examples": [
        {"cn": "五月。", "py": "Wǔyuè.", "vi": "Tháng năm."},
      ],
    },
    "日": {
      "meaning": "Ngày",
      "examples": [
        {"cn": "三月八日。", "py": "SÃ„ï¿½nyuÃƒÂ¨ bÃ„ï¿½rÃƒÂ¬.", "vi": "Ngày 8/3."},
      ],
    },
    "Ã¥ï¿½Â·": {
      "meaning": "Ngày (số)",
      "examples": [
        {
          "cn": "Ã¤Â»Å Ã¥Â¤Â©Ã¥â€¡Â Ã¥ï¿½Â·Ã¯Â¼Å¸",
          "py": "JÃ„Â«ntiÃ„ï¿½n jÃ‡ï¿½ hÃƒÂ o?",
          "vi": "Hôm nay ngày mấy?",
        },
      ],
    },
    "星期": {
      "meaning": "Tuần",
      "examples": [
        {"cn": "星期天。", "py": "XÃ„Â«ngqÃ„Â«tiÃ„ï¿½n.", "vi": "Chủ nhật."},
      ],
    },
    "点": {
      "meaning": "GiÃ¡Â»ï¿½",
      "examples": [
        {"cn": "八点。", "py": "BÃ„ï¿½ diÃ‡Å½n.", "vi": "TÃƒÂ¡m giÃ¡Â»ï¿½."},
      ],
    },
    "分钟": {
      "meaning": "Phút",
      "examples": [
        {"cn": "五分钟。", "py": "WÃ‡â€ fÃ„â€œnzhÃ…ï¿½ng.", "vi": "Năm phút."},
      ],
    },
    "现在": {
      "meaning": "BÃƒÂ¢y giÃ¡Â»ï¿½",
      "examples": [
        {
          "cn": "现在几点?",
          "py": "XiÃƒÂ nzÃƒÂ i jÃ‡ï¿½ diÃ‡Å½n?",
          "vi": "BÃƒÂ¢y giÃ¡Â»ï¿½ mÃ¡ÂºÂ¥y giÃ¡Â»ï¿½?",
        },
      ],
    },
    "时候": {
      "meaning": "Lúc, khi",
      "examples": [
        {"cn": "什么时候？", "py": "Shénme shíhou?", "vi": "Khi nào?"},
      ],
    },
    // === HSK 1: Ăn uống ===
    "Ã¥ï¿½Æ’": {
      "meaning": "Ăn",
      "examples": [
        {
          "cn": "Ã¥ï¿½Æ’Ã©Â¥Â­Ã¤Âºâ€ Ã£â‚¬â€š",
          "py": "Chīfàn le.",
          "vi": "Ăn cơm rồi.",
        },
      ],
    },
    "Ã¥â€“ï¿½": {
      "meaning": "Uống",
      "examples": [
        {"cn": "Ã¥â€“ï¿½Ã¨Å’Â¶Ã£â‚¬â€š", "py": "Hē chá.", "vi": "Uống trà."},
      ],
    },
    "饭": {
      "meaning": "Cơm",
      "examples": [
        {"cn": "Ã¥ï¿½Å¡Ã©Â¥Â­Ã£â‚¬â€š", "py": "Zuò fàn.", "vi": "Nấu cơm."},
      ],
    },
    "米饭": {
      "meaning": "Cơm trắng",
      "examples": [
        {
          "cn": "Ã¥ï¿½Æ’Ã§Â±Â³Ã©Â¥Â­Ã£â‚¬â€š",
          "py": "ChÃ„Â« mÃ‡ï¿½fÃƒÂ n.",
          "vi": "Ăn cơm trắng.",
        },
      ],
    },
    "Ã¨ï¿½Å“": {
      "meaning": "Rau, món ăn",
      "examples": [
        {"cn": "Ã¥ï¿½Å¡Ã¨ï¿½Å“Ã£â‚¬â€š", "py": "Zuò cài.", "vi": "Nấu ăn."},
      ],
    },
    "水果": {
      "meaning": "Trái cây",
      "examples": [
        {
          "cn": "Ã¥ï¿½Æ’Ã¦Â°Â´Ã¦Å¾Å“Ã£â‚¬â€š",
          "py": "ChÃ„Â« shuÃ‡ï¿½guÃ‡â€™.",
          "vi": "Ăn trái cây.",
        },
      ],
    },
    "苹果": {
      "meaning": "Táo",
      "examples": [
        {"cn": "一个苹果。", "py": "Yí ge píngguǒ.", "vi": "Một quả táo."},
      ],
    },
    "茶": {
      "meaning": "Trà",
      "examples": [
        {
          "cn": "Ã¨Â¯Â·Ã¥â€“ï¿½Ã¨Å’Â¶Ã£â‚¬â€š",
          "py": "QÃ‡ï¿½ng hÃ„â€œ chÃƒÂ¡.",
          "vi": "MÃ¡Â»ï¿½i uÃ¡Â»â€˜ng trÃƒÂ .",
        },
      ],
    },
    "水": {
      "meaning": "Nước",
      "examples": [
        {
          "cn": "Ã¥â€“ï¿½Ã¦Â°Â´Ã£â‚¬â€š",
          "py": "HÃ„â€œ shuÃ‡ï¿½.",
          "vi": "Uống nước.",
        },
      ],
    },
    // === HSK 1: Ã„ï¿½Ã¡Â»â„¢ng tÃ¡Â»Â« ===
    "是": {
      "meaning": "Là",
      "examples": [
        {
          "cn": "我是中国人。",
          "py": "WÃ‡â€™ shÃƒÂ¬ ZhÃ…ï¿½ngguÃƒÂ³ rÃƒÂ©n.",
          "vi": "TÃƒÂ´i lÃƒÂ  ngÃ†Â°Ã¡Â»ï¿½i Trung QuÃ¡Â»â€˜c.",
        },
      ],
    },
    "有": {
      "meaning": "Có",
      "examples": [
        {
          "cn": "我有一本书。",
          "py": "Wǒ yǒu yì běn shū.",
          "vi": "Tôi có một quyển sách.",
        },
      ],
    },
    "看": {
      "meaning": "Xem, nhìn",
      "examples": [
        {"cn": "看电影。", "py": "KÃƒÂ n diÃƒÂ nyÃ‡ï¿½ng.", "vi": "Xem phim."},
      ],
    },
    "Ã¥ï¿½Â¬": {
      "meaning": "Nghe",
      "examples": [
        {
          "cn": "Ã¥ï¿½Â¬Ã©Å¸Â³Ã¤Â¹ï¿½Ã£â‚¬â€š",
          "py": "Tīng yīnyuè.",
          "vi": "Nghe nhạc.",
        },
      ],
    },
    "说": {
      "meaning": "Nói",
      "examples": [
        {
          "cn": "说汉语。",
          "py": "ShuÃ…ï¿½ HÃƒÂ nyÃ‡â€.",
          "vi": "Nói tiếng Trung.",
        },
      ],
    },
    "读": {
      "meaning": "Ã„ï¿½Ã¡Â»ï¿½c",
      "examples": [
        {"cn": "读书。", "py": "Dú shū.", "vi": "Ã„ï¿½Ã¡Â»ï¿½c sÃƒÂ¡ch."},
      ],
    },
    "写": {
      "meaning": "Viết",
      "examples": [
        {"cn": "写汉字。", "py": "Xiě Hànzì.", "vi": "Viết chữ Hán."},
      ],
    },
    "Ã¦ï¿½Â¥": {
      "meaning": "Ã„ï¿½Ã¡ÂºÂ¿n",
      "examples": [
        {
          "cn": "Ã¤Â½Â Ã¦ï¿½Â¥Ã¥ï¿½Â§Ã£â‚¬â€š",
          "py": "NÃ‡ï¿½ lÃƒÂ¡i ba.",
          "vi": "Bạn đến đi.",
        },
      ],
    },
    "去": {
      "meaning": "Ã„ï¿½i",
      "examples": [
        {
          "cn": "我想去中国。",
          "py": "WÃ‡â€™ xiÃ‡Å½ng qÃƒÂ¹ ZhÃ…ï¿½ngguÃƒÂ³.",
          "vi": "Tôi muốn đi Trung Quốc.",
        },
      ],
    },
    "回": {
      "meaning": "VÃ¡Â»ï¿½",
      "examples": [
        {"cn": "回家。", "py": "HuÃƒÂ­ jiÃ„ï¿½.", "vi": "VÃ¡Â»ï¿½ nhÃƒÂ ."},
      ],
    },
    "想": {
      "meaning": "Muốn, nhớ",
      "examples": [
        {"cn": "我想你。", "py": "WÃ‡â€™ xiÃ‡Å½ng nÃ‡ï¿½.", "vi": "Tôi nhớ bạn."},
      ],
    },
    "Ã¥ï¿½Å¡": {
      "meaning": "Làm",
      "examples": [
        {
          "cn": "Ã¥ï¿½Å¡Ã¤Â½Å“Ã¤Â¸Å¡Ã£â‚¬â€š",
          "py": "Zuò zuòyè.",
          "vi": "Làm bài tập.",
        },
      ],
    },
    "买": {
      "meaning": "Mua",
      "examples": [
        {
          "cn": "Ã¤Â¹Â°Ã¨Â¡Â£Ã¦Å“ï¿½Ã£â‚¬â€š",
          "py": "Mǎi yīfu.",
          "vi": "Mua quần áo.",
        },
      ],
    },
    "Ã¥ï¿½Â«": {
      "meaning": "GÃ¡Â»ï¿½i, tÃƒÂªn lÃƒÂ ",
      "examples": [
        {
          "cn": "Ã¤Â½Â Ã¥ï¿½Â«Ã¤Â»â‚¬Ã¤Â¹Ë†Ã¥ï¿½ï¿½Ã¥Â­â€”Ã¯Â¼Å¸",
          "py": "NÃ‡ï¿½ jiÃƒÂ o shÃƒÂ©nme mÃƒÂ­ngzi?",
          "vi": "Bạn tên gì?",
        },
      ],
    },
    "认识": {
      "meaning": "Quen biết",
      "examples": [
        {
          "cn": "认识你很高兴。",
          "py": "RÃƒÂ¨nshi nÃ‡ï¿½ hÃ„â€ºn gÃ„ï¿½oxÃƒÂ¬ng.",
          "vi": "Rất vui được biết bạn.",
        },
      ],
    },
    "Ã¤Â½ï¿½": {
      "meaning": "Sống, ở",
      "examples": [
        {
          "cn": "Ã¤Â½Â Ã¤Â½ï¿½Ã¥â€œÂªÃ©â€¡Å’Ã¯Â¼Å¸",
          "py": "NÃ‡ï¿½ zhÃƒÂ¹ nÃ‡Å½lÃ‡ï¿½?",
          "vi": "Bạn sống ở đâu?",
        },
      ],
    },
    "学习": {
      "meaning": "HÃ¡Â»ï¿½c tÃ¡ÂºÂ­p",
      "examples": [
        {
          "cn": "好好学习。",
          "py": "Hǎohǎo xuéxí.",
          "vi": "HÃ¡Â»ï¿½c tÃ¡ÂºÂ­p chÃ„Æ’m chÃ¡Â»â€°.",
        },
      ],
    },
    "工作": {
      "meaning": "Làm việc",
      "examples": [
        {
          "cn": "在工作。",
          "py": "ZÃƒÂ i gÃ…ï¿½ngzuÃƒÂ².",
          "vi": "Ã„ï¿½ang lÃƒÂ m viÃ¡Â»â€¡c.",
        },
      ],
    },
    "Ã§ï¿½Â¡Ã¨Â§â€°": {
      "meaning": "NgÃ¡Â»Â§",
      "examples": [
        {
          "cn": "Ã¦Ë†â€˜Ã¦Æ’Â³Ã§ï¿½Â¡Ã¨Â§â€°Ã£â‚¬â€š",
          "py": "Wǒ xiǎng shuìjiào.",
          "vi": "Tôi muốn ngủ.",
        },
      ],
    },
    "Ã¦â€°â€œÃ§â€ÂµÃ¨Â¯ï¿½": {
      "meaning": "GÃ¡Â»ï¿½i Ã„â€˜iÃ¡Â»â€¡n",
      "examples": [
        {
          "cn": "Ã§Â»â„¢Ã¥Â¦Ë†Ã¥Â¦Ë†Ã¦â€°â€œÃ§â€ÂµÃ¨Â¯ï¿½Ã£â‚¬â€š",
          "py": "GÃ„â€ºi mÃ„ï¿½ma dÃ‡Å½ diÃƒÂ nhuÃƒÂ .",
          "vi": "GÃ¡Â»ï¿½i Ã„â€˜iÃ¡Â»â€¡n cho mÃ¡ÂºÂ¹.",
        },
      ],
    },
    "爱": {
      "meaning": "Yêu",
      "examples": [
        {"cn": "我爱你。", "py": "WÃ‡â€™ ÃƒÂ i nÃ‡ï¿½.", "vi": "Anh yêu em."},
        {
          "cn": "Ã¥Â¦Ë†Ã¥Â¦Ë†Ã§Ë†Â±Ã¥ï¿½Æ’Ã¨â€¹Â¹Ã¦Å¾Å“Ã£â‚¬â€š",
          "py": "MÃ„ï¿½ma ÃƒÂ i chÃ„Â« pÃƒÂ­ngguÃ‡â€™.",
          "vi": "Mẹ thích ăn táo.",
        },
      ],
    },
    "喜欢": {
      "meaning": "Thích",
      "examples": [
        {
          "cn": "Ã¦Ë†â€˜Ã¥â€“Å“Ã¦Â¬Â¢Ã¥â€“ï¿½Ã¨Å’Â¶Ã£â‚¬â€š",
          "py": "WÃ‡â€™ xÃ‡ï¿½huÃ„ï¿½n hÃ„â€œ chÃƒÂ¡.",
          "vi": "Tôi thích uống trà.",
        },
      ],
    },
    "爱好": {
      "meaning": "Sở thích",
      "examples": [
        {
          "cn": "你有什么爱好?",
          "py": "NÃ‡ï¿½ yÃ‡â€™u shÃƒÂ©nme ÃƒÂ ihÃƒÂ o?",
          "vi": "Bạn có sở thích gì?",
        },
        {
          "cn": "我的爱好是画画。",
          "py": "Wǒ de àihào shì huàhuà.",
          "vi": "Sở thích của tôi là vẽ.",
        },
      ],
    },
    // === HSK 1: Tính từ ===
    "好": {
      "meaning": "TÃ¡Â»â€˜t, khÃ¡Â»ï¿½e",
      "examples": [
        {
          "cn": "Ã¤Â½Â Ã¥Â¥Â½Ã¥ï¿½â€”Ã¯Â¼Å¸",
          "py": "NÃ‡ï¿½ hÃ‡Å½o ma?",
          "vi": "BÃ¡ÂºÂ¡n khÃ¡Â»ï¿½e khÃƒÂ´ng?",
        },
      ],
    },
    "大": {
      "meaning": "To, lớn",
      "examples": [
        {"cn": "很大。", "py": "Hěn dà.", "vi": "Rất to."},
      ],
    },
    "Ã¥Â°ï¿½": {
      "meaning": "NhÃ¡Â»ï¿½",
      "examples": [
        {
          "cn": "Ã¥Â¾Ë†Ã¥Â°ï¿½Ã£â‚¬â€š",
          "py": "Hěn xiǎo.",
          "vi": "RÃ¡ÂºÂ¥t nhÃ¡Â»ï¿½.",
        },
      ],
    },
    "多": {
      "meaning": "NhiÃ¡Â»ï¿½u",
      "examples": [
        {
          "cn": "人很多。",
          "py": "RÃƒÂ©n hÃ„â€ºn duÃ…ï¿½.",
          "vi": "NgÃ†Â°Ã¡Â»ï¿½i rÃ¡ÂºÂ¥t Ã„â€˜ÃƒÂ´ng.",
        },
      ],
    },
    "å°'": {
      "meaning": "Ãƒï¿½t",
      "examples": [
        {"cn": "很少。", "py": "Hěn shǎo.", "vi": "Rất ít."},
      ],
    },
    "冷": {
      "meaning": "Lạnh",
      "examples": [
        {
          "cn": "今天很冷。",
          "py": "JÃ„Â«ntiÃ„ï¿½n hÃ„â€ºn lÃ„â€ºng.",
          "vi": "Hôm nay lạnh.",
        },
      ],
    },
    "热": {
      "meaning": "Nóng",
      "examples": [
        {
          "cn": "天气很热。",
          "py": "TiÃ„ï¿½nqÃƒÂ¬ hÃ„â€ºn rÃƒÂ¨.",
          "vi": "ThÃ¡Â»ï¿½i tiÃ¡ÂºÂ¿t nÃƒÂ³ng.",
        },
      ],
    },
    "高兴": {
      "meaning": "Vui vẻ",
      "examples": [
        {
          "cn": "我很高兴。",
          "py": "WÃ‡â€™ hÃ„â€ºn gÃ„ï¿½oxÃƒÂ¬ng.",
          "vi": "Tôi rất vui.",
        },
      ],
    },
    "漂亮": {
      "meaning": "Ã„ï¿½Ã¡ÂºÂ¹p",
      "examples": [
        {
          "cn": "你很漂亮。",
          "py": "NÃ‡ï¿½ hÃ„â€ºn piÃƒÂ oliang.",
          "vi": "Bạn rất đẹp.",
        },
      ],
    },
    // === HSK 1: Phó từ & Trợ từ ===
    "Ã¤Â¸ï¿½": {
      "meaning": "Không",
      "examples": [
        {"cn": "Ã¤Â¸ï¿½Ã¥Â¥Â½Ã£â‚¬â€š", "py": "Bù hǎo.", "vi": "Không tốt."},
      ],
    },
    "没": {
      "meaning": "Chưa, không",
      "examples": [
        {"cn": "没去。", "py": "Méi qù.", "vi": "Chưa đi."},
      ],
    },
    "很": {
      "meaning": "Rất",
      "examples": [
        {"cn": "很好。", "py": "Hěn hǎo.", "vi": "Rất tốt."},
      ],
    },
    "太": {
      "meaning": "Quá",
      "examples": [
        {
          "cn": "Ã¥Â¤ÂªÃ¥Â¥Â½Ã¤Âºâ€ Ã¯Â¼ï¿½",
          "py": "Tài hǎo le!",
          "vi": "Tốt quá!",
        },
      ],
    },
    "都": {
      "meaning": "Ã„ï¿½Ã¡Â»ï¿½u",
      "examples": [
        {
          "cn": "我们都去。",
          "py": "WÃ‡â€™men dÃ…ï¿½u qÃƒÂ¹.",
          "vi": "ChÃƒÂºng tÃƒÂ´i Ã„â€˜Ã¡Â»ï¿½u Ã„â€˜i.",
        },
      ],
    },
    "和": {
      "meaning": "Và",
      "examples": [
        {"cn": "我和你。", "py": "WÃ‡â€™ hÃƒÂ© nÃ‡ï¿½.", "vi": "Tôi và bạn."},
      ],
    },
    "在": {
      "meaning": "Ở, đang",
      "examples": [
        {"cn": "我在家。", "py": "WÃ‡â€™ zÃƒÂ i jiÃ„ï¿½.", "vi": "Tôi ở nhà."},
      ],
    },
    "的": {
      "meaning": "Của",
      "examples": [
        {"cn": "我的书。", "py": "Wǒ de shū.", "vi": "Sách của tôi."},
      ],
    },
    "了": {
      "meaning": "Rồi (trợ từ)",
      "examples": [
        {"cn": "Ã¥ï¿½Æ’Ã¤Âºâ€ Ã£â‚¬â€š", "py": "Chī le.", "vi": "Ăn rồi."},
      ],
    },
    "Ã¥ï¿½â€”": {
      "meaning": "KhÃƒÂ´ng? (tÃ¡Â»Â« hÃ¡Â»ï¿½i)",
      "examples": [
        {
          "cn": "Ã¥Â¥Â½Ã¥ï¿½â€”Ã¯Â¼Å¸",
          "py": "Hǎo ma?",
          "vi": "Ã„ï¿½Ã†Â°Ã¡Â»Â£c khÃƒÂ´ng?",
        },
      ],
    },
    "å'¢": {
      "meaning": "Thì sao, nhỉ",
      "examples": [
        {"cn": "你呢?", "py": "NÃ‡ï¿½ ne?", "vi": "Còn bạn thì sao?"},
      ],
    },
    // === HSK 1: Giao tiếp ===
    "你好": {
      "meaning": "Xin chào",
      "examples": [
        {
          "cn": "Ã¤Â½Â Ã¥Â¥Â½Ã¯Â¼ï¿½",
          "py": "NÃ‡ï¿½ hÃ‡Å½o!",
          "vi": "Xin chào!",
        },
      ],
    },
    "谢谢": {
      "meaning": "Cảm ơn",
      "examples": [
        {"cn": "谢谢你。", "py": "XiÃƒÂ¨xie nÃ‡ï¿½.", "vi": "Cảm ơn bạn."},
      ],
    },
    "Ã¤Â¸ï¿½Ã¥Â®Â¢Ã¦Â°â€": {
      "meaning": "Không có chi",
      "examples": [
        {
          "cn": "Ã¤Â¸ï¿½Ã¥Â®Â¢Ã¦Â°â€Ã£â‚¬â€š",
          "py": "Bú kèqì.",
          "vi": "Không có chi.",
        },
      ],
    },
    "Ã¥Â¯Â¹Ã¤Â¸ï¿½Ã¨ÂµÂ·": {
      "meaning": "Xin lÃ¡Â»â€”i",
      "examples": [
        {
          "cn": "Ã¥Â¯Â¹Ã¤Â¸ï¿½Ã¨ÂµÂ·Ã£â‚¬â€š",
          "py": "DuÃƒÂ¬bÃƒÂ¹qÃ‡ï¿½.",
          "vi": "Xin lÃ¡Â»â€”i.",
        },
      ],
    },
    "没关系": {
      "meaning": "Không sao",
      "examples": [
        {"cn": "没关系。", "py": "MÃƒÂ©iguÃ„ï¿½nxi.", "vi": "Không sao."},
      ],
    },
    "Ã¥â€ ï¿½Ã¨Â§ï¿½": {
      "meaning": "Tạm biệt",
      "examples": [
        {"cn": "Ã¥â€ ï¿½Ã¨Â§ï¿½Ã¯Â¼ï¿½", "py": "Zàijiàn!", "vi": "Tạm biệt!"},
      ],
    },
    "请": {
      "meaning": "MÃ¡Â»ï¿½i, xin",
      "examples": [
        {
          "cn": "Ã¨Â¯Â·Ã¥ï¿½ï¿½Ã£â‚¬â€š",
          "py": "QÃ‡ï¿½ng zuÃƒÂ².",
          "vi": "MÃ¡Â»ï¿½i ngÃ¡Â»â€œi.",
        },
      ],
    },
    "å–'": {
      "meaning": "A lô",
      "examples": [
        {
          "cn": "喂,你好。",
          "py": "WÃƒÂ©i, nÃ‡ï¿½ hÃ‡Å½o.",
          "vi": "A lô, xin chào.",
        },
      ],
    },
    // === HSK 1: Giao thông ===
    "Ã¥ï¿½ï¿½": {
      "meaning": "Ngồi, đi (xe)",
      "examples": [
        {
          "cn": "Ã¥ï¿½ï¿½Ã©Â£Å¾Ã¦Å“ÂºÃ£â‚¬â€š",
          "py": "Zuò fēijī.",
          "vi": "Ã„ï¿½i mÃƒÂ¡y bay.",
        },
      ],
    },
    "飞机": {
      "meaning": "Máy bay",
      "examples": [
        {
          "cn": "Ã¥ï¿½ï¿½Ã©Â£Å¾Ã¦Å“ÂºÃ£â‚¬â€š",
          "py": "Zuò fēijī.",
          "vi": "Ã„ï¿½i mÃƒÂ¡y bay.",
        },
      ],
    },
    "出租车": {
      "meaning": "Xe taxi",
      "examples": [
        {
          "cn": "Ã¥ï¿½Â«Ã¥â€¡ÂºÃ§Â§Å¸Ã¨Â½Â¦Ã£â‚¬â€š",
          "py": "Jiào chūzūchē.",
          "vi": "GÃ¡Â»ï¿½i taxi.",
        },
      ],
    },
    "开车": {
      "meaning": "Lái xe",
      "examples": [
        {
          "cn": "Ã¤Â½Â Ã¤Â¼Å¡Ã¥Â¼â‚¬Ã¨Â½Â¦Ã¥ï¿½â€”Ã¯Â¼Å¸",
          "py": "NÃ‡ï¿½ huÃƒÂ¬ kÃ„ï¿½ichÃ„â€œ ma?",
          "vi": "Bạn biết lái xe không?",
        },
      ],
    },
    "路": {
      "meaning": "Ã„ï¿½Ã†Â°Ã¡Â»ï¿½ng",
      "examples": [
        {
          "cn": "在路上。",
          "py": "Zài lù shang.",
          "vi": "TrÃƒÂªn Ã„â€˜Ã†Â°Ã¡Â»ï¿½ng.",
        },
      ],
    },
    // === Các từ phổ biến khác ===
    "游泳": {
      "meaning": "Bơi lội",
      "examples": [
        {"cn": "我会游泳。", "py": "Wǒ huì yóuyǒng.", "vi": "Tôi biết bơi."},
        {
          "cn": "去游泳池游泳。",
          "py": "Qù yóuyǒngchí yóuyǒng.",
          "vi": "Ã„ï¿½i bÃ†Â¡i Ã¡Â»Å¸ hÃ¡Â»â€œ bÃ†Â¡i.",
        },
      ],
    },
    "学习": {
      "meaning": "HÃ¡Â»ï¿½c tÃ¡ÂºÂ­p",
      "examples": [
        {"cn": "学习汉语。", "py": "Xuéxí Hànyǔ.", "vi": "HÃ¡Â»ï¿½c tiáº¿ng Trung."},
      ],
    },
  };

  // Fast patch map for common words that are often missing/noisy from source feeds.
  static final Map<String, Map<String, dynamic>> _quickPatchMap = {
    '谁': {
      'meaning': 'ai',
      'examples': [
        {'cn': '他是谁？', 'py': 'Tā shì shéi?', 'vi': 'Anh ấy là ai?'},
        {'cn': '你在等谁？', 'py': 'Nǐ zài děng shéi?', 'vi': 'Bạn đang đợi ai?'},
      ],
    },
    '我': {
      'meaning': 'tôi',
      'examples': [
        {'cn': '我是学生。', 'py': 'Wǒ shì xuésheng.', 'vi': 'Tôi là học sinh.'},
        {
          'cn': '我喜欢汉语。',
          'py': 'Wǒ xǐhuan Hànyǔ.',
          'vi': 'Tôi thích tiếng Trung.',
        },
      ],
    },
    '你': {
      'meaning': 'bạn',
      'examples': [
        {'cn': '你好吗？', 'py': 'Nǐ hǎo ma?', 'vi': 'Bạn khỏe không?'},
        {'cn': '你叫什么名字？', 'py': 'Nǐ jiào shénme míngzi?', 'vi': 'Bạn tên gì?'},
      ],
    },
    '太': {
      'meaning': 'quá, rất',
      'examples': [
        {'cn': '太好了！', 'py': 'Tài hǎo le!', 'vi': 'Tuyệt quá!'},
        {'cn': '这个太贵了。', 'py': 'Zhège tài guì le.', 'vi': 'Cái này đắt quá.'},
        {'cn': '今天太热了。', 'py': 'Jīntiān tài rè le.', 'vi': 'Hôm nay nóng quá.'},
      ],
    },
    '的': {
      'meaning': 'trợ từ sở hữu, bổ nghĩa',
      'examples': [
        {'cn': '我的朋友。', 'py': 'Wǒ de péngyou.', 'vi': 'Bạn của tôi.'},
        {'cn': '漂亮的衣服。', 'py': 'Piàoliang de yīfu.', 'vi': 'Quần áo đẹp.'},
      ],
    },
    '是': {
      'meaning': 'là',
      'examples': [
        {'cn': '我是学生。', 'py': 'Wǒ shì xuésheng.', 'vi': 'Tôi là học sinh.'},
        {'cn': '他是老师。', 'py': 'Tā shì lǎoshī.', 'vi': 'Anh ấy là giáo viên.'},
      ],
    },
    '呢': {
      'meaning': 'trợ từ ngữ khí',
      'examples': [
        {'cn': '你呢？', 'py': 'Nǐ ne?', 'vi': 'Còn bạn thì sao?'},
        {
          'cn': '他在看书呢。',
          'py': 'Tā zài kàn shū ne.',
          'vi': 'Anh ấy đang đọc sách đấy.',
        },
      ],
    },
    '热烈': {
      'meaning': 'nhiệt liệt',
      'examples': [
        {
          'cn': '大家热烈欢迎你。',
          'py': 'Dàjiā rèliè huānyíng nǐ.',
          'vi': 'Mọi người nhiệt liệt chào mừng bạn.',
        },
        {
          'cn': '现场气氛很热烈。',
          'py': 'Xiànchǎng qìfēn hěn rèliè.',
          'vi': 'Không khí tại chỗ rất sôi nổi.',
        },
      ],
    },
  };

  static Map<String, dynamic>? _manualEntry(String simplified) {
    // Disable large legacy map because many entries are mojibake from old encoding.
    return _quickPatchMap[simplified];
  }

  static Future<void> preloadBundleIndex() async {
    _bundleLoadFuture ??= _loadBundleIndex();
    await _bundleLoadFuture;
  }

  static Future<void> _loadBundleIndex() async {
    if (_bundleLoaded) return;
    try {
      final raw = await rootBundle.loadString('assets/data/hsk_complete.json');
      final data = json.decode(raw);
      if (data is! List) return;
      for (final item in data) {
        if (item is! Map) continue;
        final row = Map<String, dynamic>.from(item as Map);
        final simplified = _cleanText((row['simplified'] ?? '').toString());
        if (simplified.isEmpty || _bundleIndex.containsKey(simplified))
          continue;

        final forms = row['forms'] is List ? row['forms'] as List : const [];
        final first = forms.isNotEmpty && forms.first is Map
            ? Map<String, dynamic>.from(forms.first as Map)
            : <String, dynamic>{};
        final trans = first['transcriptions'] is Map
            ? Map<String, dynamic>.from(first['transcriptions'] as Map)
            : <String, dynamic>{};
        final meanings = first['meanings'] is List
            ? (first['meanings'] as List)
                  .map((e) => _cleanText(e.toString()))
                  .where((e) => e.isNotEmpty)
                  .toList()
            : <String>[];

        _bundleIndex[simplified] = {
          'simplified': simplified,
          'pinyin': _cleanText((trans['pinyin'] ?? '').toString()),
          'numeric': _cleanText((trans['numeric'] ?? '').toString()),
          'meaningEn': meanings.isNotEmpty ? meanings.first : '',
          'hskLevel': row['level'] ?? row['hskLevel'] ?? row['hsk_level'] ?? 0,
        };
      }
      _bundleLoaded = true;
    } catch (_) {
      _bundleLoaded = false;
    }
  }

  static Map<String, dynamic>? _bundleEntry(String simplified) {
    return _bundleIndex[simplified];
  }

  /// Call MyMemory API to translate text
  static Future<String> _translateFromAPI(
    String text, {
    String langpair = 'zh-CN|vi',
  }) async {
    // Check cache first
    String cacheKey = '${langpair}_$text';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    try {
      final url = Uri.parse(
        '${AppConfig.apiBaseUrl}/dictionary/translate?q=${Uri.encodeComponent(text)}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String translated = data['text'] ?? '';
        if (translated.isNotEmpty &&
            translated.toLowerCase() != text.toLowerCase()) {
          _translationCache[cacheKey] = translated;
          return translated;
        }
      }
    } catch (_) {
      // Silently fail, return empty
    }
    return '';
  }

  /// Translate Vietnamese to Chinese (Simplified)
  static Future<String> translateViToZhAsync(String viText) async {
    return await _translateFromAPI(viText, langpair: 'vi|zh-CN');
  }

  static List<Map<String, dynamic>> _normalizeExamples(
    dynamic rawExamples, {
    String? defaultSource,
    String? defaultQuality,
  }) {
    if (rawExamples is! List) return <Map<String, dynamic>>[];
    return rawExamples
        .map((e) {
          final map = Map<String, dynamic>.from((e as Map?) ?? const {});
          final cn = _cleanText((map['cn'] ?? '').toString());
          if (cn.isEmpty) return null;
          return <String, dynamic>{
            'cn': cn,
            'py': _cleanText((map['py'] ?? '').toString()),
            'vi': _cleanText((map['vi'] ?? '').toString()),
            'source': _cleanText(
              (map['source'] ?? defaultSource ?? 'HSK Seed Corpus').toString(),
            ),
            'quality': _cleanText(
              (map['quality'] ?? defaultQuality ?? 'curated').toString(),
            ),
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static bool _isBrokenText(String text) {
    if (text.isEmpty) return false;
    return _mojibakePattern.hasMatch(text) ||
        TextSanitizer.isLikelyMojibake(text);
  }

  static bool _isValidMeaning(String text) {
    if (text.isEmpty) return false;
    final cleaned = text.trim().toLowerCase();
    if (cleaned == 'dang cap nhat nghia...' ||
        cleaned == 'dang cap nhat nghia' ||
        cleaned == 'đang tải nghĩa...' ||
        cleaned == 'đang tải...' ||
        cleaned == '...' ||
        cleaned == '' ||
        cleaned.startsWith('dang cap nhat') ||
        cleaned.startsWith('đang tải')) {
      return false;
    }
    return !_isBrokenText(text);
  }

  static String _cleanText(String text) {
    return TextSanitizer.clean(text);
  }

  static String _extractBestPinyin(
    String simplified,
    Map<String, dynamic> originalJson,
  ) {
    String direct = (originalJson['pinyin'] ?? '').toString().trim();
    if (direct.isNotEmpty && !_isBrokenText(direct)) return direct;

    if (originalJson['forms'] is List &&
        (originalJson['forms'] as List).isNotEmpty) {
      final form = (originalJson['forms'] as List).first;
      if (form is Map) {
        final trans = form['transcriptions'];
        if (trans is Map) {
          final numeric = (trans['numeric'] ?? '').toString().trim();
          if (numeric.isNotEmpty) {
            return PinyinUtils.convertSpaced(numeric);
          }
          final pinyin = (trans['pinyin'] ?? '').toString().trim();
          if (pinyin.isNotEmpty && !_isBrokenText(pinyin)) return pinyin;
        }
      }
    }

    final manual = _manualEntry(simplified);
    if (manual != null) {
      final ex = _normalizeExamples(manual['examples']);
      if (ex.isNotEmpty) {
        final py = (ex.first['py'] ?? '').toString().trim();
        if (py.isNotEmpty && !_isBrokenText(py)) return py;
      }
    }

    final bundle = _bundleEntry(simplified);
    if (bundle != null) {
      final pinyin = _cleanText((bundle['pinyin'] ?? '').toString());
      if (pinyin.isNotEmpty && !_isBrokenText(pinyin)) return pinyin;
      final numeric = _cleanText((bundle['numeric'] ?? '').toString());
      if (numeric.isNotEmpty && !_isBrokenText(numeric)) {
        return PinyinUtils.convertSpaced(numeric);
      }
    }
    return '';
  }

  static String _extractBestMeaning(
    String simplified,
    Map<String, dynamic> originalJson,
  ) {
    final direct = _cleanText((originalJson['meaning'] ?? '').toString());
    if (direct.isNotEmpty &&
        direct != 'Đang tải...' &&
        !_isBrokenText(direct)) {
      return direct;
    }

    if (originalJson['forms'] is List &&
        (originalJson['forms'] as List).isNotEmpty) {
      final form = (originalJson['forms'] as List).first;
      if (form is Map &&
          form['meanings'] is List &&
          (form['meanings'] as List).isNotEmpty) {
        final m = _cleanText((form['meanings'] as List).first.toString());
        if (m.isNotEmpty && !_isBrokenText(m)) return m;
      }
    }

    final manual = _manualEntry(simplified);
    if (manual != null) {
      final m = _cleanText((manual['meaning'] ?? '').toString());
      if (m.isNotEmpty && !_isBrokenText(m)) return m;
    }

    final bundle = _bundleEntry(simplified);
    if (bundle != null) {
      final m = _cleanText((bundle['meaningEn'] ?? '').toString());
      if (m.isNotEmpty && !_isBrokenText(m)) return m;
    }
    return '';
  }

  static List<Map<String, dynamic>> _buildTemplateExamples(
    String simplified,
    String pinyin,
    String meaning,
  ) {
    if (simplified.trim().isEmpty) return <Map<String, dynamic>>[];

    final seed = simplified.runes.fold<int>(0, (s, ch) => s + ch);
    final patterns = <Map<String, String>>[
      {
        'cn': '我今天学习「$simplified」。',
        'py': 'Wǒ jīntiān xuéxí "$simplified".',
        'vi': 'Hôm nay tôi học từ "$meaning".',
      },
      {
        'cn': '这个「$simplified」很常用。',
        'py': 'Zhège "$simplified" hěn chángyòng.',
        'vi': 'Từ "$meaning" này dùng rất thường xuyên.',
      },
      {
        'cn': '请用「$simplified」造句。',
        'py': 'Qǐng yòng "$simplified" zàojù.',
        'vi': 'Hãy đặt câu với từ "$meaning".',
      },
      {
        'cn': '在HSK里，「$simplified」很重要。',
        'py': 'Zài HSK lǐ, "$simplified" hěn zhòngyào.',
        'vi': 'Trong HSK, từ "$meaning" rất quan trọng.',
      },
      {
        'cn': '我想多练习「$simplified」。',
        'py': 'Wǒ xiǎng duō liànxí "$simplified".',
        'vi': 'Tôi muốn luyện thêm từ "$meaning".',
      },
      {
        'cn': '老师解释了「$simplified」的用法。',
        'py': 'Lǎoshī jiěshì le "$simplified" de yòngfǎ.',
        'vi': 'Giáo viên đã giải thích cách dùng của "$meaning".',
      },
    ];

    final results = <Map<String, dynamic>>[];
    for (var i = 0; i < 3; i++) {
      final idx = (seed + i) % patterns.length;
      final row = patterns[idx];
      results.add({
        'cn': row['cn']!,
        'py': row['py']!,
        'vi': row['vi']!,
        'source': 'Template Local',
        'quality': 'curated',
      });
    }
    return results;
  }

  static Future<List<Map<String, dynamic>>> _fetchCuratedExamples(
    String simplified,
    int hskLevel,
  ) async {
    try {
      const apiBase = AppConfig.apiBaseUrl;
      final uri = Uri.parse(
        '$apiBase/dictionary/examples-local?q=${Uri.encodeComponent(simplified)}&hskLevel=$hskLevel&limit=6',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 2));
      if (res.statusCode != 200) return <Map<String, dynamic>>[];
      final data = json.decode(res.body) as Map<String, dynamic>;
      return _normalizeExamples(
        data['results'],
        defaultSource: 'HSK Seed Corpus',
        defaultQuality: 'curated',
      );
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  /// Async version: gets data with HSK-curated examples first, external fallback second.
  static Future<Map<String, dynamic>> getDataAsync(
    String simplified,
    Map<String, dynamic> originalJson,
  ) async {
    await preloadBundleIndex();
    String pinyin = _extractBestPinyin(simplified, originalJson);
    String meaning = _extractBestMeaning(simplified, originalJson);
    final hskLevel =
        (originalJson['hskLevel'] ?? originalJson['hsk_level'] ?? 0) as int;
    List<Map<String, dynamic>> examples = _normalizeExamples(
      originalJson['examples'],
      defaultSource: 'HSK Dictionary DB',
      defaultQuality: 'seeded',
    );

    final manualEntry = _manualEntry(simplified);
    if (manualEntry != null) {
      if (meaning.isEmpty || meaning == 'Đang tải...') {
        final m = (manualEntry['meaning'] ?? '').toString();
        if (!_isBrokenText(m)) meaning = m;
      }
      if (examples.isEmpty) {
        final candidate = _normalizeExamples(
          manualEntry['examples'],
          defaultSource: 'HSK Curated Manual',
          defaultQuality: 'curated',
        );
        examples = candidate.where((e) {
          final vi = (e['vi'] ?? '').toString();
          final py = (e['py'] ?? '').toString();
          return !_isBrokenText(vi) && !_isBrokenText(py);
        }).toList();
      }
    } else {
      List<Future<void>> tasks = [];

      if (meaning.isEmpty || meaning == 'Đang tải...') {
        tasks.add(() async {
          String apiTranslation = await _translateFromAPI(simplified);
          if (apiTranslation.isNotEmpty && !_isBrokenText(apiTranslation)) {
            meaning = apiTranslation;
          } else {
            final bundle = _bundleEntry(simplified);
            final en = _cleanText((bundle?['meaningEn'] ?? '').toString());
            if (en.isNotEmpty && !_isBrokenText(en)) {
              meaning = en;
            }
          }
        }());
      }

      if (examples.isEmpty) {
        tasks.add(() async {
          examples = await _fetchCuratedExamples(simplified, hskLevel);
        }());
      }

      await Future.wait(tasks);

      if (examples.isEmpty) {
        examples = _buildTemplateExamples(
          simplified,
          pinyin,
          meaning.isNotEmpty ? meaning : simplified,
        );
      }

      if (examples.isEmpty) {
        final fallback = await GrammarAiService.generateExamples(
          simplified,
          pinyin,
          meaning,
        );
        examples = _normalizeExamples(
          fallback,
          defaultSource: 'Backend Examples',
          defaultQuality: 'community',
        );
      }

      if (meaning.isNotEmpty && _isValidMeaning(meaning)) {
        _cacheWordToBackend(
          simplified: simplified,
          pinyin: pinyin,
          meaningVi: meaning,
          examples: examples,
        );
      }
    }

    return {
      "simplified": simplified,
      "pinyin": pinyin,
      "meaning": meaning.isNotEmpty ? meaning : "Dang cap nhat nghia...",
      "examples": examples,
    };
  }

  /// Gửi từ vừa được AI tra lên backend để lưu vào PostgreSQL.
  /// Fire-and-forget: không chờ kết quả, không ảnh hưởng speed của app.
  static void _cacheWordToBackend({
    required String simplified,
    required String pinyin,
    required String meaningVi,
    required List<Map<String, dynamic>> examples,
  }) {
    const String apiBase = AppConfig.apiBaseUrl;
    try {
      http
          .post(
            Uri.parse('$apiBase/dictionary/cache'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'simplified': simplified,
              'pinyin': pinyin,
              'meaningVi': meaningVi,
              'examples': examples,
            }),
          )
          .catchError((_) {}); // Ignore errors - best effort only
    } catch (_) {}
  }

  /// Sync version: uses DB data from originalJson first, then manual map, then loading state
  static Map<String, dynamic> getData(
    String simplified,
    Map<String, dynamic> originalJson,
  ) {
    // ✅ Priority 1: If data came from local DB (has meaning + examples already), use it directly
    final String? prefilledMeaning = originalJson['meaning'] as String?;
    final dynamic prefilledExamples = originalJson['examples'];
    if (prefilledMeaning != null &&
        prefilledMeaning.isNotEmpty &&
        prefilledMeaning != 'Đang tải...') {
      String pinyin = _extractBestPinyin(simplified, originalJson);
      final examples = _normalizeExamples(
        prefilledExamples,
        defaultSource: 'HSK Dictionary DB',
        defaultQuality: 'seeded',
      );
      return {
        "simplified": simplified,
        "pinyin": pinyin,
        "meaning": prefilledMeaning,
        "examples": examples,
      };
    }

    // Priority 2: pinyin from forms field (old format)
    String pinyin = _extractBestPinyin(simplified, originalJson);
    final extractedMeaning = _extractBestMeaning(simplified, originalJson);
    final bundle = _bundleEntry(simplified);
    final bundleMeaning = _cleanText((bundle?['meaningEn'] ?? '').toString());
    final bundlePinyin = _cleanText((bundle?['pinyin'] ?? '').toString());
    if (pinyin.isEmpty && bundlePinyin.isNotEmpty) {
      pinyin = bundlePinyin;
    }

    // Priority 3: Manual map (high-quality pre-coded entries)
    final manualEntry = _manualEntry(simplified);
    if (manualEntry != null) {
      return {
        "simplified": simplified,
        "pinyin": pinyin,
        "meaning": _isBrokenText((manualEntry['meaning'] ?? '').toString())
            ? (extractedMeaning.isNotEmpty
                  ? extractedMeaning
                  : "Dang cap nhat nghia...")
            : manualEntry['meaning'],
        "examples": _normalizeExamples(
          manualEntry['examples'],
          defaultSource: 'HSK Curated Manual',
          defaultQuality: 'curated',
        ),
      };
    }

    // Priority 4: Return loading state â€” async version will fill in via AI
    return {
      "simplified": simplified,
      "pinyin": pinyin,
      "meaning": extractedMeaning.isNotEmpty
          ? extractedMeaning
          : (bundleMeaning.isNotEmpty
                ? bundleMeaning
                : "Dang cap nhat nghia..."),
      "examples": _buildTemplateExamples(
        simplified,
        pinyin,
        extractedMeaning.isNotEmpty
            ? extractedMeaning
            : (bundleMeaning.isNotEmpty ? bundleMeaning : simplified),
      ),
    };
  }
}
