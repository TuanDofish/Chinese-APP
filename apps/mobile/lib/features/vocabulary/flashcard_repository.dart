part of '../../main.dart';

class FlashcardRepository {
  static List<FlashcardTopic>? _cache;

  // Demo topics must remain useful when the API is unavailable. The compact
  // offline dictionary intentionally contains some English-only entries, so
  // these learner-facing labels keep the flashcard meanings in Vietnamese.
  static const _demoTopicText = <String, (String, String)>{
    '医生': ('yīshēng', 'bác sĩ'),
    '老师': ('lǎoshī', 'giáo viên'),
    '学生': ('xuéshēng', 'học sinh'),
    '工作': ('gōngzuò', 'công việc; làm việc'),
    '公司': ('gōngsī', 'công ty'),
    '人': ('rén', 'người'),
    '朋友': ('péngyou', 'bạn bè'),
    '名字': ('míngzi', 'tên'),
    '医院': ('yīyuàn', 'bệnh viện'),
    '商店': ('shāngdiàn', 'cửa hàng'),
    '饭馆': ('fànguǎn', 'nhà hàng'),
    '公园': ('gōngyuán', 'công viên'),
    '银行': ('yínháng', 'ngân hàng'),
    '机场': ('jīchǎng', 'sân bay'),
    '学校': ('xuéxiào', 'trường học'),
    '家': ('jiā', 'nhà; gia đình'),
    '喜欢': ('xǐhuan', 'thích'),
    '音乐': ('yīnyuè', 'âm nhạc'),
    '电影': ('diànyǐng', 'phim'),
    '跑步': ('pǎobù', 'chạy bộ'),
    '游泳': ('yóuyǒng', 'bơi'),
    '唱歌': ('chànggē', 'hát'),
    '跳舞': ('tiàowǔ', 'nhảy múa'),
    '运动': ('yùndòng', 'vận động; thể thao'),
    '问题': ('wèntí', 'câu hỏi; vấn đề'),
    '作业': ('zuòyè', 'bài tập về nhà'),
    '考试': ('kǎoshì', 'kỳ thi; thi'),
    '学习': ('xuéxí', 'học tập'),
    '汉语': ('Hànyǔ', 'tiếng Trung'),
    '书': ('shū', 'sách'),
    '字': ('zì', 'chữ Hán; ký tự'),
    '计划': ('jìhuà', 'kế hoạch'),
    '希望': ('xīwàng', 'hy vọng'),
    '决定': ('juédìng', 'quyết định; quyết định làm gì'),
    '准备': ('zhǔnbèi', 'chuẩn bị'),
    '参加': ('cānjiā', 'tham gia'),
    '开始': ('kāishǐ', 'bắt đầu'),
    '结束': ('jiéshù', 'kết thúc'),
    '明天': ('míngtiān', 'ngày mai'),
    '帮助': ('bāngzhù', 'giúp đỡ'),
    '一起': ('yìqǐ', 'cùng nhau'),
    '认识': ('rènshi', 'biết; làm quen'),
    '联系': ('liánxì', 'liên lạc'),
    '关系': ('guānxì', 'mối quan hệ'),
    '请': ('qǐng', 'mời; xin vui lòng'),
  };

  static List<FlashcardTopic> get fallbackTopics => [
    _topic(
      'hsk1_greeting',
      'HSK 1',
      'Chào hỏi cơ bản',
      Icons.waving_hand_outlined,
      ['你好', '谢谢', '汉语', '朋友'],
      'assets/images/flashcards/family/427034659a.jpg',
    ),
  ];

  static Future<List<FlashcardTopic>> loadTopics() async {
    if (_cache != null) return _cache!;
    await DictionaryRepository.ensureLoaded();
    final plannedTopics = _plans.map((plan) {
      return _topic(
        plan.id,
        plan.level,
        plan.name,
        plan.icon,
        plan.words,
        plan.imagePath,
      );
    }).toList();
    final assetTopics = await _loadAssetTopics();
    // Backend/asset content comes first so published content wins over plans.
    // A title-level merge prevents cards such as "Gia đình" from appearing
    // twice when their ids differ between the catalog and local fallback.
    _cache = _deduplicateTopics([...assetTopics, ...plannedTopics]);
    return _cache!;
  }

  static Future<List<FlashcardTopic>> _loadAssetTopics() async {
    try {
      dynamic decoded;
      try {
        final response = await http
            .get(
              Uri.parse(
                '${DictionaryRepository.apiBaseUrl}/content/flashcards',
              ),
            )
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final remote = jsonDecode(response.body);
          if (remote is Map &&
              remote['topics'] is List &&
              (remote['topics'] as List).isNotEmpty) {
            decoded = remote;
          }
        }
      } catch (_) {}
      decoded ??= jsonDecode(
        await rootBundle.loadString('assets/images/flashcards/index.json'),
      );
      if (decoded is! Map || decoded['topics'] is! List) return const [];
      return (decoded['topics'] as List)
          .whereType<Map>()
          .map((raw) => _topicFromAsset(Map<String, dynamic>.from(raw)))
          .whereType<FlashcardTopic>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static List<FlashcardTopic> _deduplicateTopics(
    List<FlashcardTopic> topics,
  ) {
    final unique = <String, FlashcardTopic>{};
    for (final topic in topics) {
      final key = _topicKey(topic);
      final existing = unique[key];
      if (existing == null) {
        unique[key] = topic;
        continue;
      }
      final knownWords = existing.words.map((word) => word.simplified).toSet();
      final mergedWords = [
        ...existing.words,
        ...topic.words.where((word) => knownWords.add(word.simplified)),
      ];
      unique[key] = FlashcardTopic(
        id: existing.id,
        level: existing.level,
        name: existing.name,
        icon: existing.icon,
        imagePath: existing.imagePath ?? topic.imagePath,
        words: mergedWords,
      );
    }
    return unique.values.toList();
  }

  static String _topicKey(FlashcardTopic topic) {
    final normalized = topic.name.toLowerCase().replaceAll(
      RegExp(r'[^a-z0-9À-ỹ]+'),
      ' ',
    );
    final family = normalized.contains('gia đình') ||
        normalized.contains('family');
    return '${topic.level}|${family ? 'family' : normalized.trim()}';
  }

  static FlashcardTopic? _topicFromAsset(Map<String, dynamic> topic) {
    final id = (topic['id'] ?? '').toString().trim();
    final wordsRaw = topic['words'];
    if (id.isEmpty || wordsRaw is! List) return null;
    final level = (topic['level'] ?? _levelForAssetTopic(id)).toString();
    final usedSources = <String, String>{};
    final entries = wordsRaw
        .whereType<Map>()
        .map((raw) {
          final word = (raw['word'] ?? '').toString().trim();
          if (word.isEmpty) return null;
          final imagePath = _resolveFlashcardImagePath(id, raw);
          final source = raw['source'];
          final sourceUrl = source is Map
              ? (source['url'] ?? '').toString().trim()
              : '';
          final sourceAlreadyUsedBy = usedSources[sourceUrl];
          final repeatedSource =
              sourceUrl.isNotEmpty &&
              sourceAlreadyUsedBy != null &&
              sourceAlreadyUsedBy != word;
          if (sourceUrl.isNotEmpty && sourceAlreadyUsedBy == null) {
            usedSources[sourceUrl] = word;
          }
          final examples = <ExampleSentenceData>[];
          final rawExamples = raw['examples'];
          if (rawExamples is List) {
            for (final example in rawExamples.whereType<Map>()) {
              final cn = (example['cn'] ?? '').toString().trim();
              final py = (example['py'] ?? '').toString().trim();
              final vi = (example['vi'] ?? '').toString().trim();
              if (cn.isNotEmpty && vi.isNotEmpty) {
                examples.add(ExampleSentenceData(cn, py, vi));
              }
            }
          }
          final fallback = DictionaryRepository.forFlashcard(
            word,
            level: level,
            imagePath: repeatedSource ? null : imagePath,
            useIndexedImage: !repeatedSource && imagePath == null,
          );
          final pinyin = (raw['pinyin'] ?? '').toString().trim();
          final meaning = (raw['meaning'] ?? '').toString().trim();
          return fallback.copyWith(
            pinyin: pinyin.isEmpty ? fallback.pinyin : pinyin,
            meaning: meaning.isEmpty ? fallback.meaning : meaning,
            level: level,
            examples: examples.isEmpty ? fallback.examples : examples,
          );
        })
        .whereType<VocabEntry>()
        .toList();
    if (entries.isEmpty) return null;
    final topicImagePath = (topic['imagePath'] ?? topic['imageUrl'] ?? '')
        .toString()
        .trim();
    final firstImagePath = wordsRaw
        .whereType<Map>()
        .map((raw) => _resolveFlashcardImagePath(id, raw))
        .whereType<String>()
        .firstWhere((image) => image.isNotEmpty, orElse: () => '');
    final imagePath = topicImagePath.isNotEmpty
        ? topicImagePath
        : (firstImagePath.isEmpty ? null : firstImagePath);
    return FlashcardTopic(
      id: id,
      level: level,
      name: (topic['name'] ?? id).toString(),
      icon: _iconForAssetTopic(id),
      imagePath: imagePath,
      words: entries,
    );
  }

  static String _levelForAssetTopic(String id) {
    return switch (id) {
      'animals' ||
      'body' ||
      'colors' ||
      'family' ||
      'food' ||
      'greeting' ||
      'home' ||
      'weather' => 'HSK 1',
      'clothes' ||
      'daily_life' ||
      'health' ||
      'nature' ||
      'places' ||
      'school' ||
      'shopping' ||
      'transport' => 'HSK 2',
      'city_life' || 'entertainment' || 'sports' => 'HSK 3',
      'media_society' => 'HSK 4',
      _ => 'HSK 2',
    };
  }

  static IconData _iconForAssetTopic(String id) {
    return switch (id) {
      'animals' => Icons.pets_outlined,
      'body' => Icons.accessibility_new_outlined,
      'city_life' => Icons.location_city_outlined,
      'clothes' => Icons.checkroom_outlined,
      'colors' => Icons.palette_outlined,
      'daily_life' => Icons.today_outlined,
      'entertainment' => Icons.movie_creation_outlined,
      'food' => Icons.local_dining_outlined,
      'health' => Icons.health_and_safety_outlined,
      'home' => Icons.chair_outlined,
      'nature' => Icons.terrain_outlined,
      'places' => Icons.place_outlined,
      'school' => Icons.school_outlined,
      'shopping' => Icons.shopping_bag_outlined,
      'sports' => Icons.sports_soccer_outlined,
      'transport' => Icons.directions_bus_outlined,
      'weather' => Icons.wb_sunny_outlined,
      _ => Icons.style_outlined,
    };
  }

  static FlashcardTopic _topic(
    String id,
    String level,
    String name,
    IconData icon,
    List<String> words,
    String imagePath,
  ) {
    final entries = words
        .map(
          (word) {
            final entry = DictionaryRepository.forFlashcard(
              word,
              level: level,
              imagePath: imagePath,
            );
            final cleanText = _demoTopicText[word];
            return cleanText == null
                ? entry
                : entry.copyWith(
                    pinyin: cleanText.$1,
                    meaning: cleanText.$2,
                  );
          },
        )
        .toList();
    final resolvedTopicImagePath = entries
        .map((entry) => entry.imagePath)
        .whereType<String>()
        .firstWhere((path) => path.isNotEmpty, orElse: () => imagePath);
    return FlashcardTopic(
      id: id,
      level: level,
      name: name,
      icon: icon,
      imagePath: resolvedTopicImagePath,
      words: entries,
    );
  }

  static final _plans = <_FlashcardPlan>[
    _FlashcardPlan(
      'hsk1_greeting',
      'HSK 1',
      'Chào hỏi cơ bản',
      Icons.waving_hand_outlined,
      'assets/images/flashcards/family/427034659a.jpg',
      ['你好', '谢谢', '再见', '对不起', '没关系', '请', '你', '我', '他', '她'],
    ),
    _FlashcardPlan(
      'hsk1_family',
      'HSK 1',
      'Gia đình',
      Icons.family_restroom_outlined,
      'assets/images/flashcards/family/e6c7ee6003.jpg',
      ['爸爸', '妈妈', '哥哥', '姐姐', '弟弟', '妹妹', '家', '朋友', '儿子', '女儿'],
    ),
    _FlashcardPlan(
      'hsk1_food',
      'HSK 1',
      'Đồ ăn thường ngày',
      Icons.local_dining_outlined,
      'assets/images/flashcards/food/edfec00f07.jpg',
      ['米饭', '面条', '包子', '苹果', '水果', '茶', '水', '吃', '喝', '好吃'],
    ),
    _FlashcardPlan(
      'hsk1_school',
      'HSK 1',
      'Trường học',
      Icons.school_outlined,
      'assets/images/flashcards/family/033e1fb01c.jpg',
      ['学习', '学生', '老师', '学校', '书', '汉语', '写', '读', '字', '作业'],
    ),
    _FlashcardPlan(
      'hsk1_time',
      'HSK 1',
      'Thời gian và số đếm',
      Icons.schedule_outlined,
      'assets/images/flashcards/colors/9d2d1f62ae.jpg',
      ['今天', '明天', '昨天', '年', '月', '日', '一', '二', '三', '十'],
    ),
    _FlashcardPlan(
      'hsk2_transport',
      'HSK 2',
      'Giao thông',
      Icons.directions_bus_outlined,
      'assets/images/flashcards/transport/fed19a817b.jpg',
      ['飞机', '汽车', '公共汽车', '地铁', '火车', '自行车', '开车', '走', '路', '到'],
    ),
    _FlashcardPlan(
      'hsk2_shopping',
      'HSK 2',
      'Mua sắm',
      Icons.shopping_bag_outlined,
      'assets/images/flashcards/food/e6803e21b9.jpg',
      ['买', '卖', '钱', '贵', '便宜', '商店', '东西', '打折', '买单', '点菜'],
    ),
    _FlashcardPlan(
      'hsk2_health',
      'HSK 2',
      'Sức khỏe và cơ thể',
      Icons.health_and_safety_outlined,
      'assets/images/flashcards/body/e6134a2993.jpg',
      ['身体', '眼睛', '耳朵', '鼻子', '手', '脚', '生病', '医院', '医生', '休息'],
    ),
    _FlashcardPlan(
      'hsk2_weather',
      'HSK 2',
      'Thời tiết',
      Icons.wb_sunny_outlined,
      'assets/images/flashcards/colors/5263651186.jpg',
      ['天气', '热', '冷', '下雨', '雪', '风', '晴', '阴', '春天', '夏天'],
    ),
    _FlashcardPlan(
      'hsk3_work',
      'HSK 3',
      'Công việc và nghề nghiệp',
      Icons.work_outline,
      'assets/images/flashcards/transport/b73c6e34a1.jpg',
      ['工作', '公司', '经理', '同事', '会议', '办公室', '安排', '任务', '完成', '决定'],
    ),
    _FlashcardPlan(
      'hsk3_emotion',
      'HSK 3',
      'Cảm xúc và tâm lý',
      Icons.emoji_emotions_outlined,
      'assets/images/flashcards/colors/97542386a9.jpg',
      ['高兴', '开心', '难过', '担心', '紧张', '生气', '感兴趣', '希望', '愿意', '突然'],
    ),
    _FlashcardPlan(
      'hsk3_travel',
      'HSK 3',
      'Du lịch và khám phá',
      Icons.explore_outlined,
      'assets/images/flashcards/transport/16678800cf.jpg',
      ['旅游', '城市', '地方', '宾馆', '机场', '地图', '出发', '到达', '参观', '风景'],
    ),
    _FlashcardPlan(
      'hsk3_tech',
      'HSK 3',
      'Công nghệ và đời sống',
      Icons.devices_outlined,
      'assets/images/flashcards/body/bf08c05e00.jpg',
      ['手机', '电脑', '上网', '照片', '消息', '电子邮件', '应用', '检查', '联系', '方便'],
    ),
    _FlashcardPlan(
      'hsk1_people_jobs',
      'HSK 1',
      'Nghề nghiệp và con người',
      Icons.badge_outlined,
      'assets/images/flashcards/family/033e1fb01c.jpg',
      ['医生', '老师', '学生', '工作', '公司', '人', '朋友', '名字'],
    ),
    _FlashcardPlan(
      'hsk1_daily_places',
      'HSK 1',
      'Địa điểm thường ngày',
      Icons.place_outlined,
      'assets/images/flashcards/places/071bd02a36.jpg',
      ['医院', '商店', '饭馆', '公园', '银行', '机场', '学校', '家'],
    ),
    _FlashcardPlan(
      'hsk2_hobbies',
      'HSK 2',
      'Sở thích',
      Icons.interests_outlined,
      'assets/images/flashcards/entertainment/2f3703e427.jpg',
      ['喜欢', '音乐', '电影', '跑步', '游泳', '唱歌', '跳舞', '运动'],
    ),
    _FlashcardPlan(
      'hsk2_study_skills',
      'HSK 2',
      'Học tập',
      Icons.menu_book_outlined,
      'assets/images/flashcards/school/413b738061.jpg',
      ['问题', '作业', '考试', '学习', '汉语', '书', '字', '老师'],
    ),
    _FlashcardPlan(
      'hsk3_planning',
      'HSK 3',
      'Kế hoạch và mục tiêu',
      Icons.event_note_outlined,
      'assets/images/flashcards/daily_life/0068330a10.jpg',
      ['计划', '希望', '决定', '准备', '参加', '开始', '结束', '明天'],
    ),
    _FlashcardPlan(
      'hsk3_social',
      'HSK 3',
      'Giao tiếp xã hội',
      Icons.groups_outlined,
      'assets/images/flashcards/city_life/47d68cd0f4.jpg',
      ['朋友', '帮助', '一起', '认识', '联系', '关系', '请', '名字'],
    ),
    _FlashcardPlan(
      'hsk4_business',
      'HSK 4',
      'Kinh doanh và kinh tế',
      Icons.business_center_outlined,
      'assets/images/flashcards/transport/e7e95e6813.jpg',
      ['经济', '发展', '市场', '价格', '顾客', '收入', '竞争', '机会', '成功', '管理'],
    ),
    _FlashcardPlan(
      'hsk4_media',
      'HSK 4',
      'Truyền thông và xã hội',
      Icons.newspaper_outlined,
      'assets/images/flashcards/city_life/c8ace4e283.jpg',
      ['新闻', '社会', '文化', '广告', '观众', '影响', '介绍', '讨论', '信息', '网络'],
    ),
    _FlashcardPlan(
      'hsk4_thinking',
      'HSK 4',
      'Tư duy và trình bày',
      Icons.psychology_outlined,
      'assets/images/flashcards/colors/d9bbeb4427.jpg',
      ['认为', '表示', '原因', '结果', '方法', '说明', '经验', '观点', '选择', '计划'],
    ),
  ];
}

class _FlashcardPlan {
  const _FlashcardPlan(
    this.id,
    this.level,
    this.name,
    this.icon,
    this.imagePath,
    this.words,
  );

  final String id;
  final String level;
  final String name;
  final IconData icon;
  final String imagePath;
  final List<String> words;
}
