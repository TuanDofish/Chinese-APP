part of '../../main.dart';

class ProfileRepository {
  static Uri _uri(String path) =>
      Uri.parse('${DictionaryRepository.apiBaseUrl}$path');

  static Future<ProfileData> load() async {
    final local = await LearningProgressStore.loadLocalProfile();
    final session = await AuthService.instance.restoreSession();
    if (session == null || session.isGuest || session.token.isEmpty) {
      return local;
    }
    try {
      final response = await http
          .get(
            _uri('/learning/summary'),
            headers: {'Authorization': 'Bearer ${session.token}'},
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return local;
      }
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is! Map) return local;
      final profile = data['profile'] is Map
          ? Map<String, dynamic>.from(data['profile'] as Map)
          : <String, dynamic>{};
      final today = data['today'] is Map
          ? Map<String, dynamic>.from(data['today'] as Map)
          : <String, dynamic>{};
      final totals = data['totals'] is Map
          ? Map<String, dynamic>.from(data['totals'] as Map)
          : <String, dynamic>{};
      final favoriteWords = data['favoriteWords'] is List
          ? (data['favoriteWords'] as List).length
          : local.savedWords;
      final goalWords =
          (profile['dailyGoalWords'] as num?)?.round() ?? local.dailyGoalWords;
      final goalMinutes =
          (profile['dailyGoalMinutes'] as num?)?.round() ??
          local.dailyGoalMinutes;
      final todayWords = (today['learnedWords'] as num?)?.round() ?? 0;
      final todayMinutes =
          ((today['studySeconds'] as num?)?.toDouble() ?? 0) / 60;
      final progress =
          ((goalWords <= 0 ? 0 : todayWords / goalWords) +
              (goalMinutes <= 0 ? 0 : todayMinutes / goalMinutes)) /
          2;
      return ProfileData(
        name: profile['displayName']?.toString() ?? local.name,
        level: profile['targetLevel']?.toString() ?? local.level,
        streakDays: (today['streak'] as num?)?.round() ?? local.streakDays,
        weeklyProgress: progress.clamp(0.0, 1.0).toDouble(),
        savedWords: favoriteWords,
        speakingScore:
            (totals['speakingScore'] as num?)?.round() ?? local.speakingScore,
        readingArticles:
            (today['reading'] as num?)?.round() ?? local.readingArticles,
        dailyGoalWords: goalWords,
        dailyGoalMinutes: goalMinutes,
        reminderTime: profile['reminderTime']?.toString() ?? local.reminderTime,
        storage: 'Đồng bộ PostgreSQL và thiết bị',
      );
    } catch (_) {
      return local;
    }
  }

  static Future<ProfileData> updateGoal({
    required String level,
    required int words,
    required int minutes,
  }) async {
    await LearningProgressStore.updateGoal(
      level: level,
      words: words,
      minutes: minutes,
    );
    try {
      final session = await AuthService.instance.restoreSession();
      if (session == null || session.isGuest || session.token.isEmpty) {
        return LearningProgressStore.loadLocalProfile();
      }
      final response = await http
          .put(
            _uri('/learning/goal'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${session.token}',
            },
            body: jsonEncode({
              'level': level,
              'words': words,
              'minutes': minutes,
            }),
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LearningProgressStore.loadLocalProfile();
      }
    } catch (_) {
      // Best effort sync; local data is the source of truth for offline mode.
    }
    return LearningProgressStore.loadLocalProfile();
  }
}
