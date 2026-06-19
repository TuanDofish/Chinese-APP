part of '../../main.dart';

class PronunciationScorer {
  static int score(
    String target,
    String recognized, {
    String targetPinyin = '',
  }) {
    final t = target.replaceAll(RegExp(r'[^\u4e00-\u9fff]'), '');
    final r = recognized.replaceAll(RegExp(r'[^\u4e00-\u9fff]'), '');
    if (t.isEmpty || r.isEmpty) return 0;
    if (t == r) return 100;
    final hanziMatches = _lcsLength(t, r);
    final lengthRatio = min(t.length, r.length) / max(t.length, r.length);
    final hanziScore =
        (hanziMatches / t.length * 100 * (0.82 + lengthRatio * 0.18)).round();
    final targetPy = _normalizePinyin(targetPinyin);
    final recognizedPy = _hanziToPinyin(r);
    var phoneticScore = 0;
    if (targetPy.isNotEmpty && recognizedPy.isNotEmpty) {
      final pinyinMatches = _lcsLength(targetPy, recognizedPy);
      final pinyinSimilarity = pinyinMatches / targetPy.length;
      phoneticScore = (pinyinSimilarity * 100 * (0.72 + lengthRatio * 0.18))
          .round();
    }
    return max(hanziScore, phoneticScore).clamp(0, 100);
  }

  static int _lcsLength(String a, String b) {
    final previous = List<int>.filled(b.length + 1, 0);
    final current = List<int>.filled(b.length + 1, 0);
    for (var i = 1; i <= a.length; i++) {
      for (var j = 1; j <= b.length; j++) {
        current[j] = a[i - 1] == b[j - 1]
            ? previous[j - 1] + 1
            : max(previous[j], current[j - 1]);
      }
      for (var j = 0; j <= b.length; j++) {
        previous[j] = current[j];
      }
    }
    return previous[b.length];
  }

  static String _normalizePinyin(String value) {
    return value
        .toLowerCase()
        .replaceAll('ā', 'a')
        .replaceAll('á', 'a')
        .replaceAll('ǎ', 'a')
        .replaceAll('à', 'a')
        .replaceAll('ē', 'e')
        .replaceAll('é', 'e')
        .replaceAll('ě', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ī', 'i')
        .replaceAll('í', 'i')
        .replaceAll('ǐ', 'i')
        .replaceAll('ì', 'i')
        .replaceAll('ō', 'o')
        .replaceAll('ó', 'o')
        .replaceAll('ǒ', 'o')
        .replaceAll('ò', 'o')
        .replaceAll('ū', 'u')
        .replaceAll('ú', 'u')
        .replaceAll('ǔ', 'u')
        .replaceAll('ù', 'u')
        .replaceAll('ǖ', 'v')
        .replaceAll('ǘ', 'v')
        .replaceAll('ǚ', 'v')
        .replaceAll('ǜ', 'v')
        .replaceAll('ü', 'v')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

  static String _hanziToPinyin(String value) {
    const map = <String, String>{
      '你': 'ni',
      '好': 'hao',
      '谢': 'xie',
      '我': 'wo',
      '是': 'shi',
      '不': 'bu',
      '去': 'qu',
      '学': 'xue',
      '习': 'xi',
      '汉': 'han',
      '语': 'yu',
      '吃': 'chi',
      '饭': 'fan',
      '米': 'mi',
      '饺': 'jiao',
      '叫': 'jiao',
      '咀': 'ju',
      '子': 'zi',
      '者': 'zhe',
      '桌': 'zhuo',
      '椅': 'yi',
      '包': 'bao',
      '水': 'shui',
      '茶': 'cha',
      '苹': 'ping',
      '果': 'guo',
      '老': 'lao',
      '师': 'shi',
      '生': 'sheng',
      '朋': 'peng',
      '友': 'you',
      '天': 'tian',
      '气': 'qi',
      '热': 're',
      '冷': 'leng',
      '雨': 'yu',
      '雪': 'xue',
      '风': 'feng',
      '家': 'jia',
      '爸': 'ba',
      '妈': 'ma',
      '狗': 'gou',
      '猫': 'mao',
      '红': 'hong',
      '色': 'se',
      '飞': 'fei',
      '机': 'ji',
      '眼': 'yan',
      '睛': 'jing',
      '工': 'gong',
      '作': 'zuo',
      '经': 'jing',
      '济': 'ji',
      '喜': 'xi',
      '欢': 'huan',
      '中': 'zhong',
      '国': 'guo',
    };
    return value.characters.map((char) => map[char] ?? '').join();
  }
}

class PronunciationPracticeSheet extends StatefulWidget {
  final VocabEntry entry;
  const PronunciationPracticeSheet({super.key, required this.entry});

  @override
  State<PronunciationPracticeSheet> createState() =>
      _PronunciationPracticeSheetState();
}

class _PronunciationPracticeSheetState
    extends State<PronunciationPracticeSheet> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _recognizedText = '';
  int? _score;

  Future<void> _startListening() async {
    bool available = await _speech.initialize();
    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = '';
        _score = null;
      });
      _speech.listen(
        onResult: (val) {
          setState(() {
            _recognizedText = val.recognizedWords;
            if (val.hasConfidenceRating && val.confidence > 0) {
              if (_recognizedText.trim() == widget.entry.simplified) {
                _score = 100;
              } else if (_recognizedText.contains(widget.entry.simplified) ||
                  widget.entry.simplified.contains(_recognizedText)) {
                _score = 80;
              } else {
                _score = 50;
              }
            }
          });
        },
        localeId: 'zh-CN',
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    if (_recognizedText.isNotEmpty && _score == null) {
      if (_recognizedText.trim() == widget.entry.simplified) {
        _score = 100;
      } else if (_recognizedText.contains(widget.entry.simplified) ||
          widget.entry.simplified.contains(_recognizedText)) {
        _score = 80;
      } else {
        _score = 50;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Kiểm tra phát âm',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            widget.entry.simplified,
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
          Text(
            widget.entry.pinyin,
            style: const TextStyle(fontSize: 20, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (_recognizedText.isNotEmpty)
            Text(
              'Bạn đã đọc: $_recognizedText',
              style: const TextStyle(fontSize: 18, color: Colors.blue),
            ),
          if (_score != null)
            Text(
              'Điểm: $_score/100',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _score! >= 80 ? Colors.green : Colors.orange,
              ),
            ),
          const SizedBox(height: 24),
          GestureDetector(
            onTapDown: (_) => _startListening(),
            onTapUp: (_) => _stopListening(),
            onTapCancel: () => _stopListening(),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: _isListening ? Colors.red : Colors.blue,
              child: const Icon(Icons.mic, size: 40, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Nhấn giữ để nói', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
