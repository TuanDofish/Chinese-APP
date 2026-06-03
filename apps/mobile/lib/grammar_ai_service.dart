import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';

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

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body) as Map<String, dynamic>;

        // Normalize score to 0-100 range
        final rawScore = (parsed['score'] as num? ?? 0).toDouble();
        if (rawScore <= 10.0) {
          parsed['score'] = (rawScore * 10).round();
        } else {
          parsed['score'] = rawScore.round();
        }

        return parsed;
      }

      throw Exception('Backend error: ${response.statusCode}');
    } catch (e) {
      debugPrint('GrammarAiService error: $e');
      return {
        'score': 0,
        'errors': [
          {
            'type': 'Lỗi kết nối',
            'explanation': 'Không thể kết nối đến server: $e',
          },
        ],
        'correction': {'cn': text, 'py': '', 'vi': 'Không thể phân tích.'},
        'suggestions': [],
        'style_tips': 'Vui lòng đảm bảo backend server (port 3001) đang chạy.',
      };
    }
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
