part of '../../main.dart';

class ReadingRepository {
  static Future<List<SentencePractice>> loadSentences() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${DictionaryRepository.apiBaseUrl}/content/pronunciation',
            ),
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final remote = jsonDecode(utf8.decode(response.bodyBytes));
        if (remote is List && remote.isNotEmpty) {
          return _sentencesFromList(remote);
        }
      }
    } catch (_) {}
    try {
      final raw = await rootBundle.loadString('assets/data/reading_hsk.json');
      final decoded = jsonDecode(raw);
      if (decoded is! List) return sentences;
      return _sentencesFromList(decoded);
    } catch (_) {
      return sentences;
    }
  }

  static List<SentencePractice> _sentencesFromList(List<dynamic> values) {
    return values
        .whereType<Map>()
        .map((raw) {
          final map = Map<String, dynamic>.from(raw);
          return SentencePractice(
            (map['level'] ?? 'HSK 1').toString(),
            (map['cn'] ?? '').toString(),
            (map['py'] ?? '').toString(),
            (map['vi'] ?? '').toString(),
            topic: (map['topic'] ?? 'Giao tiếp hằng ngày').toString(),
          );
        })
        .where((item) => item.cn.isNotEmpty)
        .toList();
  }

  static Future<List<NewsArticleData>> loadArticles({
    bool includeLive = false,
  }) async {
    final fallback = await _loadSeedArticles();
    if (!includeLive) return fallback;
    try {
      await DictionaryRepository.ensureLoaded().timeout(
        const Duration(milliseconds: 900),
      );
      final uri = Uri.parse('${DictionaryRepository.apiBaseUrl}/reading/news');
      final response = await http
          .get(uri)
          .timeout(const Duration(milliseconds: 6500));
      if (response.statusCode != 200) return fallback;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) return fallback;
      final live = decoded
          .whereType<Map>()
          .map((raw) => _articleFromMap(Map<String, dynamic>.from(raw)))
          .whereType<NewsArticleData>()
          .toList();
      return live.isEmpty ? fallback : [...live, ...fallback];
    } catch (_) {
      return fallback;
    }
  }

  static Future<List<NewsArticleData>> _loadSeedArticles() async {
    try {
      dynamic decoded;
      try {
        final response = await http
            .get(
              Uri.parse('${DictionaryRepository.apiBaseUrl}/content/articles'),
            )
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final remote = jsonDecode(utf8.decode(response.bodyBytes));
          if (remote is List && remote.isNotEmpty) decoded = remote;
        }
      } catch (_) {}
      decoded ??= jsonDecode(
        await rootBundle.loadString('assets/data/reading_news_seed.json'),
      );
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((raw) => _articleFromMap(Map<String, dynamic>.from(raw)))
          .whereType<NewsArticleData>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static NewsArticleData? _articleFromMap(Map<String, dynamic> map) {
    final title = (map['title'] ?? '').toString().trim();
    final content = (map['content'] ?? map['description'] ?? '')
        .toString()
        .trim();
    if (title.isEmpty || content.isEmpty) return null;
    final rawSentences = map['sentences'];
    final lines = <ArticleSentenceData>[];
    if (rawSentences is List) {
      for (final rawLine in rawSentences) {
        if (rawLine is Map) {
          final line = Map<String, dynamic>.from(rawLine);
          final cn = (line['cn'] ?? '').toString().trim();
          if (cn.isEmpty) continue;
          lines.add(
            ArticleSentenceData(
              cn,
              (line['py'] ?? '').toString().trim(),
              (line['vi'] ?? '').toString().trim(),
            ),
          );
        }
      }
    }
    final source = (map['source'] ?? 'Chinese RSS').toString();
    final link = (map['link'] ?? '').toString();
    final summaryVi = (map['summaryVi'] ?? map['summary_vi'] ?? '').toString();
    return NewsArticleData(
      id: (map['id'] ?? title).toString(),
      level: (map['level'] ?? 'HSK 3').toString(),
      source: source,
      title: title,
      titleVi: (map['titleVi'] ?? map['title_vi'] ?? '').toString(),
      content: content,
      summaryVi: summaryVi.isEmpty ? source : summaryVi,
      link: link,
      sentences: lines.isEmpty ? buildStudyLines(content) : lines,
      live: map['live'] == true || link.startsWith('http'),
      publishedAt: (map['publishedAt'] ?? map['published_at'] ?? '').toString(),
    );
  }

  static List<ArticleSentenceData> buildStudyLines(String text) {
    final normalized = text
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) return const [];
    final matches = RegExp(r'[^。！？!?；;]+[。！？!?；;]?').allMatches(normalized);
    final lines = <ArticleSentenceData>[];
    for (final match in matches) {
      final cn = match.group(0)?.trim() ?? '';
      if (cn.isEmpty || !RegExp(r'[\u4e00-\u9fff]').hasMatch(cn)) continue;
      lines.add(ArticleSentenceData(cn, pinyinFor(cn), meaningHintFor(cn)));
      if (lines.length >= 80) break;
    }
    return lines.isEmpty
        ? [
            ArticleSentenceData(
              normalized,
              pinyinFor(normalized),
              meaningHintFor(normalized),
            ),
          ]
        : lines;
  }

  static String pinyinFor(String text) {
    final parts = <String>[];
    var i = 0;
    while (i < text.length) {
      final char = text.substring(i, i + 1);
      if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(char)) {
        if ('，,。！？!?；;：:'.contains(char) && parts.isNotEmpty) {
          parts[parts.length - 1] = '${parts.last}${_punctToAscii(char)}';
        }
        i++;
        continue;
      }
      final entry = DictionaryRepository.lookupAt(text, i);
      if (entry == null || entry.pinyin.trim().isEmpty) {
        parts.add(char);
        i++;
        continue;
      }
      parts.add(entry.pinyin.trim());
      i += entry.simplified.length;
    }
    return parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String meaningHintFor(String text) {
    final terms = <String>[];
    final seen = <String>{};
    var i = 0;
    while (i < text.length && terms.length < 5) {
      final char = text.substring(i, i + 1);
      if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(char)) {
        i++;
        continue;
      }
      final entry = DictionaryRepository.lookupAt(text, i);
      if (entry == null) {
        i++;
        continue;
      }
      final word = entry.simplified;
      if (word.length > 1 && !seen.contains(word)) {
        seen.add(word);
        terms.add('$word: ${_shortMeaning(entry.meaning)}');
      }
      i += max(1, word.length);
    }
    if (terms.isEmpty) return 'Dịch nhanh đang cập nhật.';
    return 'Dịch nhanh theo từ khóa: ${terms.join('; ')}.';
  }

  static String _shortMeaning(String meaning) {
    final cleaned = meaning
        .replaceFirst('Nghĩa Việt đang cập nhật · ', '')
        .replaceFirst('Nghĩa tiếng Việt đang cập nhật', 'đang cập nhật')
        .trim();
    final first = cleaned.split(RegExp(r'[;,/]')).first.trim();
    return first.isEmpty ? cleaned : first;
  }

  static String _punctToAscii(String char) {
    switch (char) {
      case '，':
        return ',';
      case '。':
        return '.';
      case '！':
        return '!';
      case '？':
        return '?';
      case '；':
        return ';';
      case '：':
        return ':';
      default:
        return char;
    }
  }

  static const sentences = <SentencePractice>[
    SentencePractice('HSK 1', '大家好！', 'Dàjiā hǎo!', 'Chào mọi người!'),
    SentencePractice('HSK 1', '我是学生。', 'Wǒ shì xuésheng.', 'Tôi là học sinh.'),
    SentencePractice(
      'HSK 1',
      '你叫什么名字？',
      'Nǐ jiào shénme míngzi?',
      'Bạn tên là gì?',
    ),
    SentencePractice(
      'HSK 2',
      '我在学习汉语。',
      'Wǒ zài xuéxí Hànyǔ.',
      'Tôi đang học tiếng Trung.',
    ),
    SentencePractice(
      'HSK 2',
      '今天比昨天热。',
      'Jīntiān bǐ zuótiān rè.',
      'Hôm nay nóng hơn hôm qua.',
    ),
    SentencePractice(
      'HSK 2',
      '我坐飞机去北京。',
      'Wǒ zuò fēijī qù Běijīng.',
      'Tôi đi máy bay đến Bắc Kinh.',
    ),
    SentencePractice(
      'HSK 3',
      '我的汉语越来越好。',
      'Wǒ de Hànyǔ yuè lái yuè hǎo.',
      'Tiếng Trung của tôi ngày càng tốt.',
    ),
    SentencePractice(
      'HSK 3',
      '请把门关上。',
      'Qǐng bǎ mén guān shang.',
      'Hãy đóng cửa lại.',
    ),
    SentencePractice(
      'HSK 4',
      '虽然汉语很难，但是我很喜欢。',
      'Suīrán Hànyǔ hěn nán, dànshì wǒ hěn xǐhuan.',
      'Mặc dù tiếng Trung khó, nhưng tôi rất thích.',
    ),
    SentencePractice(
      'HSK 4',
      '他不但会说汉语，而且会写汉字。',
      'Tā búdàn huì shuō Hànyǔ, érqiě huì xiě Hànzì.',
      'Anh ấy không những biết nói tiếng Trung mà còn biết viết chữ Hán.',
    ),
  ];
}
