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
      title: 'Đọc hiểu và phát âm',
      subtitle: 'Bài học HSK có pinyin, nghĩa Việt, nghe từng câu và tra từ ngay trong bài.',
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
    final lessonItems = _articles
        .where(
          (article) =>
              !article.live &&
              article.level == _level &&
              article.sentences.length >= 4,
        )
        .toList()
      ..sort(
        (left, right) => right.sentences.length.compareTo(left.sentences.length),
      );
    final liveItems = _articles
        .where((article) => article.live && article.level == _level)
        .toList();
    final featured = lessonItems.isEmpty ? null : lessonItems.first;
    return Column(
      children: [
        LevelSelector(
          levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
          selected: _level,
          onSelected: (level) => setState(() => _level = level),
        ),
        const SizedBox(height: 16),
        AppCard(
          gradient: const LinearGradient(
            colors: [Color(0xFFEAF6F0), Color(0xFFFFF7E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_stories_outlined, color: AppColors.jade),
                  SizedBox(width: 10),
                  Text(
                    'Bài học đọc theo lộ trình',
                    style: TextStyle(
                      color: AppColors.ink,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Mỗi bài có câu tiếng Trung, pinyin, nghĩa Việt và tra từ ngay khi chạm vào chữ Hán.',
                style: TextStyle(
                  color: AppColors.muted,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_contentLoading)
          const AppCard(child: Center(child: CircularProgressIndicator())),
        if (!_contentLoading && featured != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ReadingFeaturedCard(
              item: featured,
              onOpen: () => _openReadingLesson(featured),
            ),
          ),
        if (!_contentLoading && lessonItems.length > 1)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Các bài cùng cấp',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        if (!_contentLoading && lessonItems.length > 1)
          const SizedBox(height: 10),
        ...lessonItems.skip(featured == null ? 0 : 1).map((item) {
          final sentenceCount = item.sentences.length;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openReadingLesson(item),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusPill(
                          label: item.level,
                          color: _levelColor(item.level),
                        ),
                        StatusPill(
                          icon: Icons.format_list_numbered_outlined,
                          label: '$sentenceCount câu',
                          color: AppColors.blue,
                        ),
                        StatusPill(
                          icon: Icons.schedule_outlined,
                          label: '${max(2, (sentenceCount / 2).ceil())} phút',
                          color: AppColors.plum,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'NotoSansSC',
                        fontSize: 21,
                        height: 1.32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    if (item.titleVi.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.titleVi,
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      item.summaryVi,
                      style: const TextStyle(
                        color: AppColors.muted,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _openReadingLesson(item),
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Bắt đầu học'),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Nghe tiêu đề',
                          onPressed: () => _tts.speak(item.title),
                          icon: const Icon(Icons.volume_up_outlined),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (!_contentLoading && liveItems.isNotEmpty) ...[
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Tin đọc thêm',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          ...liveItems.take(3).map(
                (item) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  leading: const Icon(Icons.rss_feed_outlined),
                  title: Text(
                    item.title,
                    style: const TextStyle(
                      fontFamily: 'NotoSansSC',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  subtitle: Text(item.source),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _openReadingLesson(item),
                ),
              ),
        ],
        if (!_contentLoading && lessonItems.isEmpty)
          const EmptyState(
            icon: Icons.menu_book_outlined,
            title: 'Bài học đọc đang được chuẩn bị',
            message: 'Hãy thử một cấp HSK khác hoặc cập nhật nội dung.',
          ),
      ],
    );
  }

  void _openReadingLesson(NewsArticleData item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NewsArticleReaderScreen(article: item)),
    );
  }

  Widget _buildVideos() {
    final lessons = _videoLessons
        .where((lesson) => lesson.level == _level)
        .where((lesson) => lesson.practiceReady)
        .toList()
      ..sort((left, right) {
        final bySentences = right.subtitles.length.compareTo(
          left.subtitles.length,
        );
        return bySentences != 0
            ? bySentences
            : right.transcriptSpanSeconds.compareTo(
                left.transcriptSpanSeconds,
              );
      });
    return Column(
      children: [
        LevelSelector(
          levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
          selected: _level,
          onSelected: (level) => setState(() => _level = level),
        ),
        const SizedBox(height: 16),
        const AppCard(
          color: Color(0xFFEAF6F0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_outlined, color: AppColors.jade),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Chỉ hiển thị video đã có phụ đề theo mốc thời gian, ít nhất 8 câu và đủ thời lượng để luyện shadowing.',
                  style: TextStyle(
                    color: AppColors.ink,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...lessons.map((lesson) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: VideoLessonCard(
              lesson: lesson,
              onOpen: () {
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
            title: 'Chưa có video sẵn sàng luyện',
            message:
                'Video cần có phụ đề theo mốc thời gian trước khi xuất hiện tại đây.',
          ),
      ],
    );
  }
}

class _ReadingFeaturedCard extends StatelessWidget {
  const _ReadingFeaturedCard({required this.item, required this.onOpen});

  final NewsArticleData item;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final sentenceCount = item.sentences.length;
    return AppCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF2E5950), Color(0xFF28443E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_outlined, color: Color(0xFFFFE1A8)),
              SizedBox(width: 8),
              Text(
                'Bài học đề xuất',
                style: TextStyle(
                  color: Color(0xFFFFE1A8),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: const TextStyle(
              fontFamily: 'NotoSansSC',
              color: Colors.white,
              fontSize: 27,
              height: 1.25,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (item.titleVi.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              item.titleVi,
              style: const TextStyle(
                color: Color(0xFFEAF6F0),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            item.summaryVi,
            style: const TextStyle(
              color: Color(0xFFE0ECE7),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _ReadingMetric(
                icon: Icons.format_list_numbered_outlined,
                label: '$sentenceCount câu',
              ),
              _ReadingMetric(
                icon: Icons.schedule_outlined,
                label: '${max(2, (sentenceCount / 2).ceil())} phút',
              ),
              const _ReadingMetric(
                icon: Icons.touch_app_outlined,
                label: 'Tra từ ngay',
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.ink,
            ),
            onPressed: onOpen,
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Vào bài học'),
          ),
        ],
      ),
    );
  }
}

class _ReadingMetric extends StatelessWidget {
  const _ReadingMetric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFFFE1A8), size: 17),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
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
                  fontFamily: 'NotoSansSC',
                  fontSize: 32,
                  height: 1.25,
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
                style: const TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
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
  late final DateTime _openedAt;
  int _currentSentence = 0;
  late String _content;
  late List<ArticleSentenceData> _lines;
  bool _loadingFullArticle = false;
  bool _showPinyin = true;
  bool _showVietnamese = true;

  @override
  void initState() {
    super.initState();
    _openedAt = DateTime.now();
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
    final elapsedMinutes = DateTime.now().difference(_openedAt).inMinutes;
    if (elapsedMinutes > 0) {
      unawaited(
        LearningProgressStore.recordReadingArticle(
          title: widget.article.title,
          minutes: elapsedMinutes.clamp(1, 60).toInt(),
        ),
      );
    }
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
                  style: HanziTextStyles.display.copyWith(
                    fontSize: 42,
                    height: 1.1,
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
              style: HanziTextStyles.reading,
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
                        label: widget.article.sourceLabel,
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
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
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
                  const SizedBox(height: 16),
                  AppCard(
                    color: const Color(0xFFF7F2EA),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.school_outlined,
                              color: AppColors.cinnabar,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tiến độ bài đọc: ${_lines.isEmpty ? 0 : _currentSentence + 1}/${_lines.length} câu',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            IconButton.filledTonal(
                              tooltip: 'Nghe toàn bài',
                              onPressed: () => _tts.speak(_content),
                              icon: const Icon(Icons.volume_up_outlined),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: _lines.isEmpty
                              ? 0
                              : (_currentSentence + 1) / _lines.length,
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.cinnabar,
                          backgroundColor: AppColors.line,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            FilterChip(
                              selected: _showPinyin,
                              showCheckmark: false,
                              label: const Text('Pinyin'),
                              onSelected: (value) =>
                                  setState(() => _showPinyin = value),
                            ),
                            FilterChip(
                              selected: _showVietnamese,
                              showCheckmark: false,
                              label: const Text('Nghĩa Việt'),
                              onSelected: (value) =>
                                  setState(() => _showVietnamese = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Chạm vào từ tiếng Trung để xem pinyin và nghĩa. Nghe từng câu rồi đọc theo trước khi sang câu tiếp.',
                    style: TextStyle(
                      color: AppColors.muted,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._lines.asMap().entries.map((entry) {
                    final index = entry.key;
                    final line = entry.value;
                    return ArticleSentenceCard(
                      index: index,
                      active: index == _currentSentence,
                      pinyin: line.py,
                      translation: line.vi,
                      showPinyin: _showPinyin,
                      showVietnamese: _showVietnamese,
                      onSelect: () =>
                          setState(() => _currentSentence = index),
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
    required this.pinyin,
    required this.translation,
    required this.showPinyin,
    required this.showVietnamese,
    required this.onSelect,
    required this.onSpeak,
  });

  final int index;
  final bool active;
  final List<InlineSpan> spans;
  final String pinyin;
  final String translation;
  final bool showPinyin;
  final bool showVietnamese;
  final VoidCallback onSelect;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onSelect,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: HanziTextStyles.reading,
                      children: spans,
                    ),
                  ),
                  if (showPinyin && pinyin.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        pinyin,
                        style: HanziTextStyles.pinyin,
                      ),
                    ),
                  if (showVietnamese && translation.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        translation,
                        style: HanziTextStyles.translation.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  else if (showVietnamese)
                    const Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Text(
                        'Bản dịch đang được cập nhật.',
                        style: TextStyle(
                          color: AppColors.muted,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
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
      ),
    );
  }
}
