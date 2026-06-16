import 'dart:convert';
import 'package:flutter/services.dart';

class VocabularyService {
  Future<List<Map<String, dynamic>>> loadHskVocabulary() async {
    // Load JSON from assets
    final String response = await rootBundle.loadString(
      'assets/data/hsk_complete.json',
    );
    final List<dynamic> data = json.decode(response);

    // Transform to simple list of maps
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // Helper to filter by level
  List<Map<String, dynamic>> filterByLevel(
    List<Map<String, dynamic>> allWords,
    int level,
  ) {
    return allWords.where((word) => word['level'] == level).toList();
  }
}
