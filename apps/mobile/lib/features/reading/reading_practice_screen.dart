part of '../../main.dart';

class ReadingPracticeScreen extends StatefulWidget {
  const ReadingPracticeScreen({super.key});

  @override
  State<ReadingPracticeScreen> createState() => _ReadingPracticeScreenState();
}

String _formatArticleTime(String value) {
  final parsed = DateTime.tryParse(value);
  if (parsed == null) return value;
  final local = parsed.toLocal();
  final now = DateTime.now();
  final difference = now.difference(local);
  if (!difference.isNegative && difference.inMinutes < 60) {
    return '${max(1, difference.inMinutes)} phút trước';
  }
  if (!difference.isNegative && difference.inHours < 24) {
    return '${difference.inHours} giờ trước';
  }
  String twoDigits(int number) => number.toString().padLeft(2, '0');
  return '${twoDigits(local.hour)}:${twoDigits(local.minute)} · '
      '${twoDigits(local.day)}/${twoDigits(local.month)}/${local.year}';
}

class _ReadingPracticeScreenState extends State<ReadingPracticeScreen> {
  int _tab = 0;
  String _level = 'HSK 1';
  String _speakingTopic = 'Tất cả';
  String _newsSource = 'Tất cả';
  int _sentenceIndex = 0;
  bool _listening = false;
  String _recognized = '';
  int? _score;
  bool _contentLoading = true;
  List<SentencePractice> _practiceSentences = ReadingRepository.sentences;
  List<NewsArticleData> _articles = const [];
  List<VideoLessonData> _videoLessons = VideoRepository.lessons;
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.45);
    _loadContent();
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<void> _loadContent({bool includeLiveNews = false}) async {
    final results = await Future.wait([
      ReadingRepository.loadSentences(),
      ReadingRepository.loadArticles(includeLive: includeLiveNews),
      VideoRepository.loadLessons(),
    ]);
    if (!mounted) return;
    setState(() {
      _practiceSentences = results[0] as List<SentencePractice>;
      _articles = results[1] as List<NewsArticleData>;
      _videoLessons = results[2] as List<VideoLessonData>;
      _contentLoading = false;
    });
  }

  List<SentencePractice> get _sentences => _practiceSentences
      .where((sentence) => sentence.level == _level)
      .where(
        (sentence) =>
            _speakingTopic == 'Tất cả' || sentence.topic == _speakingTopic,
      )
      .toList();

  Future<void> _startListening(SentencePractice current) async {
    final available = await _speech.initialize();
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Trình duyệt chưa cấp quyền micro hoặc không hỗ trợ nhận dạng giọng nói.',
          ),
        ),
      );
      return;
    }
    setState(() {
      _listening = true;
      _recognized = '';
      _score = null;
    });
    await _speech.listen(
      localeId: 'zh-CN',
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      onResult: (result) {
        setState(() => _recognized = result.recognizedWords);
        if (result.finalResult) _finishPronunciation(current);
      },
    );
  }

  Future<void> _stopListening(SentencePractice current) async {
    await _speech.stop();
    _finishPronunciation(current);
  }

  void _finishPronunciation(SentencePractice current) {
    if (!mounted) return;
    final score = PronunciationScorer.score(current.cn, _recognized);
    setState(() {
      _listening = false;
      _score = score;
    });
    LearningProgressStore.recordSpeakingScore(score);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Luyện đọc và phát âm',
      subtitle: 'Đọc bài HSK ngắn, click từ chưa biết để xem pinyin và nghĩa.',
      trailing: IconButton.filledTonal(
        tooltip: 'Tải nguồn mới',
        onPressed: () {
          setState(() {
            _recognized = '';
            _score = null;
            _contentLoading = true;
          });
          _loadContent(includeLiveNews: true);
        },
        icon: const Icon(Icons.refresh),
      ),
      children: [
        SegmentTabs(
          labels: const ['Phát âm', 'Đọc hiểu', 'Video'],
          selectedIndex: _tab,
          onChanged: (index) => setState(() => _tab = index),
        ),
        const SizedBox(height: 16),
        if (_tab == 0) _buildPronunciation(),
        if (_tab == 1) _buildReadingList(),
        if (_tab == 2) _buildVideos(),
      ],
    );
  }

  Widget _buildPronunciation() {
    final sentences = _sentences;
    final topics = [
      'Tất cả',
      ..._practiceSentences
          .where((sentence) => sentence.level == _level)
          .map((sentence) => sentence.topic)
          .where((topic) => topic.isNotEmpty)
          .toSet(),
    ];
    if (!topics.contains(_speakingTopic)) _speakingTopic = 'Tất cả';
    return Column(
      children: [
        LevelSelector(
          levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
          selected: _level,
          onSelected: (level) => setState(() {
            _level = level;
            _sentenceIndex = 0;
            _recognized = '';
            _score = null;
            _speakingTopic = 'Tất cả';
          }),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: topics.map((topic) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  avatar: Icon(
                    topic == 'Tất cả'
                        ? Icons.apps_outlined
                        : Icons.forum_outlined,
                    size: 17,
                  ),
                  label: Text(topic),
                  selected: _speakingTopic == topic,
                  onSelected: (_) => setState(() {
                    _speakingTopic = topic;
                    _sentenceIndex = 0;
                    _recognized = '';
                    _score = null;
                  }),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        if (_contentLoading)
          const AppCard(child: Center(child: CircularProgressIndicator())),
        if (!_contentLoading && sentences.isEmpty)
          const EmptyState(
            icon: Icons.record_voice_over_outlined,
            title: 'Chưa có câu luyện',
            message: 'Dữ liệu luyện phát âm cho cấp này đang được cập nhật.',
          ),
        if (!_contentLoading && sentences.isNotEmpty)
          _PronunciationPracticeCard(
            current: sentences[_sentenceIndex % sentences.length],
            currentIndex: _sentenceIndex,
            total: sentences.length,
            listening: _listening,
            recognized: _recognized,
            score: _score,
            onSpeak: () =>
                _tts.speak(sentences[_sentenceIndex % sentences.length].cn),
            onRecord: () {
              final current = sentences[_sentenceIndex % sentences.length];
              return _listening
                  ? _stopListening(current)
                  : _startListening(current);
            },
            onNext: () => setState(() {
              _sentenceIndex++;
              _recognized = '';
              _score = null;
            }),
          ),
      ],
    );
  }

  Widget _buildReadingList() {
    final levelItems =
        _articles
            .where((article) => article.live || article.level == _level)
            .toList()
          ..sort((left, right) {
            if (left.live != right.live) return left.live ? 1 : -1;
            return right.publishedAt.compareTo(left.publishedAt);
          });
    final sources = [
      'Tất cả',
      ...levelItems.map((item) => item.source).toSet(),
    ];
    if (!sources.contains(_newsSource)) _newsSource = 'Tất cả';
    final items = levelItems
        .where(
          (article) => _newsSource == 'Tất cả' || article.source == _newsSource,
        )
        .toList();
    final liveCount = _articles.where((article) => article.live).length;
    return Column(
      children: [
        LevelSelector(
          levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
          selected: _level,
          onSelected: (level) => setState(() => _level = level),
        ),
        const SizedBox(height: 16),
        AppCard(
          color: const Color(0xFFEAF6F0),
          child: Row(
            children: [
              const Icon(Icons.menu_book_outlined, color: AppColors.jade),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  liveCount > 0
                      ? 'Đang có $liveCount nguồn mới từ RSS/API ở cuối danh sách. Bài HSK vẫn được ưu tiên để học dễ hơn.'
                      : 'Bài đọc được chia theo HSK, mỗi câu có thể nghe và bấm vào từ Hán để xem pinyin, nghĩa tiếng Việt.',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() => _contentLoading = true);
                  _loadContent(includeLiveNews: true);
                },
                icon: const Icon(Icons.sync),
                label: const Text('Nguồn mới'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: sources.map((source) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(source),
                  selected: _newsSource == source,
                  onSelected: (_) => setState(() => _newsSource = source),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 14),
        if (_contentLoading)
          const AppCard(child: Center(child: CircularProgressIndicator())),
        ...items.asMap().entries.map((entry) {
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: InkWell(
                onTap: () {
                  LearningProgressStore.recordReadingArticle(title: item.title);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => NewsArticleReaderScreen(article: item),
                    ),
                  );
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.blue.withValues(alpha: 0.12),
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusPill(
                                label: item.live ? 'Nguồn mới' : item.level,
                                color: item.live
                                    ? AppColors.jade
                                    : _levelColor(item.level),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.source,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (item.publishedAt.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_outlined,
                                  size: 15,
                                  color: AppColors.muted,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _formatArticleTime(item.publishedAt),
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (item.titleVi.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.titleVi,
                              style: const TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            item.summaryVi,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Nghe tiêu đề',
                      onPressed: () => _tts.speak(item.title),
                      icon: const Icon(Icons.volume_up_outlined),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (!_contentLoading && items.isEmpty)
          const EmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Chưa có bài đọc',
            message: 'Bài đọc cho cấp này đang được cập nhật.',
          ),
      ],
    );
  }

  Widget _buildVideos() {
    final lessons = _videoLessons
        .where((lesson) => lesson.level == _level)
        .toList();
    return Column(
      children: [
        LevelSelector(
          levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
          selected: _level,
          onSelected: (level) => setState(() => _level = level),
        ),
        const SizedBox(height: 16),
        ...lessons.map((lesson) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: VideoLessonCard(
              lesson: lesson,
              onOpen: () {
                LearningProgressStore.recordStudyMinutes(4);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoLessonDetailScreen(lesson: lesson),
                  ),
                );
              },
            ),
          );
        }),
        if (!_contentLoading && lessons.isEmpty)
          const EmptyState(
            icon: Icons.video_library_outlined,
            title: 'Chưa có video',
            message: 'Video cho cấp này đang được cập nhật.',
          ),
      ],
    );
  }
}

class _PronunciationPracticeCard extends StatelessWidget {
  const _PronunciationPracticeCard({
    required this.current,
    required this.currentIndex,
    required this.total,
    required this.listening,
    required this.recognized,
    required this.score,
    required this.onSpeak,
    required this.onRecord,
    required this.onNext,
  });

  final SentencePractice current;
  final int currentIndex;
  final int total;
  final bool listening;
  final String recognized;
  final int? score;
  final VoidCallback onSpeak;
  final Future<void> Function() onRecord;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          gradient: const LinearGradient(
            colors: [Color(0xFFEAF6F0), Color(0xFFFFF7E8)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  StatusPill(
                    icon: Icons.record_voice_over_outlined,
                    label: 'Câu ${currentIndex + 1}/$total',
                  ),
                  const Spacer(),
                  if (current.topic.isNotEmpty) ...[
                    Flexible(
                      child: StatusPill(
                        label: current.topic,
                        color: AppColors.jade,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  IconButton.filledTonal(
                    tooltip: 'Nghe mẫu',
                    onPressed: onSpeak,
                    icon: const Icon(Icons.volume_up_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                current.cn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                current.py,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                current.vi,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 26),
              GestureDetector(
                onTap: () => onRecord(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: listening ? AppColors.cinnabar : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (listening ? AppColors.cinnabar : AppColors.blue)
                            .withValues(alpha: 0.22),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    listening ? Icons.stop : Icons.mic,
                    size: 40,
                    color: listening ? Colors.white : AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                listening ? 'Đang nghe... bấm để dừng' : 'Bấm để bắt đầu đọc',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        if (recognized.isNotEmpty) ...[
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn đã đọc:',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recognized,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (score != null) ...[
          const SizedBox(height: 14),
          PronunciationScoreCard(score: score!, onNext: onNext),
        ],
      ],
    );
  }
}

class NewsArticleReaderScreen extends StatefulWidget {
  const NewsArticleReaderScreen({super.key, required this.article});

  final NewsArticleData article;

  @override
  State<NewsArticleReaderScreen> createState() =>
      _NewsArticleReaderScreenState();
}

class _NewsArticleReaderScreenState extends State<NewsArticleReaderScreen> {
  final FlutterTts _tts = FlutterTts();
  int _currentSentence = 0;
  late String _content;
  late List<ArticleSentenceData> _lines;
  bool _loadingFullArticle = false;

  @override
  void initState() {
    super.initState();
    _content = widget.article.content;
    _lines = widget.article.sentences.isEmpty
        ? ReadingRepository.buildStudyLines(_content)
        : widget.article.sentences;
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.45);
    DictionaryRepository.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
    _loadFullArticle();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _showWord(VocabEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.simplified,
                  style: const TextStyle(
                    fontFamily: 'NotoSansSC',
                    fontSize: 42,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    entry.pinyin,
                    style: const TextStyle(
                      color: AppColors.cinnabar,
                      fontSize: 18,
                      height: 1.35,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _tts.speak(entry.simplified),
                  icon: const Icon(Icons.volume_up_outlined),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              entry.meaning,
              style: const TextStyle(
                color: AppColors.ink,
                fontSize: 17,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadFullArticle() async {
    final link = widget.article.link;
    if (!widget.article.live || link == null || link.isEmpty) return;
    setState(() => _loadingFullArticle = true);
    try {
      final uri = Uri.parse(
        '${DictionaryRepository.apiBaseUrl}/reading/article',
      ).replace(queryParameters: {'url': link});
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) return;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) return;
      final fullContent = (decoded['content'] ?? '').toString().trim();
      if (fullContent.length <= _content.length + 80 || !mounted) return;
      setState(() {
        _content = fullContent;
        _lines = ReadingRepository.buildStudyLines(fullContent);
        _currentSentence = 0;
      });
    } catch (_) {
      // Keep the RSS summary when the publisher blocks article fetching.
    } finally {
      if (mounted) setState(() => _loadingFullArticle = false);
    }
  }

  List<InlineSpan> _buildSpans(String text) {
    final spans = <InlineSpan>[];
    var i = 0;
    while (i < text.length) {
      final char = text.substring(i, i + 1);
      if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(char)) {
        spans.add(TextSpan(text: char));
        i++;
        continue;
      }
      final entry = DictionaryRepository.lookupAt(text, i);
      if (entry == null) {
        spans.add(TextSpan(text: char));
        i++;
        continue;
      }
      final end = min(text.length, i + entry.simplified.length);
      final originalText = text.substring(i, end);
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.ideographic,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _showWord(entry),
            child: Text(
              originalText,
              style: const TextStyle(
                fontFamily: 'NotoSansSC',
                fontSize: 22,
                height: 1.7,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
      i = end;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.level),
        actions: [
          IconButton(
            tooltip: 'Nghe bài',
            onPressed: () => _tts.speak(_content),
            icon: const Icon(Icons.volume_up_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        children: [
          if (_loadingFullArticle) const LinearProgressIndicator(minHeight: 2),
          if (_loadingFullArticle) const SizedBox(height: 14),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusPill(
                        icon: Icons.newspaper_outlined,
                        label: widget.article.source,
                      ),
                      if (widget.article.live)
                        const StatusPill(
                          label: 'RSS/API',
                          color: AppColors.jade,
                        ),
                      if (widget.article.publishedAt.isNotEmpty)
                        StatusPill(
                          icon: Icons.schedule_outlined,
                          label: _formatArticleTime(widget.article.publishedAt),
                          color: AppColors.blue,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.article.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontFamily: 'NotoSansSC',
                      fontSize: 27,
                      height: 1.28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (widget.article.titleVi.isNotEmpty &&
                      !widget.article.live) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.article.titleVi,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  ..._lines.asMap().entries.map((entry) {
                    final index = entry.key;
                    final line = entry.value;
                    return ArticleSentenceCard(
                      index: index,
                      active: index == _currentSentence,
                      onSpeak: () {
                        setState(() => _currentSentence = index);
                        _tts.speak(line.cn);
                      },
                      spans: _buildSpans(line.cn),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleSentenceCard extends StatelessWidget {
  const ArticleSentenceCard({
    super.key,
    required this.index,
    required this.active,
    required this.spans,
    required this.onSpeak,
  });

  final int index;
  final bool active;
  final List<InlineSpan> spans;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: active
            ? AppColors.cinnabar.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: active
            ? Border.all(
                color: AppColors.cinnabar.withValues(alpha: 0.38),
                width: 1.2,
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Padding(
              padding: const EdgeInsets.only(top: 7),
              child: Text(
                '${index + 1}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: active ? AppColors.cinnabar : AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'NotoSansSC',
                  color: AppColors.ink,
                  fontSize: 22,
                  height: 1.72,
                  fontWeight: FontWeight.w500,
                ),
                children: spans,
              ),
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            tooltip: 'Nghe câu',
            visualDensity: VisualDensity.compact,
            onPressed: onSpeak,
            icon: Icon(
              Icons.volume_up_outlined,
              color: active ? AppColors.cinnabar : AppColors.muted,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }
}
