part of '../../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<LearningProgressSnapshot> _snapshotFuture;
  Timer? _studyTimer;

  @override
  void initState() {
    super.initState();
    _snapshotFuture = LearningProgressStore.loadSnapshot();
    _studyTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      LearningProgressStore.recordStudyMinutes(1).then((_) {
        if (mounted) _refresh();
      });
    });
  }

  @override
  void dispose() {
    _studyTimer?.cancel();
    super.dispose();
  }

  void _refresh() {
    setState(() {
      _snapshotFuture = LearningProgressStore.loadSnapshot();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<LearningProgressSnapshot>(
      future: _snapshotFuture,
      builder: (context, snapshot) {
        final progress = snapshot.data ?? LearningProgressSnapshot.empty;
        return ScreenShell(
          title: 'Hôm nay học gì?',
          subtitle:
              '${progress.targetLevel}, mục tiêu ${progress.dailyGoalMinutes} phút và ${progress.dailyGoalWords} từ mới.',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton.filledTonal(
                tooltip: 'Làm mới',
                onPressed: _refresh,
                icon: const Icon(Icons.sync),
              ),
              const SizedBox(width: 8),
              const UserAvatar(),
            ],
          ),
          children: [
            AppCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFFAF1E6), Color(0xFFE7F2EC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 12,
                    top: -26,
                    child: Text(
                      '语',
                      style: TextStyle(
                        fontSize: 144,
                        fontWeight: FontWeight.w900,
                        color: AppColors.cinnabar.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusPill(
                        icon: Icons.flag_outlined,
                        label: 'Đang học ${progress.targetLevel}',
                      ),
                      const SizedBox(height: 18),
                      Text(
                        progress.todayWords == 0 &&
                                progress.studyMinutesToday == 0
                            ? 'Bắt đầu một phiên học mới'
                            : 'Tiếp tục nhịp học hôm nay',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(progress.todaySummary),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          FilledButton.icon(
                            onPressed: () => widget.onOpenTab(1),
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Học tiếp'),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => widget.onOpenTab(2),
                            icon: const Icon(Icons.fact_check_outlined),
                            label: const Text('Kiểm tra câu'),
                          ),
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => MiniGameScreen(
                                    level: progress.targetLevel,
                                    vocabList: List.generate(30, (i) {
                                      final items =
                                          DictionaryRepository.allEntries;
                                      if (items.isEmpty) return {};
                                      final item = items[i % items.length];
                                      return {
                                        'simplified': item.simplified,
                                        'pinyin': item.pinyin,
                                        'meaning': item.meaning,
                                      };
                                    }),
                                  ),
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFF0932B),
                            ),
                            icon: const Icon(Icons.sports_esports),
                            label: const Text('Chơi Mini Game'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            MetricWrap(
              metrics: [
                DashboardMetric(
                  '${progress.streakDays}',
                  'Ngày streak',
                  Icons.local_fire_department_outlined,
                  AppColors.cinnabar,
                ),
                DashboardMetric(
                  progress.wordsLabel,
                  'Từ hôm nay',
                  Icons.style_outlined,
                  AppColors.jade,
                ),
                DashboardMetric(
                  '${progress.studyMinutesToday} phút',
                  'Thời gian học',
                  Icons.timer_outlined,
                  AppColors.amber,
                ),
                DashboardMetric(
                  '${progress.grammarChecksToday}',
                  'Lượt sửa câu',
                  Icons.auto_fix_high_outlined,
                  AppColors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Tính năng chính',
              subtitle:
                  'Từ điển, flashcard, ngữ pháp, đọc, phát âm và hồ sơ học tập.',
            ),
            FeatureGrid(
              items: [
                FeatureItem(
                  'Từ vựng HSK',
                  'Tra từ, học theo chủ đề và lưu sổ tay.',
                  Icons.translate,
                  AppColors.cinnabar,
                  () => widget.onOpenTab(1),
                ),
                FeatureItem(
                  'Ngữ pháp',
                  'Xem mẫu câu, kiểm tra bằng AI hoặc quy tắc nội bộ.',
                  Icons.psychology_alt_outlined,
                  AppColors.blue,
                  () => widget.onOpenTab(2),
                ),
                FeatureItem(
                  'Phát âm',
                  'Nghe mẫu, ghi âm và nhận điểm tương đồng.',
                  Icons.mic_none,
                  AppColors.jade,
                  () => widget.onOpenTab(3),
                ),
                FeatureItem(
                  'Đọc và video',
                  'Đọc câu theo HSK, luyện phụ đề video ngắn.',
                  Icons.ondemand_video_outlined,
                  AppColors.plum,
                  () => widget.onOpenTab(3),
                ),
                FeatureItem(
                  'Gia sư AI',
                  'Hỏi đáp, sửa câu và tạo hội thoại theo trình độ.',
                  Icons.forum_outlined,
                  AppColors.amber,
                  () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          AiTutorScreen(level: progress.targetLevel),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Tiến độ học tập',
              subtitle:
                  'Theo dõi nhịp học 7 ngày, kỹ năng và lộ trình HSK của bạn.',
            ),
            LearningJourneyDashboard(
              progress: progress,
              onOpenVocabulary: () => widget.onOpenTab(1),
              onOpenPractice: () => widget.onOpenTab(2),
            ),
          ],
        );
      },
    );
  }
}

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key, required this.level});

  final String level;

  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<({String role, String text})> _messages = [
    (
      role: 'assistant',
      text:
          'Chào bạn. Hãy gửi một câu tiếng Trung, yêu cầu tạo hội thoại hoặc hỏi về từ vựng.',
    ),
  ];
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final message = (preset ?? _controller.text).trim();
    if (message.isEmpty || _sending) return;
    _controller.clear();
    setState(() {
      _messages.add((role: 'user', text: message));
      _sending = true;
    });
    try {
      final response = await _postAiChat({
        'message': message,
        'level': widget.level,
        'history': _messages
            .take(_messages.length - 1)
            .map((item) => {'role': item.role, 'text': item.text})
            .toList(),
      });
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          data is Map
              ? data['message'] ?? 'AI chưa phản hồi.'
              : 'AI chưa phản hồi.',
        );
      }
      final reply = data is Map ? (data['reply'] ?? '').toString() : '';
      if (!mounted) return;
      setState(() {
        _messages.add((
          role: 'assistant',
          text: reply.isEmpty ? 'AI chưa trả về nội dung.' : reply,
        ));
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _messages.add((
          role: 'assistant',
          text: 'Chưa kết nối được gia sư AI: $error',
        ));
      });
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  Future<http.Response> _postAiChat(Map<String, dynamic> payload) async {
    Object? lastError;
    for (final endpoint in _aiChatEndpoints()) {
      try {
        return await http
            .post(
              endpoint,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 20));
      } catch (error) {
        lastError = error;
      }
    }
    throw Exception(
      'Không tìm thấy backend AI tại localhost:3001 hoặc 127.0.0.1:3001. '
      'Hãy chạy API NestJS trước khi dùng Gia sư AI. Chi tiết: $lastError',
    );
  }

  List<Uri> _aiChatEndpoints() {
    final configured = DictionaryRepository.apiBaseUrl.trim();
    final candidates = <String>[
      configured,
      if (configured.contains('localhost'))
        configured.replaceFirst('localhost', '127.0.0.1'),
      if (configured.contains('127.0.0.1'))
        configured.replaceFirst('127.0.0.1', 'localhost'),
      'http://127.0.0.1:3001',
      'http://localhost:3001',
    ];
    final seen = <String>{};
    return candidates
        .map(
          (base) =>
              base.endsWith('/') ? base.substring(0, base.length - 1) : base,
        )
        .where((base) => base.isNotEmpty && seen.add(base))
        .map((base) => Uri.parse('$base/ai/chat'))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Gia sư AI · ${widget.level}')),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              scrollDirection: Axis.horizontal,
              children: [
                ActionChip(
                  label: const Text('Sửa câu của tôi'),
                  onPressed: () => _send('Hãy cho tôi một bài luyện sửa câu.'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Hội thoại ngắn'),
                  onPressed: () =>
                      _send('Tạo một hội thoại ngắn phù hợp ${widget.level}.'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Ôn từ hôm nay'),
                  onPressed: () =>
                      _send('Cho tôi một mini quiz từ vựng ${widget.level}.'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final item = _messages[index];
                final user = item.role == 'user';
                return Align(
                  alignment: user
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 560),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: user
                          ? AppColors.cinnabar
                          : const Color(0xFFF4EFE8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(
                      item.text,
                      style: TextStyle(
                        color: user ? Colors.white : AppColors.ink,
                        height: 1.5,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Nhập câu hỏi hoặc câu tiếng Trung...',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    tooltip: 'Gửi',
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
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
