part of '../../main.dart';

class FlashcardLessonScreen extends StatefulWidget {
  const FlashcardLessonScreen({
    super.key,
    required this.topic,
    required this.saved,
    required this.onToggleSaved,
  });

  final FlashcardTopic topic;
  final Set<String> saved;
  final ValueChanged<String> onToggleSaved;

  @override
  State<FlashcardLessonScreen> createState() => _FlashcardLessonScreenState();
}

class _FlashcardLessonScreenState extends State<FlashcardLessonScreen> {
  final PageController _pageController = PageController();
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  int _index = 0;
  int? _recordingIndex;
  bool _isScoringPronunciation = false;
  String _recognizedText = '';
  VideoPronunciationScore? _pronunciationScore;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.45);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _pageController.dispose();
    super.dispose();
  }

  void _clearPronunciationState() {
    _recordingIndex = null;
    _isScoringPronunciation = false;
    _recognizedText = '';
    _pronunciationScore = null;
  }

  Future<void> _togglePronunciation(VocabEntry word, int index) async {
    if (_recordingIndex == index) {
      await _stopPronunciation(word, index);
      return;
    }
    await _startPronunciation(word, index);
  }

  Future<void> _startPronunciation(VocabEntry word, int index) async {
    await _tts.stop();
    if (_recordingIndex != null) {
      await _speech.stop();
    }

    final available = await _speech.initialize();
    if (!mounted) return;
    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chưa bật được micro trên thiết bị này.')),
      );
      return;
    }

    setState(() {
      _recordingIndex = index;
      _isScoringPronunciation = false;
      _recognizedText = '';
      _pronunciationScore = null;
    });

    await _speech.listen(
      localeId: 'zh-CN',
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      listenOptions: stt.SpeechListenOptions(partialResults: true),
      onResult: (result) {
        if (!mounted || _index != index) return;
        setState(() => _recognizedText = result.recognizedWords.trim());
        if (result.finalResult) {
          unawaited(_stopPronunciation(word, index));
        }
      },
    );
  }

  Future<void> _stopPronunciation(VocabEntry word, int index) async {
    if (_recordingIndex != index || _isScoringPronunciation) return;
    await _speech.stop();
    if (!mounted) return;

    setState(() {
      _recordingIndex = null;
      _isScoringPronunciation = true;
    });

    final score = await _scoreFlashcardPronunciation(word, index);
    if (!mounted || _index != index) return;
    setState(() {
      _isScoringPronunciation = false;
      _pronunciationScore = score;
    });
    unawaited(LearningProgressStore.recordSpeakingScore(score.score));
  }

  Future<VideoPronunciationScore> _scoreFlashcardPronunciation(
    VocabEntry word,
    int index,
  ) async {
    final recognized = _recognizedText.trim();
    try {
      final response = await http
          .post(
            Uri.parse('${DictionaryRepository.apiBaseUrl}/pronunciation/score'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'target': word.simplified,
              'targetPinyin': word.pinyin,
              'recognized': recognized,
              'lessonId': 'flashcard:${widget.topic.id}',
              'lineIndex': index,
            }),
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return VideoPronunciationScore.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
      throw Exception('Pronunciation API ${response.statusCode}');
    } catch (error) {
      return VideoPronunciationScore.localFallback(
        target: word.simplified,
        targetPinyin: word.pinyin,
        recognized: recognized,
        error: error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.topic.words.length;
    final progress = (_index + 1) / total;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0E8),
      appBar: AppBar(
        title: Text(widget.topic.name),
        actions: [
          IconButton(
            tooltip: 'Quiz chủ đề',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FlashcardQuizScreen(topic: widget.topic),
              ),
            ),
            icon: const Icon(Icons.quiz_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_index + 1}/$total',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.line,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _levelColor(widget.topic.level),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: total,
              onPageChanged: (index) {
                _speech.stop();
                setState(() {
                  _index = index;
                  _clearPronunciationState();
                });
              },
              itemBuilder: (context, index) {
                final word = widget.topic.words[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: FlashcardView(
                    entry: word,
                    saved: widget.saved.contains(word.simplified),
                    isRecording: _recordingIndex == index,
                    isScoringPronunciation:
                        _isScoringPronunciation && _index == index,
                    recognizedText: _index == index ? _recognizedText : '',
                    pronunciationScore: _index == index
                        ? _pronunciationScore
                        : null,
                    onSpeak: () => _tts.speak(word.simplified),
                    onTogglePronunciation: () =>
                        _togglePronunciation(word, index),
                    onToggleSaved: () => widget.onToggleSaved(word.simplified),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _index == 0
                          ? null
                          : () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOut,
                            ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Trước'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _index == total - 1
                          ? () {
                              LearningProgressStore.recordStudyMinutes(5);
                              Navigator.pop(context);
                            }
                          : () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOut,
                            ),
                      icon: Icon(
                        _index == total - 1 ? Icons.check : Icons.arrow_forward,
                      ),
                      label: Text(_index == total - 1 ? 'Hoàn thành' : 'Tiếp'),
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
}

class FlashcardQuizScreen extends StatefulWidget {
  const FlashcardQuizScreen({super.key, required this.topic});

  final FlashcardTopic topic;

  @override
  State<FlashcardQuizScreen> createState() => _FlashcardQuizScreenState();
}

class _FlashcardQuizScreenState extends State<FlashcardQuizScreen> {
  late final List<VocabEntry> _questions;
  int _index = 0;
  int _score = 0;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _questions = [...widget.topic.words]..shuffle(Random());
  }

  List<String> get _choices {
    final current = _questions[_index];
    final distractors =
        widget.topic.words
            .where((word) => word.simplified != current.simplified)
            .map((word) => word.meaning)
            .toSet()
            .toList()
          ..shuffle(Random(current.simplified.hashCode));
    final choices = <String>[current.meaning, ...distractors.take(3)];
    choices.shuffle(Random(current.meaning.hashCode));
    return choices;
  }

  void _answer(String value) {
    if (_selected != null) return;
    final correct = value == _questions[_index].meaning;
    setState(() {
      _selected = value;
      if (correct) _score++;
    });
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      final score = _questions.isEmpty
          ? 0
          : ((_score / _questions.length) * 100).round();
      LearningProgressStore.recordQuizResult(
        score: score,
        correctCount: _score,
        totalCount: _questions.length,
      );
      ProgressService().recordAttempt(
        type: 'QUIZ',
        score: score,
        correctCount: _score,
        totalCount: _questions.length,
        durationSeconds: 300,
        targetType: 'TOPIC',
        targetId: widget.topic.id,
      );
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hoàn thành quiz'),
          content: Text('Bạn trả lời đúng $_score/${_questions.length} câu.'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Xong'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_index];
    final choices = _choices;
    return Scaffold(
      appBar: AppBar(title: Text('Quiz · ${widget.topic.name}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LinearProgressIndicator(value: (_index + 1) / _questions.length),
          const SizedBox(height: 28),
          Text(
            'Từ này có nghĩa là gì?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
          Text(
            current.simplified,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900),
          ),
          Text(
            current.pinyin,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.cinnabar,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 28),
          ...choices.map((choice) {
            final answered = _selected != null;
            final correct = choice == current.meaning;
            final selected = choice == _selected;
            final color = answered && correct
                ? AppColors.jade
                : answered && selected
                ? AppColors.cinnabar
                : AppColors.line;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: answered ? null : () => _answer(choice),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: color, width: selected ? 2 : 1),
                ),
                child: Text(choice),
              ),
            );
          }),
          if (_selected != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _next,
              icon: Icon(
                _index == _questions.length - 1
                    ? Icons.check
                    : Icons.arrow_forward,
              ),
              label: Text(
                _index == _questions.length - 1 ? 'Xem kết quả' : 'Câu tiếp',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
