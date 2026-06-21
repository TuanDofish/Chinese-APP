part of '../../main.dart';

class DictionaryRepository {
  static const String apiBaseUrl = AppConfig.apiBaseUrl;
  static final Map<String, VocabEntry> _cache = {};
  static final Map<String, VocabEntry> _exactEntries = {};
  static final Map<String, String> _flashcardImagePaths = {};
  static final Map<String, VocabEntry> _flashcardEntries = {};
  static final List<VocabEntry> _assetEntries = [];
  static final List<VocabEntry> _hskEntries = [];
  static Future<void>? _loadFuture;
  static bool _baseIndexed = false;
  static const trending = ['你好', '谢谢', '学习', '朋友', '工作', '突然', '中国', '汉语'];

  static List<VocabEntry> get allEntries => [
    ...entries,
    ..._assetEntries,
    ..._hskEntries,
  ];

  static Future<void> ensureLoaded() {
    return _loadFuture ??= _loadAssets();
  }

  static void _ensureBaseIndex() {
    if (_baseIndexed) return;
    _indexEntries(entries);
    _baseIndexed = true;
  }

  static void _indexEntries(Iterable<VocabEntry> values) {
    for (final entry in values) {
      _exactEntries.putIfAbsent(entry.simplified, () => entry);
    }
  }

  static Future<void> _loadAssets() async {
    _ensureBaseIndex();
    if (_assetEntries.isNotEmpty || _hskEntries.isNotEmpty) return;
    await _loadFlashcardImageIndex();
    try {
      final seed = jsonDecode(
        await rootBundle.loadString('assets/data/dictionary_seed_clean.json'),
      );
      if (seed is List) {
        _assetEntries.addAll(
          seed
              .whereType<Map>()
              .map((raw) => _entryFromMap(Map<String, dynamic>.from(raw)))
              .whereType<VocabEntry>(),
        );
        _indexEntries(_assetEntries);
      }
    } catch (_) {}

    try {
      final compact = jsonDecode(
        await rootBundle.loadString(
          'assets/data/dictionary_hsk14_compact.json',
        ),
      );
      if (compact is List) {
        final known = {
          for (final entry in [...entries, ..._assetEntries]) entry.simplified,
        };
        _hskEntries.addAll(
          compact.whereType<Map>().map((raw) {
            final map = Map<String, dynamic>.from(raw);
            final word = (map['simplified'] ?? '').toString();
            if (word.isEmpty || known.contains(word)) return null;
            final level = map['hskLevel'] ?? 1;
            final meaningEn = (map['meaningEn'] ?? '').toString().trim();
            final meaning = meaningEn.isEmpty
                ? 'Đang cập nhật nghĩa tiếng Việt'
                : 'Tiếng Anh: $meaningEn';
            return VocabEntry(
              simplified: word,
              pinyin: (map['pinyin'] ?? '').toString(),
              meaning: meaning,
              level: 'HSK $level',
              wordType: (map['wordType'] ?? '').toString(),
              examples: [
                ExampleSentenceData(
                  '我今天学习"$word"。',
                  'Wǒ jīntiān xuéxí "$word".',
                  'Hôm nay tôi học từ "$word".',
                ),
              ],
            );
          }).whereType<VocabEntry>(),
        );
        _indexEntries(_hskEntries);
      }
    } catch (_) {}
  }

  static Future<void> _loadFlashcardImageIndex() async {
    if (_flashcardImagePaths.isNotEmpty) return;
    try {
      final decoded = jsonDecode(
        await rootBundle.loadString('assets/images/flashcards/index.json'),
      );
      if (decoded is! Map || decoded['topics'] is! List) return;
      for (final topic in (decoded['topics'] as List).whereType<Map>()) {
        final topicId = (topic['id'] ?? '').toString().trim();
        final words = topic['words'];
        if (topicId.isEmpty || words is! List) continue;
        for (final raw in words.whereType<Map>()) {
          final word = (raw['word'] ?? '').toString().trim();
          final imagePath = _resolveFlashcardImagePath(topicId, raw);
          if (word.isEmpty || imagePath == null || imagePath.isEmpty) continue;
          _flashcardImagePaths[word] = imagePath;
          final pinyin = (raw['pinyin'] ?? '').toString().trim();
          final meaning = (raw['meaning'] ?? '').toString().trim();
          if (pinyin.isNotEmpty || meaning.isNotEmpty) {
            final normalized = _normalizedFlashcardText(word, pinyin, meaning);
            final importedExamples = <ExampleSentenceData>[];
            final rawExamples = raw['examples'];
            if (rawExamples is List) {
              for (final example in rawExamples.whereType<Map>()) {
                final cn = (example['cn'] ?? '').toString().trim();
                final py = (example['py'] ?? '').toString().trim();
                final vi = (example['vi'] ?? '').toString().trim();
                if (cn.isNotEmpty && vi.isNotEmpty) {
                  importedExamples.add(ExampleSentenceData(cn, py, vi));
                }
              }
            }
            _flashcardEntries[word] = VocabEntry(
              simplified: word,
              pinyin: normalized.$1,
              meaning: normalized.$2,
              imagePath: imagePath,
              examples: importedExamples.isNotEmpty
                  ? importedExamples.take(3).toList()
                  : _flashcardExamples(word, normalized.$1, normalized.$2),
            );
          }
        }
      }
      _indexEntries(_flashcardEntries.values);
    } catch (_) {}
  }

  static VocabEntry? _entryFromMap(Map<String, dynamic> map) {
    final word = (map['simplified'] ?? '').toString().trim();
    final meaning = (map['meaningVi'] ?? map['meaning_vi'] ?? '')
        .toString()
        .trim();
    if (word.isEmpty || meaning.isEmpty) return null;
    final examples = <ExampleSentenceData>[];
    final rawExamples = map['examples'];
    if (rawExamples is List) {
      for (final raw in rawExamples) {
        if (raw is Map && examples.length < 3) {
          final cn = (raw['cn'] ?? '').toString().trim();
          final py = (raw['py'] ?? '').toString().trim();
          final vi = (raw['vi'] ?? '').toString().trim();
          if (cn.isNotEmpty && vi.isNotEmpty) {
            examples.add(ExampleSentenceData(cn, py, vi));
          }
        }
      }
    }
    return VocabEntry(
      simplified: word,
      pinyin: (map['pinyin'] ?? '').toString(),
      meaning: meaning,
      hanViet: (map['hanViet'] ?? map['han_viet'] ?? '').toString(),
      level: 'HSK ${map['hskLevel'] ?? map['hsk_level'] ?? 1}',
      wordType: (map['wordType'] ?? map['word_type'] ?? '').toString(),
      examples: examples.isEmpty
          ? [
              ExampleSentenceData(
                '我今天学习"$word"。',
                'Wǒ jīntiān xuéxí "$word".',
                'Hôm nay tôi học từ "$word".',
              ),
            ]
          : examples,
    );
  }

  static VocabEntry? lookupLocal(String query) {
    _ensureBaseIndex();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return null;
    final exact = _exactEntries[query.trim()];
    if (exact != null) return exact;
    for (final entry in allEntries) {
      if (_matches(entry, query, q)) {
        return entry;
      }
    }
    return null;
  }

  static (String, String) _normalizedFlashcardText(
    String word,
    String pinyin,
    String meaning,
  ) {
    const curated = <String, (String, String)>{
      '天气': ('tiānqì', 'thời tiết'),
      '热': ('rè', 'nóng'),
      '冷': ('lěng', 'lạnh'),
      '下雨': ('xiàyǔ', 'mưa'),
      '雪': ('xuě', 'tuyết'),
      '风': ('fēng', 'gió'),
      '晴': ('qíng', 'trời nắng, quang đãng'),
      '阴': ('yīn', 'trời âm u'),
      '春天': ('chūntiān', 'mùa xuân'),
      '夏天': ('xiàtiān', 'mùa hè'),
      '学校': ('xuéxiào', 'trường học'),
      '老师': ('lǎoshī', 'giáo viên'),
      '学生': ('xuésheng', 'học sinh'),
      '学习': ('xuéxí', 'học tập'),
      '吃饭': ('chīfàn', 'ăn cơm'),
      '喝水': ('hēshuǐ', 'uống nước'),
      '买东西': ('mǎi dōngxi', 'mua đồ'),
      '打电话': ('dǎ diànhuà', 'gọi điện thoại'),
    };
    final value = curated[word];
    if (value != null) return value;
    return (
      pinyin,
      meaning.isEmpty ? 'Đang cập nhật nghĩa tiếng Việt' : meaning,
    );
  }

  static List<ExampleSentenceData> _flashcardExamples(
    String word,
    String pinyin,
    String meaning,
  ) {
    const curated = <String, List<ExampleSentenceData>>{
      '天气': [
        ExampleSentenceData(
          '今天天气很好，我们去公园吧。',
          'Jīntiān tiānqì hěn hǎo, wǒmen qù gōngyuán ba.',
          'Hôm nay thời tiết rất đẹp, chúng ta đi công viên nhé.',
        ),
        ExampleSentenceData(
          '你喜欢什么样的天气？',
          'Nǐ xǐhuan shénme yàng de tiānqì?',
          'Bạn thích kiểu thời tiết như thế nào?',
        ),
        ExampleSentenceData(
          '天气预报说明天会下雨。',
          'Tiānqì yùbào shuō míngtiān huì xiàyǔ.',
          'Dự báo thời tiết nói ngày mai sẽ mưa.',
        ),
      ],
      '下雨': [
        ExampleSentenceData(
          '外面下雨了，别忘了带伞。',
          'Wàimiàn xiàyǔ le, bié wàng le dài sǎn.',
          'Bên ngoài mưa rồi, đừng quên mang ô.',
        ),
      ],
      '学校': [
        ExampleSentenceData(
          '我每天坐公交车去学校。',
          'Wǒ měitiān zuò gōngjiāochē qù xuéxiào.',
          'Mỗi ngày tôi đi xe buýt đến trường.',
        ),
      ],
      '吃饭': [
        ExampleSentenceData(
          '我们一起去吃饭吧。',
          'Wǒmen yìqǐ qù chīfàn ba.',
          'Chúng ta cùng đi ăn cơm nhé.',
        ),
      ],
    };
    final examples = curated[word];
    if (examples != null) return examples;
    return [
      ExampleSentenceData(
        '这个词是"$word"。',
        'Zhège cí shì "$pinyin".',
        'Từ này có nghĩa là "$meaning".',
      ),
      ExampleSentenceData(
        '请用"$word"说一个完整的句子。',
        'Qǐng yòng "$word" shuō yí ge wánzhěng de jùzi.',
        'Hãy dùng "$word" để nói một câu hoàn chỉnh.',
      ),
    ];
  }

  static bool _matches(VocabEntry entry, String original, String folded) {
    final pinyin = entry.pinyin.toLowerCase().replaceAll(' ', '');
    final compactQuery = folded.replaceAll(' ', '');
    return entry.simplified == original ||
        entry.simplified.startsWith(original) ||
        pinyin.contains(compactQuery) ||
        entry.meaning.toLowerCase().contains(folded) ||
        entry.hanViet.toLowerCase().contains(folded);
  }

  static VocabEntry forFlashcard(
    String word, {
    required String level,
    required String? imagePath,
    bool useIndexedImage = true,
  }) {
    final found = lookupLocal(word);
    final flashcardEntry = useIndexedImage ? _flashcardEntries[word] : null;
    final resolvedImagePath = useIndexedImage
        ? (_flashcardImagePaths[word] ?? imagePath)
        : imagePath;
    if (!useIndexedImage && resolvedImagePath == null) {
      return VocabEntry(
        simplified: found?.simplified ?? word,
        pinyin: found?.pinyin ?? '',
        meaning: found?.meaning ?? 'Đang cập nhật nghĩa tiếng Việt',
        hanViet: found?.hanViet ?? '',
        level: level,
        wordType: found?.wordType ?? '',
        examples:
            found?.examples ??
            [
              ExampleSentenceData(
                '请用"$word"造句。',
                'Qǐng yòng "$word" zàojù.',
                'Hãy đặt câu với từ "$word".',
              ),
            ],
      );
    }
    if (flashcardEntry != null) {
      return flashcardEntry.copyWith(
        imagePath: resolvedImagePath,
        level: level,
      );
    }
    if (found == null) {
      return VocabEntry(
        simplified: word,
        pinyin: '',
        meaning: 'Đang cập nhật nghĩa tiếng Việt',
        level: level,
        imagePath: resolvedImagePath,
        examples: [
          ExampleSentenceData(
            '请用"$word"造句。',
            'Qǐng yòng "$word" zàojù.',
            'Hãy đặt câu với từ "$word".',
          ),
        ],
      );
    }
    return found.imagePath == null || _flashcardImagePaths.containsKey(word)
        ? found.copyWith(imagePath: resolvedImagePath, level: level)
        : found.copyWith(level: level);
  }

  static VocabEntry? lookupAt(String text, int start) {
    _ensureBaseIndex();
    for (var len = min(5, text.length - start); len >= 1; len--) {
      final slice = text.substring(start, start + len);
      if (!RegExp(r'^[\u4e00-\u9fff]+$').hasMatch(slice)) continue;
      final entry = _exactEntries[slice];
      if (entry != null) return entry;
    }
    return null;
  }

  static Future<VocabEntry?> lookupRemote(String query) async {
    final q = query.trim();
    if (q.isEmpty) return null;
    if (_cache.containsKey(q)) return _cache[q];
    try {
      final uri = Uri.parse(
        '$apiBaseUrl/dictionary/search?q=${Uri.encodeComponent(q)}',
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(milliseconds: 900));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final values = decoded is List
          ? decoded
          : decoded is Map && decoded['value'] is List
          ? decoded['value'] as List
          : const <dynamic>[];
      if (values.isEmpty || values.first is! Map) return null;
      final map = Map<String, dynamic>.from(values.first as Map);
      final meaningVi = (map['meaningVi'] ?? map['meaning_vi'] ?? '')
          .toString()
          .trim();
      final meaningEn = (map['meaningEn'] ?? map['meaning_en'] ?? '')
          .toString()
          .trim();
      final meaning = meaningVi.isNotEmpty
          ? meaningVi
          : meaningEn.isEmpty
          ? ''
          : 'Tiếng Anh: $meaningEn';
      if (meaning.isEmpty) return null;
      final examples = <ExampleSentenceData>[];
      if (map['examples'] is List) {
        for (final raw in map['examples'] as List) {
          if (raw is Map && examples.length < 3) {
            final cn = (raw['cn'] ?? '').toString();
            final py = (raw['py'] ?? '').toString();
            final vi = (raw['vi'] ?? '').toString();
            if (cn.isNotEmpty && vi.isNotEmpty) {
              examples.add(ExampleSentenceData(cn, py, vi));
            }
          }
        }
      }
      final entry = VocabEntry(
        simplified: (map['simplified'] ?? q).toString(),
        pinyin: (map['pinyin'] ?? '').toString(),
        meaning: meaning,
        hanViet: (map['hanViet'] ?? map['han_viet'] ?? '').toString(),
        level: 'HSK ${map['hskLevel'] ?? map['hsk_level'] ?? 1}',
        wordType: (map['wordType'] ?? map['word_type'] ?? '').toString(),
        examples: examples.isEmpty
            ? [
                ExampleSentenceData(
                  '我今天学习$q。',
                  'Wǒ jīntiān xuéxí $q.',
                  'Hôm nay tôi học từ $q.',
                ),
              ]
            : examples,
      );
      _cache[q] = entry;
      _indexEntries([entry]);
      return entry;
    } catch (_) {
      return null;
    }
  }

  static final entries = <VocabEntry>[
    e(
      '你好',
      'nǐ hǎo',
      'xin chào',
      hanViet: 'nhĩ hảo',
      examples: const [ExampleSentenceData('你好！', 'Nǐ hǎo!', 'Xin chào!')],
    ),
    e(
      '谢谢',
      'xièxie',
      'cảm ơn',
      hanViet: 'tạ tạ',
      examples: const [
        ExampleSentenceData('谢谢你。', 'Xièxie nǐ.', 'Cảm ơn bạn.'),
      ],
    ),
    e(
      '学习',
      'xuéxí',
      'học tập',
      hanViet: 'học tập',
      wordType: 'động từ',
      imagePath: 'assets/images/flashcards/family/033e1fb01c.jpg',
      examples: const [
        ExampleSentenceData(
          '我每天学习汉语。',
          'Wǒ měitiān xuéxí Hànyǔ.',
          'Tôi học tiếng Trung mỗi ngày.',
        ),
      ],
    ),
    e(
      '朋友',
      'péngyou',
      'bạn bè',
      hanViet: 'bằng hữu',
      imagePath: 'assets/images/flashcards/family/427034659a.jpg',
      examples: const [
        ExampleSentenceData(
          '他是我的朋友。',
          'Tā shì wǒ de péngyou.',
          'Anh ấy là bạn của tôi.',
        ),
      ],
    ),
    e(
      '工作',
      'gōngzuò',
      'làm việc, công việc',
      hanViet: 'công tác',
      examples: const [
        ExampleSentenceData(
          '我在公司工作。',
          'Wǒ zài gōngsī gōngzuò.',
          'Tôi làm việc ở công ty.',
        ),
      ],
    ),
    e(
      '喜欢',
      'xǐhuan',
      'thích',
      hanViet: 'hỉ hoan',
      examples: const [
        ExampleSentenceData(
          '我喜欢喝茶。',
          'Wǒ xǐhuan hē chá.',
          'Tôi thích uống trà.',
        ),
      ],
    ),
    e(
      '中国',
      'Zhōngguó',
      'Trung Quốc',
      hanViet: 'Trung Quốc',
      examples: const [
        ExampleSentenceData(
          '我想去中国。',
          'Wǒ xiǎng qù Zhōngguó.',
          'Tôi muốn đi Trung Quốc.',
        ),
      ],
    ),
    e(
      '汉语',
      'Hànyǔ',
      'tiếng Hán, tiếng Trung',
      hanViet: 'Hán ngữ',
      examples: const [
        ExampleSentenceData(
          '你会说汉语吗？',
          'Nǐ huì shuō Hànyǔ ma?',
          'Bạn biết nói tiếng Trung không?',
        ),
      ],
    ),
    e(
      '热闹',
      'rènao',
      'náo nhiệt, đông vui',
      hanViet: 'nhiệt nháo',
      wordType: 'tính từ',
      examples: const [
        ExampleSentenceData(
          '市场里很热闹。',
          'Shìchǎng lǐ hěn rènao.',
          'Trong chợ rất náo nhiệt.',
        ),
        ExampleSentenceData(
          '春节的时候街上很热闹。',
          'Chūnjié de shíhou jiē shang hěn rènao.',
          'Vào dịp Tết, ngoài phố rất đông vui.',
        ),
      ],
    ),
    e(
      '苹果',
      'píngguǒ',
      'quả táo',
      imagePath: 'assets/images/flashcards/food/edfec00f07.jpg',
      examples: const [
        ExampleSentenceData(
          '我买一个苹果。',
          'Wǒ mǎi yí ge píngguǒ.',
          'Tôi mua một quả táo.',
        ),
      ],
    ),
    e(
      '米饭',
      'mǐfàn',
      'cơm',
      imagePath: 'assets/images/flashcards/food/814b1c8d80.jpg',
      examples: const [
        ExampleSentenceData(
          '我喜欢吃米饭。',
          'Wǒ xǐhuan chī mǐfàn.',
          'Tôi thích ăn cơm.',
        ),
      ],
    ),
    e(
      '猫',
      'māo',
      'con mèo',
      imagePath: 'assets/images/flashcards/animals/b655de688e.jpg',
      examples: const [
        ExampleSentenceData(
          '小猫在椅子下面。',
          'Xiǎomāo zài yǐzi xiàmiàn.',
          'Con mèo nhỏ ở dưới ghế.',
        ),
      ],
    ),
    e(
      '狗',
      'gǒu',
      'con chó',
      imagePath: 'assets/images/flashcards/animals/5090e44ef9.jpg',
      examples: const [
        ExampleSentenceData(
          '这只狗很可爱。',
          'Zhè zhī gǒu hěn kěài.',
          'Con chó này rất đáng yêu.',
        ),
      ],
    ),
    e(
      '红色',
      'hóngsè',
      'màu đỏ',
      imagePath: 'assets/images/flashcards/colors/ddb86dd31c.jpg',
      examples: const [
        ExampleSentenceData('我喜欢红色。', 'Wǒ xǐhuan hóngsè.', 'Tôi thích màu đỏ.'),
      ],
    ),
    e(
      '爸爸',
      'bàba',
      'bố, ba',
      imagePath: 'assets/images/flashcards/family/e6c7ee6003.jpg',
      examples: const [
        ExampleSentenceData('爸爸去工作了。', 'Bàba qù gōngzuò le.', 'Bố đi làm rồi.'),
      ],
    ),
    e(
      '妈妈',
      'māma',
      'mẹ',
      imagePath: 'assets/images/flashcards/family/e571dca2d0.jpg',
      examples: const [
        ExampleSentenceData('妈妈做饭。', 'Māma zuò fàn.', 'Mẹ nấu cơm.'),
      ],
    ),
    e(
      '哥哥',
      'gēge',
      'anh trai',
      imagePath: 'assets/images/flashcards/family/39af35e7b7.jpg',
      examples: const [
        ExampleSentenceData(
          '我哥哥比我大三岁。',
          'Wǒ gēge bǐ wǒ dà sān suì.',
          'Anh trai tôi lớn hơn tôi ba tuổi.',
        ),
      ],
    ),
    e(
      '姐姐',
      'jiějie',
      'chị gái',
      imagePath: 'assets/images/flashcards/family/033e1fb01c.jpg',
      examples: const [
        ExampleSentenceData(
          '我姐姐在北京工作。',
          'Wǒ jiějie zài Běijīng gōngzuò.',
          'Chị gái tôi làm việc ở Bắc Kinh.',
        ),
      ],
    ),
    e(
      '弟弟',
      'dìdi',
      'em trai',
      imagePath: 'assets/images/flashcards/family/427034659a.jpg',
      examples: const [
        ExampleSentenceData(
          '弟弟在上小学。',
          'Dìdi zài shàng xiǎoxué.',
          'Em trai đang học tiểu học.',
        ),
      ],
    ),
    e(
      '妹妹',
      'mèimei',
      'em gái',
      imagePath: 'assets/images/flashcards/family/1c097b12de.jpg',
      examples: const [
        ExampleSentenceData(
          '我妹妹喜欢画画。',
          'Wǒ mèimei xǐhuan huà huà.',
          'Em gái tôi thích vẽ tranh.',
        ),
      ],
    ),
    e(
      '儿子',
      'érzi',
      'con trai',
      examples: const [
        ExampleSentenceData(
          '他有一个儿子。',
          'Tā yǒu yí ge érzi.',
          'Anh ấy có một người con trai.',
        ),
      ],
    ),
    e(
      '女儿',
      'nǚ ér',
      'con gái',
      examples: const [
        ExampleSentenceData(
          '女儿很可爱。',
          'Nǚ ér hěn kěài.',
          'Con gái rất đáng yêu.',
        ),
      ],
    ),
    e(
      '飞机',
      'fēijī',
      'máy bay',
      imagePath: 'assets/images/flashcards/transport/fed19a817b.jpg',
      examples: const [
        ExampleSentenceData(
          '我坐飞机去北京。',
          'Wǒ zuò fēijī qù Běijīng.',
          'Tôi đi máy bay đến Bắc Kinh.',
        ),
      ],
    ),
    e(
      '眼睛',
      'yǎnjing',
      'mắt',
      imagePath: 'assets/images/flashcards/body/e6134a2993.jpg',
      examples: const [
        ExampleSentenceData(
          '她的眼睛很漂亮。',
          'Tā de yǎnjing hěn piàoliang.',
          'Mắt cô ấy rất đẹp.',
        ),
      ],
    ),
    e(
      '经理',
      'jīnglǐ',
      'giám đốc, quản lý',
      level: 'HSK 3',
      examples: const [
        ExampleSentenceData(
          '经理正在开会。',
          'Jīnglǐ zhèngzài kāihuì.',
          'Quản lý đang họp.',
        ),
      ],
    ),
    e(
      '经济',
      'jīngjì',
      'kinh tế',
      level: 'HSK 4',
      examples: const [
        ExampleSentenceData(
          '中国经济发展很快。',
          'Zhōngguó jīngjì fāzhǎn hěn kuài.',
          'Kinh tế Trung Quốc phát triển rất nhanh.',
        ),
      ],
    ),
  ];

  static VocabEntry e(
    String simplified,
    String pinyin,
    String meaning, {
    String hanViet = '',
    String level = 'HSK 1',
    String wordType = '',
    String? imagePath,
    required List<ExampleSentenceData> examples,
  }) {
    return VocabEntry(
      simplified: simplified,
      pinyin: pinyin,
      meaning: meaning,
      hanViet: hanViet,
      level: level,
      wordType: wordType,
      imagePath: imagePath,
      examples: examples,
    );
  }
}

class NotebookStore {
  static const _key = 'vnchinese_notebook_words';

  static Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? <String>[]).toSet();
  }

  static Future<Set<String>> toggle(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_key) ?? <String>[]).toSet();
    if (set.contains(word)) {
      set.remove(word);
    } else {
      set.add(word);
    }
    await prefs.setStringList(_key, set.toList()..sort());
    return set;
  }
}
