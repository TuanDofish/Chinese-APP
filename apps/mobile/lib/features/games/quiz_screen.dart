import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile/features/vocabulary/vocab_data_helper.dart';
import 'package:mobile/core/utils/pinyin_utils.dart';
import 'package:mobile/core/services/progress_service.dart';

const _kAmber = Color(0xFFFFA726);
const _kGreen = Color(0xFF4CAF50);
const _kRed = Color(0xFFF44336);
const _kSurface = Color(0xFFF8F0E8);
const _kInk = Color(0xFF1A1A2E);

// ─── Quiz Screen ─────────────────────────────────────────────────────────────
class QuizScreen extends StatefulWidget {
  final List<dynamic> words;
  final VoidCallback onFinish;

  const QuizScreen({super.key, required this.words, required this.onFinish});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final ProgressService _progressService = ProgressService();
  final Random _random = Random();

  final List<_QuizQuestion> _questions = [];
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int _correctCount = 0;

  // Shake animation for wrong answer
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  // Slide animation between questions
  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _initTts();
    _shakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _buildQuestions();
    _slideCtrl.forward();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("zh-CN");
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text, {bool slow = false}) async {
    await _tts.setSpeechRate(slow ? 0.2 : 0.5);
    await _tts.speak(text);
  }

  void _buildQuestions() {
    List<Map<String, dynamic>> allData = [];
    for (var w in widget.words) {
      if (w is! Map<String, dynamic>) continue;
      final d = VocabDataHelper.getData(w['simplified'] ?? '', w);
      if ((d['simplified'] as String? ?? '').isNotEmpty) {
        allData.add(d);
      }
    }
    if (allData.length < 2) return;

    final shuffled = List.of(allData)..shuffle(_random);
    final fallbacks = [
      '的',
      '是',
      '有',
      '在',
      '好',
      '我',
      '你',
      '他',
      '来',
      '去',
      '大',
      '小',
    ];

    for (final word in shuffled) {
      // Pick 3 wrong options
      final others =
          allData.where((w) => w['simplified'] != word['simplified']).toList()
            ..shuffle(_random);
      final wrongOptions = others
          .take(3)
          .map((w) => w['simplified'] as String)
          .toList();

      // Pad with fallbacks if not enough words
      while (wrongOptions.length < 3) {
        final fb = fallbacks[_random.nextInt(fallbacks.length)];
        if (!wrongOptions.contains(fb) && fb != word['simplified']) {
          wrongOptions.add(fb);
        }
      }

      final options = [word['simplified'] as String, ...wrongOptions]
        ..shuffle(_random);
      _questions.add(
        _QuizQuestion(
          word: word,
          options: options,
          correct: word['simplified'] as String,
        ),
      );
    }
  }

  void _selectAnswer(String answer) {
    if (_isAnswered) return;
    final correct = _questions[_currentIndex].correct;
    final isCorrect = answer == correct;

    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      _isCorrect = isCorrect;
      if (isCorrect) _correctCount++;
    });

    if (!isCorrect) {
      _shakeCtrl.forward(from: 0);
    }

    // Auto-speak correct answer
    _speak(correct);
  }

  void _nextQuestion() {
    if (_currentIndex >= _questions.length - 1) {
      _showResultScreen();
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _isAnswered = false;
        _isCorrect = false;
      });
      _slideCtrl.reset();
      _slideCtrl.forward();
    }
  }

  void _showResultScreen() {
    // Mark all words as learned
    for (final q in _questions) {
      _progressService.markAsLearned(q.correct);
    }
    _progressService.recordAttempt(
      type: 'QUIZ',
      score: _questions.isEmpty
          ? 0
          : ((_correctCount / _questions.length) * 100).round(),
      correctCount: _correctCount,
      totalCount: _questions.length,
      durationSeconds: _questions.length * 20,
      targetType: 'VOCABULARY_SET',
    );
    showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ResultSheet(
        correct: _correctCount,
        total: _questions.length,
        onContinue: () {
          Navigator.pop(ctx);
          widget.onFinish();
        },
      ),
    );
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _slideCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onFinish());
      return const Center(child: CircularProgressIndicator(color: _kAmber));
    }

    final q = _questions[_currentIndex];
    return Container(
      color: _kSurface,
      child: Column(
        children: [
          Expanded(
            child: SlideTransition(
              position: _slideAnim,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // ── Instruction ──
                    const Text(
                      'Chọn tiếng Trung bạn nghe thấy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _kInk,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // ── Audio prompt card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEDD8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SpeakerBtn(
                            label: '听',
                            color: _kAmber,
                            onTap: () => _speak(q.correct),
                          ),
                          const SizedBox(width: 16),
                          _SpeakerBtn(
                            label: '慢',
                            color: const Color(0xFF607D8B),
                            onTap: () => _speak(q.correct, slow: true),
                            slow: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Mascot panda ──
                    SizedBox(
                      height: 80,
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/mascot_panda.png',
                            height: 80,
                            errorBuilder: (context, error, stackTrace) =>
                                const _PandaFallback(),
                          ),
                          const SizedBox(width: 8),
                          AnimatedOpacity(
                            opacity: _isAnswered ? 1 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _isCorrect
                                    ? _kGreen.withValues(alpha: 0.12)
                                    : _kRed.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isCorrect
                                      ? _kGreen.withValues(alpha: 0.3)
                                      : _kRed.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                _isCorrect ? '🎉 Xuất sắc!' : '💪 Cố lên!',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: _isCorrect ? _kGreen : _kRed,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── 2×2 Answer grid ──
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        physics: const NeverScrollableScrollPhysics(),
                        children: q.options.map((opt) {
                          final optData = VocabDataHelper.getData(opt, {
                            'simplified': opt,
                            'forms': [],
                          });
                          final optPy = PinyinUtils.convertSpaced(
                            optData['pinyin'] as String? ?? '',
                          );
                          return _AnswerTile(
                            hanzi: opt,
                            pinyin: optPy,
                            state: _isAnswered
                                ? (opt == q.correct
                                      ? _TileState.correct
                                      : (opt == _selectedAnswer
                                            ? _TileState.wrong
                                            : _TileState.dim))
                                : _TileState.idle,
                            onTap: () => _selectAnswer(opt),
                            shakeAnim: opt == _selectedAnswer && !_isCorrect
                                ? _shakeAnim
                                : null,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom action button ──
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: _kSurface,
              border: const Border(
                top: BorderSide(color: Color(0xFFEAE0D4), width: 1),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isAnswered ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isAnswered
                      ? (_isCorrect ? _kGreen : _kAmber)
                      : Colors.grey.shade200,
                  foregroundColor: _isAnswered
                      ? Colors.white
                      : Colors.grey.shade400,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  _isAnswered
                      ? (_currentIndex >= _questions.length - 1
                            ? 'Hoàn thành 🎉'
                            : 'Bước tiếp theo')
                      : 'Chọn đáp án',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Answer Tile ──────────────────────────────────────────────────────────────
enum _TileState { idle, correct, wrong, dim }

class _AnswerTile extends StatelessWidget {
  final String hanzi;
  final String pinyin;
  final _TileState state;
  final VoidCallback onTap;
  final Animation<double>? shakeAnim;

  const _AnswerTile({
    required this.hanzi,
    required this.pinyin,
    required this.state,
    required this.onTap,
    this.shakeAnim,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = Colors.white;
    Color border = const Color(0xFFE0D4C8);
    Color textColor = _kInk;
    double borderWidth = 2;
    IconData? icon;

    switch (state) {
      case _TileState.correct:
        bg = const Color(0xFFE8F5E9);
        border = _kGreen;
        textColor = _kGreen;
        borderWidth = 3;
        icon = Icons.check_circle_rounded;
        break;
      case _TileState.wrong:
        bg = const Color(0xFFFFEBEE);
        border = _kRed;
        textColor = _kRed;
        borderWidth = 3;
        icon = Icons.cancel_rounded;
        break;
      case _TileState.dim:
        bg = Colors.grey.shade50;
        border = Colors.grey.shade200;
        textColor = Colors.grey.shade400;
        break;
      case _TileState.idle:
        break;
    }

    Widget tile = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: borderWidth),
          boxShadow: state == _TileState.idle
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (pinyin.isNotEmpty)
                    Text(
                      pinyin,
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withValues(alpha: 0.7),
                        letterSpacing: 0.3,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    hanzi,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            if (icon != null)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(icon, size: 20, color: textColor),
              ),
          ],
        ),
      ),
    );

    if (shakeAnim != null) {
      return AnimatedBuilder(
        animation: shakeAnim!,
        builder: (_, child) => Transform.translate(
          offset: Offset(sin(shakeAnim!.value * pi * 4) * 6, 0),
          child: child,
        ),
        child: tile,
      );
    }
    return tile;
  }
}

// ─── Speaker Button ───────────────────────────────────────────────────────────
class _SpeakerBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool slow;

  const _SpeakerBtn({
    required this.label,
    required this.color,
    required this.onTap,
    this.slow = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              slow ? Icons.slow_motion_video_rounded : Icons.volume_up_rounded,
              color: color,
              size: 30,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Panda Fallback ───────────────────────────────────────────────────────────
class _PandaFallback extends StatelessWidget {
  const _PandaFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _kAmber.withValues(alpha: 0.3), width: 2),
      ),
      child: const Center(child: Text('🐼', style: TextStyle(fontSize: 42))),
    );
  }
}

// ─── Question Model ───────────────────────────────────────────────────────────
class _QuizQuestion {
  final Map<String, dynamic> word;
  final List<String> options;
  final String correct;

  const _QuizQuestion({
    required this.word,
    required this.options,
    required this.correct,
  });
}

// ─── Result Sheet ─────────────────────────────────────────────────────────────
class _ResultSheet extends StatelessWidget {
  final int correct;
  final int total;
  final VoidCallback onContinue;

  const _ResultSheet({
    required this.correct,
    required this.total,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (correct / total * 100).round() : 0;
    final isPerfect = correct == total;
    final isGood = pct >= 70;
    final emoji = isPerfect
        ? '🏆'
        : isGood
        ? '🎉'
        : '💪';
    final msg = isPerfect
        ? 'Hoàn hảo! Bạn đã thuộc hết rồi!'
        : isGood
        ? 'Rất tốt! Hãy ôn lại các từ sai nhé!'
        : 'Cố lên! Hãy học lại chủ đề này!';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Big emoji
          Text(emoji, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 12),

          // Score circle
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isGood
                  ? _kGreen.withValues(alpha: 0.1)
                  : _kAmber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: isGood ? _kGreen : _kAmber, width: 3),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$pct%',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isGood ? _kGreen : _kAmber,
                  ),
                ),
                Text(
                  '$correct/$total đúng',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Text(
            msg,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _kInk,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: isGood ? _kGreen : _kAmber,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Quay lại bài học',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
