import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile/core/services/progress_service.dart';
import 'package:mobile/features/vocabulary/vocab_data_helper.dart';
import 'package:mobile/core/services/speech_service.dart';
import 'package:mobile/core/utils/pinyin_utils.dart';

class HanziiDetailPanel extends StatefulWidget {
  final Map<String, dynamic> wordData;
  final ValueChanged<String>? onSearchRelated;

  const HanziiDetailPanel({
    super.key,
    required this.wordData,
    this.onSearchRelated,
  });

  @override
  State<HanziiDetailPanel> createState() => _HanziiDetailPanelState();
}

class _HanziiDetailPanelState extends State<HanziiDetailPanel> {
  final FlutterTts _tts = FlutterTts();
  final ProgressService _progress = ProgressService();

  bool _isFavorite = false;
  bool _isListening = false;
  int? _pronScore;
  String _recognized = '';
  late Map<String, dynamic> _data;

  static const _cinnabar = Color(0xFFC63D33);
  static const _jade = Color(0xFF1F7A63);
  static const _amber = Color(0xFFE1A326);
  static const _ink = Color(0xFF18202A);
  static const _muted = Color(0xFF475569);
  static const _surface = Color(0xFFF7F4EF);

  @override
  void initState() {
    super.initState();
    _data = _buildData(widget.wordData);
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.5);
    _progress.isFavorite(_data['simplified']).then((v) {
      if (mounted) setState(() => _isFavorite = v);
    });
    // If no meaning or no examples yet, load asynchronously (because CC-CEDICT has no examples)
    if (_data['meaning'] == 'Đang tải...' ||
        (_data['examples'] as List).isEmpty) {
      VocabDataHelper.getDataAsync(_data['simplified'], widget.wordData).then((
        d,
      ) {
        if (mounted) setState(() => _data = _mergeData(_data, d));
      });
    }
  }

  @override
  void didUpdateWidget(HanziiDetailPanel old) {
    super.didUpdateWidget(old);
    if (old.wordData['simplified'] != widget.wordData['simplified']) {
      setState(() {
        _data = _buildData(widget.wordData);
        _pronScore = null;
        _recognized = '';
      });
      _progress.isFavorite(_data['simplified']).then((v) {
        if (mounted) setState(() => _isFavorite = v);
      });
      // Load async data for new word
      if (_data['meaning'] == 'Đang tải...' ||
          (_data['examples'] as List).isEmpty) {
        VocabDataHelper.getDataAsync(_data['simplified'], widget.wordData).then(
          (d) {
            if (mounted) setState(() => _data = _mergeData(_data, d));
          },
        );
      }
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Map<String, dynamic> _buildData(Map<String, dynamic> src) {
    return VocabDataHelper.getData(src['simplified'] ?? '', src);
  }

  Map<String, dynamic> _mergeData(
    Map<String, dynamic> base,
    Map<String, dynamic> update,
  ) {
    return {...base, ...update};
  }

  Future<void> _speak(String text) => _tts.speak(text);

  void _toggleFavorite() async {
    final word = _data['simplified'];
    await _progress.toggleFavorite(word);
    final v = await _progress.isFavorite(word);
    if (mounted) {
      setState(() => _isFavorite = v);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            v ? 'Đã lưu "$word" vào Sổ tay ⭐' : 'Đã xóa "$word" khỏi Sổ tay',
          ),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _ink,
        ),
      );
    }
  }

  Future<void> _checkPronunciation() async {
    if (!SpeechService.isSupported) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ Dùng Chrome để luyện phát âm.')),
      );
      return;
    }
    setState(() {
      _isListening = true;
      _pronScore = null;
      _recognized = '';
    });
    final result = await SpeechService.listen();
    if (mounted) {
      final score = SpeechService.calculateScore(_data['simplified'], result);
      setState(() {
        _isListening = false;
        _recognized = result;
        _pronScore = score;
      });
    }
  }

  Color _scoreColor(int s) => s >= 80
      ? _jade
      : s >= 50
      ? _amber
      : _cinnabar;
  String _scoreEmoji(int s) => s >= 90
      ? '🎉 Xuất sắc!'
      : s >= 70
      ? '👍 Tốt lắm!'
      : s >= 50
      ? '😊 Khá ổn!'
      : '💪 Thử lại!';

  @override
  Widget build(BuildContext context) {
    final simplified = _data['simplified'] as String? ?? '';
    final pinyinRaw = _data['pinyin'] as String? ?? '';
    final pinyin = PinyinUtils.convertSpaced(
      pinyinRaw,
    ); // "you2 yong3" → "yóu yǒng"
    final meaning = _data['meaning'] as String? ?? '';
    final hanViet = widget.wordData['hanViet'] as String? ?? '';
    final radical = widget.wordData['radical'] as String? ?? '';
    final wordType = widget.wordData['wordType'] as String? ?? '';
    final hskLevel = widget.wordData['hskLevel'];
    final examples =
        (_data['examples'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];

    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9E2D8)),
        ),
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────────────────────
            _buildHeader(
              simplified,
              pinyin,
              hanViet,
              wordType,
              hskLevel,
              meaning,
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0EBE5)),

            // ─── TabBar ──────────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: _cinnabar,
                unselectedLabelColor: _muted,
                indicatorColor: _cinnabar,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Từ điển'),
                  Tab(text: 'Hán tự'),
                  Tab(text: 'Phát âm'),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: Color(0xFFF0EBE5)),

            // ─── Content ─────────────────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  _buildDictionaryTab(
                    simplified,
                    meaning,
                    wordType,
                    radical,
                    hskLevel,
                    examples,
                  ),
                  _buildCharacterTab(simplified, pinyin, hanViet, radical),
                  _buildPronunciationTab(simplified),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header ──────────────────────────────────────────────────────────────
  Widget _buildHeader(
    String simplified,
    String pinyin,
    String hanViet,
    String wordType,
    dynamic hskLevel,
    String meaning,
  ) {
    final parsedHsk = int.tryParse('${hskLevel ?? 0}') ?? 0;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Big Hanzi
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.end,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        Text(
                          simplified,
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            color: _ink,
                            height: 1,
                          ),
                        ),
                        if (pinyin.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              pinyin,
                              style: const TextStyle(
                                fontSize: 26,
                                color: _cinnabar,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        if (parsedHsk > 0) _buildBadge('HSK $parsedHsk', _jade),
                      ],
                    ),
                    if (hanViet.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Hán Việt: $hanViet',
                          style: const TextStyle(fontSize: 13, color: _muted),
                        ),
                      ),
                  ],
                ),
              ),
              // Actions column
              Column(
                children: [
                  _iconBtn(
                    Icons.volume_up_rounded,
                    _amber,
                    () => _speak(simplified),
                    tooltip: 'Nghe phát âm',
                  ),
                  _iconBtn(
                    _isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    _isFavorite ? _cinnabar : Colors.grey,
                    _toggleFavorite,
                    tooltip: _isFavorite ? 'Xóa khỏi Sổ tay' : 'Lưu Sổ tay',
                  ),
                  _iconBtn(Icons.copy_rounded, Colors.grey, () {
                    Clipboard.setData(ClipboardData(text: simplified));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép'),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }, tooltip: 'Sao chép'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _iconBtn(
    IconData icon,
    Color color,
    VoidCallback onTap, {
    String? tooltip,
  }) {
    return IconButton(
      icon: Icon(icon, color: color),
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  // ─── Tab 1: Từ điển ─────────────────────────────────────────────────────
  Widget _buildDictionaryTab(
    String simplified,
    String meaning,
    String wordType,
    String radical,
    dynamic hskLevel,
    List<Map<String, dynamic>> examples,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Meaning card
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.translate_rounded,
                    size: 16,
                    color: _cinnabar,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Nghĩa tiếng Việt',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                meaning.isEmpty ? '...' : meaning,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              if (wordType.isNotEmpty) ...[
                const SizedBox(height: 8),
                _buildBadge(wordType, _muted),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Examples
        if (examples.isNotEmpty) ...[
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.format_quote_rounded,
                      size: 16,
                      color: _amber,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Ví dụ câu',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...examples.asMap().entries.map(
                  (e) => _buildExampleItem(e.key + 1, e.value, simplified),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Meta info (Radical only, hide HSK level per user request)
        if (radical.isNotEmpty)
          _sectionCard(
            child: _buildMetaItem(
              'Bộ thủ',
              radical,
              Icons.category_rounded,
              _cinnabar,
            ),
          ),
      ],
    );
  }

  Widget _buildExampleItem(
    int num,
    Map<String, dynamic> ex,
    String simplified,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => _speak(ex['cn'] ?? ''),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 2, right: 10),
                decoration: BoxDecoration(
                  color: _cinnabar.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$num',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _cinnabar,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _highlightHanzi(ex['cn'] ?? '', simplified),
                    const SizedBox(height: 3),
                    Text(
                      PinyinUtils.convert(ex['py'] ?? ''),
                      style: const TextStyle(fontSize: 13, color: _cinnabar),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ex['vi'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: _muted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if ((ex['source'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Nguồn: ${ex['source']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.volume_up_outlined,
                size: 18,
                color: Color(0xFFE7DDD0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlightHanzi(String text, String highlight) {
    if (highlight.isEmpty || !text.contains(highlight)) {
      return Text(
        text,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
      );
    }
    final parts = text.split(highlight);
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(TextSpan(text: parts[i]));
      }
      if (i < parts.length - 1) {
        spans.add(
          TextSpan(
            text: highlight,
            style: const TextStyle(
              color: _cinnabar,
              fontWeight: FontWeight.w800,
            ),
          ),
        );
      }
    }
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
        children: spans,
      ),
    );
  }

  Widget _buildMetaItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Tab 2: Hán tự ──────────────────────────────────────────────────────
  Widget _buildCharacterTab(
    String simplified,
    String pinyin,
    String hanViet,
    String radical,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Big character display
        _sectionCard(
          child: Row(
            children: [
              Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _cinnabar.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _cinnabar.withValues(alpha: 0.15)),
                ),
                child: Text(
                  simplified,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: _cinnabar,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _charInfo(
                      'Pinyin',
                      pinyin.isNotEmpty ? pinyin : 'â€”',
                      _cinnabar,
                    ),
                    const SizedBox(height: 10),
                    _charInfo(
                      'Hán Việt',
                      hanViet.isNotEmpty ? hanViet : 'â€”',
                      _jade,
                    ),
                    const SizedBox(height: 10),
                    _charInfo(
                      'Bộ thủ',
                      radical.isNotEmpty ? radical : 'â€”',
                      _amber,
                    ),
                    const SizedBox(height: 10),
                    _charInfo(
                      'Số nét',
                      widget.wordData['strokeCount'] != null &&
                              widget.wordData['strokeCount'] != 0
                          ? '${widget.wordData["strokeCount"]}'
                          : 'â€”',
                      _muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Stroke order placeholder
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.gesture_rounded, size: 16, color: _amber),
                  SizedBox(width: 6),
                  Text(
                    'Thứ tự nét vẽ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    5,
                    (i) => _strokeStep(simplified, i + 1),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Center(
                child: Text(
                  '(Tính năng hoạt ảnh nét vẽ đang phát triển)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Tip card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFECB3)),
          ),
          child: const Row(
            children: [
              Text('💡', style: TextStyle(fontSize: 18)),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mẹo học: Nhớ bộ thủ giúp đoán nghĩa và ghi nhớ từ mới nhanh hơn.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6D4C00),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _charInfo(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: _muted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _strokeStep(String char, int step) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: step == 1 ? _cinnabar.withValues(alpha: 0.1) : _surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: step == 1
                  ? _cinnabar.withValues(alpha: 0.4)
                  : const Color(0xFFE7DDD0),
            ),
          ),
          child: Text(
            char,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: step == 1 ? _cinnabar : _ink.withValues(alpha: 0.3),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('$step', style: const TextStyle(fontSize: 11, color: _muted)),
      ],
    );
  }

  // ─── Tab 3: Luyện phát âm ────────────────────────────────────────────────
  Widget _buildPronunciationTab(String simplified) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionCard(
          child: Column(
            children: [
              Text(
                simplified,
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _actionButton(
                    icon: Icons.volume_up_rounded,
                    label: 'Nghe mẫu',
                    color: _amber,
                    onTap: () => _speak(simplified),
                  ),
                  const SizedBox(width: 16),
                  _isListening
                      ? Container(
                          width: 120,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _cinnabar.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _cinnabar.withValues(alpha: 0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _cinnabar,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Đang nghe...',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _cinnabar,
                                ),
                              ),
                            ],
                          ),
                        )
                      : _actionButton(
                          icon: Icons.mic_rounded,
                          label: 'Luyện phát âm',
                          color: _cinnabar,
                          onTap: _checkPronunciation,
                        ),
                ],
              ),
            ],
          ),
        ),

        if (_pronScore != null) ...[
          const SizedBox(height: 12),
          _sectionCard(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_pronScore',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: _scoreColor(_pronScore!),
                      ),
                    ),
                    const Text(
                      '/100',
                      style: TextStyle(fontSize: 18, color: _muted),
                    ),
                  ],
                ),
                Text(
                  _scoreEmoji(_pronScore!),
                  style: const TextStyle(fontSize: 18),
                ),
                if (_recognized.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(),
                  const SizedBox(height: 10),
                  _pronRow('Bạn nói:', _recognized, _muted),
                  const SizedBox(height: 4),
                  _pronRow('Chuẩn:', simplified, _ink),
                ],
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (SpeechService.lastAudioUrl != null)
                      TextButton.icon(
                        onPressed: SpeechService.playLastRecording,
                        icon: const Icon(Icons.headphones_rounded, size: 16),
                        label: const Text('Nghe lại'),
                      ),
                    TextButton.icon(
                      onPressed: _checkPronunciation,
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Thử lại'),
                      style: TextButton.styleFrom(foregroundColor: _cinnabar),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 12),
        _sectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.tips_and_updates_rounded, size: 16, color: _jade),
                  SizedBox(width: 6),
                  Text(
                    'Cách luyện tập hiệu quả',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: _muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...[
                '1. Nghe mẫu ít nhất 3 lần trước khi phát âm.',
                '2. Chú ý thanh điệu (1-4, thanh nhẹ).',
                '3. Luyện từng âm tiết rồi ghép lại.',
                '4. Đạt 80+ điểm là phát âm tốt!',
              ].map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    tip,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _muted,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pronRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$label ', style: const TextStyle(fontSize: 13, color: _muted)),
        Text(
          '"$value"',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7DDD0)),
      ),
      child: child,
    );
  }
}
