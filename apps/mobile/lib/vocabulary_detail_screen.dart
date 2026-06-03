import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'progress_service.dart';
import 'vocab_data_helper.dart';
import 'pinyin_utils.dart';

// ─── Color constants ────────────────────────────────────────────────────────
const _kAmber = Color(0xFFFFA726);
const _kAmberDeep = Color(0xFFEF6C00);
const _kSurface = Color(0xFFF8F0E8); // warm cream background
const _kCard = Color(0xFFFFFFFF);
const _kInk = Color(0xFF1A1A2E);
const _kMuted = Color(0xFF94A3B8);
const _kGreen = Color(0xFF4CAF50);

// ─── Main Flashcard Widget ──────────────────────────────────────────────────
class VocabularyDetailScreen extends StatefulWidget {
  final Map<String, dynamic> word;
  final VoidCallback onNext;
  final bool showPinyin;

  const VocabularyDetailScreen({
    super.key,
    required this.word,
    required this.onNext,
    required this.showPinyin,
  });

  @override
  State<VocabularyDetailScreen> createState() => _VocabularyDetailScreenState();
}

class _VocabularyDetailScreenState extends State<VocabularyDetailScreen>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final ProgressService _progressService = ProgressService();
  bool _isFavorite = false;
  late Map<String, dynamic> _data;
  bool _isSpeaking = false;

  // Entrance animation
  late AnimationController _enterCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _initTts();
    _initAnimations();
    _loadData();
  }

  void _initAnimations() {
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
    _enterCtrl.forward();
  }

  @override
  void didUpdateWidget(VocabularyDetailScreen old) {
    super.didUpdateWidget(old);
    if (old.word['simplified'] != widget.word['simplified']) {
      _enterCtrl.reset();
      _enterCtrl.forward();
      _loadData();
    }
  }

  void _loadData() {
    _data = VocabDataHelper.getData(widget.word['simplified'] ?? '', widget.word);
    _progressService.isFavorite(widget.word['simplified'] ?? '').then((v) {
      if (mounted) setState(() => _isFavorite = v);
    });
    if (_data['meaning'] == 'Đang tải...' || (_data['examples'] as List? ?? []).isEmpty) {
      VocabDataHelper.getDataAsync(widget.word['simplified'] ?? '', widget.word).then((d) {
        if (mounted) setState(() => _data = {..._data, ...d});
      });
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("zh-CN");
    await _tts.setSpeechRate(0.5);
  }

  Future<void> _speak(String text, {bool slow = false}) async {
    setState(() => _isSpeaking = true);
    await _tts.setSpeechRate(slow ? 0.2 : 0.5);
    await _tts.speak(text);
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _handleNext() {
    _progressService.markAsLearned(_data['simplified'] ?? '');
    widget.onNext();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final simplified = _data['simplified'] as String? ?? '';
    final pinyinRaw = _data['pinyin'] as String? ?? '';
    final pinyin = PinyinUtils.convertSpaced(pinyinRaw);
    final meaning = _data['meaning'] as String? ?? '';
    final wordType = _data['wordType'] as String? ?? '';
    final examples = (_data['examples'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ?? [];

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Container(
          color: _kSurface,
          child: Column(
            children: [
              // ── Scrollable body ──
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),

                      // ── Illustration box ──
                      _IllustrationBox(simplified: simplified),
                      const SizedBox(height: 20),

                      // ── Pinyin ──
                      if (widget.showPinyin && pinyin.isNotEmpty)
                        Text(
                          pinyin,
                          style: const TextStyle(
                            fontSize: 22,
                            color: _kMuted,
                            letterSpacing: 0.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 6),

                      // ── Big Hanzi ──
                      Text(
                        simplified,
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          color: _kInk,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Audio buttons ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _AudioBtn(
                            icon: Icons.volume_up_rounded,
                            color: _kAmber,
                            onTap: () => _speak(simplified),
                            tooltip: 'Nghe bình thường',
                          ),
                          const SizedBox(width: 14),
                          _AudioBtn(
                            icon: Icons.speed_rounded,
                            color: const Color(0xFF78909C),
                            onTap: () => _speak(simplified, slow: true),
                            tooltip: 'Nghe chậm',
                            slow: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Meaning card ──
                      _MeaningCard(
                        wordType: wordType,
                        meaning: meaning,
                        simplified: simplified,
                        examples: examples,
                        onSpeak: _speak,
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // ── Bottom action ──
              _BottomBar(
                isFavorite: _isFavorite,
                onFavorite: () async {
                  await _progressService.toggleFavorite(simplified);
                  final v = await _progressService.isFavorite(simplified);
                  if (mounted) {
                    setState(() => _isFavorite = v);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(v ? 'Đã lưu "$simplified" vào Sổ tay ⭐' : 'Đã xóa khỏi Sổ tay'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: _kInk,
                    ));
                  }
                },
                onNext: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Illustration Box ────────────────────────────────────────────────────────
class _IllustrationBox extends StatelessWidget {
  final String simplified;
  const _IllustrationBox({required this.simplified});

  // Map simple emoji/icon for common words
  static const Map<String, IconData> _iconMap = {
    '我': Icons.person_outline_rounded,
    '你': Icons.person_outline_rounded,
    '他': Icons.man_outlined,
    '她': Icons.woman_outlined,
    '我们': Icons.group_outlined,
    '你好': Icons.waving_hand_outlined,
    '谢谢': Icons.favorite_outline_rounded,
    '猫': Icons.pets_outlined,
    '狗': Icons.pets_outlined,
    '书': Icons.menu_book_rounded,
    '吃': Icons.restaurant_outlined,
    '喝': Icons.local_cafe_outlined,
    '水': Icons.water_drop_outlined,
    '学习': Icons.school_outlined,
    '老师': Icons.school_outlined,
    '朋友': Icons.group_outlined,
    '妈妈': Icons.woman_rounded,
    '爸爸': Icons.man_rounded,
    '家': Icons.home_outlined,
    '工作': Icons.work_outline_rounded,
    '钱': Icons.attach_money_rounded,
    '睡觉': Icons.bedtime_outlined,
  };

  static const Map<String, String> _imageMap = {
    '中国': 'assets/images/words/china.png',
    '美国': 'assets/images/words/united-states-of-america.png',
    '英国': 'assets/images/words/united-kingdom.png',
    '德国': 'assets/images/words/germany.png',
    '日本': 'assets/images/words/japan.png',
    '越南': 'assets/images/words/vietnam.png',
  };

  @override
  Widget build(BuildContext context) {
    final icon = _iconMap[simplified] ?? Icons.auto_awesome_outlined;
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEDD8), Color(0xFFFFF4E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft circles for depth
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _kAmber.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -10,
              bottom: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _kAmber.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            if (_imageMap.containsKey(simplified))
              Image.asset(
                _imageMap[simplified]!,
                height: 116,
                fit: BoxFit.contain,
              )
            else
              Image.asset(
                'assets/images/flashcards/$simplified.png',
                height: 140,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 82, color: _kAmber.withOpacity(0.72)),
                    const SizedBox(height: 8),
                    Text(
                      simplified,
                      style: TextStyle(
                        color: _kAmberDeep.withOpacity(0.7),
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Audio Button ────────────────────────────────────────────────────────────
class _AudioBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;
  final bool slow;

  const _AudioBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
    this.slow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: slow
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.volume_up_rounded, color: color, size: 28),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.slow_motion_video, size: 10, color: Colors.white),
                        ),
                      ),
                    ],
                  )
                : Icon(icon, color: color, size: 28),
          ),
        ),
      ),
    );
  }
}

// ─── Meaning Card ────────────────────────────────────────────────────────────
class _MeaningCard extends StatelessWidget {
  final String wordType;
  final String meaning;
  final String simplified;
  final List<Map<String, dynamic>> examples;
  final Future<void> Function(String, {bool slow}) onSpeak;

  const _MeaningCard({
    required this.wordType,
    required this.meaning,
    required this.simplified,
    required this.examples,
    required this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Word type + meaning
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (wordType.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _kAmber.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    wordType,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _kAmberDeep,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (wordType.isNotEmpty) const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meaning,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _kInk),
                ),
              ),
            ],
          ),

          if (examples.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0EBE5)),
            const SizedBox(height: 12),
            Text(
              'Cụm từ kết hợp:',
              style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ...examples.take(3).map((ex) => _ExampleRow(ex: ex, simplified: simplified, onSpeak: onSpeak)),
          ],
        ],
      ),
    );
  }
}

// ─── Example Row ─────────────────────────────────────────────────────────────
class _ExampleRow extends StatelessWidget {
  final Map<String, dynamic> ex;
  final String simplified;
  final Future<void> Function(String, {bool slow}) onSpeak;

  const _ExampleRow({required this.ex, required this.simplified, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final cn = ex['cn'] as String? ?? '';
    final py = ex['py'] as String? ?? '';
    final vi = ex['vi'] as String? ?? '';
    final source = ex['source'] as String? ?? '';

    // Highlight the target word in the sentence
    List<TextSpan> spans = [];
    if (cn.contains(simplified) && simplified.isNotEmpty) {
      final parts = cn.split(simplified);
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(text: parts[i], style: const TextStyle(color: _kInk)));
        }
        if (i < parts.length - 1) {
          spans.add(TextSpan(
            text: simplified,
            style: const TextStyle(color: _kAmber, fontWeight: FontWeight.w800),
          ));
        }
      }
    } else {
      spans.add(TextSpan(text: cn, style: const TextStyle(color: _kInk)));
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (py.isNotEmpty)
                  Text(
                    py,
                    style: const TextStyle(fontSize: 11, color: _kMuted, letterSpacing: 0.4),
                  ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    children: spans,
                  ),
                ),
                if (vi.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      vi,
                      style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                    ),
                  ),
                if (source.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      'Nguồn: $source',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Speaker buttons
          GestureDetector(
            onTap: () => onSpeak(cn),
            child: Icon(Icons.volume_up_outlined, size: 18, color: Colors.grey[400]),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onSpeak(cn, slow: true),
            child: Icon(Icons.slow_motion_video_outlined, size: 18, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Bar ──────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onNext;

  const _BottomBar({
    required this.isFavorite,
    required this.onFavorite,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      decoration: BoxDecoration(
        color: _kSurface,
        border: const Border(top: BorderSide(color: Color(0xFFEAE0D4), width: 1)),
      ),
      child: Row(
        children: [
          // Favorite icon button
          GestureDetector(
            onTap: onFavorite,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isFavorite ? _kAmber.withOpacity(0.12) : Colors.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFavorite ? _kAmber.withOpacity(0.4) : Colors.grey.shade300,
                ),
              ),
              child: Icon(
                isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isFavorite ? _kAmber : Colors.grey[400],
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Next button
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAmber,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Bước tiếp theo',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
