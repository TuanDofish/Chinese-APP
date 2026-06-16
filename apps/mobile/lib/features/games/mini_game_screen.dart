import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

// ─── Models ──────────────────────────────────────────────────────────────────

class GameWord {
  final String simplified;
  final String pinyin;
  final String meaning;

  const GameWord({
    required this.simplified,
    required this.pinyin,
    required this.meaning,
  });
}

// ─── Main Game Screen ────────────────────────────────────────────────────────

class MiniGameScreen extends StatefulWidget {
  final String level;
  final List<Map<String, dynamic>> vocabList;

  const MiniGameScreen({
    super.key,
    required this.level,
    required this.vocabList,
  });

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen>
    with TickerProviderStateMixin {
  int _currentGame = 0;
  int _totalScore = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _questionsAnswered = 0;
  int _correctAnswers = 0;
  bool _gameFinished = false;
  final int _totalQuestions = 10;

  late List<GameWord> _words;
  late AnimationController _shakeController;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  // Game types
  static const int _matchingGame = 0;
  static const int _fillGame = 1;
  static const int _listenGame = 2;
  static const int _orderGame = 3;

  @override
  void initState() {
    super.initState();
    _words = _prepareWords();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _bounceAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
  }

  List<GameWord> _prepareWords() {
    final all = widget.vocabList
        .where(
          (w) =>
              (w['simplified'] ?? '').toString().isNotEmpty &&
              (w['meaning'] ?? '').toString().isNotEmpty,
        )
        .map(
          (w) => GameWord(
            simplified: w['simplified'] ?? '',
            pinyin: w['pinyin'] ?? '',
            meaning: w['meaning'] ?? '',
          ),
        )
        .toList();
    all.shuffle(Random());
    return all.take(40).toList(); // pool of words
  }

  void _onCorrect() {
    setState(() {
      _correctAnswers++;
      _streak++;
      if (_streak > _bestStreak) _bestStreak = _streak;
      _totalScore += 10 + (_streak > 3 ? (_streak - 3) * 5 : 0);
      _questionsAnswered++;
    });
    _bounceController.reset();
    _bounceController.forward();
    _checkFinish();
  }

  void _onWrong() {
    setState(() {
      _streak = 0;
      _questionsAnswered++;
    });
    _shakeController.reset();
    _shakeController.forward();
    _checkFinish();
  }

  void _checkFinish() {
    if (_questionsAnswered >= _totalQuestions) {
      setState(() => _gameFinished = true);
    }
  }

  void _nextGame() {
    setState(() {
      _currentGame = (_currentGame + 1) % 4;
    });
  }

  void _restart() {
    setState(() {
      _words = _prepareWords();
      _currentGame = 0;
      _totalScore = 0;
      _streak = 0;
      _bestStreak = 0;
      _questionsAnswered = 0;
      _correctAnswers = 0;
      _gameFinished = false;
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            // Progress bar
            _buildProgressBar(),
            // Score & streak
            _buildScoreRow(),
            // Game content
            Expanded(
              child: _gameFinished ? _buildResults() : _buildCurrentGame(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Mini Game · ${widget.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$_totalScore',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = _questionsAnswered / _totalQuestions;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: Colors.white.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation<Color>(
            progress < 0.5
                ? const Color(0xFF4CAF50)
                : progress < 0.8
                ? const Color(0xFFFFC107)
                : const Color(0xFFFF5722),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Text(
            '$_questionsAnswered/$_totalQuestions',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const Spacer(),
          if (_streak >= 2)
            AnimatedBuilder(
              animation: _bounceAnim,
              builder: (_, child) => Transform.scale(
                scale: 1.0 + _bounceAnim.value * 0.2,
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B35), Color(0xFFFF4444)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '$_streak streak!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentGame() {
    final gameType = _currentGame % 4;
    switch (gameType) {
      case _matchingGame:
        return _MatchingGameWidget(
          words: _words,
          questionIndex: _questionsAnswered,
          onCorrect: () {
            _onCorrect();
            _nextGame();
          },
          onWrong: () {
            _onWrong();
            _nextGame();
          },
        );
      case _fillGame:
        return _FillInGameWidget(
          words: _words,
          questionIndex: _questionsAnswered,
          onCorrect: () {
            _onCorrect();
            _nextGame();
          },
          onWrong: () {
            _onWrong();
            _nextGame();
          },
        );
      case _listenGame:
        return _ListenChooseGameWidget(
          words: _words,
          questionIndex: _questionsAnswered,
          onCorrect: () {
            _onCorrect();
            _nextGame();
          },
          onWrong: () {
            _onWrong();
            _nextGame();
          },
        );
      case _orderGame:
        return _SentenceOrderGameWidget(
          words: _words,
          questionIndex: _questionsAnswered,
          onCorrect: () {
            _onCorrect();
            _nextGame();
          },
          onWrong: () {
            _onWrong();
            _nextGame();
          },
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildResults() {
    final percent = ((_correctAnswers / _totalQuestions) * 100).round();
    final grade = percent >= 90
        ? '🏆 Xuất sắc!'
        : percent >= 70
        ? '🌟 Tốt lắm!'
        : percent >= 50
        ? '👍 Khá ổn!'
        : '💪 Cần luyện thêm!';
    final gradeColor = percent >= 90
        ? Colors.amber
        : percent >= 70
        ? Colors.green
        : percent >= 50
        ? Colors.orange
        : Colors.red;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              grade,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: gradeColor,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gradeColor, width: 4),
                color: gradeColor.withOpacity(0.1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: gradeColor,
                    ),
                  ),
                  Text(
                    '$_correctAnswers/$_totalQuestions',
                    style: TextStyle(fontSize: 14, color: gradeColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem(
                    Icons.star_rounded,
                    Colors.amber,
                    '$_totalScore',
                    'Điểm',
                  ),
                  _statItem(
                    Icons.local_fire_department,
                    Colors.orange,
                    '$_bestStreak',
                    'Best Streak',
                  ),
                  _statItem(
                    Icons.check_circle_outline,
                    Colors.green,
                    '$_correctAnswers',
                    'Đúng',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _restart,
                icon: const Icon(Icons.replay_rounded),
                label: const Text(
                  'Chơi lại',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gradeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Quay lại',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(IconData icon, Color color, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GAME 1: Matching - Choose the correct meaning
// ═══════════════════════════════════════════════════════════════════════════════

class _MatchingGameWidget extends StatefulWidget {
  final List<GameWord> words;
  final int questionIndex;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const _MatchingGameWidget({
    required this.words,
    required this.questionIndex,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<_MatchingGameWidget> createState() => _MatchingGameWidgetState();
}

class _MatchingGameWidgetState extends State<_MatchingGameWidget> {
  late GameWord _target;
  late List<String> _options;
  int? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    final idx = widget.questionIndex % widget.words.length;
    _target = widget.words[idx];
    final others = widget.words
        .where((w) => w.simplified != _target.simplified)
        .toList();
    others.shuffle(Random());
    _options = [_target.meaning, ...others.take(3).map((w) => w.meaning)];
    _options.shuffle(Random());
    _selected = null;
    _answered = false;
  }

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
    });
    final correct = _options[i] == _target.meaning;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (correct) {
        widget.onCorrect();
      } else {
        widget.onWrong();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '🎯 Ghép nghĩa',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Từ này có nghĩa gì?',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 16),
          Text(
            _target.simplified,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          if (_target.pinyin.isNotEmpty)
            Text(
              _target.pinyin,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.amber,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 32),
          ...List.generate(_options.length, (i) {
            final isCorrect = _options[i] == _target.meaning;
            final isSelected = _selected == i;
            Color bgColor = Colors.white.withOpacity(0.06);
            Color borderColor = Colors.white.withOpacity(0.15);
            Color textColor = Colors.white;

            if (_answered) {
              if (isCorrect) {
                bgColor = Colors.green.withOpacity(0.2);
                borderColor = Colors.green;
              } else if (isSelected) {
                bgColor = Colors.red.withOpacity(0.2);
                borderColor = Colors.red;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _select(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: bgColor,
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: _answered && isCorrect
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: 16,
                                )
                              : _answered && isSelected
                              ? const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 16,
                                )
                              : Text(
                                  '${String.fromCharCode(65 + i)}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          _options[i],
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GAME 2: Fill in the blank - Type the Hanzi
// ═══════════════════════════════════════════════════════════════════════════════

class _FillInGameWidget extends StatefulWidget {
  final List<GameWord> words;
  final int questionIndex;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const _FillInGameWidget({
    required this.words,
    required this.questionIndex,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<_FillInGameWidget> createState() => _FillInGameWidgetState();
}

class _FillInGameWidgetState extends State<_FillInGameWidget> {
  late GameWord _target;
  late List<String> _charOptions;
  String _answer = '';
  bool _answered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    final idx = (widget.questionIndex + 2) % widget.words.length;
    _target = widget.words[idx];
    // Create character options from the target + random chars
    final targetChars = _target.simplified.split('');
    final allChars = widget.words
        .expand((w) => w.simplified.split(''))
        .toSet()
        .where((c) => !targetChars.contains(c))
        .toList();
    allChars.shuffle(Random());
    final extraChars = allChars.take(4).toList();
    _charOptions = [...targetChars, ...extraChars];
    _charOptions.shuffle(Random());
    _answer = '';
    _answered = false;
    _isCorrect = false;
  }

  void _tapChar(String ch) {
    if (_answered) return;
    setState(() => _answer += ch);
    if (_answer.length >= _target.simplified.length) {
      _check();
    }
  }

  void _removeChar() {
    if (_answered || _answer.isEmpty) return;
    setState(() => _answer = _answer.substring(0, _answer.length - 1));
  }

  void _check() {
    setState(() {
      _answered = true;
      _isCorrect = _answer == _target.simplified;
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_isCorrect) {
        widget.onCorrect();
      } else {
        widget.onWrong();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '✏️ Viết Hán tự',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Chọn đúng Hán tự cho nghĩa sau:',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Text(
            _target.meaning,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (_target.pinyin.isNotEmpty)
            Text(
              _target.pinyin,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.amber,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 24),
          // Answer area
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: _answered
                  ? (_isCorrect
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15))
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _answered
                    ? (_isCorrect ? Colors.green : Colors.red)
                    : Colors.white.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _answer.isEmpty ? '_ ' * _target.simplified.length : _answer,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: _answer.isEmpty ? Colors.white24 : Colors.white,
                    letterSpacing: 8,
                  ),
                ),
                if (_answer.isNotEmpty && !_answered)
                  IconButton(
                    onPressed: _removeChar,
                    icon: const Icon(
                      Icons.backspace_outlined,
                      color: Colors.white54,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          if (_answered && !_isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'Đáp án: ${_target.simplified}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Character options
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: _charOptions.map((ch) {
              return GestureDetector(
                onTap: () => _tapChar(ch),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      ch,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GAME 3: Listen and Choose
// ═══════════════════════════════════════════════════════════════════════════════

class _ListenChooseGameWidget extends StatefulWidget {
  final List<GameWord> words;
  final int questionIndex;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const _ListenChooseGameWidget({
    required this.words,
    required this.questionIndex,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<_ListenChooseGameWidget> createState() =>
      _ListenChooseGameWidgetState();
}

class _ListenChooseGameWidgetState extends State<_ListenChooseGameWidget> {
  final FlutterTts _tts = FlutterTts();
  late GameWord _target;
  late List<GameWord> _options;
  int? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.45);
    _setup();
  }

  void _setup() {
    final idx = (widget.questionIndex + 1) % widget.words.length;
    _target = widget.words[idx];
    final others = widget.words
        .where((w) => w.simplified != _target.simplified)
        .toList();
    others.shuffle(Random());
    _options = [_target, ...others.take(3)];
    _options.shuffle(Random());
    _selected = null;
    _answered = false;

    Future.delayed(const Duration(milliseconds: 500), () {
      _tts.speak(_target.simplified);
    });
  }

  void _select(int i) {
    if (_answered) return;
    setState(() {
      _selected = i;
      _answered = true;
    });
    final correct = _options[i].simplified == _target.simplified;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (correct) {
        widget.onCorrect();
      } else {
        widget.onWrong();
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '🎧 Nghe và chọn',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Nghe và chọn đúng từ bạn nghe được:',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 24),
          // Play button
          GestureDetector(
            onTap: () => _tts.speak(_target.simplified),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.volume_up_rounded,
                color: Colors.white,
                size: 44,
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _tts.speak(_target.simplified),
            child: const Text(
              'Nghe lại',
              style: TextStyle(color: Colors.green),
            ),
          ),
          const SizedBox(height: 20),
          // Options grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.6,
            children: List.generate(_options.length, (i) {
              final opt = _options[i];
              final isCorrect = opt.simplified == _target.simplified;
              final isSelected = _selected == i;
              Color bgColor = Colors.white.withOpacity(0.06);
              Color borderColor = Colors.white.withOpacity(0.15);

              if (_answered) {
                if (isCorrect) {
                  bgColor = Colors.green.withOpacity(0.2);
                  borderColor = Colors.green;
                } else if (isSelected) {
                  bgColor = Colors.red.withOpacity(0.2);
                  borderColor = Colors.red;
                }
              }

              return GestureDetector(
                onTap: () => _select(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        opt.simplified,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        opt.meaning,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// GAME 4: Sentence Order - Arrange characters
// ═══════════════════════════════════════════════════════════════════════════════

class _SentenceOrderGameWidget extends StatefulWidget {
  final List<GameWord> words;
  final int questionIndex;
  final VoidCallback onCorrect;
  final VoidCallback onWrong;

  const _SentenceOrderGameWidget({
    required this.words,
    required this.questionIndex,
    required this.onCorrect,
    required this.onWrong,
  });

  @override
  State<_SentenceOrderGameWidget> createState() =>
      _SentenceOrderGameWidgetState();
}

class _SentenceOrderGameWidgetState extends State<_SentenceOrderGameWidget> {
  late GameWord _target;
  late List<String> _shuffledChars;
  List<String> _arranged = [];
  bool _answered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  void _setup() {
    final idx = (widget.questionIndex + 3) % widget.words.length;
    _target = widget.words[idx];
    _shuffledChars = _target.simplified.split('');
    // Only shuffle if more than 1 char
    if (_shuffledChars.length > 1) {
      // Ensure shuffled != original
      do {
        _shuffledChars.shuffle(Random());
      } while (_shuffledChars.join() == _target.simplified &&
          _shuffledChars.length > 1);
    }
    _arranged = [];
    _answered = false;
    _isCorrect = false;
  }

  void _tapChar(int i) {
    if (_answered) return;
    setState(() {
      _arranged.add(_shuffledChars[i]);
      _shuffledChars = List.from(_shuffledChars)..removeAt(i);
    });
    if (_shuffledChars.isEmpty) _check();
  }

  void _removeArranged(int i) {
    if (_answered) return;
    setState(() {
      _shuffledChars.add(_arranged[i]);
      _arranged = List.from(_arranged)..removeAt(i);
    });
  }

  void _check() {
    setState(() {
      _answered = true;
      _isCorrect = _arranged.join() == _target.simplified;
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (_isCorrect) {
        widget.onCorrect();
      } else {
        widget.onWrong();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // For single-char words, just auto-correct
    if (_target.simplified.length <= 1) {
      Future.microtask(() => widget.onCorrect());
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '🧩 Sắp xếp từ',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sắp xếp đúng thứ tự Hán tự:',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            _target.meaning,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          if (_target.pinyin.isNotEmpty)
            Text(
              _target.pinyin,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.amber,
                fontStyle: FontStyle.italic,
              ),
            ),
          const SizedBox(height: 28),
          // Arranged area
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _answered
                  ? (_isCorrect
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15))
                  : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _answered
                    ? (_isCorrect ? Colors.green : Colors.red)
                    : Colors.white.withOpacity(0.15),
                width: 2,
              ),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _arranged.isEmpty
                  ? [
                      Text(
                        'Chạm vào các chữ bên dưới',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 14,
                        ),
                      ),
                    ]
                  : List.generate(_arranged.length, (i) {
                      return GestureDetector(
                        onTap: () => _removeArranged(i),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _arranged[i],
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
            ),
          ),
          if (_answered && !_isCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'Đáp án: ${_target.simplified}',
              style: const TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Shuffled chars
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: List.generate(_shuffledChars.length, (i) {
              return GestureDetector(
                onTap: () => _tapChar(i),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _shuffledChars[i],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
