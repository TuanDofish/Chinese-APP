import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/core/config/app_config.dart';

class GrammarAiException implements Exception {
  const GrammarAiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GrammarAiService {
  /// Kiểm tra ngữ pháp qua backend API (backend sẽ gọi Gemini).
  /// Không cần API key trong frontend build.
  static Future<Map<String, dynamic>> checkGrammar(String text) async {
    try {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/grammar/check');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'text': text.trim()}),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded is! Map) {
          throw const GrammarAiException(
            'Backend AI trả về dữ liệu không đúng định dạng.',
          );
        }
        final parsed = Map<String, dynamic>.from(decoded);

        // Normalize score to 0-100 range
        final rawScore = _scoreValue(parsed['score']);
        if (rawScore <= 10.0) {
          parsed['score'] = rawScore > 0 ? (rawScore * 10).round() : 0;
        } else {
          parsed['score'] = rawScore.round().clamp(0, 100);
        }

        return parsed;
      }

      throw GrammarAiException(
        _errorMessage(response.statusCode, response.bodyBytes),
      );
    } catch (e) {
      debugPrint('GrammarAiService error: $e');
      if (e is GrammarAiException) rethrow;
      throw GrammarAiException('Không thể kết nối AI backend: $e');
    }
  }

  static double _scoreValue(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _errorMessage(int statusCode, List<int> bodyBytes) {
    var message = 'Backend AI không phản hồi.';
    if (bodyBytes.isNotEmpty) {
      final body = utf8.decode(bodyBytes);
      try {
        final decoded = json.decode(body);
        if (decoded is Map) {
          final raw = decoded['message'] ?? decoded['error'];
          if (raw is List) {
            message = raw.join('. ');
          } else if (raw != null && raw.toString().trim().isNotEmpty) {
            message = raw.toString().trim();
          }
        }
      } catch (_) {
        final compact = body.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (compact.isNotEmpty) {
          message = compact.length > 180
              ? '${compact.substring(0, 180)}...'
              : compact;
        }
      }
    }
    return 'Backend $statusCode: $message';
  }

  static Future<List<Map<String, String>>> generateExamples(
    String word,
    String pinyin,
    String meaning,
  ) async {
    try {
      final url = Uri.parse(
        '${AppConfig.apiBaseUrl}/dictionary/examples?q=${Uri.encodeComponent(word)}',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List?;
        if (results != null && results.isNotEmpty) {
          List<Map<String, String>> examples = [];
          for (var item in results) {
            if (examples.length >= 3) break;
            final cn = item['cn'] ?? item['simplified'] ?? '';
            final py = item['py'] ?? item['pinyin'] ?? '';
            final vi = item['vi'] ?? item['meaning'] ?? '';
            examples.add({
              'cn': cn.toString(),
              'py': py.toString(),
              'vi': vi.toString(),
            });
          }
          return examples;
        }
      }
    } catch (e) {
      debugPrint('Error fetching examples: $e');
    }
    return _mockGenerateExamples(word, pinyin, meaning);
  }

  static List<Map<String, String>> _mockGenerateExamples(
    String word,
    String pinyin,
    String meaning,
  ) {
    return [
      {
        'cn': '我们正在学习"$word"。',
        'py': "Wǒmen zhèngzài xuéxí '$word'.",
        'vi': "Chúng tôi đang học từ '$meaning'.",
      },
      {
        'cn': '这个"$word"很难。',
        'py': "Zhège '$word' hěn nán.",
        'vi': "Từ '$meaning' này rất khó.",
      },
    ];
  }
}
