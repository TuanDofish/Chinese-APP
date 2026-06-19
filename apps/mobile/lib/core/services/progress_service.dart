import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/config/app_config.dart';
import 'package:mobile/features/auth/auth_service.dart';

class ProgressService {
  static const String _keyLearnedWords = 'learned_words';
  static const String _keyFavoriteWords = 'favorite_words';
  static const String _keyDailyGoalWords = 'daily_goal_words';
  static const String _keyDailyGoalMinutes = 'daily_goal_minutes';
  static const String _keyStreak = 'streak_count';
  static const String _keyTodayWordsCount = 'today_words_count';
  static const String _keyTodayMinutes = 'today_minutes';
  static const String _keyTodayDate = 'today_date';
  static Future<void>? _hydrateFuture;
  static bool _hydrated = false;

  Future<void> _hydrateFromApi() {
    if (_hydrated) return Future.value();
    return _hydrateFuture ??= _pullRemote().whenComplete(() {
      _hydrated = true;
      _hydrateFuture = null;
    });
  }

  Future<void> _pullRemote() async {
    final session = await AuthService.instance.restoreSession();
    if (session == null || session.isGuest || session.token.isEmpty) return;
    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.apiBaseUrl}/learning/summary'),
            headers: {'Authorization': 'Bearer ${session.token}'},
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode < 200 || response.statusCode >= 300) return;
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map) return;
      final prefs = await SharedPreferences.getInstance();
      final learned = (data['learnedWords'] as List? ?? const [])
          .map((item) => item.toString())
          .toSet();
      final favorites = (data['favoriteWords'] as List? ?? const [])
          .map((item) => item.toString())
          .toSet();
      learned.addAll(prefs.getStringList(_keyLearnedWords) ?? const []);
      favorites.addAll(prefs.getStringList(_keyFavoriteWords) ?? const []);
      await prefs.setStringList(_keyLearnedWords, learned.toList());
      await prefs.setStringList(_keyFavoriteWords, favorites.toList());
      final profile = data['profile'];
      if (profile is Map) {
        await prefs.setInt(
          _keyDailyGoalWords,
          (profile['dailyGoalWords'] as num?)?.round() ?? 10,
        );
        await prefs.setInt(
          _keyDailyGoalMinutes,
          (profile['dailyGoalMinutes'] as num?)?.round() ?? 15,
        );
      }
      final today = data['today'];
      if (today is Map) {
        await prefs.setString(
          _keyTodayDate,
          DateTime.now().toIso8601String().substring(0, 10),
        );
        await prefs.setInt(
          _keyTodayWordsCount,
          (today['learnedWords'] as num?)?.round() ?? 0,
        );
        await prefs.setInt(
          _keyTodayMinutes,
          ((today['studySeconds'] as num?)?.toDouble() ?? 0) ~/ 60,
        );
        await prefs.setInt(_keyStreak, (today['streak'] as num?)?.round() ?? 0);
      }
    } catch (_) {
      // Offline mode keeps using SharedPreferences.
    }
  }

  Future<void> _send(
    String path,
    String method,
    Map<String, dynamic> body,
  ) async {
    final session = await AuthService.instance.restoreSession();
    if (session == null || session.isGuest || session.token.isEmpty) return;
    try {
      final request =
          http.Request(method, Uri.parse('${AppConfig.apiBaseUrl}$path'))
            ..headers.addAll({
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${session.token}',
            })
            ..body = jsonEncode(body);
      final response = await request.send().timeout(const Duration(seconds: 4));
      await response.stream.drain<void>();
    } catch (_) {
      // The local update is retained and can be synchronized next session.
    }
  }

  // === Learned Words ===
  Future<Set<String>> getLearnedWords() async {
    await _hydrateFromApi();
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_keyLearnedWords) ?? []).toSet();
  }

  Future<void> markAsLearned(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final learned = await getLearnedWords();
    learned.add(word);
    await prefs.setStringList(_keyLearnedWords, learned.toList());
    // Also increment today's word count
    await _incrementTodayWords();
    await _send('/learning/words/${Uri.encodeComponent(word)}', 'PUT', {
      'learned': true,
    });
  }

  // === Favorite Words (Sổ tay) ===
  Future<Set<String>> getFavoriteWords() async {
    await _hydrateFromApi();
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_keyFavoriteWords) ?? []).toSet();
  }

  Future<bool> isFavorite(String word) async {
    final favorites = await getFavoriteWords();
    return favorites.contains(word);
  }

  Future<void> toggleFavorite(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavoriteWords();
    final nextFavorite = !favorites.contains(word);
    if (!nextFavorite) {
      favorites.remove(word);
    } else {
      favorites.add(word);
    }
    await prefs.setStringList(_keyFavoriteWords, favorites.toList());
    await _send('/learning/words/${Uri.encodeComponent(word)}', 'PUT', {
      'favorite': nextFavorite,
    });
  }

  // === Daily Goals ===
  Future<int> getDailyGoalWords() async {
    await _hydrateFromApi();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyGoalWords) ?? 10; // Default: 10 words/day
  }

  Future<int> getDailyGoalMinutes() async {
    await _hydrateFromApi();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyGoalMinutes) ?? 15; // Default: 15 min/day
  }

  Future<void> setDailyGoal({int? words, int? minutes}) async {
    final prefs = await SharedPreferences.getInstance();
    if (words != null) await prefs.setInt(_keyDailyGoalWords, words);
    if (minutes != null) await prefs.setInt(_keyDailyGoalMinutes, minutes);
    await _send('/learning/goal', 'PUT', {
      'words': ?words,
      'minutes': ?minutes,
    });
  }

  // === Today's Progress ===
  Future<void> _checkAndResetToday() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toIso8601String().substring(0, 10);
    String? savedDate = prefs.getString(_keyTodayDate);
    if (savedDate != today) {
      // New day! Update streak and reset counters
      if (savedDate != null) {
        DateTime lastDate = DateTime.parse(savedDate);
        DateTime todayDate = DateTime.parse(today);
        int diff = todayDate.difference(lastDate).inDays;
        if (diff == 1) {
          // Consecutive day
          int streak = prefs.getInt(_keyStreak) ?? 0;
          await prefs.setInt(_keyStreak, streak + 1);
        } else if (diff > 1) {
          // Streak broken
          await prefs.setInt(_keyStreak, 1);
        }
      } else {
        await prefs.setInt(_keyStreak, 1);
      }
      await prefs.setString(_keyTodayDate, today);
      await prefs.setInt(_keyTodayWordsCount, 0);
      await prefs.setInt(_keyTodayMinutes, 0);
    }
  }

  Future<void> _incrementTodayWords() async {
    await _checkAndResetToday();
    final prefs = await SharedPreferences.getInstance();
    int count = prefs.getInt(_keyTodayWordsCount) ?? 0;
    await prefs.setInt(_keyTodayWordsCount, count + 1);
  }

  Future<void> addStudyMinutes(int minutes) async {
    await _checkAndResetToday();
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt(_keyTodayMinutes) ?? 0;
    await prefs.setInt(_keyTodayMinutes, current + minutes);
    await _send('/learning/study-time', 'POST', {'seconds': minutes * 60});
  }

  Future<int> getTodayWordsCount() async {
    await _checkAndResetToday();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTodayWordsCount) ?? 0;
  }

  Future<int> getTodayMinutes() async {
    await _checkAndResetToday();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTodayMinutes) ?? 0;
  }

  Future<int> getStreak() async {
    await _checkAndResetToday();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  Future<void> recordAttempt({
    required String type,
    required int score,
    required int correctCount,
    required int totalCount,
    int durationSeconds = 0,
    String? targetType,
    String? targetId,
    Map<String, dynamic>? result,
  }) {
    return _send('/learning/attempts', 'POST', {
      'type': type,
      'score': score,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'durationSeconds': durationSeconds,
      'targetType': ?targetType,
      'targetId': ?targetId,
      'result': result ?? const <String, dynamic>{},
    });
  }
}
