import 'app_config.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'grammar_ai_service.dart';
import 'pinyin_utils.dart';
import 'text_sanitizer.dart';

class VocabDataHelper {
  // Cache for API translations to avoid repeated calls
  static final Map<String, String> _translationCache = {};
  static final RegExp _mojibakePattern = RegExp(r'[ÃÄÂðŸ]');
  static final Map<String, Map<String, dynamic>> _bundleIndex = {};
  static Future<void>? _bundleLoadFuture;
  static bool _bundleLoaded = false;

  // High-quality manual map for common HSK 1 & 2 words
  static final Map<String, Map<String, dynamic>> _manualMap = {
    // === HSK 1: Ä�áº¡i tá»« ===
    "我": {"meaning": "Tôi", "examples": [
      {"cn": "æˆ‘æ˜¯å­¦ç”Ÿã€‚", "py": "WÇ’ shÃ¬ xuÃ©sheng.", "vi": "TÃ´i lÃ  há»�c sinh."},
      {"cn": "æˆ‘å–œæ¬¢ä¸­å›½ã€‚", "py": "WÇ’ xÇ�huÄ�n ZhÅ�ngguÃ³.", "vi": "TÃ´i thÃ­ch Trung Quá»‘c."}
    ]},
    "ä½ ": {"meaning": "Báº¡n", "examples": [
      {"cn": "ä½ å¥½ï¼�", "py": "NÇ� hÇŽo!", "vi": "Xin chÃ o!"},
      {"cn": "ä½ å�«ä»€ä¹ˆå��å­—ï¼Ÿ", "py": "NÇ� jiÃ o shÃ©nme mÃ­ngzi?", "vi": "Báº¡n tÃªn gÃ¬?"}
    ]},
    "ä»–": {"meaning": "Anh áº¥y", "examples": [
      {"cn": "ä»–æ˜¯è€�å¸ˆã€‚", "py": "TÄ� shÃ¬ lÇŽoshÄ«.", "vi": "Anh áº¥y lÃ  giÃ¡o viÃªn."},
      {"cn": "ä»–å¾ˆé«˜ã€‚", "py": "TÄ� hÄ›n gÄ�o.", "vi": "Anh áº¥y ráº¥t cao."}
    ]},
    "她": {"meaning": "Cô ấy", "examples": [
      {"cn": "å¥¹å¾ˆæ¼‚äº®ã€‚", "py": "TÄ� hÄ›n piÃ oliang.", "vi": "CÃ´ áº¥y ráº¥t Ä‘áº¹p."},
      {"cn": "å¥¹æ˜¯æˆ‘æœ‹å�‹ã€‚", "py": "TÄ� shÃ¬ wÇ’ pÃ©ngyou.", "vi": "CÃ´ áº¥y lÃ  báº¡n tÃ´i."}
    ]},
    "我们": {"meaning": "Chúng tôi", "examples": [
      {"cn": "æˆ‘ä»¬åŽ»å�ƒé¥­å�§ã€‚", "py": "WÇ’men qÃ¹ chÄ«fÃ n ba.", "vi": "ChÃºng ta Ä‘i Äƒn cÆ¡m Ä‘i."},
    ]},
    "è¿™": {"meaning": "Ä�Ã¢y, nÃ y", "examples": [{"cn": "è¿™æ˜¯ä»€ä¹ˆï¼Ÿ", "py": "ZhÃ¨ shÃ¬ shÃ©nme?", "vi": "Ä�Ã¢y lÃ  cÃ¡i gÃ¬?"}]},
    "é‚£": {"meaning": "Kia, Ä‘Ã³", "examples": [{"cn": "é‚£æ˜¯è°�ï¼Ÿ", "py": "NÃ  shÃ¬ shÃ©i?", "vi": "Ä�Ã³ lÃ  ai?"}]},
    "å“ª": {"meaning": "NÃ o, Ä‘Ã¢u", "examples": [{"cn": "ä½ æ˜¯å“ªå›½äººï¼Ÿ", "py": "NÇ� shÃ¬ nÇŽ guÃ³ rÃ©n?", "vi": "Báº¡n lÃ  ngÆ°á»�i nÆ°á»›c nÃ o?"}]},
    "è°�": {"meaning": "Ai", "examples": [{"cn": "ä»–æ˜¯è°�ï¼Ÿ", "py": "TÄ� shÃ¬ shÃ©i?", "vi": "Anh áº¥y lÃ  ai?"}]},
    "ä»€ä¹ˆ": {"meaning": "CÃ¡i gÃ¬", "examples": [{"cn": "è¿™æ˜¯ä»€ä¹ˆï¼Ÿ", "py": "ZhÃ¨ shÃ¬ shÃ©nme?", "vi": "Ä�Ã¢y lÃ  cÃ¡i gÃ¬?"}]},
    "å‡ ": {"meaning": "Máº¥y", "examples": [{"cn": "ä½ å‡ å²�ï¼Ÿ", "py": "NÇ� jÇ� suÃ¬?", "vi": "Báº¡n máº¥y tuá»•i?"}]},
    "æ€Žä¹ˆ": {"meaning": "Tháº¿ nÃ o, sao", "examples": [{"cn": "ä½ æ€Žä¹ˆäº†ï¼Ÿ", "py": "NÇ� zÄ›nme le?", "vi": "Báº¡n lÃ m sao váº­y?"}]},
    "æ€Žä¹ˆæ ·": {"meaning": "NhÆ° tháº¿ nÃ o", "examples": [{"cn": "å¤©æ°”æ€Žä¹ˆæ ·ï¼Ÿ", "py": "TiÄ�nqÃ¬ zÄ›nmeyÃ ng?", "vi": "Thá»�i tiáº¿t tháº¿ nÃ o?"}]},
    // === HSK 1: Số đếm ===
    "一": {"meaning": "Một (1)", "examples": [{"cn": "一个苹果。", "py": "Yí ge píngguǒ.", "vi": "Một quả táo."}]},
    "二": {"meaning": "Hai (2)", "examples": [{"cn": "二月。", "py": "Èryuè.", "vi": "Tháng hai."}]},
    "ä¸‰": {"meaning": "Ba (3)", "examples": [{"cn": "ä¸‰å¤©ã€‚", "py": "SÄ�n tiÄ�n.", "vi": "Ba ngÃ y."}]},
    "四": {"meaning": "Bốn (4)", "examples": [{"cn": "四年。", "py": "Sì nián.", "vi": "Bốn năm."}]},
    "äº”": {"meaning": "NÄƒm (5)", "examples": [{"cn": "äº”ä¸ªäººã€‚", "py": "WÇ” ge rÃ©n.", "vi": "NÄƒm ngÆ°á»�i."}]},
    "六": {"meaning": "Sáu (6)", "examples": [{"cn": "星期六。", "py": "Xīngqīliù.", "vi": "Thứ bảy."}]},
    "ä¸ƒ": {"meaning": "Báº£y (7)", "examples": [{"cn": "ä¸ƒç‚¹ã€‚", "py": "QÄ« diÇŽn.", "vi": "Báº£y giá»�."}]},
    "å…«": {"meaning": "TÃ¡m (8)", "examples": [{"cn": "å…«ä¸ªæœˆã€‚", "py": "BÄ� ge yuÃ¨.", "vi": "TÃ¡m thÃ¡ng."}]},
    "ä¹�": {"meaning": "ChÃ­n (9)", "examples": [{"cn": "ä¹�æœˆã€‚", "py": "JiÇ”yuÃ¨.", "vi": "ThÃ¡ng chÃ­n."}]},
    "å��": {"meaning": "MÆ°á»�i (10)", "examples": [{"cn": "å��å�—é’±ã€‚", "py": "ShÃ­ kuÃ i qiÃ¡n.", "vi": "MÆ°á»�i Ä‘á»“ng."}]},
    "零": {"meaning": "Không (0)", "examples": [{"cn": "零度。", "py": "Líng dù.", "vi": "Không độ."}]},
    // === HSK 1: Gia Ä‘Ã¬nh & Con ngÆ°á»�i ===
    "äºº": {"meaning": "NgÆ°á»�i", "examples": [{"cn": "ä¸­å›½äººã€‚", "py": "ZhÅ�ngguÃ³ rÃ©n.", "vi": "NgÆ°á»�i Trung Quá»‘c."}]},
    "å��å­—": {"meaning": "TÃªn", "examples": [{"cn": "ä½ å�«ä»€ä¹ˆå��å­—ï¼Ÿ", "py": "NÇ� jiÃ o shÃ©nme mÃ­ngzi?", "vi": "Báº¡n tÃªn gÃ¬?"}]},
    "çˆ¸": {"meaning": "Bá»‘ (thÃ¢n máº­t)", "examples": [{"cn": "çˆ¸ï¼Œæˆ‘å›žæ�¥äº†ã€‚", "py": "BÃ , wÇ’ huÃ­lÃ¡i le.", "vi": "Bá»‘ Æ¡i, con vá»� rá»“i."}]},
    "çˆ¸çˆ¸": {"meaning": "Bá»‘, cha", "examples": [{"cn": "çˆ¸çˆ¸åŽ»å·¥ä½œäº†ã€‚", "py": "BÃ ba qÃ¹ gÅ�ngzuÃ² le.", "vi": "Bá»‘ Ä‘i lÃ m rá»“i."}]},
    "å¦ˆ": {"meaning": "Máº¹ (thÃ¢n máº­t)", "examples": [{"cn": "å¦ˆï¼Œå�ƒé¥­äº†ã€‚", "py": "MÄ�, chÄ«fÃ n le.", "vi": "Máº¹, Äƒn cÆ¡m rá»“i."}]},
    "å¦ˆå¦ˆ": {"meaning": "Máº¹", "examples": [{"cn": "å¦ˆå¦ˆå�šé¥­ã€‚", "py": "MÄ�ma zuÃ² fÃ n.", "vi": "Máº¹ náº¥u cÆ¡m."}]},
    "å„¿å­�": {"meaning": "Con trai", "examples": [{"cn": "ä»–æœ‰ä¸€ä¸ªå„¿å­�ã€‚", "py": "TÄ� yÇ’u yÃ­ ge Ã©rzi.", "vi": "Anh áº¥y cÃ³ má»™t con trai."}]},
    "å¥³å„¿": {"meaning": "Con gÃ¡i", "examples": [{"cn": "å¥³å„¿å¾ˆå�¯çˆ±ã€‚", "py": "NÇš'Ã©r hÄ›n kÄ›'Ã i.", "vi": "Con gÃ¡i ráº¥t Ä‘Ã¡ng yÃªu."}]},
    "æœ‹å�‹": {"meaning": "Báº¡n bÃ¨", "examples": [{"cn": "æˆ‘ä»¬æ˜¯å¥½æœ‹å�‹ã€‚", "py": "WÇ’men shÃ¬ hÇŽo pÃ©ngyou.", "vi": "ChÃºng ta lÃ  báº¡n tá»‘t."}]},
    "å…ˆç”Ÿ": {"meaning": "Ã”ng, ngÃ i", "examples": [{"cn": "çŽ‹å…ˆç”Ÿä½ å¥½ã€‚", "py": "WÃ¡ng xiÄ�nsheng nÇ� hÇŽo.", "vi": "ChÃ o Ã´ng VÆ°Æ¡ng."}]},
    "å°�å§�": {"meaning": "CÃ´, tiá»ƒu thÆ°", "examples": [{"cn": "æ�Žå°�å§�è¯·å��ã€‚", "py": "LÇ� xiÇŽojiÄ› qÇ�ng zuÃ².", "vi": "Má»�i cÃ´ LÃ½ ngá»“i."}]},
    "è€�å¸ˆ": {"meaning": "Tháº§y/cÃ´ giÃ¡o", "examples": [{"cn": "è€�å¸ˆå¥½ï¼�", "py": "LÇŽoshÄ« hÇŽo!", "vi": "Em chÃ o tháº§y/cÃ´!"}]},
    "å­¦ç”Ÿ": {"meaning": "Há»�c sinh", "examples": [{"cn": "æˆ‘æ˜¯å­¦ç”Ÿã€‚", "py": "WÇ’ shÃ¬ xuÃ©sheng.", "vi": "TÃ´i lÃ  há»�c sinh."}]},
    "å�Œå­¦": {"meaning": "Báº¡n há»�c", "examples": [{"cn": "ä»–æ˜¯æˆ‘å�Œå­¦ã€‚", "py": "TÄ� shÃ¬ wÇ’ tÃ³ngxuÃ©.", "vi": "Cáº­u áº¥y lÃ  báº¡n há»�c tÃ´i."}]},
    "åŒ»ç”Ÿ": {"meaning": "BÃ¡c sÄ©", "examples": [{"cn": "åŒ»ç”Ÿè¯´å¤šå–�æ°´ã€‚", "py": "YÄ«shÄ“ng shuÅ� duÅ� hÄ“ shuÇ�.", "vi": "BÃ¡c sÄ© báº£o uá»‘ng nhiá»�u nÆ°á»›c."}]},
    // === HSK 1: Ä�á»“ váº­t & Ä�á»‹a Ä‘iá»ƒm ===
    "ä¹¦": {"meaning": "SÃ¡ch", "examples": [{"cn": "çœ‹ä¹¦ã€‚", "py": "KÃ n shÅ«.", "vi": "Ä�á»�c sÃ¡ch."}]},
    "æ¤…å­�": {"meaning": "Gháº¿", "examples": [{"cn": "å��æ¤…å­�ã€‚", "py": "ZuÃ² yÇ�zi.", "vi": "Ngá»“i gháº¿."}]},
    "æ¡Œå­�": {"meaning": "BÃ n", "examples": [{"cn": "ä¹¦åœ¨æ¡Œå­�ä¸Šã€‚", "py": "ShÅ« zÃ i zhuÅ�zi shÃ ng.", "vi": "SÃ¡ch á»Ÿ trÃªn bÃ n."}]},
    "æ�¯å­�": {"meaning": "Cá»‘c", "examples": [{"cn": "ä¸€ä¸ªæ�¯å­�ã€‚", "py": "YÃ­ ge bÄ“izi.", "vi": "Má»™t cÃ¡i cá»‘c."}]},
    "电脑": {"meaning": "Máy tính", "examples": [{"cn": "用电脑。", "py": "Yòng diànnǎo.", "vi": "Dùng máy tính."}]},
    "电视": {"meaning": "Ti vi", "examples": [{"cn": "看电视。", "py": "Kàn diànshì.", "vi": "Xem ti vi."}]},
    "ç”µå½±": {"meaning": "Phim", "examples": [{"cn": "çœ‹ç”µå½±ã€‚", "py": "KÃ n diÃ nyÇ�ng.", "vi": "Xem phim."}]},
    "è¡£æœ�": {"meaning": "Quáº§n Ã¡o", "examples": [{"cn": "ä¹°è¡£æœ�ã€‚", "py": "MÇŽi yÄ«fu.", "vi": "Mua quáº§n Ã¡o."}]},
    "ä¸œè¥¿": {"meaning": "Ä�á»“ váº­t", "examples": [{"cn": "ä¹°ä¸œè¥¿ã€‚", "py": "MÇŽi dÅ�ngxi.", "vi": "Mua Ä‘á»“."}]},
    "é’±": {"meaning": "Tiá»�n", "examples": [{"cn": "å¤šå°‘é’±ï¼Ÿ", "py": "DuÅ�shÇŽo qiÃ¡n?", "vi": "Bao nhiÃªu tiá»�n?"}]},
    "å®¶": {"meaning": "NhÃ ", "examples": [{"cn": "å›žå®¶ã€‚", "py": "HuÃ­ jiÄ�.", "vi": "Vá»� nhÃ ."}]},
    "å­¦æ ¡": {"meaning": "TrÆ°á»�ng há»�c", "examples": [{"cn": "åŽ»å­¦æ ¡ã€‚", "py": "QÃ¹ xuÃ©xiÃ o.", "vi": "Ä�i Ä‘áº¿n trÆ°á»�ng."}]},
    "é¥­åº—": {"meaning": "NhÃ  hÃ ng", "examples": [{"cn": "åŽ»é¥­åº—å�ƒé¥­ã€‚", "py": "QÃ¹ fÃ ndiÃ n chÄ«fÃ n.", "vi": "Ä�i nhÃ  hÃ ng Äƒn cÆ¡m."}]},
    "å•†åº—": {"meaning": "Cá»­a hÃ ng", "examples": [{"cn": "åŽ»å•†åº—ä¹°ä¸œè¥¿ã€‚", "py": "QÃ¹ shÄ�ngdiÃ n mÇŽi dÅ�ngxi.", "vi": "Ä�i cá»­a hÃ ng mua Ä‘á»“."}]},
    "åŒ»é™¢": {"meaning": "Bá»‡nh viá»‡n", "examples": [{"cn": "åŽ»åŒ»é™¢ã€‚", "py": "QÃ¹ yÄ«yuÃ n.", "vi": "Ä�i bá»‡nh viá»‡n."}]},
    "ç�«è½¦ç«™": {"meaning": "Ga tÃ u há»�a", "examples": [{"cn": "åŽ»ç�«è½¦ç«™ã€‚", "py": "QÃ¹ huÇ’chÄ“zhÃ n.", "vi": "Ä�i ga tÃ u."}]},
    "ä¸­å›½": {"meaning": "Trung Quá»‘c", "examples": [{"cn": "æˆ‘çˆ±ä¸­å›½ã€‚", "py": "WÇ’ Ã i ZhÅ�ngguÃ³.", "vi": "TÃ´i yÃªu Trung Quá»‘c."}]},
    "åŒ—äº¬": {"meaning": "Báº¯c Kinh", "examples": [
      {"cn": "åŒ—äº¬æ˜¯ä¸­å›½çš„é¦–éƒ½ã€‚", "py": "BÄ›ijÄ«ng shÃ¬ ZhÅ�ngguÃ³ de shÇ’udÅ«.", "vi": "Báº¯c Kinh lÃ  thá»§ Ä‘Ã´ Trung Quá»‘c."},
      {"cn": "我想去北京。", "py": "Wǒ xiǎng qù Běijīng.", "vi": "Tôi muốn đi Bắc Kinh."}
    ]},
    // === HSK 1: Thá»�i gian ===
    "ä»Šå¤©": {"meaning": "HÃ´m nay", "examples": [{"cn": "ä»Šå¤©æ˜ŸæœŸä¸€ã€‚", "py": "JÄ«ntiÄ�n xÄ«ngqÄ«yÄ«.", "vi": "HÃ´m nay thá»© hai."}]},
    "æ˜Žå¤©": {"meaning": "NgÃ y mai", "examples": [{"cn": "æ˜Žå¤©è§�ï¼�", "py": "MÃ­ngtiÄ�n jiÃ n!", "vi": "NgÃ y mai gáº·p!"}]},
    "æ˜¨å¤©": {"meaning": "HÃ´m qua", "examples": [{"cn": "æ˜¨å¤©ä¸‹é›¨äº†ã€‚", "py": "ZuÃ³tiÄ�n xiÃ yÇ” le.", "vi": "HÃ´m qua trá»�i mÆ°a."}]},
    "ä¸Šå�ˆ": {"meaning": "Buá»•i sÃ¡ng", "examples": [{"cn": "ä¸Šå�ˆå¥½ï¼�", "py": "ShÃ ngwÇ” hÇŽo!", "vi": "ChÃ o buá»•i sÃ¡ng!"}]},
    "ä¸­å�ˆ": {"meaning": "Buá»•i trÆ°a", "examples": [{"cn": "ä¸­å�ˆå�ƒé¥­ã€‚", "py": "ZhÅ�ngwÇ” chÄ«fÃ n.", "vi": "TrÆ°a Äƒn cÆ¡m."}]},
    "ä¸‹å�ˆ": {"meaning": "Buá»•i chiá»�u", "examples": [{"cn": "ä¸‹å�ˆæœ‰è¯¾ã€‚", "py": "XiÃ wÇ” yÇ’u kÃ¨.", "vi": "Chiá»�u cÃ³ tiáº¿t há»�c."}]},
    "年": {"meaning": "Năm", "examples": [{"cn": "明年。", "py": "Míngnián.", "vi": "Năm sau."}]},
    "月": {"meaning": "Tháng", "examples": [{"cn": "五月。", "py": "Wǔyuè.", "vi": "Tháng năm."}]},
    "æ—¥": {"meaning": "NgÃ y", "examples": [{"cn": "ä¸‰æœˆå…«æ—¥ã€‚", "py": "SÄ�nyuÃ¨ bÄ�rÃ¬.", "vi": "NgÃ y 8/3."}]},
    "å�·": {"meaning": "NgÃ y (sá»‘)", "examples": [{"cn": "ä»Šå¤©å‡ å�·ï¼Ÿ", "py": "JÄ«ntiÄ�n jÇ� hÃ o?", "vi": "HÃ´m nay ngÃ y máº¥y?"}]},
    "æ˜ŸæœŸ": {"meaning": "Tuáº§n", "examples": [{"cn": "æ˜ŸæœŸå¤©ã€‚", "py": "XÄ«ngqÄ«tiÄ�n.", "vi": "Chá»§ nháº­t."}]},
    "ç‚¹": {"meaning": "Giá»�", "examples": [{"cn": "å…«ç‚¹ã€‚", "py": "BÄ� diÇŽn.", "vi": "TÃ¡m giá»�."}]},
    "åˆ†é’Ÿ": {"meaning": "PhÃºt", "examples": [{"cn": "äº”åˆ†é’Ÿã€‚", "py": "WÇ” fÄ“nzhÅ�ng.", "vi": "NÄƒm phÃºt."}]},
    "çŽ°åœ¨": {"meaning": "BÃ¢y giá»�", "examples": [{"cn": "çŽ°åœ¨å‡ ç‚¹ï¼Ÿ", "py": "XiÃ nzÃ i jÇ� diÇŽn?", "vi": "BÃ¢y giá»� máº¥y giá»�?"}]},
    "时候": {"meaning": "Lúc, khi", "examples": [{"cn": "什么时候？", "py": "Shénme shíhou?", "vi": "Khi nào?"}]},
    // === HSK 1: Ăn uống ===
    "å�ƒ": {"meaning": "Ä‚n", "examples": [{"cn": "å�ƒé¥­äº†ã€‚", "py": "ChÄ«fÃ n le.", "vi": "Ä‚n cÆ¡m rá»“i."}]},
    "å–�": {"meaning": "Uá»‘ng", "examples": [{"cn": "å–�èŒ¶ã€‚", "py": "HÄ“ chÃ¡.", "vi": "Uá»‘ng trÃ ."}]},
    "é¥­": {"meaning": "CÆ¡m", "examples": [{"cn": "å�šé¥­ã€‚", "py": "ZuÃ² fÃ n.", "vi": "Náº¥u cÆ¡m."}]},
    "ç±³é¥­": {"meaning": "CÆ¡m tráº¯ng", "examples": [{"cn": "å�ƒç±³é¥­ã€‚", "py": "ChÄ« mÇ�fÃ n.", "vi": "Ä‚n cÆ¡m tráº¯ng."}]},
    "è�œ": {"meaning": "Rau, mÃ³n Äƒn", "examples": [{"cn": "å�šè�œã€‚", "py": "ZuÃ² cÃ i.", "vi": "Náº¥u Äƒn."}]},
    "æ°´æžœ": {"meaning": "TrÃ¡i cÃ¢y", "examples": [{"cn": "å�ƒæ°´æžœã€‚", "py": "ChÄ« shuÇ�guÇ’.", "vi": "Ä‚n trÃ¡i cÃ¢y."}]},
    "苹果": {"meaning": "Táo", "examples": [{"cn": "一个苹果。", "py": "Yí ge píngguǒ.", "vi": "Một quả táo."}]},
    "èŒ¶": {"meaning": "TrÃ ", "examples": [{"cn": "è¯·å–�èŒ¶ã€‚", "py": "QÇ�ng hÄ“ chÃ¡.", "vi": "Má»�i uá»‘ng trÃ ."}]},
    "æ°´": {"meaning": "NÆ°á»›c", "examples": [{"cn": "å–�æ°´ã€‚", "py": "HÄ“ shuÇ�.", "vi": "Uá»‘ng nÆ°á»›c."}]},
    // === HSK 1: Ä�á»™ng tá»« ===
    "æ˜¯": {"meaning": "LÃ ", "examples": [{"cn": "æˆ‘æ˜¯ä¸­å›½äººã€‚", "py": "WÇ’ shÃ¬ ZhÅ�ngguÃ³ rÃ©n.", "vi": "TÃ´i lÃ  ngÆ°á»�i Trung Quá»‘c."}]},
    "有": {"meaning": "Có", "examples": [{"cn": "我有一本书。", "py": "Wǒ yǒu yì běn shū.", "vi": "Tôi có một quyển sách."}]},
    "çœ‹": {"meaning": "Xem, nhÃ¬n", "examples": [{"cn": "çœ‹ç”µå½±ã€‚", "py": "KÃ n diÃ nyÇ�ng.", "vi": "Xem phim."}]},
    "å�¬": {"meaning": "Nghe", "examples": [{"cn": "å�¬éŸ³ä¹�ã€‚", "py": "TÄ«ng yÄ«nyuÃ¨.", "vi": "Nghe nháº¡c."}]},
    "è¯´": {"meaning": "NÃ³i", "examples": [{"cn": "è¯´æ±‰è¯­ã€‚", "py": "ShuÅ� HÃ nyÇ”.", "vi": "NÃ³i tiáº¿ng Trung."}]},
    "è¯»": {"meaning": "Ä�á»�c", "examples": [{"cn": "è¯»ä¹¦ã€‚", "py": "DÃº shÅ«.", "vi": "Ä�á»�c sÃ¡ch."}]},
    "写": {"meaning": "Viết", "examples": [{"cn": "写汉字。", "py": "Xiě Hànzì.", "vi": "Viết chữ Hán."}]},
    "æ�¥": {"meaning": "Ä�áº¿n", "examples": [{"cn": "ä½ æ�¥å�§ã€‚", "py": "NÇ� lÃ¡i ba.", "vi": "Báº¡n Ä‘áº¿n Ä‘i."}]},
    "åŽ»": {"meaning": "Ä�i", "examples": [{"cn": "æˆ‘æƒ³åŽ»ä¸­å›½ã€‚", "py": "WÇ’ xiÇŽng qÃ¹ ZhÅ�ngguÃ³.", "vi": "TÃ´i muá»‘n Ä‘i Trung Quá»‘c."}]},
    "å›ž": {"meaning": "Vá»�", "examples": [{"cn": "å›žå®¶ã€‚", "py": "HuÃ­ jiÄ�.", "vi": "Vá»� nhÃ ."}]},
    "æƒ³": {"meaning": "Muá»‘n, nhá»›", "examples": [{"cn": "æˆ‘æƒ³ä½ ã€‚", "py": "WÇ’ xiÇŽng nÇ�.", "vi": "TÃ´i nhá»› báº¡n."}]},
    "å�š": {"meaning": "LÃ m", "examples": [{"cn": "å�šä½œä¸šã€‚", "py": "ZuÃ² zuÃ²yÃ¨.", "vi": "LÃ m bÃ i táº­p."}]},
    "ä¹°": {"meaning": "Mua", "examples": [{"cn": "ä¹°è¡£æœ�ã€‚", "py": "MÇŽi yÄ«fu.", "vi": "Mua quáº§n Ã¡o."}]},
    "å�«": {"meaning": "Gá»�i, tÃªn lÃ ", "examples": [{"cn": "ä½ å�«ä»€ä¹ˆå��å­—ï¼Ÿ", "py": "NÇ� jiÃ o shÃ©nme mÃ­ngzi?", "vi": "Báº¡n tÃªn gÃ¬?"}]},
    "è®¤è¯†": {"meaning": "Quen biáº¿t", "examples": [{"cn": "è®¤è¯†ä½ å¾ˆé«˜å…´ã€‚", "py": "RÃ¨nshi nÇ� hÄ›n gÄ�oxÃ¬ng.", "vi": "Ráº¥t vui Ä‘Æ°á»£c biáº¿t báº¡n."}]},
    "ä½�": {"meaning": "Sá»‘ng, á»Ÿ", "examples": [{"cn": "ä½ ä½�å“ªé‡Œï¼Ÿ", "py": "NÇ� zhÃ¹ nÇŽlÇ�?", "vi": "Báº¡n sá»‘ng á»Ÿ Ä‘Ã¢u?"}]},
    "å­¦ä¹ ": {"meaning": "Há»�c táº­p", "examples": [{"cn": "å¥½å¥½å­¦ä¹ ã€‚", "py": "HÇŽohÇŽo xuÃ©xÃ­.", "vi": "Há»�c táº­p chÄƒm chá»‰."}]},
    "å·¥ä½œ": {"meaning": "LÃ m viá»‡c", "examples": [{"cn": "åœ¨å·¥ä½œã€‚", "py": "ZÃ i gÅ�ngzuÃ².", "vi": "Ä�ang lÃ m viá»‡c."}]},
    "ç�¡è§‰": {"meaning": "Ngá»§", "examples": [{"cn": "æˆ‘æƒ³ç�¡è§‰ã€‚", "py": "WÇ’ xiÇŽng shuÃ¬jiÃ o.", "vi": "TÃ´i muá»‘n ngá»§."}]},
    "æ‰“ç”µè¯�": {"meaning": "Gá»�i Ä‘iá»‡n", "examples": [{"cn": "ç»™å¦ˆå¦ˆæ‰“ç”µè¯�ã€‚", "py": "GÄ›i mÄ�ma dÇŽ diÃ nhuÃ .", "vi": "Gá»�i Ä‘iá»‡n cho máº¹."}]},
    "爱": {"meaning": "Yêu", "examples": [
      {"cn": "æˆ‘çˆ±ä½ ã€‚", "py": "WÇ’ Ã i nÇ�.", "vi": "Anh yÃªu em."},
      {"cn": "å¦ˆå¦ˆçˆ±å�ƒè‹¹æžœã€‚", "py": "MÄ�ma Ã i chÄ« pÃ­ngguÇ’.", "vi": "Máº¹ thÃ­ch Äƒn tÃ¡o."}
    ]},
    "å–œæ¬¢": {"meaning": "ThÃ­ch", "examples": [{"cn": "æˆ‘å–œæ¬¢å–�èŒ¶ã€‚", "py": "WÇ’ xÇ�huÄ�n hÄ“ chÃ¡.", "vi": "TÃ´i thÃ­ch uá»‘ng trÃ ."}]},
    "爱好": {"meaning": "Sở thích", "examples": [
      {"cn": "ä½ æœ‰ä»€ä¹ˆçˆ±å¥½ï¼Ÿ", "py": "NÇ� yÇ’u shÃ©nme Ã ihÃ o?", "vi": "Báº¡n cÃ³ sá»Ÿ thÃ­ch gÃ¬?"},
      {"cn": "我的爱好是画画。", "py": "Wǒ de àihào shì huàhuà.", "vi": "Sở thích của tôi là vẽ."}
    ]},
    // === HSK 1: Tính từ ===
    "å¥½": {"meaning": "Tá»‘t, khá»�e", "examples": [{"cn": "ä½ å¥½å�—ï¼Ÿ", "py": "NÇ� hÇŽo ma?", "vi": "Báº¡n khá»�e khÃ´ng?"}]},
    "大": {"meaning": "To, lớn", "examples": [{"cn": "很大。", "py": "Hěn dà.", "vi": "Rất to."}]},
    "å°�": {"meaning": "Nhá»�", "examples": [{"cn": "å¾ˆå°�ã€‚", "py": "HÄ›n xiÇŽo.", "vi": "Ráº¥t nhá»�."}]},
    "å¤š": {"meaning": "Nhiá»�u", "examples": [{"cn": "äººå¾ˆå¤šã€‚", "py": "RÃ©n hÄ›n duÅ�.", "vi": "NgÆ°á»�i ráº¥t Ä‘Ã´ng."}]},
    "å°‘": {"meaning": "Ã�t", "examples": [{"cn": "å¾ˆå°‘ã€‚", "py": "HÄ›n shÇŽo.", "vi": "Ráº¥t Ã­t."}]},
    "å†·": {"meaning": "Láº¡nh", "examples": [{"cn": "ä»Šå¤©å¾ˆå†·ã€‚", "py": "JÄ«ntiÄ�n hÄ›n lÄ›ng.", "vi": "HÃ´m nay láº¡nh."}]},
    "çƒ­": {"meaning": "NÃ³ng", "examples": [{"cn": "å¤©æ°”å¾ˆçƒ­ã€‚", "py": "TiÄ�nqÃ¬ hÄ›n rÃ¨.", "vi": "Thá»�i tiáº¿t nÃ³ng."}]},
    "é«˜å…´": {"meaning": "Vui váº»", "examples": [{"cn": "æˆ‘å¾ˆé«˜å…´ã€‚", "py": "WÇ’ hÄ›n gÄ�oxÃ¬ng.", "vi": "TÃ´i ráº¥t vui."}]},
    "æ¼‚äº®": {"meaning": "Ä�áº¹p", "examples": [{"cn": "ä½ å¾ˆæ¼‚äº®ã€‚", "py": "NÇ� hÄ›n piÃ oliang.", "vi": "Báº¡n ráº¥t Ä‘áº¹p."}]},
    // === HSK 1: Phó từ & Trợ từ ===
    "ä¸�": {"meaning": "KhÃ´ng", "examples": [{"cn": "ä¸�å¥½ã€‚", "py": "BÃ¹ hÇŽo.", "vi": "KhÃ´ng tá»‘t."}]},
    "没": {"meaning": "Chưa, không", "examples": [{"cn": "没去。", "py": "Méi qù.", "vi": "Chưa đi."}]},
    "很": {"meaning": "Rất", "examples": [{"cn": "很好。", "py": "Hěn hǎo.", "vi": "Rất tốt."}]},
    "å¤ª": {"meaning": "QuÃ¡", "examples": [{"cn": "å¤ªå¥½äº†ï¼�", "py": "TÃ i hÇŽo le!", "vi": "Tá»‘t quÃ¡!"}]},
    "éƒ½": {"meaning": "Ä�á»�u", "examples": [{"cn": "æˆ‘ä»¬éƒ½åŽ»ã€‚", "py": "WÇ’men dÅ�u qÃ¹.", "vi": "ChÃºng tÃ´i Ä‘á»�u Ä‘i."}]},
    "å’Œ": {"meaning": "VÃ ", "examples": [{"cn": "æˆ‘å’Œä½ ã€‚", "py": "WÇ’ hÃ© nÇ�.", "vi": "TÃ´i vÃ  báº¡n."}]},
    "åœ¨": {"meaning": "á»ž, Ä‘ang", "examples": [{"cn": "æˆ‘åœ¨å®¶ã€‚", "py": "WÇ’ zÃ i jiÄ�.", "vi": "TÃ´i á»Ÿ nhÃ ."}]},
    "的": {"meaning": "Của", "examples": [{"cn": "我的书。", "py": "Wǒ de shū.", "vi": "Sách của tôi."}]},
    "äº†": {"meaning": "Rá»“i (trá»£ tá»«)", "examples": [{"cn": "å�ƒäº†ã€‚", "py": "ChÄ« le.", "vi": "Ä‚n rá»“i."}]},
    "å�—": {"meaning": "KhÃ´ng? (tá»« há»�i)", "examples": [{"cn": "å¥½å�—ï¼Ÿ", "py": "HÇŽo ma?", "vi": "Ä�Æ°á»£c khÃ´ng?"}]},
    "å‘¢": {"meaning": "ThÃ¬ sao, nhá»‰", "examples": [{"cn": "ä½ å‘¢ï¼Ÿ", "py": "NÇ� ne?", "vi": "CÃ²n báº¡n thÃ¬ sao?"}]},
    // === HSK 1: Giao tiáº¿p ===
    "ä½ å¥½": {"meaning": "Xin chÃ o", "examples": [{"cn": "ä½ å¥½ï¼�", "py": "NÇ� hÇŽo!", "vi": "Xin chÃ o!"}]},
    "è°¢è°¢": {"meaning": "Cáº£m Æ¡n", "examples": [{"cn": "è°¢è°¢ä½ ã€‚", "py": "XiÃ¨xie nÇ�.", "vi": "Cáº£m Æ¡n báº¡n."}]},
    "ä¸�å®¢æ°”": {"meaning": "KhÃ´ng cÃ³ chi", "examples": [{"cn": "ä¸�å®¢æ°”ã€‚", "py": "BÃº kÃ¨qÃ¬.", "vi": "KhÃ´ng cÃ³ chi."}]},
    "å¯¹ä¸�èµ·": {"meaning": "Xin lá»—i", "examples": [{"cn": "å¯¹ä¸�èµ·ã€‚", "py": "DuÃ¬bÃ¹qÇ�.", "vi": "Xin lá»—i."}]},
    "æ²¡å…³ç³»": {"meaning": "KhÃ´ng sao", "examples": [{"cn": "æ²¡å…³ç³»ã€‚", "py": "MÃ©iguÄ�nxi.", "vi": "KhÃ´ng sao."}]},
    "å†�è§�": {"meaning": "Táº¡m biá»‡t", "examples": [{"cn": "å†�è§�ï¼�", "py": "ZÃ ijiÃ n!", "vi": "Táº¡m biá»‡t!"}]},
    "è¯·": {"meaning": "Má»�i, xin", "examples": [{"cn": "è¯·å��ã€‚", "py": "QÇ�ng zuÃ².", "vi": "Má»�i ngá»“i."}]},
    "å–‚": {"meaning": "A lÃ´", "examples": [{"cn": "å–‚ï¼Œä½ å¥½ã€‚", "py": "WÃ©i, nÇ� hÇŽo.", "vi": "A lÃ´, xin chÃ o."}]},
    // === HSK 1: Giao thông ===
    "å��": {"meaning": "Ngá»“i, Ä‘i (xe)", "examples": [{"cn": "å��é£žæœºã€‚", "py": "ZuÃ² fÄ“ijÄ«.", "vi": "Ä�i mÃ¡y bay."}]},
    "é£žæœº": {"meaning": "MÃ¡y bay", "examples": [{"cn": "å��é£žæœºã€‚", "py": "ZuÃ² fÄ“ijÄ«.", "vi": "Ä�i mÃ¡y bay."}]},
    "å‡ºç§Ÿè½¦": {"meaning": "Xe taxi", "examples": [{"cn": "å�«å‡ºç§Ÿè½¦ã€‚", "py": "JiÃ o chÅ«zÅ«chÄ“.", "vi": "Gá»�i taxi."}]},
    "å¼€è½¦": {"meaning": "LÃ¡i xe", "examples": [{"cn": "ä½ ä¼šå¼€è½¦å�—ï¼Ÿ", "py": "NÇ� huÃ¬ kÄ�ichÄ“ ma?", "vi": "Báº¡n biáº¿t lÃ¡i xe khÃ´ng?"}]},
    "è·¯": {"meaning": "Ä�Æ°á»�ng", "examples": [{"cn": "åœ¨è·¯ä¸Šã€‚", "py": "ZÃ i lÃ¹ shang.", "vi": "TrÃªn Ä‘Æ°á»�ng."}]},
    // === Các từ phổ biến khác ===
    "游泳": {"meaning": "Bơi lội", "examples": [
      {"cn": "我会游泳。", "py": "Wǒ huì yóuyǒng.", "vi": "Tôi biết bơi."},
      {"cn": "åŽ»æ¸¸æ³³æ± æ¸¸æ³³ã€‚", "py": "QÃ¹ yÃ³uyÇ’ngchÃ­ yÃ³uyÇ’ng.", "vi": "Ä�i bÆ¡i á»Ÿ há»“ bÆ¡i."}
    ]},
    "å­¦ä¹ ": {"meaning": "Há»�c táº­p", "examples": [
      {"cn": "å­¦ä¹ æ±‰è¯­ã€‚", "py": "XuÃ©xÃ­ HÃ nyÇ”.", "vi": "Há»�c tiếng Trung."}
    ]},
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
        {'cn': '我喜欢汉语。', 'py': 'Wǒ xǐhuan Hànyǔ.', 'vi': 'Tôi thích tiếng Trung.'},
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
        {'cn': '他在看书呢。', 'py': 'Tā zài kàn shū ne.', 'vi': 'Anh ấy đang đọc sách đấy.'},
      ],
    },
    '热烈': {
      'meaning': 'nhiệt liệt',
      'examples': [
        {'cn': '大家热烈欢迎你。', 'py': 'Dàjiā rèliè huānyíng nǐ.', 'vi': 'Mọi người nhiệt liệt chào mừng bạn.'},
        {'cn': '现场气氛很热烈。', 'py': 'Xiànchǎng qìfēn hěn rèliè.', 'vi': 'Không khí tại chỗ rất sôi nổi.'},
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
        if (simplified.isEmpty || _bundleIndex.containsKey(simplified)) continue;

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
  static Future<String> _translateFromAPI(String text, {String langpair = 'zh-CN|vi'}) async {
    // Check cache first
    String cacheKey = '${langpair}_$text';
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    try {
      final url = Uri.parse(
        '${AppConfig.apiBaseUrl}/dictionary/translate?q=${Uri.encodeComponent(text)}'
      );
      final response = await http.get(url).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String translated = data['text'] ?? '';
        if (translated.isNotEmpty && translated.toLowerCase() != text.toLowerCase()) {
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
            'source': _cleanText((map['source'] ?? defaultSource ?? 'HSK Seed Corpus').toString()),
            'quality': _cleanText((map['quality'] ?? defaultQuality ?? 'curated').toString()),
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  static bool _isBrokenText(String text) {
    if (text.isEmpty) return false;
    return _mojibakePattern.hasMatch(text) || TextSanitizer.isLikelyMojibake(text);
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

  static String _extractBestPinyin(String simplified, Map<String, dynamic> originalJson) {
    String direct = (originalJson['pinyin'] ?? '').toString().trim();
    if (direct.isNotEmpty && !_isBrokenText(direct)) return direct;

    if (originalJson['forms'] is List && (originalJson['forms'] as List).isNotEmpty) {
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

  static String _extractBestMeaning(String simplified, Map<String, dynamic> originalJson) {
    final direct = _cleanText((originalJson['meaning'] ?? '').toString());
    if (direct.isNotEmpty && direct != 'Đang tải...' && !_isBrokenText(direct)) {
      return direct;
    }

    if (originalJson['forms'] is List && (originalJson['forms'] as List).isNotEmpty) {
      final form = (originalJson['forms'] as List).first;
      if (form is Map && form['meanings'] is List && (form['meanings'] as List).isNotEmpty) {
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
      {'cn': '我今天学习「$simplified」。', 'py': 'Wǒ jīntiān xuéxí "$simplified".', 'vi': 'Hôm nay tôi học từ "$meaning".'},
      {'cn': '这个「$simplified」很常用。', 'py': 'Zhège "$simplified" hěn chángyòng.', 'vi': 'Từ "$meaning" này dùng rất thường xuyên.'},
      {'cn': '请用「$simplified」造句。', 'py': 'Qǐng yòng "$simplified" zàojù.', 'vi': 'Hãy đặt câu với từ "$meaning".'},
      {'cn': '在HSK里，「$simplified」很重要。', 'py': 'Zài HSK lǐ, "$simplified" hěn zhòngyào.', 'vi': 'Trong HSK, từ "$meaning" rất quan trọng.'},
      {'cn': '我想多练习「$simplified」。', 'py': 'Wǒ xiǎng duō liànxí "$simplified".', 'vi': 'Tôi muốn luyện thêm từ "$meaning".'},
      {'cn': '老师解释了「$simplified」的用法。', 'py': 'Lǎoshī jiěshì le "$simplified" de yòngfǎ.', 'vi': 'Giáo viên đã giải thích cách dùng của "$meaning".'},
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
  static Future<Map<String, dynamic>> getDataAsync(String simplified, Map<String, dynamic> originalJson) async {
    await preloadBundleIndex();
    String pinyin = _extractBestPinyin(simplified, originalJson);
    String meaning = _extractBestMeaning(simplified, originalJson);
    final hskLevel = (originalJson['hskLevel'] ?? originalJson['hsk_level'] ?? 0) as int;
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
        final fallback = await GrammarAiService.generateExamples(simplified, pinyin, meaning);
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
      "examples": examples
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
      http.post(
        Uri.parse('$apiBase/dictionary/cache'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'simplified': simplified,
          'pinyin': pinyin,
          'meaningVi': meaningVi,
          'examples': examples,
        }),
      ).catchError((_) {}); // Ignore errors - best effort only
    } catch (_) {}
  }


  /// Sync version: uses DB data from originalJson first, then manual map, then loading state
  static Map<String, dynamic> getData(String simplified, Map<String, dynamic> originalJson) {
    // ✅ Priority 1: If data came from local DB (has meaning + examples already), use it directly
    final String? prefilledMeaning = originalJson['meaning'] as String?;
    final dynamic prefilledExamples = originalJson['examples'];
    if (prefilledMeaning != null && prefilledMeaning.isNotEmpty && prefilledMeaning != 'Đang tải...') {
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
            ? (extractedMeaning.isNotEmpty ? extractedMeaning : "Dang cap nhat nghia...")
            : manualEntry['meaning'],
        "examples": _normalizeExamples(
          manualEntry['examples'],
          defaultSource: 'HSK Curated Manual',
          defaultQuality: 'curated',
        ),
      };
    }

    // Priority 4: Return loading state — async version will fill in via AI
    return {
      "simplified": simplified,
      "pinyin": pinyin,
      "meaning": extractedMeaning.isNotEmpty
          ? extractedMeaning
          : (bundleMeaning.isNotEmpty ? bundleMeaning : "Dang cap nhat nghia..."),
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










