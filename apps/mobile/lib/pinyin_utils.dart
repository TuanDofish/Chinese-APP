/// Utility to convert numeric pinyin (e.g. ni3 hao3) to tone-mark pinyin (nǐ hǎo).
class PinyinUtils {
  static const Map<String, List<String>> _toneMap = {
    'a': ['a', '\u0101', '\u00e1', '\u01ce', '\u00e0'],
    'e': ['e', '\u0113', '\u00e9', '\u011b', '\u00e8'],
    'i': ['i', '\u012b', '\u00ed', '\u01d0', '\u00ec'],
    'o': ['o', '\u014d', '\u00f3', '\u01d2', '\u00f2'],
    'u': ['u', '\u016b', '\u00fa', '\u01d4', '\u00f9'],
    '\u00fc': ['\u00fc', '\u01d6', '\u01d8', '\u01da', '\u01dc'],
    'A': ['A', '\u0100', '\u00c1', '\u01cd', '\u00c0'],
    'E': ['E', '\u0112', '\u00c9', '\u011a', '\u00c8'],
    'I': ['I', '\u012a', '\u00cd', '\u01cf', '\u00cc'],
    'O': ['O', '\u014c', '\u00d3', '\u01d1', '\u00d2'],
    'U': ['U', '\u016a', '\u00da', '\u01d3', '\u00d9'],
    '\u00dc': ['\u00dc', '\u01d5', '\u01d7', '\u01d9', '\u01db'],
  };

  static String convertSyllable(String syllable) {
    final match = RegExp(r'^([a-zA-Z\u00fc\u00dc:]+)([0-5])$').firstMatch(syllable.trim());
    if (match == null) return syllable;

    String base = match.group(1)!;
    final int tone = int.parse(match.group(2)!);
    if (tone == 0 || tone == 5) return base;

    base = base.replaceAll('v', '\u00fc').replaceAll('V', '\u00dc');

    for (final vowel in const ['a', 'e', 'A', 'E']) {
      if (base.contains(vowel)) return _applyTone(base, vowel, tone);
    }

    if (base.contains('ou')) return _applyTone(base, 'o', tone);
    if (base.contains('OU')) return _applyTone(base, 'O', tone);

    for (final vowel in const ['\u00fc', 'u', 'i', 'o', 'e', '\u00dc', 'U', 'I', 'O', 'E']) {
      final idx = base.lastIndexOf(vowel);
      if (idx != -1) return _applyTone(base, vowel, tone);
    }

    return base;
  }

  static String _applyTone(String text, String vowel, int tone) {
    final tones = _toneMap[vowel];
    if (tones == null || tone < 1 || tone > 4) return text;
    return text.replaceFirst(vowel, tones[tone]);
  }

  static String convert(String numeric) {
    if (numeric.isEmpty) return numeric;
    if (_hasToneMarks(numeric)) return numeric;
    final syllables = numeric.trim().split(RegExp(r'\s+'));
    return syllables.map(convertSyllable).join('');
  }

  static String convertSpaced(String numeric) {
    if (numeric.isEmpty) return numeric;
    if (_hasToneMarks(numeric)) return numeric;
    final syllables = numeric.trim().split(RegExp(r'\s+'));
    return syllables.map(convertSyllable).join(' ');
  }

  static bool _hasToneMarks(String text) {
    return RegExp(r'[\u0101\u00e1\u01ce\u00e0\u0113\u00e9\u011b\u00e8\u012b\u00ed\u01d0\u00ec\u014d\u00f3\u01d2\u00f2\u016b\u00fa\u01d4\u00f9\u01d6\u01d8\u01da\u01dc]').hasMatch(text);
  }
}
