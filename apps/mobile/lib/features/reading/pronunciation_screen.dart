import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Bộ dữ liệu câu luyện phát âm cho từng cấp độ
class PronunciationLesson {
  final String chinese;
  final String pinyin;
  final String vietnamese;
  final String level;

  const PronunciationLesson({
    required this.chinese,
    required this.pinyin,
    required this.vietnamese,
    required this.level,
  });
}

class PronunciationScreen extends StatefulWidget {
  const PronunciationScreen({super.key});

  @override
  State<PronunciationScreen> createState() => _PronunciationScreenState();
}

class _PronunciationScreenState extends State<PronunciationScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

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

  static const List<PronunciationLesson> _lessons = [
    // HSK 1
    PronunciationLesson(
      chinese: "你好",
      pinyin: "Nǐ hǎo",
      vietnamese: "Xin chào",
      level: "HSK 1",
    ),
    PronunciationLesson(
      chinese: "谢谢",
      pinyin: "Xièxiè",
      vietnamese: "Cảm ơn",
      level: "HSK 1",
    ),
    PronunciationLesson(
      chinese: "对不起",
      pinyin: "Duìbuqǐ",
      vietnamese: "Xin lỗi",
      level: "HSK 1",
    ),
    PronunciationLesson(
      chinese: "我是学生",
      pinyin: "Wǒ shì xuésheng",
      vietnamese: "Tôi là học sinh",
      level: "HSK 1",
    ),
    PronunciationLesson(
      chinese: "今天天气很好",
      pinyin: "Jīntiān tiānqì hěn hǎo",
      vietnamese: "Hôm nay thời tiết rất đẹp",
      level: "HSK 1",
    ),
    // HSK 2
    PronunciationLesson(
      chinese: "我喜欢学习中文",
      pinyin: "Wǒ xǐhuān xuéxí Zhōngwén",
      vietnamese: "Tôi thích học tiếng Trung",
      level: "HSK 2",
    ),
    PronunciationLesson(
      chinese: "你吃饭了吗",
      pinyin: "Nǐ chīfàn le ma",
      vietnamese: "Bạn đã ăn cơm chưa?",
      level: "HSK 2",
    ),
    PronunciationLesson(
      chinese: "我每天都去上班",
      pinyin: "Wǒ měitiān dōu qù shàngbān",
      vietnamese: "Mỗi ngày tôi đều đi làm",
      level: "HSK 2",
    ),
    // HSK 3
    PronunciationLesson(
      chinese: "我在北京学习汉语",
      pinyin: "Wǒ zài Běijīng xuéxí Hànyǔ",
      vietnamese: "Tôi đang học tiếng Trung tại Bắc Kinh",
      level: "HSK 3",
    ),
    PronunciationLesson(
      chinese: "学习语言需要很多时间",
      pinyin: "Xuéxí yǔyán xūyào hěnduō shíjiān",
      vietnamese: "Học ngôn ngữ cần rất nhiều thời gian",
      level: "HSK 3",
    ),
    // HSK 4
    PronunciationLesson(
      chinese: "通过努力学习，我的中文越来越好",
      pinyin: "Tōngguò nǔlì xuéxí, wǒ de Zhōngwén yuè lái yuè hǎo",
      vietnamese:
          "Thông qua học tập chăm chỉ, tiếng Trung của tôi ngày càng tốt hơn",
      level: "HSK 4",
    ),
    PronunciationLesson(
      chinese: "中国文化非常丰富多彩",
      pinyin: "Zhōngguó wénhuà fēicháng fēngfù duōcǎi",
      vietnamese: "Văn hóa Trung Quốc vô cùng phong phú đa dạng",
      level: "HSK 4",
    ),
  ];

  List<PronunciationLesson> get _filteredLessons =>
      _lessons.where((l) => l.level == _selectedLevel).toList();

  PronunciationLesson get _currentLesson {
    final list = _filteredLessons;
    if (list.isEmpty) return _lessons[0];
    return list[_currentLessonIndex.clamp(0, list.length - 1)];
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (_isListening) {
            setState(() => _isListening = false);
            _pulseController.stop();
            _pulseController.reset();
            if (_recognizedText.isNotEmpty) {
              _analyzePronounciation();
            }
          }
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        _pulseController.stop();
        _pulseController.reset();
      },
    );
    if (mounted) setState(() => _speechAvailable = available);
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("zh-CN");
    await _tts.setSpeechRate(0.45);
    await _tts.setVolume(1.0);
    _tts.setStartHandler(() => setState(() => _ttsSpeaking = true));
    _tts.setCompletionHandler(() => setState(() => _ttsSpeaking = false));
  }

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
      _showSnack(
        "Máy không hỗ trợ nhận dạng giọng nói. Vui lòng thử trên điện thoại thật.",
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
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      localeId: 'zh-CN',
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    _pulseController.stop();
    _pulseController.reset();
    setState(() => _isListening = false);
    if (_recognizedText.isNotEmpty) {
      _analyzePronounciation();
    }
  }

  /// Chấm điểm phát âm: so sánh từ nhận được với câu chuẩn
  Future<void> _analyzePronounciation() async {
    if (_recognizedText.isEmpty) return;
    setState(() => _isAnalyzing = true);

    final target = _currentLesson.chinese;
    final recognized = _recognizedText;

    // Tính điểm đơn giản dựa trên độ giống nhau ký tự
    final score = _calculateSimilarity(target, recognized);

    // Nếu có API key thực => dùng Gemini để phân tích sâu hơn
    // Ở đây ta dùng logic local trước
    await Future.delayed(const Duration(milliseconds: 500));

    final result = _buildScoreResult(target, recognized, score);
    if (mounted) {
      setState(() {
        _scoreResult = result;
        _isAnalyzing = false;
      });
    }
  }

  double _calculateSimilarity(String target, String recognized) {
    if (recognized.isEmpty) return 0;
    // Remove spaces and punctuation for comparison
    String t = target.replaceAll(RegExp(r'[\s\u3002\uff01\uff1f]'), '');
    String r = recognized.replaceAll(RegExp(r'[\s\u3002\uff01\uff1f]'), '');

    if (t == r) return 100;

    // Count matching characters (order-aware)
    int matches = 0;
    int minLen = min(t.length, r.length);
    for (int i = 0; i < minLen; i++) {
      if (t[i] == r[i]) matches++;
    }

    // Count characters present anywhere (unordered)
    int unorderedMatches = 0;
    final tChars = t.split('').toList();
    final rChars = r.split('').toList();
    for (var ch in rChars) {
      if (tChars.contains(ch)) {
        unorderedMatches++;
        tChars.remove(ch);
      }
    }

    // Weighted: 70% ordered + 30% unordered
    double orderedScore = t.isNotEmpty ? (matches / t.length) * 100 : 0;
    double unorderedScore = t.isNotEmpty
        ? (unorderedMatches / t.length) * 100
        : 0;
    double raw = (orderedScore * 0.7) + (unorderedScore * 0.3);

    // Penalize if lengths are very different
    double lengthPenalty = 1.0;
    if (r.length > t.length * 2 || (r.isEmpty && t.isNotEmpty)) {
      lengthPenalty = 0.5;
    }

    return (raw * lengthPenalty).clamp(0, 100);
  }

  Map<String, dynamic> _buildScoreResult(
    String target,
    String recognized,
    double score,
  ) {
    String grade;
    Color gradeColor;
    String feedback;
    List<String> tips = [];

    if (score >= 92) {
      grade = "Xuất sắc! 🏆";
      gradeColor = Colors.green;
      feedback = "Phát âm của bạn rất chuẩn! Tiếp tục phát huy!";
    } else if (score >= 78) {
      grade = "Tốt lắm! 🌟";
      gradeColor = Colors.blue;
      feedback = "Bạn đọc khá tốt, chỉ cần chú ý một vài âm tiết nhỏ.";
      tips.add("Thử đọc lại chậm hơn, chú ý từng thanh điệu.");
    } else if (score >= 60) {
      grade = "Khá ổn 👍";
      gradeColor = Colors.orange;
      feedback = "Cần luyện tập thêm. Hãy nghe mẫu nhiều lần trước khi đọc.";
      tips.add("Nghe mẫu (nút loa) 3-5 lần trước khi tự đọc.");
      tips.add("Tập từng từ trước, rồi mới ghép cả câu.");
    } else if (score >= 40) {
      grade = "Cần cố gắng 💪";
      gradeColor = Colors.deepOrange;
      feedback = "Phát âm cần cải thiện nhiều. Đừng nản lòng!";
      tips.add("Bắt đầu với các câu ngắn hơn ở cấp độ dưới.");
      tips.add(
        "Chú ý thanh điệu tiếng Trung: 1-bằng, 2-lên, 3-xuống-lên, 4-xuống, nhẹ.",
      );
      tips.add("Luyện phát âm Pinyin trước khi đọc chữ Hán.");
    } else {
      grade = "Hãy thử lại! 🎯";
      gradeColor = Colors.red;
      feedback =
          "Máy không nhận ra câu bạn đọc. Thử đọc to hơn và rõ ràng hơn.";
      tips.add("Đảm bảo không có tiếng ồn xung quanh.");
      tips.add("Đọc to, rõ ràng ngay gần micro điện thoại.");
      tips.add("Thử nghe mẫu phát âm nhiều lần rồi nhái theo.");
    }

    return {
      'score': score.round(),
      'grade': grade,
      'gradeColor': gradeColor,
      'feedback': feedback,
      'tips': tips,
      'recognized': recognized,
      'target': target,
    };
  }

  void _nextLesson() {
    final list = _filteredLessons;
    setState(() {
      _currentLessonIndex = (_currentLessonIndex + 1) % list.length;
      _recognizedText = '';
      _scoreResult = null;
    });
  }

  void _prevLesson() {
    final list = _filteredLessons;
    setState(() {
      _currentLessonIndex =
          (_currentLessonIndex - 1 + list.length) % list.length;
      _recognizedText = '';
      _scoreResult = null;
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = _currentLesson;
    final filteredLen = _filteredLessons.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Luyện phát âm"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                "${_currentLessonIndex.clamp(0, filteredLen - 1) + 1}/$filteredLen",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Level selector
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'].map((level) {
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
                      onSelected: (_) {
                        setState(() {
                          _selectedLevel = level;
                          _currentLessonIndex = 0;
                          _recognizedText = '';
                          _scoreResult = null;
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // === Câu luyện phát âm ===
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
                  // Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white70,
                        ),
                        onPressed: _prevLesson,
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
                          lesson.level,
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
                        onPressed: _nextLesson,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Chinese text
                  Text(
                    lesson.chinese,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Pinyin
                  Text(
                    lesson.pinyin,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  // Vietnamese
                  Text(
                    lesson.vietnamese,
                    style: const TextStyle(fontSize: 14, color: Colors.white60),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Listen button
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
            const SizedBox(height: 32),

            // === MIC BUTTON ===
            Center(
              child: Column(
                children: [
                  const Text(
                    "Bấm và đọc câu bên trên:",
                    style: TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isListening ? _pulseAnimation.value : 1.0,
                        child: child,
                      );
                    },
                    child: GestureDetector(
                      onTap: _isListening ? _stopListening : _startListening,
                      child: Container(
                        width: 90,
                        height: 90,
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
                  const SizedBox(height: 12),
                  Text(
                    _isListening
                        ? "🎙️ Đang nghe... (Bấm để dừng)"
                        : "Bấm để bắt đầu đọc",
                    style: TextStyle(
                      color: _isListening
                          ? const Color(0xFFD32F2F)
                          : Colors.grey,
                      fontWeight: _isListening
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),

            // === RECOGNIZED TEXT ===
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
                      _recognizedText.isEmpty
                          ? "(Không nhận ra)"
                          : _recognizedText,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // === ANALYZING ===
            if (_isAnalyzing) ...[
              const SizedBox(height: 24),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFFD32F2F)),
                    SizedBox(height: 8),
                    Text(
                      "AI đang chấm điểm phát âm...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],

            // === SCORE RESULT ===
            if (_scoreResult != null && !_isAnalyzing) ...[
              const SizedBox(height: 24),
              _buildScoreCard(_scoreResult!),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(Map<String, dynamic> result) {
    final int score = result['score'] as int;
    final String grade = result['grade'] as String;
    final Color gradeColor = result['gradeColor'] as Color;
    final String feedback = result['feedback'] as String;
    final List<String> tips = List<String>.from(result['tips'] as List);

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
              // Score circle
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
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                    Text(
                      "/ 100",
                      style: TextStyle(fontSize: 11, color: gradeColor),
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: gradeColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feedback,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Progress bar
          const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            const Text(
              "💡 Lời khuyên:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ...tips.map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "• ",
                      style: TextStyle(color: Color(0xFFD32F2F)),
                    ),
                    Expanded(
                      child: Text(tip, style: const TextStyle(fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Try again button
          const SizedBox(height: 16),
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
}
