part of '../../main.dart';

class GrammarRepository {
  static Future<List<GrammarLessonData>>? _loadFuture;

  static Future<List<GrammarLessonData>> loadLessons() {
    return _loadFuture ??= _loadLessons();
  }

  static Future<List<GrammarLessonData>> _loadLessons() async {
    try {
      dynamic decoded;
      try {
        final response = await http
            .get(
              Uri.parse('${DictionaryRepository.apiBaseUrl}/content/grammar'),
            )
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final remote = jsonDecode(utf8.decode(response.bodyBytes));
          if (remote is List && remote.isNotEmpty) decoded = remote;
        }
      } catch (_) {}
      decoded ??= jsonDecode(
        await rootBundle.loadString('assets/data/grammar_hsk14.json'),
      );
      if (decoded is! List) return lessons;
      return decoded
          .whereType<Map>()
          .map((raw) {
            final map = Map<String, dynamic>.from(raw);
            final examples = <ExampleSentenceData>[];
            final rawExamples = map['examples'];
            if (rawExamples is List) {
              for (final rawExample in rawExamples) {
                if (rawExample is Map && examples.length < 3) {
                  final ex = Map<String, dynamic>.from(rawExample);
                  final cn = (ex['cn'] ?? '').toString().trim();
                  final py = (ex['py'] ?? '').toString().trim();
                  final vi = (ex['vi'] ?? '').toString().trim();
                  if (cn.isNotEmpty && vi.isNotEmpty) {
                    examples.add(ExampleSentenceData(cn, py, vi));
                  }
                }
              }
            }
            return GrammarLessonData(
              level: (map['level'] ?? 'HSK 1').toString(),
              title: (map['title'] ?? '').toString(),
              pattern: (map['pattern'] ?? map['title'] ?? '').toString(),
              explanation: (map['explanation'] ?? '').toString(),
              examples: examples,
              note: (map['note'] ?? '').toString(),
            );
          })
          .where((lesson) => lesson.title.isNotEmpty)
          .toList();
    } catch (_) {
      return lessons;
    }
  }

  static const lessons = <GrammarLessonData>[
    GrammarLessonData(
      level: 'HSK 1',
      title: 'Câu phán đoán với 是 (shì)',
      pattern: 'Chủ ngữ + 是 + Danh từ',
      explanation:
          'Dùng để xác định danh tính, nghề nghiệp, quốc tịch hoặc bản chất của sự vật.',
      examples: [
        ExampleSentenceData('我是学生。', 'Wǒ shì xuésheng.', 'Tôi là học sinh.'),
        ExampleSentenceData(
          '他是中国人。',
          'Tā shì Zhōngguó rén.',
          'Anh ấy là người Trung Quốc.',
        ),
      ],
      note: 'Phủ định dùng 不 是: 我不是老师。',
    ),
    GrammarLessonData(
      level: 'HSK 1',
      title: 'Câu hỏi với 吗 (ma)',
      pattern: 'Câu trần thuật + 吗？',
      explanation: 'Thêm 吗 ở cuối câu để tạo câu hỏi có/không.',
      examples: [
        ExampleSentenceData(
          '你是学生吗？',
          'Nǐ shì xuésheng ma?',
          'Bạn là học sinh phải không?',
        ),
        ExampleSentenceData(
          '你喜欢茶吗？',
          'Nǐ xǐhuan chá ma?',
          'Bạn thích trà không?',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 1',
      title: 'Phó từ phủ định 不 (bù)',
      pattern: '不 + Động từ / Tính từ',
      explanation: 'Dùng để phủ định hành động, thói quen hoặc tính chất.',
      examples: [
        ExampleSentenceData('我不去学校。', 'Wǒ bú qù xuéxiào.', 'Tôi không đi học.'),
        ExampleSentenceData('今天不冷。', 'Jīntiān bù lěng.', 'Hôm nay không lạnh.'),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 2',
      title: 'Trợ từ 了 (le)',
      pattern: 'Động từ + 了',
      explanation:
          'Biểu thị hành động đã hoàn thành hoặc tình huống đã thay đổi.',
      examples: [
        ExampleSentenceData('我吃了饭。', 'Wǒ chī le fàn.', 'Tôi ăn cơm rồi.'),
        ExampleSentenceData(
          '他去了北京。',
          'Tā qù le Běijīng.',
          'Anh ấy đã đi Bắc Kinh.',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 2',
      title: 'Câu so sánh với 比 (bǐ)',
      pattern: 'A + 比 + B + Tính từ',
      explanation: 'Dùng để so sánh hơn giữa hai đối tượng.',
      examples: [
        ExampleSentenceData('他比我高。', 'Tā bǐ wǒ gāo.', 'Anh ấy cao hơn tôi.'),
        ExampleSentenceData(
          '今天比昨天热。',
          'Jīntiān bǐ zuótiān rè.',
          'Hôm nay nóng hơn hôm qua.',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 2',
      title: 'Đang làm gì với 在 (zài)',
      pattern: 'Chủ ngữ + 在 + Động từ',
      explanation: 'Diễn tả hành động đang xảy ra tại thời điểm nói.',
      examples: [
        ExampleSentenceData(
          '我在学习汉语。',
          'Wǒ zài xuéxí Hànyǔ.',
          'Tôi đang học tiếng Trung.',
        ),
        ExampleSentenceData('妈妈在做饭。', 'Māma zài zuò fàn.', 'Mẹ đang nấu cơm.'),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 3',
      title: 'Câu 把 (bǎ)',
      pattern: 'Chủ ngữ + 把 + Tân ngữ + Động từ + Kết quả',
      explanation: 'Nhấn mạnh cách xử lý hoặc kết quả tác động lên tân ngữ.',
      examples: [
        ExampleSentenceData(
          '我把书放在桌子上。',
          'Wǒ bǎ shū fàng zài zhuōzi shang.',
          'Tôi đặt sách lên bàn.',
        ),
        ExampleSentenceData(
          '请把门关上。',
          'Qǐng bǎ mén guān shang.',
          'Hãy đóng cửa lại.',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 3',
      title: 'Càng ngày càng 越来越',
      pattern: '越来越 + Tính từ',
      explanation: 'Diễn tả mức độ tăng dần theo thời gian.',
      examples: [
        ExampleSentenceData(
          '天气越来越冷。',
          'Tiānqì yuè lái yuè lěng.',
          'Thời tiết càng ngày càng lạnh.',
        ),
        ExampleSentenceData(
          '我的汉语越来越好。',
          'Wǒ de Hànyǔ yuè lái yuè hǎo.',
          'Tiếng Trung của tôi ngày càng tốt.',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 4',
      title: 'Mặc dù... nhưng... 虽然...但是...',
      pattern: '虽然 + Mệnh đề 1，但是 + Mệnh đề 2',
      explanation: 'Nối hai vế có quan hệ tương phản hoặc nhượng bộ.',
      examples: [
        ExampleSentenceData(
          '虽然汉语很难，但是我很喜欢。',
          'Suīrán Hànyǔ hěn nán, dànshì wǒ hěn xǐhuan.',
          'Mặc dù tiếng Trung khó, nhưng tôi rất thích.',
        ),
        ExampleSentenceData(
          '虽然下雨，但是他还是来了。',
          'Suīrán xià yǔ, dànshì tā háishi lái le.',
          'Dù trời mưa, anh ấy vẫn đến.',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 4',
      title: 'Không những... mà còn... 不但...而且...',
      pattern: '不但 + Mệnh đề 1，而且 + Mệnh đề 2',
      explanation: 'Dùng để bổ sung ý ở mức độ mạnh hơn.',
      examples: [
        ExampleSentenceData(
          '他不但会说汉语，而且会写汉字。',
          'Tā búdàn huì shuō Hànyǔ, érqiě huì xiě Hànzì.',
          'Anh ấy không những biết nói tiếng Trung mà còn biết viết chữ Hán.',
        ),
        ExampleSentenceData(
          '这里不但热闹，而且很方便。',
          'Zhèlǐ búdàn rènao, érqiě hěn fāngbiàn.',
          'Ở đây không những náo nhiệt mà còn rất tiện.',
        ),
      ],
    ),
  ];
}
