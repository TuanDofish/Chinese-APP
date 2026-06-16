import 'dart:convert';

class TextSanitizer {
  static final RegExp _mojibakePattern = RegExp(r'[ÃÂÄÅÆÇÐÑØÙÚÛÝÞßæøð]|\uFFFD');

  static bool isLikelyMojibake(String text) {
    if (text.isEmpty) return false;
    return _mojibakePattern.hasMatch(text);
  }

  static String repair(String text) {
    if (text.isEmpty) return text;
    if (!isLikelyMojibake(text)) return text;
    try {
      return utf8.decode(latin1.encode(text), allowMalformed: true);
    } catch (_) {
      return text;
    }
  }

  static String clean(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return '';
    return repair(raw).replaceAll(RegExp(r'\s+'), ' ');
  }
}
