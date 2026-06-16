import 'dart:convert';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:mobile/core/services/progress_service.dart';
import 'package:mobile/features/vocabulary/vocab_data_helper.dart';
import 'package:mobile/features/reading/pronunciation_data.dart';

// Data model for a news article
class NewsArticle {
  final String title;
  final String titleVi;
  final String content;
  final String source;
  final String level;
  final Color color;
  final DateTime? pubDate;
  final String? link;
  final bool isLive;

  const NewsArticle({
    required this.title,
    required this.titleVi,
    required this.content,
    required this.source,
    required this.level,
    required this.color,
    this.pubDate,
    this.link,
    this.isLive = false,
  });
}

class NewsReaderScreen extends StatefulWidget {
  const NewsReaderScreen({super.key});

  @override
  State<NewsReaderScreen> createState() => _NewsReaderScreenState();
}

class _NewsReaderScreenState extends State<NewsReaderScreen>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ProgressService _progressService = ProgressService();
  late TabController _tabController;

  // ===== PRONUNCIATION STATE =====
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _speechAvailable = false;
  bool _isListening = false;
  bool _isAnalyzing = false;
  bool _ttsSpeaking = false;
  String _recognizedText = '';
  Map<String, dynamic>? _scoreResult;
  int _currentLessonIndex = 0;
  String _selectedLevel = 'HSK 1';

  List<HskSentence> get _filteredLessons =>
      PronunciationData.sentences[_selectedLevel] ?? [];

  HskSentence get _currentLesson {
    final list = _filteredLessons;
    if (list.isEmpty) return PronunciationData.sentences['HSK 1']!.first;
    return list[_currentLessonIndex.clamp(0, list.length - 1)];
  }

  // ===== LIVE NEWS STATE =====
  List<NewsArticle> _liveArticles = [];
  bool _isLoadingNews = false;
  String _newsError = '';
  int _selectedSourceIndex = 0;
  NewsArticle? _selectedLiveArticle;
  String? _selectedWord;
  bool _isLoadingDefinition = false;
  Map<String, String> _wordDefinition = {};

  // CORS proxy for Flutter Web compatibility
  static const String _corsProxy = 'https://api.allorigins.win/raw?url=';

  static const List<Map<String, String>> _rssSources = [
    {
      'name': 'BBC 中文',
      'url': 'https://feeds.bbci.co.uk/chinese/rss.xml',
      'level': 'HSK 5-6',
    },
    {
      'name': 'VOA 中文',
      'url': 'https://www.voanews.com/api/epiqegynmv',
      'level': 'HSK 4-5',
    },
    {'name': 'RFI 中文', 'url': 'https://www.rfi.fr/cn/rss', 'level': 'HSK 4-6'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initTts();
    _initSpeech();
    _tabController.addListener(() {
      if (_tabController.index == 1 &&
          _liveArticles.isEmpty &&
          !_isLoadingNews) {
        _fetchLiveNews();
      }
    });
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("zh-CN");
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    _tts.setStartHandler(() => setState(() => _ttsSpeaking = true));
    _tts.setCompletionHandler(() => setState(() => _ttsSpeaking = false));
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if ((status == 'done' || status == 'notListening') && _isListening) {
          setState(() => _isListening = false);
          _pulseController.stop();
          _pulseController.reset();
          if (_recognizedText.isNotEmpty) _analyzePronounciation();
        }
      },
      onError: (_) {
        setState(() => _isListening = false);
        _pulseController.stop();
        _pulseController.reset();
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    _pulseController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ===== PRONUNCIATION METHODS =====
  Future<void> _speakExample() async {
    if (_ttsSpeaking) {
      await _tts.stop();
      setState(() => _ttsSpeaking = false);
      return;
    }
    await _tts.speak(_currentLesson.chinese);
  }

  Future<void> _startListening() async {
    if (!_speechAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Mic không hoạt động trên trình duyệt Web. Vui lòng dùng app trên điện thoại thật.",
          ),
        ),
      );
      return;
    }
    setState(() {
      _recognizedText = '';
      _scoreResult = null;
      _isListening = true;
    });
    _pulseController.repeat(reverse: true);
    await _speech.listen(
      onResult: (r) => setState(() => _recognizedText = r.recognizedWords),
      localeId: 'zh-CN',
      listenFor: const Duration(seconds: 12),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(partialResults: true),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    _pulseController.stop();
    _pulseController.reset();
    setState(() => _isListening = false);
    if (_recognizedText.isNotEmpty) _analyzePronounciation();
  }

  Future<void> _analyzePronounciation() async {
    setState(() => _isAnalyzing = true);
    await Future.delayed(const Duration(milliseconds: 400));
    final score = _calculateSimilarity(_currentLesson.chinese, _recognizedText);
    if (mounted)
      setState(() {
        _scoreResult = _buildScoreResult(score);
        _isAnalyzing = false;
      });
  }

  double _calculateSimilarity(String target, String recognized) {
    if (recognized.isEmpty) return 0;
    String t = target.replaceAll(RegExp(r'[\s\u3002\uff01\uff1f，？！。]'), '');
    String r = recognized.replaceAll(RegExp(r'[\s\u3002\uff01\uff1f，？！。]'), '');
    if (t == r) return 100;
    int matches = 0;
    int minLen = min(t.length, r.length);
    for (int i = 0; i < minLen; i++) {
      if (t[i] == r[i]) matches++;
    }
    int unordered = 0;
    final tc = t.split('').toList();
    for (var ch in r.split('')) {
      if (tc.contains(ch)) {
        unordered++;
        tc.remove(ch);
      }
    }
    double ordered = t.isNotEmpty ? (matches / t.length) * 100 : 0;
    double unorderedScore = t.isNotEmpty ? (unordered / t.length) * 100 : 0;
    return ((ordered * 0.7 + unorderedScore * 0.3)).clamp(0, 100);
  }

  Map<String, dynamic> _buildScoreResult(double score) {
    final s = score.round();
    if (s >= 92) {
      return {
        'score': s,
        'grade': "Xuất sắc! 🏆",
        'color': Colors.green,
        'feedback': "Phát âm của bạn rất chuẩn! Tuyệt vời!",
        'tips': [],
      };
    } else if (s >= 75) {
      return {
        'score': s,
        'grade': "Tốt lắm! 🌟",
        'color': Colors.blue,
        'feedback': "Phát âm khá tốt, chú ý một vài âm tiết nhỏ.",
        'tips': ["Thử đọc lại chậm hơn, chú ý từng thanh điệu."],
      };
    } else if (s >= 55) {
      return {
        'score': s,
        'grade': "Khá ổn 👍",
        'color': Colors.orange,
        'feedback': "Cần luyện tập thêm. Nghe mẫu nhiều lần rồi đọc theo.",
        'tips': [
          "Nghe mẫu (nút loa) 3-5 lần trước khi tự đọc.",
          "Tập từng từ trước rồi mới ghép câu.",
        ],
      };
    } else if (s >= 35) {
      return {
        'score': s,
        'grade': "Cần cố gắng 💪",
        'color': Colors.deepOrange,
        'feedback': "Phát âm cần cải thiện nhiều. Đừng nản lòng!",
        'tips': [
          "Bắt đầu với câu ngắn hơn ở cấp độ dưới.",
          "4 thanh điệu: bằng(ā), lên(á), xuống-lên(ǎ), xuống(à).",
        ],
      };
    } else {
      return {
        'score': s,
        'grade': "Hãy thử lại! 🎯",
        'color': Colors.red,
        'feedback': "Máy chưa nhận ra bạn đọc. Đọc to hơn và rõ hơn nhé!",
        'tips': [
          "Đảm bảo không có tiếng ồn xung quanh.",
          "Đọc to, rõ ràng ngay gần micro điện thoại.",
        ],
      };
    }
  }

  // ===== NEWS METHODS =====
  Future<void> _fetchLiveNews() async {
    setState(() {
      _isLoadingNews = true;
      _newsError = '';
      _liveArticles = [];
      _selectedLiveArticle = null;
    });

    final source = _rssSources[_selectedSourceIndex];
    final originalUrl = source['url']!;
    // Use CORS proxy for Flutter Web compatibility
    final proxyUrl = '$_corsProxy${Uri.encodeComponent(originalUrl)}';
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];

    try {
      final response = await http
          .get(Uri.parse(proxyUrl), headers: {'Accept': '*/*'})
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        String body = response.body;
        final articles = _parseRSS(
          body,
          source['name']!,
          source['level']!,
          colors,
        );
        setState(() {
          _liveArticles = articles;
          _isLoadingNews = false;
          if (articles.isNotEmpty) _selectedLiveArticle = articles[0];
          if (articles.isEmpty) {
            _newsError =
                'Tải thành công nhưng không có bài đọc tiếng Trung. Thử nguồn khác.';
          }
        });
      } else {
        setState(() {
          _isLoadingNews = false;
          _newsError =
              'Server trả lỗi (HTTP ${response.statusCode}). Thử nguồn khác hoặc thử lại sau.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingNews = false;
        _newsError =
            'Lỗi kết nối: Không tải được tin tức.\nKiểm tra mạng và thử lại.\n(${e.toString().split(':').first})';
      });
    }
  }

  List<NewsArticle> _parseRSS(
    String xml,
    String sourceName,
    String level,
    List<Color> colors,
  ) {
    List<NewsArticle> articles = [];
    final itemRegex = RegExp(r'<item>(.*?)</item>', dotAll: true);
    int colorIdx = 0;
    for (final m in itemRegex.allMatches(xml)) {
      if (articles.length >= 12) break;
      final item = m.group(1) ?? '';
      String title = _stripHtml(_extractTag(item, 'title'));
      String description = _stripHtml(_extractTag(item, 'description'));
      String link = _extractTag(item, 'link');
      String pubDateStr = _extractTag(item, 'pubDate');

      if (title.isEmpty && description.isEmpty) continue;
      bool hasChinese = RegExp(
        r'[\u4e00-\u9fff]',
      ).hasMatch(title + description);
      if (!hasChinese) continue;

      DateTime? pubDate;
      try {
        pubDate = DateTime.parse(pubDateStr);
      } catch (_) {}

      String content = description.length > 30 ? description : title;
      articles.add(
        NewsArticle(
          title: title.isNotEmpty
              ? title
              : description.substring(0, description.length.clamp(0, 50)),
          titleVi: '[$sourceName]',
          content: content,
          source: sourceName,
          level: level,
          color: colors[colorIdx % colors.length],
          pubDate: pubDate,
          link: link,
          isLive: true,
        ),
      );
      colorIdx++;
    }
    return articles;
  }

  String _extractTag(String xml, String tag) {
    final r1 = RegExp(
      '<$tag[^>]*><!\\[CDATA\\[(.+?)\\]\\]><\\/$tag>',
      dotAll: true,
    );
    final m1 = r1.firstMatch(xml);
    if (m1 != null) return m1.group(1)?.trim() ?? '';
    final r2 = RegExp('<$tag[^>]*>(.*?)<\\/$tag>', dotAll: true);
    return r2.firstMatch(xml)?.group(1)?.trim() ?? '';
  }

  String _stripHtml(String html) => html
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // ===== WORD LOOKUP =====
  Future<void> _lookupWord(String word) async {
    if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(word)) return;
    setState(() {
      _selectedWord = word;
      _isLoadingDefinition = true;
      _wordDefinition = {};
    });
    _tts.speak(word);

    Map<String, dynamic> local = VocabDataHelper.getData(word, {"forms": []});
    if (local['meaning'] != null && local['meaning'] != 'Đang tải...') {
      setState(() {
        _wordDefinition = {
          'word': word,
          'pinyin': local['pinyin'] ?? '',
          'meaning': local['meaning'] ?? '',
        };
        _isLoadingDefinition = false;
      });
      return;
    }

    String meaning = '';
    try {
      final url = Uri.parse(
        'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(word)}&langpair=zh-CN|vi',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 6));
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        String t = data['responseData']['translatedText'] ?? '';
        if (t != word && t.isNotEmpty) meaning = t;
      }
    } catch (_) {}

    setState(() {
      _wordDefinition = {
        'word': word,
        'pinyin': '',
        'meaning': meaning.isNotEmpty
            ? meaning
            : '(Không tra được nghĩa lúc này)',
      };
      _isLoadingDefinition = false;
    });
  }

  List<String> _splitText(String text) {
    List<String> result = [];
    String buffer = '';
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      if (RegExp(r'[\u4e00-\u9fff]').hasMatch(char)) {
        if (buffer.isNotEmpty) {
          result.add(buffer);
          buffer = '';
        }
        if (i + 2 < text.length && _isCommonWord(text.substring(i, i + 3))) {
          result.add(text.substring(i, i + 3));
          i += 2;
        } else if (i + 1 < text.length &&
            _isCommonWord(text.substring(i, i + 2))) {
          result.add(text.substring(i, i + 2));
          i += 1;
        } else {
          result.add(char);
        }
      } else {
        buffer += char;
      }
    }
    if (buffer.isNotEmpty) result.add(buffer);
    return result;
  }

  List<String> _splitSentences(String text) {
    // Split by punctuation
    final sentences = text.split(RegExp(r'([。！？；.!?;])'));
    final result = <String>[];
    for (int i = 0; i < sentences.length; i += 2) {
      if (sentences[i].trim().isEmpty) continue;
      String s = sentences[i];
      if (i + 1 < sentences.length) {
        s += sentences[i + 1]; // add punctuation back
      }
      result.add(s.trim());
    }
    return result;
  }

  bool _isCommonWord(String w) {
    const s = {
      '今天',
      '天气',
      '非常',
      '公园',
      '跑步',
      '很多',
      '新闻',
      '中国',
      '经济',
      '发展',
      '政府',
      '社会',
      '文化',
      '教育',
      '科技',
      '环境',
      '国际',
      '合作',
      '报道',
      '记者',
      '事件',
      '影响',
      '重要',
      '问题',
      '解决',
      '国家',
      '政策',
      '改革',
      '基础',
      '设施',
      '研究',
      '数据',
      '人工',
      '智能',
      '互联',
      '网络',
      '技术',
      '创新',
      '企业',
      '市场',
      '消费',
      '贸易',
      '投资',
      '金融',
      '银行',
      '货币',
      '汇率',
      '价格',
      '通货',
      '膨胀',
      '学习',
      '语言',
      '方法',
      '首先',
      '其次',
      '每天',
      '练习',
      '汉字',
      '歌曲',
      '电影',
      '喜欢',
      '朋友',
      '认识',
      '中文',
      '越南',
      '周末',
      '常常',
      '一起',
      '吃饭',
      '好吃',
      '传统',
      '节日',
      '春节',
      '鞭炮',
      '饺子',
      '孩子',
      '红包',
      '中秋',
      '月饼',
      '端午',
      '粽子',
      '龙舟',
      '不仅',
      '庆祝',
      '团聚',
      '生活',
      '现在',
      '人们',
      '支付',
      '外卖',
      '面对',
      '交流',
      '思考',
      '需要',
      '改变',
      '各个',
      '医疗',
      '气候',
      '能源',
      '信息',
    };
    return s.contains(w);
  }

  // ===== BUILD =====
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Luyện đọc tiếng Trung"),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFFD32F2F),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFD32F2F),
          tabs: const [
            Tab(icon: Icon(Icons.mic), text: "Luyện phát âm"),
            Tab(icon: Icon(Icons.newspaper), text: "Báo Trung Quốc"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildPronunciationTab(), _buildLiveNewsTab()],
      ),
    );
  }

  // ===== TAB 1: Pronunciation Practice =====
  Widget _buildPronunciationTab() {
    final lesson = _currentLesson;
    final list = _filteredLessons;
    final totalCount = list.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Level selector
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: PronunciationData.sentences.keys.map((level) {
                bool sel = level == _selectedLevel;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(level),
                    selected: sel,
                    selectedColor: const Color(0xFFD32F2F),
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (_) => setState(() {
                      _selectedLevel = level;
                      _currentLessonIndex = 0;
                      _recognizedText = '';
                      _scoreResult = null;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${_currentLessonIndex + 1} / $totalCount câu",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 12),

          // Lesson card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFFF6659)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() {
                        _currentLessonIndex =
                            (_currentLessonIndex - 1 + list.length) %
                            list.length;
                        _recognizedText = '';
                        _scoreResult = null;
                      }),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _selectedLevel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                      ),
                      onPressed: () => setState(() {
                        _currentLessonIndex =
                            (_currentLessonIndex + 1) % list.length;
                        _recognizedText = '';
                        _scoreResult = null;
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  lesson.chinese,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  lesson.pinyin,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  lesson.vietnamese,
                  style: const TextStyle(fontSize: 13, color: Colors.white60),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  icon: Icon(
                    _ttsSpeaking ? Icons.stop : Icons.volume_up,
                    color: Colors.white,
                  ),
                  label: Text(
                    _ttsSpeaking ? "Dừng" : "Nghe mẫu phát âm",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _speakExample,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Mic button
          Center(
            child: Column(
              children: [
                const Text(
                  "Bấm mic và đọc câu bên trên:",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (ctx, child) => Transform.scale(
                    scale: _isListening ? _pulseAnimation.value : 1.0,
                    child: child,
                  ),
                  child: GestureDetector(
                    onTap: _isListening ? _stopListening : _startListening,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: _isListening
                            ? const Color(0xFFD32F2F)
                            : Colors.grey.shade200,
                        shape: BoxShape.circle,
                        boxShadow: _isListening
                            ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFFD32F2F,
                                  ).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: _isListening
                            ? Colors.white
                            : Colors.grey.shade700,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _isListening
                      ? "🎙️ Đang nghe... (Bấm để dừng)"
                      : "Bấm để bắt đầu đọc",
                  style: TextStyle(
                    color: _isListening ? const Color(0xFFD32F2F) : Colors.grey,
                    fontWeight: _isListening
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),

          // Recognized text
          if (_recognizedText.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "🎤 Bạn đã đọc:",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _recognizedText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Analyzing
          if (_isAnalyzing) ...[
            const SizedBox(height: 24),
            const Center(
              child: Column(
                children: [
                  CircularProgressIndicator(color: Color(0xFFD32F2F)),
                  SizedBox(height: 8),
                  Text(
                    "Đang chấm điểm phát âm...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],

          // Score card
          if (_scoreResult != null && !_isAnalyzing) ...[
            const SizedBox(height: 20),
            _buildScoreCard(_scoreResult!),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildScoreCard(Map<String, dynamic> result) {
    final int score = result['score'] as int;
    final String grade = result['grade'] as String;
    final Color gradeColor = result['color'] as Color;
    final String feedback = result['feedback'] as String;
    final List tips = result['tips'] as List;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradeColor.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: gradeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: gradeColor, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$score",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                    Text(
                      "/ 100",
                      style: TextStyle(fontSize: 10, color: gradeColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(gradeColor),
            ),
          ),
          if (tips.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              "💡 Lời khuyên:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 6),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "â€¢ ",
                      style: TextStyle(color: Color(0xFFD32F2F)),
                    ),
                    Expanded(
                      child: Text(
                        tip.toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text("Đọc lại câu này"),
              style: OutlinedButton.styleFrom(
                foregroundColor: gradeColor,
                side: BorderSide(color: gradeColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => setState(() {
                _recognizedText = '';
                _scoreResult = null;
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ===== TAB 2: Live News =====
  Widget _buildLiveNewsTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.white,
          child: Row(
            children: [
              const Text(
                "Nguồn: ",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_rssSources.length, (i) {
                      bool sel = i == _selectedSourceIndex;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(_rssSources[i]['name']!),
                          selected: sel,
                          selectedColor: const Color(0xFFD32F2F),
                          labelStyle: TextStyle(
                            color: sel ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (_) {
                            setState(() {
                              _selectedSourceIndex = i;
                              _liveArticles = [];
                              _selectedLiveArticle = null;
                            });
                            _fetchLiveNews();
                          },
                        ),
                      );
                    }),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Color(0xFFD32F2F)),
                tooltip: "Tải lại",
                onPressed: _fetchLiveNews,
              ),
            ],
          ),
        ),

        if (_isLoadingNews)
          const Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFFD32F2F)),
                  SizedBox(height: 16),
                  Text(
                    "Đang tải tin tức mới nhất...",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else if (_newsError.isNotEmpty)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.signal_wifi_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _newsError,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text("Thử lại"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _fetchLiveNews,
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_liveArticles.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.newspaper, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "Nhấn để tải tin tức mới nhất",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text("Tải tin tức"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _fetchLiveNews,
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: Column(
              children: [
                SizedBox(
                  height: 130,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: _liveArticles.length,
                    itemBuilder: (ctx, i) {
                      final a = _liveArticles[i];
                      bool isSelected = _selectedLiveArticle == a;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedLiveArticle = a;
                          _selectedWord = null;
                        }),
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? a.color.withValues(alpha: 0.12)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? a.color
                                  : Colors.grey.shade200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: a.color.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      a.source,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: a.color,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (a.pubDate != null)
                                    Text(
                                      "${a.pubDate!.day}/${a.pubDate!.month}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                a.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (_selectedLiveArticle != null)
                  Expanded(child: _buildArticleContent(_selectedLiveArticle!)),
                _buildWordDefinitionPanel(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildArticleContent(NewsArticle article) {
    final sentences = _splitSentences(article.content);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          article.title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        if (article.pubDate != null)
          Text(
            "${article.pubDate!.day}/${article.pubDate!.month}/${article.pubDate!.year} · ${article.source}",
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: article.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                article.level,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: article.color,
                ),
              ),
            ),
            const Spacer(),
            IconButton.filledTonal(
              icon: const Icon(
                Icons.volume_up_outlined,
                color: Color(0xFFD32F2F),
              ),
              onPressed: () => _tts.speak(article.content),
              tooltip: "Nghe toàn bài",
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(color: Color(0xFFE0E0E0)),
        const SizedBox(height: 12),
        Text(
          "💡 Chạm vào từ để tra nghĩa. Bấm loa để nghe câu.",
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 16),
        ...sentences.asMap().entries.map((entry) {
          final idx = entry.key;
          final sent = entry.value;
          final words = _splitText(sent);
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEAE0D4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: const Color(0xFFF4F0EB),
                  child: Text(
                    '${idx + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: words.map((w) {
                        bool isChinese = RegExp(r'[\u4e00-\u9fff]').hasMatch(w);
                        bool isSelected = w == _selectedWord;
                        return WidgetSpan(
                          child: GestureDetector(
                            onTap: isChinese ? () => _lookupWord(w) : null,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 1,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFFFF3E0)
                                    : null,
                                borderRadius: BorderRadius.circular(4),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFFFFC107),
                                        width: 1.5,
                                      )
                                    : null,
                              ),
                              child: Text(
                                w,
                                style: TextStyle(
                                  fontSize: 24,
                                  height: 1.6,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                  color: isChinese
                                      ? const Color(0xFF1A1A2E)
                                      : Colors.grey,
                                  decoration: isChinese && !isSelected
                                      ? TextDecoration.underline
                                      : null,
                                  decorationColor: Colors.grey.withValues(
                                    alpha: 0.3,
                                  ),
                                  decorationStyle: TextDecorationStyle.dotted,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.volume_up_outlined,
                    color: Colors.grey,
                    size: 22,
                  ),
                  onPressed: () => _tts.speak(sent),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWordDefinitionPanel() {
    if (_selectedWord == null) return const SizedBox();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _isLoadingDefinition
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: Center(child: CircularProgressIndicator()),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _wordDefinition['word'] ?? '',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD32F2F),
                      ),
                    ),
                    if ((_wordDefinition['pinyin'] ?? '').isNotEmpty)
                      Text(
                        _wordDefinition['pinyin']!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _wordDefinition['meaning'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        color: Color(0xFFFFC107),
                      ),
                      onPressed: () =>
                          _tts.speak(_wordDefinition['word'] ?? ''),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.bookmark_add,
                        color: Color(0xFFD32F2F),
                      ),
                      onPressed: () async {
                        await _progressService.toggleFavorite(
                          _wordDefinition['word'] ?? '',
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Đã lưu "${_wordDefinition['word']}" ⭐',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
