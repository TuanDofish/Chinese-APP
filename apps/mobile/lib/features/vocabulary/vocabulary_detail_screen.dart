import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mobile/core/services/progress_service.dart';
import 'package:mobile/features/vocabulary/vocab_data_helper.dart';
import 'package:mobile/core/utils/pinyin_utils.dart';

// ─── Color constants ────────────────────────────────────────────────────────
const _kAmber = Color(0xFFFFA726);
const _kAmberDeep = Color(0xFFEF6C00);
const _kSurface = Color(0xFFF8F0E8); // warm cream background
const _kCard = Color(0xFFFFFFFF);
const _kInk = Color(0xFF1A1A2E);
const _kMuted = Color(0xFF475569);
const _kCinnabar = Color(0xFFC83E35);

// ─── Pexels keyword mapping for common Chinese words ────────────────────────
const Map<String, String> _pexelsKeywords = {
  '爸爸': 'father family',
  '妈妈': 'mother family',
  '家': 'home house',
  '猫': 'cat',
  '狗': 'dog',
  '书': 'book reading',
  '吃': 'eating food',
  '喝': 'drinking',
  '水': 'water',
  '学习': 'study learning',
  '老师': 'teacher classroom',
  '朋友': 'friends',
  '工作': 'working office',
  '睡觉': 'sleeping bed',
  '中国': 'china',
  '美国': 'america',
  '越南': 'vietnam',
  '日本': 'japan',
  '学校': 'school',
  '医院': 'hospital',
  '饭店': 'restaurant',
  '电影': 'movie cinema',
  '音乐': 'music',
  '天气': 'weather sky',
  '花': 'flower',
  '树': 'tree nature',
  '山': 'mountain',
  '海': 'ocean sea',
  '鱼': 'fish',
  '鸟': 'bird',
  '车': 'car vehicle',
  '飞机': 'airplane',
  '火车': 'train',
  '手机': 'smartphone',
  '电脑': 'computer laptop',
  '衣服': 'clothes fashion',
  '水果': 'fruits',
  '蔬菜': 'vegetables',
  '早上': 'morning sunrise',
  '晚上': 'night city',
  '春天': 'spring flowers',
  '夏天': 'summer beach',
  '秋天': 'autumn leaves',
  '冬天': 'winter snow',
  '运动': 'sports exercise',
  '跑步': 'running jogging',
  '游泳': 'swimming pool',
  '唱歌': 'singing',
  '跳舞': 'dancing',
  '画画': 'painting art',
  '旅游': 'travel',
  '咖啡': 'coffee',
  '茶': 'tea',
  '苹果': 'apple fruit',
  '米饭': 'rice food',
  '面条': 'noodles',
  '生日': 'birthday celebration',
  '圣诞': 'christmas',
  '新年': 'new year celebration',
  '太阳': 'sun sunshine',
  '月亮': 'moon night',
  '星星': 'stars sky',
  '雨': 'rain',
  '雪': 'snow',
};

/// Get a Pexels search keyword for a Chinese word
String _getPexelsQuery(String simplified, String meaning) {
  if (_pexelsKeywords.containsKey(simplified)) {
    return _pexelsKeywords[simplified]!;
  }
  // Use meaning as fallback, take first meaningful word
  final cleaned = meaning
      .replaceAll(RegExp(r'[,;/，；、]'), ' ')
      .split(' ')
      .where((w) => w.length > 1)
      .take(2)
      .join(' ');
  return cleaned.isNotEmpty ? cleaned : 'chinese culture';
}

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
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut));
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
    _data = VocabDataHelper.getData(
      widget.word['simplified'] ?? '',
      widget.word,
    );
    _progressService.isFavorite(widget.word['simplified'] ?? '').then((v) {
      if (mounted) setState(() => _isFavorite = v);
    });
    if (_data['meaning'] == 'Đang tải...' ||
        (_data['examples'] as List? ?? []).isEmpty) {
      VocabDataHelper.getDataAsync(
        widget.word['simplified'] ?? '',
        widget.word,
      ).then((d) {
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
    final examples =
        (_data['examples'] as List?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];

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
                      const SizedBox(height: 12),

                      // ── TOP: Pexels Image ──
                      _PexelsImageBox(simplified: simplified, meaning: meaning),
                      const SizedBox(height: 20),

                      // ── Hanzi + Pinyin + Meaning Card ──
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: _kCard,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Big Hanzi
                            Text(
                              simplified,
                              style: const TextStyle(
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                                color: _kInk,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Pinyin
                            if (widget.showPinyin && pinyin.isNotEmpty)
                              Text(
                                pinyin,
                                style: const TextStyle(
                                  fontSize: 22,
                                  color: _kCinnabar,
                                  letterSpacing: 0.8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            const SizedBox(height: 8),

                            // Divider
                            Container(
                              width: 60,
                              height: 2,
                              decoration: BoxDecoration(
                                color: _kAmber.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Meaning
                            if (wordType.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _kAmber.withValues(alpha: 0.13),
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
                            Text(
                              meaning,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: _kInk,
                              ),
                            ),
                            const SizedBox(height: 18),

                            // Audio + Bookmark + Image buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _CircleActionBtn(
                                  icon: _isSpeaking
                                      ? Icons.graphic_eq_rounded
                                      : Icons.volume_up_rounded,
                                  color: _isSpeaking ? _kAmberDeep : _kCinnabar,
                                  onTap: _isSpeaking
                                      ? () {}
                                      : () => _speak(simplified),
                                  tooltip: 'Nghe bình thường',
                                ),
                                const SizedBox(width: 16),
                                _CircleActionBtn(
                                  icon: _isFavorite
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: _isFavorite ? _kAmber : _kMuted,
                                  onTap: () async {
                                    await _progressService.toggleFavorite(
                                      simplified,
                                    );
                                    final v = await _progressService.isFavorite(
                                      simplified,
                                    );
                                    if (!context.mounted) return;
                                    setState(() => _isFavorite = v);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          v
                                              ? 'Đã lưu "$simplified" vào Sổ tay ⭐'
                                              : 'Đã xóa khỏi Sổ tay',
                                        ),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: _kInk,
                                      ),
                                    );
                                  },
                                  tooltip: 'Lưu vào Sổ tay',
                                ),
                                const SizedBox(width: 16),
                                _CircleActionBtn(
                                  icon: Icons.speed_rounded,
                                  color: _isSpeaking
                                      ? _kAmberDeep
                                      : const Color(0xFF78909C),
                                  onTap: _isSpeaking
                                      ? () {}
                                      : () => _speak(simplified, slow: true),
                                  tooltip: 'Nghe chậm',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Examples card ──
                      if (examples.isNotEmpty)
                        _ExamplesCard(
                          examples: examples,
                          simplified: simplified,
                          onSpeak: _speak,
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // ── Bottom navigation ──
              _BottomBar(onPrev: null, onNext: _handleNext),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pexels Image Box ────────────────────────────────────────────────────────
class _PexelsImageBox extends StatelessWidget {
  final String simplified;
  final String meaning;
  const _PexelsImageBox({required this.simplified, required this.meaning});

  static const Map<String, String> _localImageMap = {
    '中国': 'assets/images/words/china.png',
    '美国': 'assets/images/words/united-states-of-america.png',
    '英国': 'assets/images/words/united-kingdom.png',
    '德国': 'assets/images/words/germany.png',
    '日本': 'assets/images/words/japan.png',
    '越南': 'assets/images/words/vietnam.png',
  };

  @override
  Widget build(BuildContext context) {
    // Use local assets if available
    if (_localImageMap.containsKey(simplified)) {
      return _buildImageContainer(
        child: Image.asset(
          _localImageMap[simplified]!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(),
        ),
      );
    }

    // Use Pexels via free image source
    final query = _getPexelsQuery(simplified, meaning);

    // Use a curated Unsplash-style URL that doesn't need API key
    final unsplashUrl =
        'https://source.unsplash.com/600x300/?${Uri.encodeComponent(query)}';

    return _buildImageContainer(
      child: Image.network(
        unsplashUrl,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoading();
        },
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      ),
    );
  }

  Widget _buildImageContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 60,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                    ],
                  ),
                ),
              ),
            ),
            // Photo credit
            Positioned(
              bottom: 6,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_camera_outlined,
                      size: 10,
                      color: Colors.white70,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Unsplash',
                      style: TextStyle(fontSize: 9, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFFFEDD8), const Color(0xFFFFF4E9)],
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: _kAmber, strokeWidth: 2),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFEDD8), Color(0xFFFFF4E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: _kAmber.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              simplified,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: _kAmberDeep.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Circle Action Button ────────────────────────────────────────────────────
class _CircleActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.1),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
        ),
      ),
    );
  }
}

// ─── Examples Card ───────────────────────────────────────────────────────────
class _ExamplesCard extends StatelessWidget {
  final List<Map<String, dynamic>> examples;
  final String simplified;
  final Future<void> Function(String, {bool slow}) onSpeak;

  const _ExamplesCard({
    required this.examples,
    required this.simplified,
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote_rounded,
                color: _kAmber.withValues(alpha: 0.6),
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                'Cụm từ kết hợp',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...examples
              .take(3)
              .map(
                (ex) => _ExampleRow(
                  ex: ex,
                  simplified: simplified,
                  onSpeak: onSpeak,
                ),
              ),
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

  const _ExampleRow({
    required this.ex,
    required this.simplified,
    required this.onSpeak,
  });

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
          spans.add(
            TextSpan(
              text: parts[i],
              style: const TextStyle(color: _kInk),
            ),
          );
        }
        if (i < parts.length - 1) {
          spans.add(
            TextSpan(
              text: simplified,
              style: const TextStyle(
                color: _kCinnabar,
                fontWeight: FontWeight.w800,
              ),
            ),
          );
        }
      }
    } else {
      spans.add(
        TextSpan(
          text: cn,
          style: const TextStyle(color: _kInk),
        ),
      );
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
                    style: const TextStyle(
                      fontSize: 11,
                      color: _kMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
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
          GestureDetector(
            onTap: () => onSpeak(cn),
            child: Icon(
              Icons.volume_up_outlined,
              size: 18,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom Bar ──────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final VoidCallback? onPrev;
  final VoidCallback onNext;

  const _BottomBar({this.onPrev, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      decoration: BoxDecoration(
        color: _kSurface,
        border: const Border(
          top: BorderSide(color: Color(0xFFEAE0D4), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Prev button
          if (onPrev != null)
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: onPrev,
                  icon: const Icon(Icons.arrow_back_rounded, size: 18),
                  label: const Text('Trước'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: Color(0xFFE0D6CA)),
                  ),
                ),
              ),
            ),
          if (onPrev != null) const SizedBox(width: 12),
          // Next button
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kCinnabar,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_forward_rounded, size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Tiếp',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
