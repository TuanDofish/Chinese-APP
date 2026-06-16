part of '../../main.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int _tab = 0;
  Set<String> _saved = {};

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await NotebookStore.load();
    if (mounted) setState(() => _saved = saved);
  }

  Future<void> _toggleSaved(String word) async {
    final wasSaved = _saved.contains(word);
    final saved = await NotebookStore.toggle(word);
    if (!wasSaved && saved.contains(word)) {
      final level = DictionaryRepository.lookupLocal(word)?.level ?? 'HSK 1';
      await LearningProgressStore.recordVocabularyWord(
        level: level,
        word: word,
      );
    }
    if (mounted) setState(() => _saved = saved);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Từ vựng HSK',
      subtitle:
          'Tra từ Trung - Việt, học flashcard theo chủ đề và quản lý sổ tay.',
      trailing: IconButton.filledTonal(
        tooltip: 'Đồng bộ sổ tay',
        onPressed: _loadSaved,
        icon: const Icon(Icons.cloud_sync_outlined),
      ),
      children: [
        SegmentTabs(
          labels: const ['Từ điển', 'Bài học', 'Sổ tay'],
          selectedIndex: _tab,
          onChanged: (index) => setState(() => _tab = index),
        ),
        const SizedBox(height: 16),
        if (_tab == 0)
          DictionaryPanel(saved: _saved, onToggleSaved: _toggleSaved),
        if (_tab == 1)
          FlashcardTopicsPanel(saved: _saved, onToggleSaved: _toggleSaved),
        if (_tab == 2)
          NotebookPanel(saved: _saved, onToggleSaved: _toggleSaved),
      ],
    );
  }
}

class DictionaryPanel extends StatefulWidget {
  const DictionaryPanel({
    super.key,
    required this.saved,
    required this.onToggleSaved,
  });

  final Set<String> saved;
  final ValueChanged<String> onToggleSaved;

  @override
  State<DictionaryPanel> createState() => _DictionaryPanelState();
}

class _DictionaryPanelState extends State<DictionaryPanel> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  VocabEntry? _result;
  bool _loading = false;
  bool _dictionaryReady = false;
  String _message = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    DictionaryRepository.ensureLoaded().then((_) {
      if (mounted) setState(() => _dictionaryReady = true);
    });
    _controller.addListener(() {
      _debounce?.cancel();
      final q = _controller.text.trim();
      if (q.isEmpty) return;
      _debounce = Timer(
        const Duration(milliseconds: 260),
        () => _search(q, quick: true),
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _search(String query, {bool quick = false}) async {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _message = '';
    });

    await DictionaryRepository.ensureLoaded();
    final local = DictionaryRepository.lookupLocal(q);
    if (local != null) {
      setState(() {
        _result = local;
        _loading = false;
      });
      return;
    }

    final remote = await DictionaryRepository.lookupRemote(q);
    if (!mounted) return;
    setState(() {
      _result = remote ?? local;
      _loading = false;
      _message = _result == null
          ? 'Không tìm thấy từ phù hợp. Hãy thử Hán tự, pinyin hoặc nghĩa tiếng Việt.'
          : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                decoration: InputDecoration(
                  hintText: _dictionaryReady
                      ? '突然 / học / xuexi'
                      : 'Đang nạp từ điển HSK...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.cinnabar,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Xóa',
                          icon: const Icon(Icons.cancel_rounded),
                          onPressed: () => setState(() {
                            _controller.clear();
                            _result = null;
                            _message = '';
                          }),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: _loading ? null : () => _search(_controller.text),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Tra'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Từ thịnh hành',
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DictionaryRepository.trending.map((word) {
            return ActionChip(
              label: Text(word),
              onPressed: () {
                _controller.text = word;
                _search(word);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        if (_message.isNotEmpty)
          EmptyState(
            icon: Icons.search_off,
            title: 'Chưa có kết quả',
            message: _message,
          ),
        if (_result != null)
          DictionaryResultCard(
            entry: _result!,
            saved: widget.saved.contains(_result!.simplified),
            onSpeak: () => _tts.speak(_result!.simplified),
            onToggleSaved: () => widget.onToggleSaved(_result!.simplified),
          ),
      ],
    );
  }
}

class DictionaryResultCard extends StatelessWidget {
  const DictionaryResultCard({
    super.key,
    required this.entry,
    required this.saved,
    required this.onSpeak,
    required this.onToggleSaved,
  });

  final VocabEntry entry;
  final bool saved;
  final VoidCallback onSpeak;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        entry.simplified,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        entry.pinyin,
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppColors.cinnabar,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Nghe phát âm',
                  onPressed: onSpeak,
                  icon: const Icon(
                    Icons.volume_up_outlined,
                    color: AppColors.amber,
                  ),
                ),
                IconButton(
                  tooltip: saved ? 'Bỏ khỏi sổ tay' : 'Lưu vào sổ tay',
                  onPressed: onToggleSaved,
                  icon: Icon(
                    saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? AppColors.cinnabar : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLine(
                  icon: Icons.translate,
                  label: 'Nghĩa tiếng Việt',
                  value: entry.meaning,
                ),
                if (entry.hanViet.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InfoLine(
                    icon: Icons.spellcheck,
                    label: 'Hán Việt',
                    value: entry.hanViet,
                  ),
                ],
                if (entry.wordType.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InfoLine(
                    icon: Icons.category_outlined,
                    label: 'Loại từ',
                    value: entry.wordType,
                  ),
                ],
                const SizedBox(height: 18),
                const Text(
                  'Ví dụ câu',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                ...entry.examples.map((ex) => ExampleTile(example: ex)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardTopicsPanel extends StatefulWidget {
  const FlashcardTopicsPanel({
    super.key,
    required this.saved,
    required this.onToggleSaved,
  });

  final Set<String> saved;
  final ValueChanged<String> onToggleSaved;

  @override
  State<FlashcardTopicsPanel> createState() => _FlashcardTopicsPanelState();
}

class _FlashcardTopicsPanelState extends State<FlashcardTopicsPanel> {
  String _level = 'HSK 1';
  late final Future<List<FlashcardTopic>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = FlashcardRepository.loadTopics();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlashcardTopic>>(
      future: _topicsFuture,
      builder: (context, snapshot) {
        final allTopics = snapshot.data ?? FlashcardRepository.fallbackTopics;
        final topics = allTopics
            .where((topic) => topic.level == _level)
            .toList();
        if (!snapshot.hasData && allTopics.isEmpty) {
          return const AppCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildTopicList(topics);
      },
    );
  }

  Widget _buildTopicList(List<FlashcardTopic> topics) {
    final allWords = topics
        .expand((topic) => topic.words.map((word) => word.simplified))
        .toSet();
    final learned = widget.saved.intersection(allWords).length;

    return Column(
      children: [
        LevelSelector(
          levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
          selected: _level,
          onSelected: (level) => setState(() => _level = level),
        ),
        const SizedBox(height: 16),
        AppCard(
          gradient: LinearGradient(
            colors: [
              _levelColor(_level).withValues(alpha: 0.86),
              _levelColor(_level).withValues(alpha: 0.68),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _level,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$learned/${allWords.length} từ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  StatusPill(
                    label:
                        '${allWords.isEmpty ? 0 : (learned / allWords.length * 100).round()}%',
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: allWords.isEmpty ? 0 : learned / allWords.length,
                  backgroundColor: Colors.white.withValues(alpha: 0.28),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Mỗi chủ đề là một bài học flashcard có ảnh, nghe mẫu và quiz ngắn.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...topics.map(
          (topic) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TopicCard(
              topic: topic,
              savedCount: topic.words
                  .where((word) => widget.saved.contains(word.simplified))
                  .length,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FlashcardLessonScreen(
                      topic: topic,
                      saved: widget.saved,
                      onToggleSaved: widget.onToggleSaved,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class NotebookPanel extends StatelessWidget {
  const NotebookPanel({
    super.key,
    required this.saved,
    required this.onToggleSaved,
  });

  final Set<String> saved;
  final ValueChanged<String> onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final words = saved
        .map(DictionaryRepository.lookupLocal)
        .whereType<VocabEntry>()
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          color: const Color(0xFFFFFAF0),
          child: Row(
            children: [
              const Icon(Icons.bookmark_added_outlined, color: AppColors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sổ tay hiện có ${saved.length} từ. Danh sách này được lưu tự động trên thiết bị.',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (words.isEmpty)
          const EmptyState(
            icon: Icons.bookmark_border,
            title: 'Chưa có từ nào',
            message: 'Hãy lưu từ khi tra cứu hoặc học theo chủ đề.',
          )
        else
          ...words.map(
            (word) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CompactWordCard(
                entry: word,
                onRemove: () => onToggleSaved(word.simplified),
              ),
            ),
          ),
      ],
    );
  }
}
