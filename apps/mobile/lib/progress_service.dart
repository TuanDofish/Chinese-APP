import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _keyLearnedWords = 'learned_words';
  static const String _keyFavoriteWords = 'favorite_words';
  static const String _keyDailyGoalWords = 'daily_goal_words';
  static const String _keyDailyGoalMinutes = 'daily_goal_minutes';
  static const String _keyStreak = 'streak_count';
  static const String _keyLastStudyDate = 'last_study_date';
  static const String _keyTodayWordsCount = 'today_words_count';
  static const String _keyTodayMinutes = 'today_minutes';
  static const String _keyTodayDate = 'today_date';

  // === Learned Words ===
  Future<Set<String>> getLearnedWords() async {
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
  }

  // === Favorite Words (Sổ tay) ===
  Future<Set<String>> getFavoriteWords() async {
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
    if (favorites.contains(word)) {
      favorites.remove(word);
    } else {
      favorites.add(word);
    }
    await prefs.setStringList(_keyFavoriteWords, favorites.toList());
  }

  // === Daily Goals ===
  Future<int> getDailyGoalWords() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyGoalWords) ?? 10; // Default: 10 words/day
  }

  Future<int> getDailyGoalMinutes() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyDailyGoalMinutes) ?? 15; // Default: 15 min/day
  }

  Future<void> setDailyGoal({int? words, int? minutes}) async {
    final prefs = await SharedPreferences.getInstance();
    if (words != null) await prefs.setInt(_keyDailyGoalWords, words);
    if (minutes != null) await prefs.setInt(_keyDailyGoalMinutes, minutes);
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
}
