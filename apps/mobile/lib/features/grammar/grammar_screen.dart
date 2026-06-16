part of '../../main.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  int _tab = 0;
  String _level = 'HSK 1';
  final TextEditingController _controller = TextEditingController(
    text: '我不学校去',
  );
  GrammarCheckResult? _result;
  bool _checking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checking = true;
      _result = null;
    });
    GrammarCheckResult result;
    try {
      final ai = await GrammarAiService.checkGrammar(text);
      result = _grammarResultFromAi(ai, text);
    } catch (error) {
      result = _aiUnavailableResult(text, error);
    }
    await LearningProgressStore.recordGrammarCheck(text, result);
    if (!mounted) return;
    setState(() {
      _result = result;
      _checking = false;
    });
  }

  GrammarCheckResult _aiUnavailableResult(String text, Object error) {
    final local = GrammarChecker.check(text);
    return GrammarCheckResult(
      score: 0,
      title: 'Chưa chấm được bằng AI',
      summary:
          'Backend AI chưa phản hồi nên app không tự cho điểm thay Gemini.',
      correction: local.correction,
      explanation:
          'Gợi ý nội bộ: ${local.summary} Cấu hình và chạy backend port 3001 với GEMINI_API_KEY để nhận điểm AI thật.',
      errors: [
        'Lỗi kết nối AI: $error',
        ...local.errors.map((item) => 'Gợi ý nội bộ: $item'),
      ],
      source: 'local',
      provider: 'Bộ quy tắc nội bộ',
      suggestions: local.correction.isEmpty ? const [] : [local.correction],
    );
  }

  GrammarCheckResult _grammarResultFromAi(
    Map<String, dynamic> data,
    String original,
  ) {
    final rawScore = data['score'];
    final score = rawScore is num ? rawScore.round().clamp(0, 100) : 0;
    final correction = data['correction'];
    final correctionCn = correction is Map
        ? (correction['cn'] ?? correction['chinese'] ?? original).toString()
        : (data['correctionCn'] ?? data['corrected'] ?? original).toString();
    final correctionVi = correction is Map
        ? (correction['vi'] ?? '').toString()
        : (data['vi'] ?? '').toString();
    final errors = <String>[];
    final rawErrors = data['errors'];
    if (rawErrors is List) {
      for (final item in rawErrors) {
        if (item is Map) {
          final type = (item['type'] ?? 'Lỗi').toString();
          final explanation = (item['explanation'] ?? item['message'] ?? '')
              .toString();
          final fix = (item['fix'] ?? item['suggestion'] ?? '').toString();
          errors.add(
            [
              type,
              explanation,
              fix,
            ].where((part) => part.trim().isNotEmpty).join(': '),
          );
        } else {
          errors.add(item.toString());
        }
      }
    }
    final isCorrect = score > 0 && (data['isCorrect'] == true || score >= 85);
    final suggestions = <String>[];
    final rawSuggestions = data['suggestions'];
    if (rawSuggestions is List) {
      for (final item in rawSuggestions) {
        if (item is Map) {
          final cn = (item['cn'] ?? item['chinese'] ?? '').toString();
          final py = (item['py'] ?? item['pinyin'] ?? '').toString();
          final vi = (item['vi'] ?? item['meaning'] ?? item['note'] ?? '')
              .toString();
          suggestions.add(
            [cn, py, vi].where((part) => part.trim().isNotEmpty).join('\n'),
          );
        } else {
          suggestions.add(item.toString());
        }
      }
    }
    final source = (data['source'] ?? '').toString();
    final provider = (data['provider'] ?? 'Google Gemini').toString();
    final model = (data['model'] ?? '').toString();
    return GrammarCheckResult(
      score: score,
      title: isCorrect ? 'AI chấm: câu dùng được' : 'AI chấm: cần chỉnh',
      summary:
          (data['summary'] ??
                  data['style_tips'] ??
                  (isCorrect
                      ? 'AI không phát hiện lỗi lớn.'
                      : 'AI phát hiện điểm cần chỉnh.'))
              .toString(),
      correction: correctionCn,
      explanation: correctionVi.isNotEmpty
          ? correctionVi
          : (data['explanation'] ?? data['style_tips'] ?? '').toString(),
      errors: errors,
      source: source.isEmpty ? 'gemini' : source,
      provider: model.isEmpty ? provider : '$provider · $model',
      suggestions: suggestions.where((item) => item.trim().isNotEmpty).toList(),
    );
  }

  void _showHistory() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: FutureBuilder<List<GrammarHistoryItem>>(
              future: LearningProgressStore.loadGrammarHistory(),
              builder: (context, snapshot) {
                final items = snapshot.data ?? const <GrammarHistoryItem>[];
                if (!snapshot.hasData) {
                  return const SizedBox(
                    height: 180,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history,
                    title: 'Chưa có lịch sử',
                    message: 'Các câu đã kiểm tra sẽ xuất hiện tại đây.',
                  );
                }
                return SizedBox(
                  height: min(520, MediaQuery.of(context).size.height * 0.72),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lịch sử kiểm tra',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      StatusPill(
                                        label: '${item.score}/100',
                                        color: item.score >= 85
                                            ? AppColors.jade
                                            : item.score >= 60
                                            ? AppColors.amber
                                            : AppColors.cinnabar,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          item.dateLabel,
                                          style: const TextStyle(
                                            color: AppColors.muted,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item.input,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.correction,
                                    style: const TextStyle(
                                      color: AppColors.jade,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Ngữ pháp và AI',
      subtitle: 'Xem mẫu câu theo HSK, nhập câu tiếng Trung để nhận phản hồi.',
      trailing: IconButton.filledTonal(
        tooltip: 'Lịch sử kiểm tra',
        onPressed: _showHistory,
        icon: const Icon(Icons.history),
      ),
      children: [
        SegmentTabs(
          labels: const ['Bài học', 'AI kiểm tra'],
          selectedIndex: _tab,
          onChanged: (index) => setState(() => _tab = index),
        ),
        const SizedBox(height: 16),
        if (_tab == 0) _buildLessons(),
        if (_tab == 1) _buildChecker(),
      ],
    );
  }

  Widget _buildLessons() {
    return FutureBuilder<List<GrammarLessonData>>(
      future: GrammarRepository.loadLessons(),
      builder: (context, snapshot) {
        final lessons = (snapshot.data ?? GrammarRepository.lessons)
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
            if (!snapshot.hasData)
              const AppCard(child: Center(child: CircularProgressIndicator())),
            ...lessons.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GrammarLessonCard(
                  index: entry.key + 1,
                  lesson: entry.value,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChecker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.blue),
                  SizedBox(width: 8),
                  Text(
                    'AI sửa câu tiếng Trung',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Nhập câu cần kiểm tra, ví dụ: 我不学校去',
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _checking ? null : _check,
                icon: _checking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.fact_check_outlined),
                label: Text(
                  _checking ? 'Đang kiểm tra...' : 'Kiểm tra ngữ pháp',
                ),
              ),
            ],
          ),
        ),
        if (_result != null) ...[
          const SizedBox(height: 16),
          GrammarResultCard(result: _result!),
        ],
      ],
    );
  }
}
