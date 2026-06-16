import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:mobile/features/auth/auth_service.dart';
import 'package:mobile/features/grammar/grammar_ai_service.dart';
import 'package:mobile/features/games/mini_game_screen.dart';
import 'package:mobile/core/services/progress_service.dart';

part 'app/app_shell.dart';
part 'features/auth/auth_flow.dart';
part 'features/home/home_screen.dart';
part 'features/vocabulary/vocabulary_screen.dart';
part 'features/grammar/grammar_screen.dart';
part 'features/reading/reading_practice_screen.dart';

void main() {
  runApp(const VNChineseApp());
}

class AppColors {
  static const ink = Color(0xFF151922);
  static const muted = Color(0xFF596275);
  static const paper = Color(0xFFFAF7F2);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFE4D9CC);
  static const cinnabar = Color(0xFFC83E35);
  static const jade = Color(0xFF197A62);
  static const amber = Color(0xFFE0A326);
  static const blue = Color(0xFF2563A9);
  static const plum = Color(0xFF7E4C8B);
}

class VNChineseApp extends StatelessWidget {
  const VNChineseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VNChinese',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        fontFamilyFallback: const ['Roboto', 'Arial', 'NotoSansSC'],
        visualDensity: VisualDensity.standard,
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.cinnabar,
          primary: AppColors.cinnabar,
          secondary: AppColors.jade,
          surface: AppColors.surface,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            height: 1.14,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          headlineMedium: TextStyle(
            fontSize: 25,
            height: 1.22,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            height: 1.28,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          bodyLarge: TextStyle(
            fontSize: 15.5,
            height: 1.55,
            color: AppColors.ink,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.5,
            height: 1.55,
            color: AppColors.muted,
          ),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.paper,
          foregroundColor: AppColors.ink,
          titleTextStyle: TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 74,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.cinnabar.withValues(alpha: 0.12),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.ink : AppColors.muted,
              size: selected ? 25 : 23,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? AppColors.ink : AppColors.muted,
              fontSize: 12,
              height: 1.15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.cinnabar, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.cinnabar,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            side: const BorderSide(color: AppColors.line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class ProfileData {
  const ProfileData({
    required this.name,
    required this.level,
    required this.streakDays,
    required this.weeklyProgress,
    required this.savedWords,
    required this.speakingScore,
    required this.readingArticles,
    required this.dailyGoalWords,
    required this.dailyGoalMinutes,
    required this.reminderTime,
    required this.storage,
  });

  final String name;
  final String level;
  final int streakDays;
  final double weeklyProgress;
  final int savedWords;
  final int speakingScore;
  final int readingArticles;
  final int dailyGoalWords;
  final int dailyGoalMinutes;
  final String reminderTime;
  final String storage;

  static const fallback = ProfileData(
    name: 'Người học VNChinese',
    level: 'HSK 2',
    streakDays: 0,
    weeklyProgress: 0,
    savedWords: 0,
    speakingScore: 0,
    readingArticles: 0,
    dailyGoalWords: 18,
    dailyGoalMinutes: 25,
    reminderTime: '20:30',
    storage: 'Thiết bị hiện tại',
  );

  double get progress => weeklyProgress.clamp(0.0, 1.0).toDouble();
  String get progressLabel => '${(progress * 100).round()}%';

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      name: _string(json['name'], fallback.name),
      level: _string(json['level'], fallback.level),
      streakDays: _int(json['streakDays'], fallback.streakDays),
      weeklyProgress: _double(json['weeklyProgress'], fallback.weeklyProgress),
      savedWords: _int(json['savedWords'], fallback.savedWords),
      speakingScore: _int(json['speakingScore'], fallback.speakingScore),
      readingArticles: _int(json['readingArticles'], fallback.readingArticles),
      dailyGoalWords: _int(json['dailyGoalWords'], fallback.dailyGoalWords),
      dailyGoalMinutes: _int(
        json['dailyGoalMinutes'],
        fallback.dailyGoalMinutes,
      ),
      reminderTime: _string(json['reminderTime'], fallback.reminderTime),
      storage: _string(json['storage'], fallback.storage),
    );
  }

  static String _string(dynamic value, String fallback) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static int _int(dynamic value, int fallback) {
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _double(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class LearningDayStat {
  const LearningDayStat({
    required this.date,
    this.learnedWords = 0,
    this.reviewedWords = 0,
    this.studyMinutes = 0,
    this.grammarChecks = 0,
    this.reading = 0,
    this.speaking = 0,
    this.quizzes = 0,
    this.scoreTotal = 0,
    this.scoreCount = 0,
    this.correctCount = 0,
    this.totalCount = 0,
  });

  final DateTime date;
  final int learnedWords;
  final int reviewedWords;
  final int studyMinutes;
  final int grammarChecks;
  final int reading;
  final int speaking;
  final int quizzes;
  final int scoreTotal;
  final int scoreCount;
  final int correctCount;
  final int totalCount;

  bool get isActive =>
      learnedWords +
          reviewedWords +
          studyMinutes +
          grammarChecks +
          reading +
          speaking +
          quizzes >
      0;

  int get averageScore =>
      scoreCount <= 0 ? 0 : (scoreTotal / scoreCount).round();

  String get weekdayLabel {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return labels[date.weekday - 1];
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String().substring(0, 10),
    'learnedWords': learnedWords,
    'reviewedWords': reviewedWords,
    'studyMinutes': studyMinutes,
    'grammarChecks': grammarChecks,
    'reading': reading,
    'speaking': speaking,
    'quizzes': quizzes,
    'scoreTotal': scoreTotal,
    'scoreCount': scoreCount,
    'correctCount': correctCount,
    'totalCount': totalCount,
  };

  factory LearningDayStat.fromJson(
    Map<String, dynamic> json, {
    DateTime? fallbackDate,
  }) {
    return LearningDayStat(
      date:
          DateTime.tryParse((json['date'] ?? '').toString()) ??
          fallbackDate ??
          DateTime.now(),
      learnedWords: ProfileData._int(json['learnedWords'], 0),
      reviewedWords: ProfileData._int(json['reviewedWords'], 0),
      studyMinutes: ProfileData._int(json['studyMinutes'], 0),
      grammarChecks: ProfileData._int(json['grammarChecks'], 0),
      reading: ProfileData._int(json['reading'], 0),
      speaking: ProfileData._int(json['speaking'], 0),
      quizzes: ProfileData._int(json['quizzes'], 0),
      scoreTotal: ProfileData._int(json['scoreTotal'], 0),
      scoreCount: ProfileData._int(json['scoreCount'], 0),
      correctCount: ProfileData._int(json['correctCount'], 0),
      totalCount: ProfileData._int(json['totalCount'], 0),
    );
  }
}

class HskLevelProgress {
  const HskLevelProgress({
    required this.level,
    required this.totalWords,
    required this.learnedWords,
    this.masteredWords = 0,
    this.dueReview = 0,
  });

  final String level;
  final int totalWords;
  final int learnedWords;
  final int masteredWords;
  final int dueReview;

  double get progress =>
      totalWords <= 0 ? 0 : (learnedWords / totalWords).clamp(0.0, 1.0);

  factory HskLevelProgress.fromJson(Map<String, dynamic> json) {
    return HskLevelProgress(
      level: (json['level'] ?? 'HSK 1').toString(),
      totalWords: ProfileData._int(json['totalWords'], 0),
      learnedWords: ProfileData._int(json['learnedWords'], 0),
      masteredWords: ProfileData._int(json['masteredWords'], 0),
      dueReview: ProfileData._int(json['dueReview'], 0),
    );
  }
}

class LearningActivityItem {
  const LearningActivityItem({
    required this.kind,
    required this.title,
    required this.detail,
    required this.occurredAt,
  });

  final String kind;
  final String title;
  final String detail;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => {
    'kind': kind,
    'title': title,
    'detail': detail,
    'occurredAt': occurredAt.toIso8601String(),
  };

  factory LearningActivityItem.fromJson(Map<String, dynamic> json) {
    return LearningActivityItem(
      kind: (json['kind'] ?? 'practice').toString(),
      title: (json['title'] ?? 'Hoạt động học').toString(),
      detail: (json['detail'] ?? '').toString(),
      occurredAt:
          DateTime.tryParse((json['occurredAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  String get timeLabel {
    final now = DateTime.now();
    final difference = now.difference(occurredAt);
    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    if (difference.inDays == 1) return 'Hôm qua';
    return '${occurredAt.day.toString().padLeft(2, '0')}/'
        '${occurredAt.month.toString().padLeft(2, '0')}';
  }
}

class LearningProgressSnapshot {
  const LearningProgressSnapshot({
    required this.targetLevel,
    required this.dailyGoalWords,
    required this.dailyGoalMinutes,
    required this.savedWords,
    required this.todayWords,
    required this.studyMinutesToday,
    required this.grammarChecksToday,
    required this.readingArticlesThisWeek,
    required this.speakingScore,
    required this.streakDays,
    required this.weeklyStudyMinutes,
    required this.weeklyWords,
    required this.weeklyReviews,
    required this.activeDaysThisWeek,
    required this.accuracy,
    required this.totalLearnedWords,
    required this.totalMasteredWords,
    required this.dueReviewWords,
    required this.vocabularyScore,
    required this.grammarScore,
    required this.readingScore,
    required this.lastSevenDays,
    required this.roadmap,
    required this.recentActivities,
  });

  final String targetLevel;
  final int dailyGoalWords;
  final int dailyGoalMinutes;
  final int savedWords;
  final int todayWords;
  final int studyMinutesToday;
  final int grammarChecksToday;
  final int readingArticlesThisWeek;
  final int speakingScore;
  final int streakDays;
  final int weeklyStudyMinutes;
  final int weeklyWords;
  final int weeklyReviews;
  final int activeDaysThisWeek;
  final int accuracy;
  final int totalLearnedWords;
  final int totalMasteredWords;
  final int dueReviewWords;
  final int vocabularyScore;
  final int grammarScore;
  final int readingScore;
  final List<LearningDayStat> lastSevenDays;
  final List<HskLevelProgress> roadmap;
  final List<LearningActivityItem> recentActivities;

  static const empty = LearningProgressSnapshot(
    targetLevel: 'HSK 2',
    dailyGoalWords: 18,
    dailyGoalMinutes: 25,
    savedWords: 0,
    todayWords: 0,
    studyMinutesToday: 0,
    grammarChecksToday: 0,
    readingArticlesThisWeek: 0,
    speakingScore: 0,
    streakDays: 0,
    weeklyStudyMinutes: 0,
    weeklyWords: 0,
    weeklyReviews: 0,
    activeDaysThisWeek: 0,
    accuracy: 0,
    totalLearnedWords: 0,
    totalMasteredWords: 0,
    dueReviewWords: 0,
    vocabularyScore: 0,
    grammarScore: 0,
    readingScore: 0,
    lastSevenDays: [],
    roadmap: [],
    recentActivities: [],
  );

  double get dailyProgress {
    final wordProgress = dailyGoalWords <= 0
        ? 0.0
        : todayWords / dailyGoalWords;
    final minuteProgress = dailyGoalMinutes <= 0
        ? 0.0
        : studyMinutesToday / dailyGoalMinutes;
    return ((wordProgress + minuteProgress) / 2).clamp(0.0, 1.0).toDouble();
  }

  String get wordsLabel => '$todayWords/$dailyGoalWords';

  double get weeklyGoalProgress {
    final wordGoal = dailyGoalWords * 7;
    final minuteGoal = dailyGoalMinutes * 7;
    final wordProgress = wordGoal <= 0 ? 0.0 : weeklyWords / wordGoal;
    final minuteProgress = minuteGoal <= 0
        ? 0.0
        : weeklyStudyMinutes / minuteGoal;
    return ((wordProgress + minuteProgress) / 2).clamp(0.0, 1.0).toDouble();
  }

  String get todaySummary {
    if (todayWords == 0 &&
        studyMinutesToday == 0 &&
        grammarChecksToday == 0 &&
        readingArticlesThisWeek == 0) {
      return 'Chọn một bài từ vựng, kiểm tra câu hoặc đọc một bài ngắn để app bắt đầu ghi tiến độ hôm nay.';
    }
    return 'Đã học $todayWords từ, $studyMinutesToday phút, sửa $grammarChecksToday câu và mở $readingArticlesThisWeek bài đọc trong tuần.';
  }
}

class GrammarHistoryItem {
  const GrammarHistoryItem({
    required this.input,
    required this.correction,
    required this.score,
    required this.title,
    required this.checkedAt,
  });

  final String input;
  final String correction;
  final int score;
  final String title;
  final DateTime checkedAt;

  Map<String, dynamic> toJson() => {
    'input': input,
    'correction': correction,
    'score': score,
    'title': title,
    'checkedAt': checkedAt.toIso8601String(),
  };

  factory GrammarHistoryItem.fromJson(Map<String, dynamic> json) {
    return GrammarHistoryItem(
      input: (json['input'] ?? '').toString(),
      correction: (json['correction'] ?? '').toString(),
      score: ProfileData._int(json['score'], 0),
      title: (json['title'] ?? 'Kiểm tra câu').toString(),
      checkedAt:
          DateTime.tryParse((json['checkedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }

  String get dateLabel {
    final hour = checkedAt.hour.toString().padLeft(2, '0');
    final minute = checkedAt.minute.toString().padLeft(2, '0');
    final day = checkedAt.day.toString().padLeft(2, '0');
    final month = checkedAt.month.toString().padLeft(2, '0');
    return '$hour:$minute $day/$month/${checkedAt.year}';
  }
}

class LearningProgressStore {
  static const _goalLevelKey = 'vnchinese_goal_level';
  static const _goalWordsKey = 'vnchinese_goal_words';
  static const _goalMinutesKey = 'vnchinese_goal_minutes';
  static const _todayDateKey = 'vnchinese_today_date';
  static const _todayWordsKey = 'vnchinese_today_words';
  static const _todayMinutesKey = 'vnchinese_today_minutes';
  static const _todayGrammarKey = 'vnchinese_today_grammar_checks';
  static const _lastStudyDateKey = 'vnchinese_last_study_date';
  static const _streakKey = 'vnchinese_streak_days';
  static const _readingWeekKey = 'vnchinese_reading_week';
  static const _readingWeekCountKey = 'vnchinese_reading_week_count';
  static const _speakingScoreKey = 'vnchinese_speaking_score';
  static const _grammarHistoryKey = 'vnchinese_grammar_history';
  static const _reminderTimeKey = 'vnchinese_reminder_time';
  static const _learnedLevelPrefix = 'vnchinese_learned_level_';
  static const _learnedWordsPrefix = 'vnchinese_learned_words_';
  static const _dailyHistoryKey = 'vnchinese_daily_history_v2';
  static const _activityHistoryKey = 'vnchinese_activity_history_v1';
  static const _officialTotals = {
    'HSK 1': 150,
    'HSK 2': 300,
    'HSK 3': 600,
    'HSK 4': 1200,
    'HSK 5': 2500,
    'HSK 6': 5000,
  };

  static String _dateKey(DateTime date) =>
      date.toIso8601String().substring(0, 10);

  static String _weekKey(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(firstDay).inDays + 1;
    final week = ((dayOfYear + firstDay.weekday - 2) / 7).floor() + 1;
    return '${date.year}-$week';
  }

  static Future<void> _resetDailyIfNeeded(SharedPreferences prefs) async {
    final today = _dateKey(DateTime.now());
    if (prefs.getString(_todayDateKey) == today) return;
    await prefs.setString(_todayDateKey, today);
    await prefs.setInt(_todayWordsKey, 0);
    await prefs.setInt(_todayMinutesKey, 0);
    await prefs.setInt(_todayGrammarKey, 0);
  }

  static Future<void> _resetWeeklyIfNeeded(SharedPreferences prefs) async {
    final week = _weekKey(DateTime.now());
    if (prefs.getString(_readingWeekKey) == week) return;
    await prefs.setString(_readingWeekKey, week);
    await prefs.setInt(_readingWeekCountKey, 0);
  }

  static Future<void> _touchStudy(SharedPreferences prefs) async {
    final today = _dateKey(DateTime.now());
    final last = prefs.getString(_lastStudyDateKey);
    if (last == today) return;

    var nextStreak = 1;
    if (last != null) {
      final lastDate = DateTime.tryParse(last);
      final todayDate = DateTime.tryParse(today);
      if (lastDate != null && todayDate != null) {
        final diff = todayDate.difference(lastDate).inDays;
        nextStreak = diff == 1 ? (prefs.getInt(_streakKey) ?? 0) + 1 : 1;
      }
    }
    await prefs.setString(_lastStudyDateKey, today);
    await prefs.setInt(_streakKey, nextStreak);
  }

  static Map<String, dynamic> _loadDailyHistory(SharedPreferences prefs) {
    final raw = prefs.getString(_dailyHistoryKey);
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  static Future<void> _recordDaily(
    SharedPreferences prefs, {
    int learnedWords = 0,
    int reviewedWords = 0,
    int studyMinutes = 0,
    int grammarChecks = 0,
    int reading = 0,
    int speaking = 0,
    int quizzes = 0,
    int scoreTotal = 0,
    int scoreCount = 0,
    int correctCount = 0,
    int totalCount = 0,
  }) async {
    final history = _loadDailyHistory(prefs);
    final key = _dateKey(DateTime.now());
    final existing = history[key] is Map
        ? Map<String, dynamic>.from(history[key] as Map)
        : <String, dynamic>{'date': key};
    int current(String field) => ProfileData._int(existing[field], 0);
    history[key] = {
      'date': key,
      'learnedWords': current('learnedWords') + learnedWords,
      'reviewedWords': current('reviewedWords') + reviewedWords,
      'studyMinutes': current('studyMinutes') + studyMinutes,
      'grammarChecks': current('grammarChecks') + grammarChecks,
      'reading': current('reading') + reading,
      'speaking': current('speaking') + speaking,
      'quizzes': current('quizzes') + quizzes,
      'scoreTotal': current('scoreTotal') + scoreTotal,
      'scoreCount': current('scoreCount') + scoreCount,
      'correctCount': current('correctCount') + correctCount,
      'totalCount': current('totalCount') + totalCount,
    };
    final sortedKeys = history.keys.toList()..sort();
    for (final oldKey in sortedKeys.take(max(0, sortedKeys.length - 90))) {
      history.remove(oldKey);
    }
    await prefs.setString(_dailyHistoryKey, jsonEncode(history));
  }

  static Future<List<LearningDayStat>> _loadLastSevenDays(
    SharedPreferences prefs,
  ) async {
    final history = _loadDailyHistory(prefs);
    final todayKey = _dateKey(DateTime.now());
    final result = <LearningDayStat>[];
    for (var offset = 6; offset >= 0; offset--) {
      final date = DateTime.now().subtract(Duration(days: offset));
      final key = _dateKey(date);
      final data = history[key] is Map
          ? Map<String, dynamic>.from(history[key] as Map)
          : <String, dynamic>{'date': key};
      if (key == todayKey) {
        data['learnedWords'] = max(
          ProfileData._int(data['learnedWords'], 0),
          prefs.getInt(_todayWordsKey) ?? 0,
        );
        data['studyMinutes'] = max(
          ProfileData._int(data['studyMinutes'], 0),
          prefs.getInt(_todayMinutesKey) ?? 0,
        );
        data['grammarChecks'] = max(
          ProfileData._int(data['grammarChecks'], 0),
          prefs.getInt(_todayGrammarKey) ?? 0,
        );
      }
      result.add(LearningDayStat.fromJson(data, fallbackDate: date));
    }
    return result;
  }

  static Future<void> _addActivity(
    SharedPreferences prefs,
    LearningActivityItem item,
  ) async {
    final raw = prefs.getStringList(_activityHistoryKey) ?? <String>[];
    raw.insert(0, jsonEncode(item.toJson()));
    await prefs.setStringList(_activityHistoryKey, raw.take(20).toList());
  }

  static Future<List<LearningActivityItem>> _loadActivities(
    SharedPreferences prefs,
  ) async {
    final raw = prefs.getStringList(_activityHistoryKey) ?? <String>[];
    return raw
        .map((item) {
          try {
            return LearningActivityItem.fromJson(
              Map<String, dynamic>.from(jsonDecode(item) as Map),
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<LearningActivityItem>()
        .take(8)
        .toList();
  }

  static Future<void> _sendRemote(
    String method,
    String path,
    Map<String, dynamic> body,
  ) async {
    final session = await AuthService.instance.restoreSession();
    if (session == null || session.isGuest || session.token.isEmpty) return;
    try {
      final request =
          http.Request(
              method,
              Uri.parse('${DictionaryRepository.apiBaseUrl}$path'),
            )
            ..headers.addAll({
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${session.token}',
            })
            ..body = jsonEncode(body);
      final response = await request.send().timeout(const Duration(seconds: 5));
      await response.stream.drain<void>();
    } catch (_) {
      // Offline activity remains available in SharedPreferences.
    }
  }

  static Future<LearningProgressSnapshot> loadSnapshot({
    bool includeRemote = true,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetDailyIfNeeded(prefs);
    await _resetWeeklyIfNeeded(prefs);
    final saved = await NotebookStore.load();
    final learnedByLevel = await loadLearnedWordsByLevel();
    final roadmap = _officialTotals.entries
        .map(
          (entry) => HskLevelProgress(
            level: entry.key,
            totalWords: entry.value,
            learnedWords: learnedByLevel[entry.key] ?? 0,
          ),
        )
        .toList();
    final lastSevenDays = await _loadLastSevenDays(prefs);
    final recentActivities = await _loadActivities(prefs);
    final weeklyStudyMinutes = lastSevenDays.fold<int>(
      0,
      (total, day) => total + day.studyMinutes,
    );
    final weeklyWords = lastSevenDays.fold<int>(
      0,
      (total, day) => total + day.learnedWords,
    );
    final weeklyReviews = lastSevenDays.fold<int>(
      0,
      (total, day) => total + day.reviewedWords,
    );
    final scoreTotal = lastSevenDays.fold<int>(
      0,
      (total, day) => total + day.scoreTotal,
    );
    final scoreCount = lastSevenDays.fold<int>(
      0,
      (total, day) => total + day.scoreCount,
    );
    final correctCount = lastSevenDays.fold<int>(
      0,
      (total, day) => total + day.correctCount,
    );
    final totalCount = lastSevenDays.fold<int>(
      0,
      (total, day) => total + day.totalCount,
    );
    final targetLevel = prefs.getString(_goalLevelKey) ?? 'HSK 2';
    final targetRoadmap = roadmap.firstWhere(
      (item) => item.level == targetLevel,
      orElse: () => roadmap.first,
    );
    final speakingScore = prefs.getInt(_speakingScoreKey) ?? 0;
    final grammarHistory = await loadGrammarHistory();
    final grammarScore = grammarHistory.isEmpty
        ? 0
        : (grammarHistory.fold<int>(0, (sum, item) => sum + item.score) /
                  grammarHistory.length)
              .round();
    final readingCount = prefs.getInt(_readingWeekCountKey) ?? 0;
    final local = LearningProgressSnapshot(
      targetLevel: targetLevel,
      dailyGoalWords: prefs.getInt(_goalWordsKey) ?? 18,
      dailyGoalMinutes: prefs.getInt(_goalMinutesKey) ?? 25,
      savedWords: saved.length,
      todayWords: prefs.getInt(_todayWordsKey) ?? 0,
      studyMinutesToday: prefs.getInt(_todayMinutesKey) ?? 0,
      grammarChecksToday: prefs.getInt(_todayGrammarKey) ?? 0,
      readingArticlesThisWeek: readingCount,
      speakingScore: speakingScore,
      streakDays: prefs.getInt(_streakKey) ?? 0,
      weeklyStudyMinutes: weeklyStudyMinutes,
      weeklyWords: weeklyWords,
      weeklyReviews: weeklyReviews,
      activeDaysThisWeek: lastSevenDays.where((day) => day.isActive).length,
      accuracy: totalCount > 0
          ? ((correctCount / totalCount) * 100).round()
          : (scoreCount > 0 ? (scoreTotal / scoreCount).round() : 0),
      totalLearnedWords: roadmap.fold<int>(
        0,
        (total, level) => total + level.learnedWords,
      ),
      totalMasteredWords: 0,
      dueReviewWords: 0,
      vocabularyScore: (targetRoadmap.progress * 100).round(),
      grammarScore: grammarScore,
      readingScore: (readingCount * 20).clamp(0, 100),
      lastSevenDays: lastSevenDays,
      roadmap: roadmap,
      recentActivities: recentActivities,
    );
    return includeRemote ? _loadRemoteSnapshot(local) : local;
  }

  static Future<LearningProgressSnapshot> _loadRemoteSnapshot(
    LearningProgressSnapshot local,
  ) async {
    final session = await AuthService.instance.restoreSession();
    if (session == null || session.isGuest || session.token.isEmpty) {
      return local;
    }
    try {
      final response = await http
          .get(
            Uri.parse('${DictionaryRepository.apiBaseUrl}/learning/summary'),
            headers: {'Authorization': 'Bearer ${session.token}'},
          )
          .timeout(const Duration(seconds: 5));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return local;
      }
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) return local;
      final data = Map<String, dynamic>.from(decoded);
      Map<String, dynamic> mapOf(String key) => data[key] is Map
          ? Map<String, dynamic>.from(data[key] as Map)
          : <String, dynamic>{};
      final profile = mapOf('profile');
      final today = mapOf('today');
      final weekly = mapOf('weekly');
      final totals = mapOf('totals');
      final skills = mapOf('skills');

      final remoteDays = <String, LearningDayStat>{};
      for (final item
          in data['activity'] is List ? data['activity'] as List : const []) {
        if (item is! Map) continue;
        final json = Map<String, dynamic>.from(item);
        final date = DateTime.tryParse((json['date'] ?? '').toString());
        if (date == null) continue;
        remoteDays[_dateKey(date)] = LearningDayStat.fromJson(json);
      }
      final mergedDays = local.lastSevenDays.map((localDay) {
        final remoteDay = remoteDays[_dateKey(localDay.date)];
        if (remoteDay == null) return localDay;
        return LearningDayStat(
          date: localDay.date,
          learnedWords: max(localDay.learnedWords, remoteDay.learnedWords),
          reviewedWords: max(localDay.reviewedWords, remoteDay.reviewedWords),
          studyMinutes: max(localDay.studyMinutes, remoteDay.studyMinutes),
          grammarChecks: max(localDay.grammarChecks, remoteDay.grammarChecks),
          reading: max(localDay.reading, remoteDay.reading),
          speaking: max(localDay.speaking, remoteDay.speaking),
          quizzes: max(localDay.quizzes, remoteDay.quizzes),
          scoreTotal: localDay.scoreTotal,
          scoreCount: localDay.scoreCount,
          correctCount: localDay.correctCount,
          totalCount: localDay.totalCount,
        );
      }).toList();

      final remoteRoadmap = <HskLevelProgress>[];
      for (final item
          in data['roadmap'] is List ? data['roadmap'] as List : const []) {
        if (item is Map) {
          remoteRoadmap.add(
            HskLevelProgress.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
      final mergedRoadmap = remoteRoadmap.isEmpty
          ? local.roadmap
          : remoteRoadmap.map((remote) {
              final localLevel = local.roadmap
                  .where((item) => item.level == remote.level)
                  .firstOrNull;
              return HskLevelProgress(
                level: remote.level,
                totalWords: max(remote.totalWords, localLevel?.totalWords ?? 0),
                learnedWords: max(
                  remote.learnedWords,
                  localLevel?.learnedWords ?? 0,
                ),
                masteredWords: remote.masteredWords,
                dueReview: remote.dueReview,
              );
            }).toList();

      final remoteActivities = <LearningActivityItem>[];
      for (final item
          in data['recentActivities'] is List
              ? data['recentActivities'] as List
              : const []) {
        if (item is Map) {
          remoteActivities.add(
            LearningActivityItem.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
      final activityKeys = <String>{};
      final mergedActivities = [...remoteActivities, ...local.recentActivities]
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
      final uniqueActivities = mergedActivities
          .where(
            (item) => activityKeys.add(
              '${item.kind}|${item.title}|${item.detail}|'
              '${item.occurredAt.millisecondsSinceEpoch ~/ 60000}',
            ),
          )
          .take(8)
          .toList();

      final targetLevel =
          profile['targetLevel']?.toString() ?? local.targetLevel;
      final targetRoadmap = mergedRoadmap
          .where((item) => item.level == targetLevel)
          .firstOrNull;
      final remoteReadingThisWeek = mergedDays.fold<int>(
        0,
        (total, day) => total + day.reading,
      );
      return LearningProgressSnapshot(
        targetLevel: targetLevel,
        dailyGoalWords: ProfileData._int(
          profile['dailyGoalWords'],
          local.dailyGoalWords,
        ),
        dailyGoalMinutes: ProfileData._int(
          profile['dailyGoalMinutes'],
          local.dailyGoalMinutes,
        ),
        savedWords: max(
          local.savedWords,
          data['favoriteWords'] is List
              ? (data['favoriteWords'] as List).length
              : 0,
        ),
        todayWords: max(
          local.todayWords,
          ProfileData._int(today['learnedWords'], 0),
        ),
        studyMinutesToday: max(
          local.studyMinutesToday,
          (ProfileData._int(today['studySeconds'], 0) / 60).round(),
        ),
        grammarChecksToday: max(
          local.grammarChecksToday,
          ProfileData._int(today['aiInteractions'], 0),
        ),
        readingArticlesThisWeek: max(
          local.readingArticlesThisWeek,
          remoteReadingThisWeek,
        ),
        speakingScore: ProfileData._int(
          totals['speakingScore'],
          local.speakingScore,
        ),
        streakDays: max(local.streakDays, ProfileData._int(today['streak'], 0)),
        weeklyStudyMinutes: max(
          local.weeklyStudyMinutes,
          ProfileData._int(weekly['studyMinutes'], 0),
        ),
        weeklyWords: max(
          local.weeklyWords,
          ProfileData._int(weekly['learnedWords'], 0),
        ),
        weeklyReviews: max(
          local.weeklyReviews,
          ProfileData._int(weekly['reviewedWords'], 0),
        ),
        activeDaysThisWeek: max(
          local.activeDaysThisWeek,
          ProfileData._int(weekly['activeDays'], 0),
        ),
        accuracy: ProfileData._int(totals['accuracy'], local.accuracy),
        totalLearnedWords: max(
          local.totalLearnedWords,
          ProfileData._int(totals['learnedWords'], 0),
        ),
        totalMasteredWords: ProfileData._int(
          totals['masteredWords'],
          local.totalMasteredWords,
        ),
        dueReviewWords: ProfileData._int(
          totals['dueReview'],
          local.dueReviewWords,
        ),
        vocabularyScore: ProfileData._int(
          skills['vocabulary'],
          targetRoadmap == null
              ? local.vocabularyScore
              : (targetRoadmap.progress * 100).round(),
        ),
        grammarScore: ProfileData._int(skills['grammar'], local.grammarScore),
        readingScore: ProfileData._int(skills['reading'], local.readingScore),
        lastSevenDays: mergedDays,
        roadmap: mergedRoadmap,
        recentActivities: uniqueActivities,
      );
    } catch (_) {
      return local;
    }
  }

  static Future<ProfileData> loadLocalProfile() async {
    final progress = await loadSnapshot(includeRemote: false);
    final session = await AuthService.instance.restoreSession();
    return ProfileData(
      name: session?.displayName ?? ProfileData.fallback.name,
      level: progress.targetLevel,
      streakDays: progress.streakDays,
      weeklyProgress: progress.dailyProgress,
      savedWords: progress.savedWords,
      speakingScore: progress.speakingScore,
      readingArticles: progress.readingArticlesThisWeek,
      dailyGoalWords: progress.dailyGoalWords,
      dailyGoalMinutes: progress.dailyGoalMinutes,
      reminderTime:
          (await SharedPreferences.getInstance()).getString(_reminderTimeKey) ??
          ProfileData.fallback.reminderTime,
      storage: 'Lưu cục bộ trên thiết bị',
    );
  }

  static Future<void> updateGoal({
    required String level,
    required int words,
    required int minutes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_goalLevelKey, level);
    await prefs.setInt(_goalWordsKey, words);
    await prefs.setInt(_goalMinutesKey, minutes);
  }

  static Future<void> updateReminder(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderTimeKey, time);
  }

  static Future<Map<String, int>> loadLearnedWordsByLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final level in _officialTotals.keys)
        level: max(
          prefs.getInt('$_learnedLevelPrefix$level') ?? 0,
          (prefs.getStringList('$_learnedWordsPrefix$level') ?? const [])
              .toSet()
              .length,
        ),
    };
  }

  static Future<void> recordVocabularyWord({
    required String level,
    String? word,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetDailyIfNeeded(prefs);
    final safeLevel = _officialTotals.containsKey(level) ? level : 'HSK 1';
    final cleanWord = word?.trim() ?? '';
    final learnedKey = '$_learnedWordsPrefix$safeLevel';
    final learnedWords = (prefs.getStringList(learnedKey) ?? <String>[])
        .toSet();
    final isNew = cleanWord.isEmpty || learnedWords.add(cleanWord);
    if (!isNew) return;
    await _touchStudy(prefs);
    await prefs.setInt(_todayWordsKey, (prefs.getInt(_todayWordsKey) ?? 0) + 1);
    await prefs.setInt(
      _todayMinutesKey,
      (prefs.getInt(_todayMinutesKey) ?? 0) + 2,
    );
    if (cleanWord.isNotEmpty) {
      await prefs.setStringList(learnedKey, learnedWords.toList()..sort());
    }
    final levelKey = '$_learnedLevelPrefix$safeLevel';
    await prefs.setInt(levelKey, (prefs.getInt(levelKey) ?? 0) + 1);
    await _recordDaily(prefs, learnedWords: 1, studyMinutes: 2);
    await _addActivity(
      prefs,
      LearningActivityItem(
        kind: 'vocabulary',
        title: 'Học từ mới',
        detail: cleanWord.isEmpty ? safeLevel : '$cleanWord · $safeLevel',
        occurredAt: DateTime.now(),
      ),
    );
    if (cleanWord.isNotEmpty) {
      await _sendRemote(
        'PUT',
        '/learning/words/${Uri.encodeComponent(cleanWord)}',
        {'learned': true, 'favorite': true},
      );
    }
  }

  static Future<void> recordStudyMinutes(int minutes) async {
    if (minutes <= 0) return;
    final prefs = await SharedPreferences.getInstance();
    await _resetDailyIfNeeded(prefs);
    await _touchStudy(prefs);
    await prefs.setInt(
      _todayMinutesKey,
      (prefs.getInt(_todayMinutesKey) ?? 0) + minutes,
    );
    await _recordDaily(prefs, studyMinutes: minutes);
  }

  static Future<void> recordGrammarCheck(
    String input,
    GrammarCheckResult result,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetDailyIfNeeded(prefs);
    await _touchStudy(prefs);
    await prefs.setInt(
      _todayGrammarKey,
      (prefs.getInt(_todayGrammarKey) ?? 0) + 1,
    );
    await prefs.setInt(
      _todayMinutesKey,
      (prefs.getInt(_todayMinutesKey) ?? 0) + 3,
    );

    final history = prefs.getStringList(_grammarHistoryKey) ?? <String>[];
    final item = GrammarHistoryItem(
      input: input,
      correction: result.correction,
      score: result.score,
      title: result.title,
      checkedAt: DateTime.now(),
    );
    history.insert(0, jsonEncode(item.toJson()));
    await prefs.setStringList(_grammarHistoryKey, history.take(20).toList());
    await _recordDaily(
      prefs,
      studyMinutes: 3,
      grammarChecks: 1,
      scoreTotal: result.score,
      scoreCount: 1,
      correctCount: result.score >= 70 ? 1 : 0,
      totalCount: 1,
    );
    await _addActivity(
      prefs,
      LearningActivityItem(
        kind: 'grammar',
        title: 'Kiểm tra ngữ pháp',
        detail: '${result.score} điểm · ${result.title}',
        occurredAt: DateTime.now(),
      ),
    );
    await _sendRemote('POST', '/learning/attempts', {
      'type': 'QUIZ',
      'targetType': 'GRAMMAR',
      'targetId': input.length > 80 ? input.substring(0, 80) : input,
      'score': result.score,
      'correctCount': result.score >= 70 ? 1 : 0,
      'totalCount': 1,
      'durationSeconds': 180,
    });
  }

  static Future<List<GrammarHistoryItem>> loadGrammarHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_grammarHistoryKey) ?? <String>[];
    return raw
        .map((item) {
          try {
            return GrammarHistoryItem.fromJson(
              jsonDecode(item) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<GrammarHistoryItem>()
        .toList();
  }

  static Future<void> recordReadingArticle({
    int minutes = 4,
    String? title,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetDailyIfNeeded(prefs);
    await _resetWeeklyIfNeeded(prefs);
    await _touchStudy(prefs);
    await prefs.setInt(
      _readingWeekCountKey,
      (prefs.getInt(_readingWeekCountKey) ?? 0) + 1,
    );
    await prefs.setInt(
      _todayMinutesKey,
      (prefs.getInt(_todayMinutesKey) ?? 0) + minutes,
    );
    await _recordDaily(prefs, studyMinutes: minutes, reading: 1);
    await _addActivity(
      prefs,
      LearningActivityItem(
        kind: 'reading',
        title: 'Đọc bài báo',
        detail: [
          if ((title ?? '').trim().isNotEmpty) title!.trim(),
          '$minutes phút',
        ].join(' · '),
        occurredAt: DateTime.now(),
      ),
    );
    await _sendRemote('POST', '/learning/attempts', {
      'type': 'READING',
      'targetType': 'ARTICLE',
      'targetId': (title ?? '').trim(),
      'score': 0,
      'correctCount': 0,
      'totalCount': 0,
      'durationSeconds': minutes * 60,
    });
  }

  static Future<void> recordSpeakingScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetDailyIfNeeded(prefs);
    await _touchStudy(prefs);
    final previous = prefs.getInt(_speakingScoreKey);
    final nextScore = previous == null
        ? score
        : ((previous + score) / 2).round();
    await prefs.setInt(_speakingScoreKey, nextScore.clamp(0, 100));
    await prefs.setInt(
      _todayMinutesKey,
      (prefs.getInt(_todayMinutesKey) ?? 0) + 3,
    );
    await _recordDaily(
      prefs,
      studyMinutes: 3,
      speaking: 1,
      scoreTotal: score,
      scoreCount: 1,
    );
    await _addActivity(
      prefs,
      LearningActivityItem(
        kind: 'speaking',
        title: 'Luyện phát âm',
        detail: '$score điểm',
        occurredAt: DateTime.now(),
      ),
    );
    await _sendRemote('POST', '/learning/attempts', {
      'type': 'PRONUNCIATION',
      'score': score,
      'correctCount': score >= 70 ? 1 : 0,
      'totalCount': 1,
      'durationSeconds': 180,
    });
  }

  static Future<void> recordQuizResult({
    required int score,
    required int correctCount,
    required int totalCount,
    int minutes = 5,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _resetDailyIfNeeded(prefs);
    await _touchStudy(prefs);
    await prefs.setInt(
      _todayMinutesKey,
      (prefs.getInt(_todayMinutesKey) ?? 0) + minutes,
    );
    await _recordDaily(
      prefs,
      studyMinutes: minutes,
      quizzes: 1,
      scoreTotal: score,
      scoreCount: 1,
      correctCount: correctCount,
      totalCount: totalCount,
    );
    await _addActivity(
      prefs,
      LearningActivityItem(
        kind: 'quiz',
        title: 'Hoàn thành bài kiểm tra',
        detail: '$score điểm · $correctCount/$totalCount câu đúng',
        occurredAt: DateTime.now(),
      ),
    );
  }
}

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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileData> _profileFuture;
  ProfileData _profile = ProfileData.fallback;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<ProfileData> _loadProfile() async {
    try {
      final profile = await ProfileRepository.load();
      _profile = profile;
      return profile;
    } catch (_) {
      return _profile;
    }
  }

  void _refreshProfile() {
    setState(() => _profileFuture = _loadProfile());
  }

  Future<void> _saveGoal(String level, int words, int minutes) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final profile = await ProfileRepository.updateGoal(
        level: level,
        words: words,
        minutes: minutes,
      );
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _profileFuture = Future.value(profile);
      });
      messenger.showSnackBar(
        const SnackBar(content: Text('Đã cập nhật mục tiêu học.')),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Chưa lưu được mục tiêu: $error')),
      );
    }
  }

  void _openGoalSheet(ProfileData profile) {
    var level = profile.level;
    var words = profile.dailyGoalWords.toDouble();
    var minutes = profile.dailyGoalMinutes.toDouble();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Đổi mục tiêu học',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: level,
                      decoration: const InputDecoration(labelText: 'Cấp HSK'),
                      items:
                          const [
                                'HSK 1',
                                'HSK 2',
                                'HSK 3',
                                'HSK 4',
                                'HSK 5',
                                'HSK 6',
                              ]
                              .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Text(item),
                                ),
                              )
                              .toList(),
                      onChanged: (value) =>
                          setSheetState(() => level = value ?? level),
                    ),
                    const SizedBox(height: 12),
                    Text('Từ mới mỗi ngày: ${words.round()}'),
                    Slider(
                      value: words,
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '${words.round()} từ',
                      onChanged: (value) => setSheetState(() => words = value),
                    ),
                    Text('Thời gian luyện: ${minutes.round()} phút/ngày'),
                    Slider(
                      value: minutes,
                      min: 10,
                      max: 90,
                      divisions: 8,
                      label: '${minutes.round()} phút',
                      onChanged: (value) =>
                          setSheetState(() => minutes = value),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _saveGoal(level, words.round(), minutes.round());
                        },
                        icon: const Icon(Icons.cloud_done_outlined),
                        label: const Text('Lưu mục tiêu'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showStats(ProfileData profile) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thống kê tài khoản',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                ProfileActionRow(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Chuỗi ngày học',
                  value: '${profile.streakDays} ngày',
                  color: AppColors.cinnabar,
                ),
                const Divider(height: 20),
                ProfileActionRow(
                  icon: Icons.school_outlined,
                  title: 'Tiến độ ${profile.level}',
                  value: profile.progressLabel,
                  color: AppColors.blue,
                ),
                const Divider(height: 20),
                ProfileActionRow(
                  icon: Icons.schedule_outlined,
                  title: 'Mục tiêu hằng ngày',
                  value:
                      '${profile.dailyGoalWords} từ, ${profile.dailyGoalMinutes} phút',
                  color: AppColors.jade,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRowMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickReminder(ProfileData profile) async {
    final parts = profile.reminderTime.split(':');
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 20,
        minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 30 : 30,
      ),
      helpText: 'Chọn giờ nhắc học',
    );
    if (selected == null) return;
    final value =
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    await LearningProgressStore.updateReminder(value);
    if (!mounted) return;
    _refreshProfile();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Đã đặt giờ nhắc học lúc $value.')));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileData>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data ?? _profile;
        final loading = snapshot.connectionState == ConnectionState.waiting;
        return ScreenShell(
          title: 'Tài khoản',
          subtitle: loading
              ? 'Đang đồng bộ dữ liệu tài khoản...'
              : 'Tiến độ học tập và mục tiêu cá nhân.',
          trailing: IconButton.filledTonal(
            tooltip: 'Làm mới tài khoản',
            onPressed: _refreshProfile,
            icon: const Icon(Icons.sync),
          ),
          children: [
            AppCard(
              child: Row(
                children: [
                  const UserAvatar(size: 56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mục tiêu hiện tại: ${profile.level}',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Đăng xuất',
                    onPressed: widget.onLogout,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            MetricWrap(
              metrics: [
                DashboardMetric(
                  '${profile.streakDays}',
                  'Ngày streak',
                  Icons.local_fire_department_outlined,
                  AppColors.cinnabar,
                ),
                DashboardMetric(
                  profile.progressLabel,
                  profile.level,
                  Icons.school_outlined,
                  AppColors.blue,
                ),
                DashboardMetric(
                  '${profile.savedWords}',
                  'Từ đã lưu',
                  Icons.bookmark,
                  AppColors.amber,
                ),
                DashboardMetric(
                  '${profile.speakingScore}',
                  'Điểm phát âm',
                  Icons.mic_none,
                  AppColors.jade,
                ),
              ],
            ),
            const SizedBox(height: 18),
            AppCard(
              gradient: const LinearGradient(
                colors: [Color(0xFF17202A), Color(0xFF1B7F79)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.flag_outlined, color: Colors.white),
                      const SizedBox(width: 8),
                      const Text(
                        'Lộ trình cá nhân',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const Spacer(),
                      StatusPill(label: profile.level, color: AppColors.amber),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Mục tiêu: ${profile.dailyGoalWords} từ/ngày, ${profile.dailyGoalMinutes} phút luyện, ${profile.readingArticles} bài đọc tuần này',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: profile.progress,
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFFFD178),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _openGoalSheet(profile),
                        icon: const Icon(Icons.tune),
                        label: const Text('Đổi mục tiêu'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showStats(profile),
                        icon: const Icon(Icons.insights),
                        label: const Text('Xem thống kê'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white30),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SectionHeader(title: 'Hoạt động học'),
            AppCard(
              child: Column(
                children: [
                  ProfileActionRow(
                    icon: Icons.bookmark_added_outlined,
                    title: 'Sổ tay từ vựng',
                    value: '${profile.savedWords} từ đã lưu',
                    color: AppColors.amber,
                    onTap: () =>
                        _showRowMessage('Sổ tay đã được lưu trên thiết bị.'),
                  ),
                  const Divider(height: 20),
                  ProfileActionRow(
                    icon: Icons.record_voice_over_outlined,
                    title: 'Luyện nói',
                    value: 'Điểm trung bình ${profile.speakingScore}',
                    color: AppColors.jade,
                    onTap: () => _showRowMessage(
                      'Điểm phát âm được cập nhật sau mỗi lần luyện.',
                    ),
                  ),
                  const Divider(height: 20),
                  ProfileActionRow(
                    icon: Icons.newspaper_outlined,
                    title: 'Đọc hiểu',
                    value: '${profile.readingArticles} bài đã mở tuần này',
                    color: AppColors.blue,
                    onTap: () =>
                        _showRowMessage('Thống kê đọc hiểu đã sẵn sàng.'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppCard(
              child: Column(
                children: [
                  ProfileActionRow(
                    icon: Icons.notifications_active_outlined,
                    title: 'Nhắc học hằng ngày',
                    value: profile.reminderTime,
                    color: AppColors.cinnabar,
                    onTap: () => _pickReminder(profile),
                  ),
                  const Divider(height: 20),
                  ProfileActionRow(
                    icon: Icons.cloud_done_outlined,
                    title: 'Dữ liệu học tập',
                    value: profile.storage,
                    color: AppColors.jade,
                    onTap: _refreshProfile,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: widget.onLogout,
              icon: const Icon(Icons.logout),
              label: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );
  }
}

class ProfileActionRow extends StatelessWidget {
  const ProfileActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(color: AppColors.muted)),
              ],
            ),
          ),
          Icon(
            onTap == null ? Icons.info_outline : Icons.chevron_right,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

class FlashcardLessonScreen extends StatefulWidget {
  const FlashcardLessonScreen({
    super.key,
    required this.topic,
    required this.saved,
    required this.onToggleSaved,
  });

  final FlashcardTopic topic;
  final Set<String> saved;
  final ValueChanged<String> onToggleSaved;

  @override
  State<FlashcardLessonScreen> createState() => _FlashcardLessonScreenState();
}

class _FlashcardLessonScreenState extends State<FlashcardLessonScreen> {
  final PageController _pageController = PageController();
  final FlutterTts _tts = FlutterTts();
  int _index = 0;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.45);
  }

  @override
  void dispose() {
    _tts.stop();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.topic.words.length;
    final progress = (_index + 1) / total;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0E8),
      appBar: AppBar(
        title: Text(widget.topic.name),
        actions: [
          IconButton(
            tooltip: 'Quiz chủ đề',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FlashcardQuizScreen(topic: widget.topic),
              ),
            ),
            icon: const Icon(Icons.quiz_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_index + 1}/$total',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.line,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _levelColor(widget.topic.level),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: total,
              onPageChanged: (index) => setState(() {
                _index = index;
                _showBack = false;
              }),
              itemBuilder: (context, index) {
                final word = widget.topic.words[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: FlashcardView(
                    entry: word,
                    showBack: _showBack,
                    saved: widget.saved.contains(word.simplified),
                    onFlip: () => setState(() => _showBack = !_showBack),
                    onSpeak: () => _tts.speak(word.simplified),
                    onToggleSaved: () => widget.onToggleSaved(word.simplified),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _index == 0
                          ? null
                          : () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOut,
                            ),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Trước'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _index == total - 1
                          ? () {
                              LearningProgressStore.recordStudyMinutes(5);
                              Navigator.pop(context);
                            }
                          : () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 260),
                              curve: Curves.easeOut,
                            ),
                      icon: Icon(
                        _index == total - 1 ? Icons.check : Icons.arrow_forward,
                      ),
                      label: Text(_index == total - 1 ? 'Hoàn thành' : 'Tiếp'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardQuizScreen extends StatefulWidget {
  const FlashcardQuizScreen({super.key, required this.topic});

  final FlashcardTopic topic;

  @override
  State<FlashcardQuizScreen> createState() => _FlashcardQuizScreenState();
}

class _FlashcardQuizScreenState extends State<FlashcardQuizScreen> {
  late final List<VocabEntry> _questions;
  int _index = 0;
  int _score = 0;
  String? _selected;

  @override
  void initState() {
    super.initState();
    _questions = [...widget.topic.words]..shuffle(Random());
  }

  List<String> get _choices {
    final current = _questions[_index];
    final distractors =
        widget.topic.words
            .where((word) => word.simplified != current.simplified)
            .map((word) => word.meaning)
            .toSet()
            .toList()
          ..shuffle(Random(current.simplified.hashCode));
    final choices = <String>[current.meaning, ...distractors.take(3)];
    choices.shuffle(Random(current.meaning.hashCode));
    return choices;
  }

  void _answer(String value) {
    if (_selected != null) return;
    final correct = value == _questions[_index].meaning;
    setState(() {
      _selected = value;
      if (correct) _score++;
    });
  }

  void _next() {
    if (_index >= _questions.length - 1) {
      final score = _questions.isEmpty
          ? 0
          : ((_score / _questions.length) * 100).round();
      LearningProgressStore.recordQuizResult(
        score: score,
        correctCount: _score,
        totalCount: _questions.length,
      );
      ProgressService().recordAttempt(
        type: 'QUIZ',
        score: score,
        correctCount: _score,
        totalCount: _questions.length,
        durationSeconds: 300,
        targetType: 'TOPIC',
        targetId: widget.topic.id,
      );
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hoàn thành quiz'),
          content: Text('Bạn trả lời đúng $_score/${_questions.length} câu.'),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Xong'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      _index++;
      _selected = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final current = _questions[_index];
    final choices = _choices;
    return Scaffold(
      appBar: AppBar(title: Text('Quiz · ${widget.topic.name}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LinearProgressIndicator(value: (_index + 1) / _questions.length),
          const SizedBox(height: 28),
          Text(
            'Từ này có nghĩa là gì?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 18),
          Text(
            current.simplified,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900),
          ),
          Text(
            current.pinyin,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.cinnabar,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 28),
          ...choices.map((choice) {
            final answered = _selected != null;
            final correct = choice == current.meaning;
            final selected = choice == _selected;
            final color = answered && correct
                ? AppColors.jade
                : answered && selected
                ? AppColors.cinnabar
                : AppColors.line;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: OutlinedButton(
                onPressed: answered ? null : () => _answer(choice),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(color: color, width: selected ? 2 : 1),
                ),
                child: Text(choice),
              ),
            );
          }),
          if (_selected != null) ...[
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _next,
              icon: Icon(
                _index == _questions.length - 1
                    ? Icons.check
                    : Icons.arrow_forward,
              ),
              label: Text(
                _index == _questions.length - 1 ? 'Xem kết quả' : 'Câu tiếp',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class VideoLessonDetailScreen extends StatefulWidget {
  const VideoLessonDetailScreen({super.key, required this.lesson});

  final VideoLessonData lesson;

  @override
  State<VideoLessonDetailScreen> createState() =>
      _VideoLessonDetailScreenState();
}

class _VideoLessonDetailScreenState extends State<VideoLessonDetailScreen> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ScrollController _scrollController = ScrollController();
  late final YoutubePlayerController _ytController;
  StreamSubscription? _playerSubscription;
  Timer? _positionTimer;
  int _current = -1;
  bool _listening = false;
  bool _isPlaying = false;
  bool _autoPause = true;
  bool _showPinyin = true;
  bool _showVietnamese = true;
  bool _pausedAtLineEnd = false;
  bool _pollingPosition = false;
  bool _awaitingPractice = false;
  double _videoDurationSeconds = 0;
  String _recognized = '';
  int? _lockedLine;
  final Map<int, int> _scores = {};

  @override
  void initState() {
    super.initState();
    _autoPause = widget.lesson.hasTimedSubtitles;
    if (widget.lesson.subtitles.isNotEmpty) _current = 0;
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.44);
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: widget.lesson.youtubeId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );
    _playerSubscription = _ytController.listen((event) {
      if (!mounted) return;
      final playing = event.playerState == PlayerState.playing;
      final durationSeconds =
          event.metaData.duration.inMilliseconds /
          Duration.millisecondsPerSecond;
      final hasNewDuration =
          durationSeconds > 0 &&
          (durationSeconds - _videoDurationSeconds).abs() > 0.5;
      _startPositionTimer();
      if (playing != _isPlaying || hasNewDuration) {
        setState(() {
          _isPlaying = playing;
          if (hasNewDuration) _videoDurationSeconds = durationSeconds;
        });
      }
    });
    _startPositionTimer();
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _stopPositionTimer();
    _ytController.close();
    _tts.stop();
    _speech.stop();
    _scrollController.dispose();
    super.dispose();
  }

  double _lineStart(int index) {
    final sub = widget.lesson.subtitles[index];
    return sub.end > sub.start ? sub.start : 0;
  }

  double _lineEnd(int index) {
    final sub = widget.lesson.subtitles[index];
    final start = _lineStart(index);
    return sub.end > sub.start ? max(start + 0.8, sub.end) : 0;
  }

  void _startPositionTimer() {
    if (_positionTimer != null) return;
    _positionTimer = Timer.periodic(
      const Duration(milliseconds: 250),
      (_) => _pollPosition(),
    );
  }

  void _stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  Future<void> _pollPosition() async {
    if (_pollingPosition || !mounted) return;
    _pollingPosition = true;
    try {
      if (_videoDurationSeconds <= 0) {
        final duration = await _ytController.duration;
        if (duration > 0 && mounted) {
          setState(() => _videoDurationSeconds = duration);
        }
      }
      final seconds = await _ytController.currentTime;
      final playerState = await _ytController.playerState;
      final playing = playerState == PlayerState.playing;
      if (mounted) _syncActiveLine(seconds, playing);
    } catch (_) {
      // The iframe can briefly reject currentTime while the video is loading.
    } finally {
      _pollingPosition = false;
    }
  }

  void _syncActiveLine(double seconds, bool playing) {
    if (widget.lesson.subtitles.isEmpty) return;
    if (!widget.lesson.hasTimedSubtitles) {
      if (playing != _isPlaying) setState(() => _isPlaying = playing);
      return;
    }
    final locked = _lockedLine;
    if (locked != null) {
      final lineEnd = _lineEnd(locked);
      final shouldPause =
          _autoPause &&
          playing &&
          seconds >= lineEnd - 0.08 &&
          !_pausedAtLineEnd;

      if (_current != locked || playing != _isPlaying || shouldPause) {
        setState(() {
          _current = locked;
          _isPlaying = shouldPause ? false : playing;
          if (shouldPause) {
            _pausedAtLineEnd = true;
            _awaitingPractice = true;
            _lockedLine = null;
          }
        });
        _scrollToCurrent();
      }

      if (shouldPause) {
        _ytController.pauseVideo();
      }
      return;
    }

    var newIndex = _current;
    var matched = false;
    for (var i = 0; i < widget.lesson.subtitles.length; i++) {
      if (seconds >= _lineStart(i) && seconds <= _lineEnd(i)) {
        newIndex = i;
        matched = true;
        break;
      }
    }
    if (!matched) {
      newIndex = 0;
      for (var i = 0; i < widget.lesson.subtitles.length; i++) {
        if (_lineStart(i) <= seconds) newIndex = i;
      }
    }

    if (newIndex != _current || playing != _isPlaying) {
      setState(() {
        _current = newIndex;
        _isPlaying = playing;
      });
      if (newIndex >= 0) _scrollToCurrent();
    }
  }

  void _scrollToCurrent() {
    if (!_scrollController.hasClients || _current < 0) return;
    final target = (_current * 118.0) - 80;
    _scrollController.animateTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _playLine(int index) {
    setState(() {
      _current = index;
      _recognized = '';
      _lockedLine = index;
      _awaitingPractice = false;
      _pausedAtLineEnd = false;
    });
    if (!widget.lesson.hasTimedSubtitles) {
      _tts.speak(widget.lesson.subtitles[index].cn);
      return;
    }
    _ytController.seekTo(seconds: _lineStart(index), allowSeekAhead: true);
    _ytController.playVideo();
    _startPositionTimer();
  }

  void _toggleVideo() {
    _pausedAtLineEnd = false;
    if (widget.lesson.hasTimedSubtitles &&
        !_isPlaying &&
        _current < 0 &&
        widget.lesson.subtitles.isNotEmpty) {
      setState(() {
        _lockedLine = 0;
        _current = 0;
      });
    }
    if (_isPlaying) {
      _ytController.pauseVideo();
    } else {
      if (widget.lesson.hasTimedSubtitles) {
        _lockedLine ??= _activeLineIndex >= 0 ? _activeLineIndex : null;
      }
      _ytController.playVideo();
      _startPositionTimer();
    }
  }

  int get _activeLineIndex {
    if (widget.lesson.subtitles.isEmpty) return -1;
    return _current.clamp(0, widget.lesson.subtitles.length - 1);
  }

  Widget _buildShadowingPanel() {
    final index = _activeLineIndex;
    if (index < 0) return const SizedBox.shrink();
    final sub = widget.lesson.subtitles[index];
    final score = _scores[index];
    final listeningThisLine = _listening && _current == index;
    final scoreColor = score == null
        ? Colors.white54
        : score >= 85
        ? AppColors.jade
        : score >= 65
        ? AppColors.amber
        : AppColors.cinnabar;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF20242E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: listeningThisLine
              ? AppColors.cinnabar
              : Colors.white.withValues(alpha: 0.08),
          width: listeningThisLine ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusPill(label: 'Câu ${index + 1}', color: AppColors.cinnabar),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.lesson.hasTimedSubtitles
                      ? 'Video tự dừng ở cuối câu, ghi âm xong sẽ đi tiếp'
                      : 'Bài này chưa có mốc thời gian, dùng nghe mẫu từng câu',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (score != null)
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scoreColor, width: 4),
                  ),
                  child: Text(
                    '$score',
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            sub.cn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              height: 1.22,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (_showPinyin && sub.py.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              sub.py,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFCC80),
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ],
          if (_showVietnamese && sub.vi.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              sub.vi,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontStyle: FontStyle.italic,
                fontSize: 15,
              ),
            ),
          ],
          if (_recognized.isNotEmpty && _current == index) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Máy nghe được: $_recognized',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => _playLine(index),
                icon: const Icon(Icons.replay_5),
                label: const Text('Phát lại đoạn'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
              FilledButton.icon(
                onPressed: listeningThisLine
                    ? () => _stopLine(index)
                    : () => _recordLine(index),
                icon: Icon(
                  listeningThisLine
                      ? Icons.stop_circle
                      : _awaitingPractice && _current == index
                      ? Icons.mic
                      : Icons.mic_none,
                ),
                label: Text(
                  listeningThisLine ? 'Dừng ghi âm' : 'Ghi âm nhại lại',
                ),
              ),
              OutlinedButton.icon(
                onPressed: index >= widget.lesson.subtitles.length - 1
                    ? null
                    : () => _playLine(index + 1),
                icon: const Icon(Icons.skip_next),
                label: const Text('Câu tiếp'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      color: const Color(0xFF10131A),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton.filledTonal(
            tooltip: _isPlaying ? 'Tạm dừng' : 'Phát video',
            onPressed: _toggleVideo,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          FilterChip(
            selected: widget.lesson.hasTimedSubtitles && _autoPause,
            showCheckmark: false,
            avatar: Icon(
              _autoPause ? Icons.pause_circle : Icons.play_circle_outline,
              size: 18,
            ),
            label: Text(
              widget.lesson.hasTimedSubtitles
                  ? 'Tự dừng từng câu'
                  : 'Chưa có timing',
            ),
            onSelected: widget.lesson.hasTimedSubtitles
                ? (value) => setState(() {
                    _autoPause = value;
                    _pausedAtLineEnd = false;
                    _awaitingPractice = false;
                  })
                : null,
          ),
          FilterChip(
            selected: _showPinyin,
            showCheckmark: false,
            label: const Text('Pinyin'),
            onSelected: (value) => setState(() => _showPinyin = value),
          ),
          FilterChip(
            selected: _showVietnamese,
            showCheckmark: false,
            label: const Text('Tiếng Việt'),
            onSelected: (value) => setState(() => _showVietnamese = value),
          ),
        ],
      ),
    );
  }

  Future<void> _recordLine(int index) async {
    await _ytController.pauseVideo();
    _stopPositionTimer();
    final available = await _speech.initialize();
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không mở được micro để kiểm tra phát âm.'),
        ),
      );
      return;
    }
    setState(() {
      _current = index;
      _listening = true;
      _recognized = '';
      _awaitingPractice = false;
      _scores.remove(index);
    });
    await _speech.listen(
      localeId: 'zh-CN',
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      onResult: (result) {
        setState(() => _recognized = result.recognizedWords);
        if (result.finalResult) _finishLine(index);
      },
    );
  }

  Future<void> _stopLine(int index) async {
    await _speech.stop();
    _finishLine(index);
  }

  void _finishLine(int index) {
    if (!mounted) return;
    final target = widget.lesson.subtitles[index].cn;
    final shouldContinue =
        _autoPause && index < widget.lesson.subtitles.length - 1;
    final score = PronunciationScorer.score(target, _recognized);
    setState(() {
      _listening = false;
      _awaitingPractice = false;
      _scores[index] = score;
    });
    LearningProgressStore.recordSpeakingScore(score);
    if (shouldContinue) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted || _listening || _current != index) return;
        _playLine(index + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10131A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF10131A),
        foregroundColor: Colors.white,
        title: Text(widget.lesson.title),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            clipBehavior: Clip.antiAlias,
            child: YoutubePlayer(
              controller: _ytController,
              aspectRatio: 16 / 9,
            ),
          ),
          _buildVideoControls(),
          _buildShadowingPanel(),
          Container(
            color: const Color(0xFF1A1D26),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                StatusPill(label: widget.lesson.level, color: AppColors.jade),
                const SizedBox(width: 10),
                StatusPill(
                  label: widget.lesson.source,
                  color: AppColors.cinnabar,
                ),
                const SizedBox(width: 10),
                Text(
                  '${widget.lesson.subtitles.length} câu phụ đề',
                  style: const TextStyle(color: Colors.white70),
                ),
                const Spacer(),
                Icon(
                  widget.lesson.hasTimedSubtitles
                      ? Icons.sync
                      : Icons.warning_amber_rounded,
                  color: widget.lesson.hasTimedSubtitles
                      ? AppColors.jade
                      : AppColors.amber,
                  size: 18,
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: widget.lesson.subtitles.length,
              itemBuilder: (context, index) {
                final sub = widget.lesson.subtitles[index];
                final active = index == _current;
                final score = _scores[index];
                return InkWell(
                  onTap: () => _playLine(index),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.cinnabar.withValues(alpha: 0.18)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: active ? AppColors.cinnabar : Colors.white10,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: active
                              ? AppColors.cinnabar
                              : Colors.white12,
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.cn,
                                style: TextStyle(
                                  color: active ? Colors.white : Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (_showPinyin && sub.py.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  sub.py,
                                  style: const TextStyle(
                                    color: Color(0xFFFFCC80),
                                  ),
                                ),
                              ],
                              if (_showVietnamese && sub.vi.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  sub.vi,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                              if (active && _recognized.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Bạn đọc: $_recognized',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                              if (score != null) ...[
                                const SizedBox(height: 8),
                                StatusPill(
                                  label: '$score điểm',
                                  color: score >= 80
                                      ? AppColors.jade
                                      : AppColors.amber,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              tooltip: 'Nghe câu',
                              onPressed: () => _playLine(index),
                              icon: const Icon(
                                Icons.play_circle_outline,
                                color: Colors.white54,
                              ),
                            ),
                            IconButton(
                              tooltip: active && _listening
                                  ? 'Dừng ghi âm'
                                  : 'Ghi âm đọc theo',
                              onPressed: active && _listening
                                  ? () => _stopLine(index)
                                  : () => _recordLine(index),
                              icon: Icon(
                                active && _listening
                                    ? Icons.stop_circle_outlined
                                    : Icons.mic_none,
                                color: active && _listening
                                    ? AppColors.cinnabar
                                    : Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? AppColors.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: gradient == null ? AppColors.line : Colors.transparent,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ScreenShell extends StatelessWidget {
  const ScreenShell({
    super.key,
    required this.title,
    required this.children,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

class SegmentTabs extends StatelessWidget {
  const SegmentTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(7),
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  labels[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : AppColors.muted,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LevelSelector extends StatelessWidget {
  const LevelSelector({
    super.key,
    required this.levels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> levels;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: levels.map((level) {
          final active = level == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: active,
              label: Text(level),
              selectedColor: _levelColor(level).withValues(alpha: 0.16),
              labelStyle: TextStyle(
                color: active ? _levelColor(level) : AppColors.muted,
                fontWeight: FontWeight.w900,
              ),
              onSelected: (_) => onSelected(level),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.inverted = false, this.showText = false});

  final bool inverted;
  final bool showText;

  @override
  Widget build(BuildContext context) {
    final fg = inverted ? Colors.white : AppColors.cinnabar;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: inverted
                ? Colors.white.withValues(alpha: 0.12)
                : AppColors.cinnabar.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: inverted
                  ? Colors.white24
                  : AppColors.cinnabar.withValues(alpha: 0.18),
            ),
          ),
          child: Text(
            '文',
            style: TextStyle(
              color: fg,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VNChinese',
                style: TextStyle(
                  color: inverted ? Colors.white : AppColors.ink,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'AI HSK Coach',
                style: TextStyle(
                  color: inverted ? Colors.white70 : AppColors.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class VisualBadge extends StatelessWidget {
  const VisualBadge({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFFD178)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterTile extends StatelessWidget {
  const CharacterTile({super.key, required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppColors.cinnabar.withValues(alpha: 0.12),
      child: const Text(
        'T',
        style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.ink),
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  const StatusPill({super.key, this.icon, required this.label, this.color});

  final IconData? icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.cinnabar;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: c.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: c),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class FeatureItem {
  const FeatureItem(
    this.title,
    this.description,
    this.icon,
    this.color,
    this.onTap,
  );
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class FeatureGrid extends StatelessWidget {
  const FeatureGrid({super.key, required this.items});

  final List<FeatureItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: items.map((item) {
            return SizedBox(
              width: width,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(8),
                child: AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, color: item.color),
                      const SizedBox(height: 14),
                      Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class DashboardMetric {
  const DashboardMetric(this.value, this.label, this.icon, this.color);
  final String value;
  final String label;
  final IconData icon;
  final Color color;
}

class MetricWrap extends StatelessWidget {
  const MetricWrap({super.key, required this.metrics});

  final List<DashboardMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 4 : 2;
        final gap = 12.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: metrics.map((metric) {
            return SizedBox(
              width: width,
              child: AppCard(
                color: metric.color.withValues(alpha: 0.09),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(metric.icon, color: metric.color),
                    const SizedBox(height: 14),
                    Text(
                      metric.value,
                      style: TextStyle(
                        color: metric.color,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                    Text(
                      metric.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class LearningJourneyDashboard extends StatelessWidget {
  const LearningJourneyDashboard({
    super.key,
    required this.progress,
    required this.onOpenVocabulary,
    required this.onOpenPractice,
  });

  final LearningProgressSnapshot progress;
  final VoidCallback onOpenVocabulary;
  final VoidCallback onOpenPractice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7 ngày gần nhất',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${progress.weeklyStudyMinutes} phút · '
                          '${progress.weeklyWords} từ mới',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  _ProgressRing(value: progress.weeklyGoalProgress),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 620 ? 4 : 2;
                  final width =
                      (constraints.maxWidth - (columns - 1) * 12) / columns;
                  return Wrap(
                    spacing: 12,
                    runSpacing: 14,
                    children: [
                      _JourneyMetric(
                        width: width,
                        icon: Icons.calendar_month_outlined,
                        color: AppColors.blue,
                        value: '${progress.activeDaysThisWeek}/7',
                        label: 'Ngày hoạt động',
                      ),
                      _JourneyMetric(
                        width: width,
                        icon: Icons.local_fire_department_outlined,
                        color: AppColors.cinnabar,
                        value: '${progress.streakDays} ngày',
                        label: 'Chuỗi hiện tại',
                      ),
                      _JourneyMetric(
                        width: width,
                        icon: Icons.task_alt,
                        color: AppColors.jade,
                        value: '${progress.accuracy}%',
                        label: 'Độ chính xác',
                      ),
                      _JourneyMetric(
                        width: width,
                        icon: Icons.refresh,
                        color: AppColors.amber,
                        value: '${progress.dueReviewWords}',
                        label: 'Từ cần ôn',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Thời lượng mỗi ngày',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              _WeeklyActivityChart(
                days: progress.lastSevenDays,
                dailyGoalMinutes: progress.dailyGoalMinutes,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.insights_outlined, color: AppColors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Năng lực hiện tại',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onOpenPractice,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Luyện tập'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SkillProgress(
                label: 'Từ vựng',
                score: progress.vocabularyScore,
                color: AppColors.cinnabar,
              ),
              _SkillProgress(
                label: 'Ngữ pháp',
                score: progress.grammarScore,
                color: AppColors.blue,
              ),
              _SkillProgress(
                label: 'Nghe và nói',
                score: progress.speakingScore,
                color: AppColors.jade,
              ),
              _SkillProgress(
                label: 'Đọc hiểu',
                score: progress.readingScore,
                color: AppColors.plum,
                showBottomSpacing: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.route_outlined, color: AppColors.cinnabar),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Lộ trình HSK',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onOpenVocabulary,
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('Học từ'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._visibleRoadmap(progress).map(
                (item) => _HskProgressRow(
                  item: item,
                  isCurrent: item.level == progress.targetLevel,
                  onTap: onOpenVocabulary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, color: AppColors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Hoạt động gần đây',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (progress.recentActivities.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    'Hoàn thành một bài học để bắt đầu nhật ký tiến độ.',
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              else
                ...progress.recentActivities
                    .take(5)
                    .map((item) => _RecentActivityRow(item: item)),
            ],
          ),
        ),
      ],
    );
  }

  List<HskLevelProgress> _visibleRoadmap(LearningProgressSnapshot snapshot) {
    final target =
        int.tryParse(snapshot.targetLevel.replaceAll(RegExp(r'\D'), '')) ?? 2;
    return snapshot.roadmap.take(max(4, min(6, target + 1))).toList();
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return SizedBox(
      width: 66,
      height: 66,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 7,
              backgroundColor: AppColors.line,
              color: AppColors.jade,
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              color: AppColors.jade,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyMetric extends StatelessWidget {
  const _JourneyMetric({
    required this.width,
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final double width;
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyActivityChart extends StatelessWidget {
  const _WeeklyActivityChart({
    required this.days,
    required this.dailyGoalMinutes,
  });

  final List<LearningDayStat> days;
  final int dailyGoalMinutes;

  @override
  Widget build(BuildContext context) {
    final values = days.isEmpty
        ? List.generate(
            7,
            (index) => LearningDayStat(
              date: DateTime.now().subtract(Duration(days: 6 - index)),
            ),
          )
        : days;
    final maxMinutes = max(
      dailyGoalMinutes,
      values.fold<int>(1, (peak, day) => max(peak, day.studyMinutes)),
    );
    return SizedBox(
      height: 132,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: values.map((day) {
          final ratio = day.studyMinutes <= 0
              ? 0.0
              : (day.studyMinutes / maxMinutes).clamp(0.0, 1.0);
          final reachedGoal =
              dailyGoalMinutes > 0 && day.studyMinutes >= dailyGoalMinutes;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    day.studyMinutes == 0 ? '' : '${day.studyMinutes}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: reachedGoal ? AppColors.jade : AppColors.muted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 22,
                    height: max(4.0, ratio * 80),
                    decoration: BoxDecoration(
                      color: day.studyMinutes == 0
                          ? AppColors.line
                          : reachedGoal
                          ? AppColors.jade
                          : AppColors.blue,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    day.weekdayLabel,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _SkillProgress extends StatelessWidget {
  const _SkillProgress({
    required this.label,
    required this.score,
    required this.color,
    this.showBottomSpacing = true,
  });

  final String label;
  final int score;
  final Color color;
  final bool showBottomSpacing;

  @override
  Widget build(BuildContext context) {
    final safeScore = score.clamp(0, 100);
    return Padding(
      padding: EdgeInsets.only(bottom: showBottomSpacing ? 14 : 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '$safeScore%',
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: safeScore / 100,
              minHeight: 8,
              backgroundColor: AppColors.line,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _HskProgressRow extends StatelessWidget {
  const _HskProgressRow({
    required this.item,
    required this.isCurrent,
    required this.onTap,
  });

  final HskLevelProgress item;
  final bool isCurrent;
  final VoidCallback onTap;

  Color get color {
    return switch (item.level) {
      'HSK 1' => AppColors.jade,
      'HSK 2' => AppColors.cinnabar,
      'HSK 3' => AppColors.blue,
      'HSK 4' => AppColors.plum,
      'HSK 5' => AppColors.amber,
      _ => AppColors.ink,
    };
  }

  @override
  Widget build(BuildContext context) {
    final percent = (item.progress * 100).round();
    return Material(
      color: isCurrent ? color.withValues(alpha: 0.06) : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.school_outlined, color: color, size: 21),
                  const SizedBox(width: 8),
                  Text(
                    item.level,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 8),
                    StatusPill(label: 'Đang học', color: color),
                  ],
                  const Spacer(),
                  Flexible(
                    child: Text(
                      '${item.learnedWords}/${item.totalWords} · $percent%',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 8,
                  backgroundColor: AppColors.line,
                  color: color,
                ),
              ),
              if (item.masteredWords > 0 || item.dueReview > 0) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.masteredWords} từ đã vững',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        '${item.dueReview} cần ôn',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityRow extends StatelessWidget {
  const _RecentActivityRow({required this.item});

  final LearningActivityItem item;

  Color get color {
    return switch (item.kind) {
      'vocabulary' => AppColors.cinnabar,
      'grammar' || 'quiz' => AppColors.blue,
      'speaking' => AppColors.jade,
      'reading' => AppColors.plum,
      _ => AppColors.amber,
    };
  }

  IconData get icon {
    return switch (item.kind) {
      'vocabulary' => Icons.translate,
      'grammar' => Icons.auto_fix_high_outlined,
      'quiz' => Icons.fact_check_outlined,
      'speaking' => Icons.mic_none,
      'reading' => Icons.menu_book_outlined,
      _ => Icons.check_circle_outline,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (item.detail.isNotEmpty)
                  Text(
                    item.detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(item.timeLabel, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            Icon(icon, size: 50, color: AppColors.muted),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class InfoLine extends StatelessWidget {
  const InfoLine({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.cinnabar, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.muted,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ExampleTile extends StatelessWidget {
  const ExampleTile({super.key, required this.example});

  final ExampleSentenceData example;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.cn,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            example.py,
            style: const TextStyle(
              color: AppColors.blue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            example.vi,
            style: const TextStyle(
              color: AppColors.muted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

class CompactWordCard extends StatelessWidget {
  const CompactWordCard({
    super.key,
    required this.entry,
    required this.onRemove,
  });

  final VocabEntry entry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Text(
            entry.simplified,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.pinyin,
                  style: const TextStyle(
                    color: AppColors.cinnabar,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  entry.meaning,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Bỏ khỏi sổ tay',
            onPressed: onRemove,
            icon: const Icon(Icons.bookmark_remove_outlined),
          ),
        ],
      ),
    );
  }
}

class FlashcardTopicArt extends StatelessWidget {
  const FlashcardTopicArt({
    super.key,
    required this.topic,
    required this.color,
  });

  final FlashcardTopic topic;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.95),
            _pairedVisualColor(color).withValues(alpha: 0.92),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: -8,
            child: Icon(
              topic.icon,
              size: 54,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
          Center(child: Icon(topic.icon, color: Colors.white, size: 30)),
        ],
      ),
    );
    final imagePath = topic.imagePath;
    if (imagePath == null || imagePath.isEmpty) return fallback;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.48),
                Colors.black.withValues(alpha: 0.08),
              ],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
        ),
      ],
    );
  }
}

class FlashcardWordArt extends StatelessWidget {
  const FlashcardWordArt({super.key, required this.entry});

  final VocabEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = _visualPalette(entry.simplified);
    final icon = _visualIconFor(entry);
    final fallback = _fallback(colors, icon);
    final imagePath = entry.imagePath;
    if (imagePath == null || imagePath.isEmpty) return fallback;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => fallback,
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.02),
                Colors.black.withValues(alpha: 0.68),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(
          left: 28,
          right: 28,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.simplified,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  height: 1,
                  shadows: [Shadow(blurRadius: 12, color: Colors.black87)],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.meaning,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fallback(List<Color> colors, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            right: -28,
            top: -34,
            child: Icon(
              icon,
              size: 180,
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            left: -18,
            bottom: -24,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.13),
              ),
            ),
          ),
          Positioned(
            right: 22,
            bottom: 34,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Học bằng hình',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 28,
            top: 24,
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: colors.first, size: 62),
            ),
          ),
          Positioned(
            left: 28,
            right: 28,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.simplified,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.savedCount,
    required this.onTap,
  });

  final FlashcardTopic topic;
  final int savedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _levelColor(topic.level);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AppCard(
        child: Row(
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: FlashcardTopicArt(topic: topic, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      StatusPill(label: 'Flashcard', color: color),
                      const StatusPill(label: 'Quiz', color: AppColors.blue),
                    ],
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: topic.words.isEmpty
                          ? 0
                          : savedCount / topic.words.length,
                      minHeight: 5,
                      backgroundColor: AppColors.line,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$savedCount/${topic.words.length} từ',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FlashcardImageSuggestion {
  const FlashcardImageSuggestion({
    required this.provider,
    required this.keyword,
    required this.style,
    required this.flaticonSearchUrl,
    required this.note,
  });

  final String provider;
  final String keyword;
  final String style;
  final String flaticonSearchUrl;
  final String note;

  factory FlashcardImageSuggestion.fromJson(Map<String, dynamic> json) {
    return FlashcardImageSuggestion(
      provider: (json['provider'] ?? 'local-flat-icon').toString(),
      keyword: (json['keyword'] ?? '').toString(),
      style: (json['style'] ?? '').toString(),
      flaticonSearchUrl: (json['flaticonSearchUrl'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
    );
  }

  factory FlashcardImageSuggestion.fallback(VocabEntry entry) {
    final keyword = '${entry.simplified} ${entry.meaning}'.trim();
    return FlashcardImageSuggestion(
      provider: 'fallback-flat-icon',
      keyword: keyword,
      style: 'rounded flat vector, bright, simple object, no text',
      flaticonSearchUrl:
          'https://www.flaticon.com/search?word=${Uri.encodeComponent(keyword)}',
      note:
          'Backend chưa phản hồi. Có thể dùng URL tìm kiếm này để lấy ảnh có license, hoặc thay bằng asset/API ảnh riêng.',
    );
  }
}

class FlashcardImageRepository {
  static Future<FlashcardImageSuggestion> suggest(VocabEntry entry) async {
    final uri = Uri.parse(
      '${DictionaryRepository.apiBaseUrl}/flashcard/image-suggestion'
      '?q=${Uri.encodeComponent(entry.simplified)}'
      '&meaning=${Uri.encodeComponent(entry.meaning)}',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 3));
    if (response.statusCode != 200) {
      throw Exception('Image suggestion API ${response.statusCode}');
    }
    return FlashcardImageSuggestion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

class FlashcardView extends StatelessWidget {
  const FlashcardView({
    super.key,
    required this.entry,
    required this.showBack,
    required this.saved,
    required this.onFlip,
    required this.onSpeak,
    required this.onToggleSaved,
  });

  final VocabEntry entry;
  final bool showBack;
  final bool saved;
  final VoidCallback onFlip;
  final VoidCallback onSpeak;
  final VoidCallback onToggleSaved;

  void _showPronunciationCheck(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => PronunciationPracticeSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onFlip,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        children: [
          // 1. IMAGE BOX
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (entry.imagePath != null && entry.imagePath!.isNotEmpty)
                      Image.asset(
                        entry.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _FlashcardImageFallback(entry: entry),
                      )
                    else
                      _FlashcardImageFallback(entry: entry),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.12),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.94),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.cinnabar,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 2. PINYIN
          Text(
            entry.pinyin,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              color: AppColors.muted,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),

          // 3. BIG HANZI
          Text(
            entry.simplified,
            style: const TextStyle(
              fontSize: 80,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 16),

          // 4. MEANING
          Text(
            entry.meaning,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.cinnabar,
            ),
          ),

          const SizedBox(height: 24),

          // 5. EXAMPLES (Back of Card)
          if (showBack && entry.examples.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    entry.examples.first.cn,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.examples.first.py,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.examples.first.vi,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // 6. BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filledTonal(
                tooltip: 'Nghe mẫu',
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up_outlined),
              ),
              const SizedBox(width: 16),
              IconButton.filledTonal(
                tooltip: saved ? 'Bỏ khỏi sổ tay' : 'Lưu vào sổ tay',
                onPressed: onToggleSaved,
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border),
              ),
              const SizedBox(width: 16),
              IconButton.filledTonal(
                tooltip: 'Kiểm tra phát âm',
                onPressed: () => _showPronunciationCheck(context),
                icon: const Icon(Icons.mic_none_outlined),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FlashcardImageFallback extends StatelessWidget {
  const _FlashcardImageFallback({required this.entry});

  final VocabEntry entry;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEAF6F0), Color(0xFFFFF1E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          entry.simplified,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 76,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class GrammarLessonCard extends StatelessWidget {
  const GrammarLessonCard({
    super.key,
    required this.index,
    required this.lesson,
  });

  final int index;
  final GrammarLessonData lesson;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  lesson.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F6FB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.blue.withValues(alpha: 0.16)),
            ),
            child: Text(
              lesson.pattern,
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(lesson.explanation),
          const SizedBox(height: 12),
          const Text(
            'Ví dụ minh họa:',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 8),
          ...lesson.examples.map((ex) => ExampleTile(example: ex)),
          if (lesson.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            AppCard(color: const Color(0xFFFFFAEA), child: Text(lesson.note)),
          ],
        ],
      ),
    );
  }
}

class GrammarResultCard extends StatelessWidget {
  const GrammarResultCard({super.key, required this.result});

  final GrammarCheckResult result;

  @override
  Widget build(BuildContext context) {
    final unavailable = result.score <= 0 && !result.isAi;
    final good = result.score >= 85;
    final color = unavailable
        ? AppColors.blue
        : good
        ? AppColors.jade
        : result.score >= 60
        ? AppColors.amber
        : AppColors.cinnabar;
    return Column(
      children: [
        AppCard(
          child: Row(
            children: [
              Container(
                width: 78,
                height: 78,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 5),
                ),
                child: Text(
                  unavailable ? 'AI' : '${result.score}',
                  style: TextStyle(
                    color: color,
                    fontSize: unavailable ? 20 : 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(result.summary),
                    const SizedBox(height: 8),
                    StatusPill(
                      icon: result.isAi
                          ? Icons.auto_awesome
                          : Icons.offline_bolt_outlined,
                      label: result.provider,
                      color: color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          color: const Color(0xFFEFFAF4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Câu sửa lại chính xác:',
                style: TextStyle(
                  color: AppColors.jade,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 10),
              SelectableText(
                result.correction,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.explanation,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (result.suggestions.isNotEmpty) ...[
          const SizedBox(height: 12),
          AppCard(
            color: const Color(0xFFF0F6FB),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gợi ý diễn đạt:',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ...result.suggestions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SelectableText(item),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...result.errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                color: const Color(0xFFFFF7E8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.amber,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(error)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class PronunciationScoreCard extends StatelessWidget {
  const PronunciationScoreCard({
    super.key,
    required this.score,
    required this.onNext,
  });

  final int score;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final color = score >= 85
        ? AppColors.jade
        : score >= 60
        ? AppColors.amber
        : AppColors.cinnabar;
    final title = score >= 85
        ? 'Phát âm tốt'
        : score >= 60
        ? 'Khá ổn'
        : 'Cần luyện thêm';
    final feedback = score >= 85
        ? 'Bạn đọc rất gần với câu mẫu.'
        : score >= 60
        ? 'Hãy nghe mẫu thêm một lần và chú ý thanh điệu.'
        : 'Đọc chậm hơn, rõ từng âm tiết và thử lại.';
    return AppCard(
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 5),
            ),
            child: Text(
              '$score',
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(feedback),
              ],
            ),
          ),
          TextButton(onPressed: onNext, child: const Text('Câu tiếp')),
        ],
      ),
    );
  }
}

class VideoLessonCard extends StatelessWidget {
  const VideoLessonCard({
    super.key,
    required this.lesson,
    required this.onOpen,
  });

  final VideoLessonData lesson;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(8),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 8.4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                    child: Image.network(
                      lesson.thumbnail,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Container(color: const Color(0xFF1E2132)),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(8),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.58),
                        ],
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.play_circle_fill,
                      color: Colors.white,
                      size: 56,
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: StatusPill(
                      label: lesson.level,
                      color: AppColors.jade,
                    ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.62),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${lesson.subtitles.length} câu',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lesson.titleCn,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusPill(
                        icon: Icons.ondemand_video_outlined,
                        label: lesson.source,
                        color: AppColors.cinnabar,
                      ),
                      StatusPill(
                        icon: lesson.hasTimedSubtitles
                            ? Icons.sync
                            : Icons.edit_note,
                        label: lesson.hasTimedSubtitles
                            ? 'Phụ đề đã khớp'
                            : 'Luyện câu thủ công',
                        color: lesson.hasTimedSubtitles
                            ? AppColors.jade
                            : AppColors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.youtubeUrl,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.blue, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VocabEntry {
  const VocabEntry({
    required this.simplified,
    required this.pinyin,
    required this.meaning,
    this.hanViet = '',
    this.level = 'HSK 1',
    this.wordType = '',
    this.imagePath,
    required this.examples,
  });

  final String simplified;
  final String pinyin;
  final String meaning;
  final String hanViet;
  final String level;
  final String wordType;
  final String? imagePath;
  final List<ExampleSentenceData> examples;

  VocabEntry copyWith({
    String? simplified,
    String? pinyin,
    String? meaning,
    String? hanViet,
    String? level,
    String? wordType,
    String? imagePath,
    List<ExampleSentenceData>? examples,
  }) {
    return VocabEntry(
      simplified: simplified ?? this.simplified,
      pinyin: pinyin ?? this.pinyin,
      meaning: meaning ?? this.meaning,
      hanViet: hanViet ?? this.hanViet,
      level: level ?? this.level,
      wordType: wordType ?? this.wordType,
      imagePath: imagePath ?? this.imagePath,
      examples: examples ?? this.examples,
    );
  }
}

class ExampleSentenceData {
  const ExampleSentenceData(this.cn, this.py, this.vi);
  final String cn;
  final String py;
  final String vi;
}

class FlashcardTopic {
  const FlashcardTopic({
    required this.id,
    required this.level,
    required this.name,
    required this.icon,
    required this.words,
    this.imagePath,
  });

  final String id;
  final String level;
  final String name;
  final IconData icon;
  final List<VocabEntry> words;
  final String? imagePath;
}

class GrammarLessonData {
  const GrammarLessonData({
    required this.level,
    required this.title,
    required this.pattern,
    required this.explanation,
    required this.examples,
    this.note = '',
  });

  final String level;
  final String title;
  final String pattern;
  final String explanation;
  final List<ExampleSentenceData> examples;
  final String note;
}

class GrammarCheckResult {
  const GrammarCheckResult({
    required this.score,
    required this.title,
    required this.summary,
    required this.correction,
    required this.explanation,
    required this.errors,
    this.source = 'local',
    this.provider = 'Bộ quy tắc nội bộ',
    this.suggestions = const [],
  });

  final int score;
  final String title;
  final String summary;
  final String correction;
  final String explanation;
  final List<String> errors;
  final String source;
  final String provider;
  final List<String> suggestions;

  bool get isAi => source.startsWith('gemini');
}

class SentencePractice {
  const SentencePractice(
    this.level,
    this.cn,
    this.py,
    this.vi, {
    this.topic = 'Giao tiếp hằng ngày',
  });
  final String level;
  final String cn;
  final String py;
  final String vi;
  final String topic;
}

class NewsArticleData {
  const NewsArticleData({
    required this.id,
    required this.level,
    required this.source,
    required this.title,
    required this.titleVi,
    required this.content,
    required this.summaryVi,
    this.link,
    this.sentences = const [],
    this.live = false,
    this.publishedAt = '',
  });

  final String id;
  final String level;
  final String source;
  final String title;
  final String titleVi;
  final String content;
  final String summaryVi;
  final String? link;
  final List<ArticleSentenceData> sentences;
  final bool live;
  final String publishedAt;
}

class ArticleSentenceData {
  const ArticleSentenceData(this.cn, this.py, this.vi);

  final String cn;
  final String py;
  final String vi;
}

class VideoSubtitleData {
  const VideoSubtitleData(
    this.cn,
    this.py,
    this.vi, {
    this.start = 0,
    this.end = 0,
  });

  final String cn;
  final String py;
  final String vi;
  final double start;
  final double end;
}

class VideoLessonData {
  const VideoLessonData({
    required this.title,
    required this.titleCn,
    required this.level,
    required this.youtubeId,
    required this.subtitles,
    this.source = 'Little Fox Chinese',
    this.transcriptStatus = 'untimed',
  });

  final String title;
  final String titleCn;
  final String level;
  final String youtubeId;
  final List<VideoSubtitleData> subtitles;
  final String source;
  final String transcriptStatus;
  bool get hasTimedSubtitles =>
      subtitles.isNotEmpty &&
      subtitles.every((subtitle) => subtitle.end > subtitle.start);
  String get thumbnail => 'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg';
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$youtubeId';
}

class DictionaryRepository {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001',
  );
  static final Map<String, VocabEntry> _cache = {};
  static final Map<String, VocabEntry> _exactEntries = {};
  static final Map<String, String> _flashcardImagePaths = {};
  static final Map<String, VocabEntry> _flashcardEntries = {};
  static final List<VocabEntry> _assetEntries = [];
  static final List<VocabEntry> _hskEntries = [];
  static Future<void>? _loadFuture;
  static bool _baseIndexed = false;
  static const trending = ['你好', '谢谢', '学习', '朋友', '工作', '突然', '中国', '汉语'];

  static List<VocabEntry> get allEntries => [
    ...entries,
    ..._assetEntries,
    ..._hskEntries,
  ];

  static Future<void> ensureLoaded() {
    return _loadFuture ??= _loadAssets();
  }

  static void _ensureBaseIndex() {
    if (_baseIndexed) return;
    _indexEntries(entries);
    _baseIndexed = true;
  }

  static void _indexEntries(Iterable<VocabEntry> values) {
    for (final entry in values) {
      _exactEntries.putIfAbsent(entry.simplified, () => entry);
    }
  }

  static Future<void> _loadAssets() async {
    _ensureBaseIndex();
    if (_assetEntries.isNotEmpty || _hskEntries.isNotEmpty) return;
    await _loadFlashcardImageIndex();
    try {
      final seed = jsonDecode(
        await rootBundle.loadString('assets/data/dictionary_seed_clean.json'),
      );
      if (seed is List) {
        _assetEntries.addAll(
          seed
              .whereType<Map>()
              .map((raw) => _entryFromMap(Map<String, dynamic>.from(raw)))
              .whereType<VocabEntry>(),
        );
        _indexEntries(_assetEntries);
      }
    } catch (_) {}

    try {
      final compact = jsonDecode(
        await rootBundle.loadString(
          'assets/data/dictionary_hsk14_compact.json',
        ),
      );
      if (compact is List) {
        final known = {
          for (final entry in [...entries, ..._assetEntries]) entry.simplified,
        };
        _hskEntries.addAll(
          compact.whereType<Map>().map((raw) {
            final map = Map<String, dynamic>.from(raw);
            final word = (map['simplified'] ?? '').toString();
            if (word.isEmpty || known.contains(word)) return null;
            final level = map['hskLevel'] ?? 1;
            final meaningEn = (map['meaningEn'] ?? '').toString().trim();
            final meaning = meaningEn.isEmpty
                ? 'Nghĩa tiếng Việt đang cập nhật'
                : 'Nghĩa Việt đang cập nhật · $meaningEn';
            return VocabEntry(
              simplified: word,
              pinyin: (map['pinyin'] ?? '').toString(),
              meaning: meaning,
              level: 'HSK $level',
              wordType: (map['wordType'] ?? '').toString(),
              examples: [
                ExampleSentenceData(
                  '我今天学习"$word"。',
                  'Wǒ jīntiān xuéxí "$word".',
                  'Hôm nay tôi học từ "$word".',
                ),
              ],
            );
          }).whereType<VocabEntry>(),
        );
        _indexEntries(_hskEntries);
      }
    } catch (_) {}
  }

  static Future<void> _loadFlashcardImageIndex() async {
    if (_flashcardImagePaths.isNotEmpty) return;
    try {
      final decoded = jsonDecode(
        await rootBundle.loadString('assets/images/flashcards/index.json'),
      );
      if (decoded is! Map || decoded['topics'] is! List) return;
      for (final topic in (decoded['topics'] as List).whereType<Map>()) {
        final topicId = (topic['id'] ?? '').toString().trim();
        final words = topic['words'];
        if (topicId.isEmpty || words is! List) continue;
        for (final raw in words.whereType<Map>()) {
          final word = (raw['word'] ?? '').toString().trim();
          final image = (raw['image'] ?? '').toString().trim();
          if (word.isEmpty || image.isEmpty) continue;
          final imagePath = 'assets/images/flashcards/$topicId/$image';
          _flashcardImagePaths[word] = imagePath;
          final pinyin = (raw['pinyin'] ?? '').toString().trim();
          final meaning = (raw['meaning'] ?? '').toString().trim();
          if (pinyin.isNotEmpty || meaning.isNotEmpty) {
            final normalized = _normalizedFlashcardText(word, pinyin, meaning);
            final importedExamples = <ExampleSentenceData>[];
            final rawExamples = raw['examples'];
            if (rawExamples is List) {
              for (final example in rawExamples.whereType<Map>()) {
                final cn = (example['cn'] ?? '').toString().trim();
                final py = (example['py'] ?? '').toString().trim();
                final vi = (example['vi'] ?? '').toString().trim();
                if (cn.isNotEmpty && vi.isNotEmpty) {
                  importedExamples.add(ExampleSentenceData(cn, py, vi));
                }
              }
            }
            _flashcardEntries[word] = VocabEntry(
              simplified: word,
              pinyin: normalized.$1,
              meaning: normalized.$2,
              imagePath: imagePath,
              examples: importedExamples.isNotEmpty
                  ? importedExamples.take(3).toList()
                  : _flashcardExamples(word, normalized.$1, normalized.$2),
            );
          }
        }
      }
      _indexEntries(_flashcardEntries.values);
    } catch (_) {}
  }

  static VocabEntry? _entryFromMap(Map<String, dynamic> map) {
    final word = (map['simplified'] ?? '').toString().trim();
    final meaning = (map['meaningVi'] ?? map['meaning_vi'] ?? '')
        .toString()
        .trim();
    if (word.isEmpty || meaning.isEmpty) return null;
    final examples = <ExampleSentenceData>[];
    final rawExamples = map['examples'];
    if (rawExamples is List) {
      for (final raw in rawExamples) {
        if (raw is Map && examples.length < 3) {
          final cn = (raw['cn'] ?? '').toString().trim();
          final py = (raw['py'] ?? '').toString().trim();
          final vi = (raw['vi'] ?? '').toString().trim();
          if (cn.isNotEmpty && vi.isNotEmpty) {
            examples.add(ExampleSentenceData(cn, py, vi));
          }
        }
      }
    }
    return VocabEntry(
      simplified: word,
      pinyin: (map['pinyin'] ?? '').toString(),
      meaning: meaning,
      hanViet: (map['hanViet'] ?? map['han_viet'] ?? '').toString(),
      level: 'HSK ${map['hskLevel'] ?? map['hsk_level'] ?? 1}',
      wordType: (map['wordType'] ?? map['word_type'] ?? '').toString(),
      examples: examples.isEmpty
          ? [
              ExampleSentenceData(
                '我今天学习"$word"。',
                'Wǒ jīntiān xuéxí "$word".',
                'Hôm nay tôi học từ "$word".',
              ),
            ]
          : examples,
    );
  }

  static VocabEntry? lookupLocal(String query) {
    _ensureBaseIndex();
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return null;
    final exact = _exactEntries[query.trim()];
    if (exact != null) return exact;
    for (final entry in allEntries) {
      if (_matches(entry, query, q)) {
        return entry;
      }
    }
    return null;
  }

  static (String, String) _normalizedFlashcardText(
    String word,
    String pinyin,
    String meaning,
  ) {
    const curated = <String, (String, String)>{
      '天气': ('tiānqì', 'thời tiết'),
      '热': ('rè', 'nóng'),
      '冷': ('lěng', 'lạnh'),
      '下雨': ('xiàyǔ', 'mưa'),
      '雪': ('xuě', 'tuyết'),
      '风': ('fēng', 'gió'),
      '晴': ('qíng', 'trời nắng, quang đãng'),
      '阴': ('yīn', 'trời âm u'),
      '春天': ('chūntiān', 'mùa xuân'),
      '夏天': ('xiàtiān', 'mùa hè'),
      '学校': ('xuéxiào', 'trường học'),
      '老师': ('lǎoshī', 'giáo viên'),
      '学生': ('xuésheng', 'học sinh'),
      '学习': ('xuéxí', 'học tập'),
      '吃饭': ('chīfàn', 'ăn cơm'),
      '喝水': ('hēshuǐ', 'uống nước'),
      '买东西': ('mǎi dōngxi', 'mua đồ'),
      '打电话': ('dǎ diànhuà', 'gọi điện thoại'),
    };
    final value = curated[word];
    if (value != null) return value;
    return (
      pinyin,
      meaning.isEmpty ? 'Nghĩa tiếng Việt đang cập nhật' : meaning,
    );
  }

  static List<ExampleSentenceData> _flashcardExamples(
    String word,
    String pinyin,
    String meaning,
  ) {
    const curated = <String, List<ExampleSentenceData>>{
      '天气': [
        ExampleSentenceData(
          '今天天气很好，我们去公园吧。',
          'Jīntiān tiānqì hěn hǎo, wǒmen qù gōngyuán ba.',
          'Hôm nay thời tiết rất đẹp, chúng ta đi công viên nhé.',
        ),
        ExampleSentenceData(
          '你喜欢什么样的天气？',
          'Nǐ xǐhuan shénme yàng de tiānqì?',
          'Bạn thích kiểu thời tiết như thế nào?',
        ),
        ExampleSentenceData(
          '天气预报说明天会下雨。',
          'Tiānqì yùbào shuō míngtiān huì xiàyǔ.',
          'Dự báo thời tiết nói ngày mai sẽ mưa.',
        ),
      ],
      '下雨': [
        ExampleSentenceData(
          '外面下雨了，别忘了带伞。',
          'Wàimiàn xiàyǔ le, bié wàng le dài sǎn.',
          'Bên ngoài mưa rồi, đừng quên mang ô.',
        ),
      ],
      '学校': [
        ExampleSentenceData(
          '我每天坐公交车去学校。',
          'Wǒ měitiān zuò gōngjiāochē qù xuéxiào.',
          'Mỗi ngày tôi đi xe buýt đến trường.',
        ),
      ],
      '吃饭': [
        ExampleSentenceData(
          '我们一起去吃饭吧。',
          'Wǒmen yìqǐ qù chīfàn ba.',
          'Chúng ta cùng đi ăn cơm nhé.',
        ),
      ],
    };
    final examples = curated[word];
    if (examples != null) return examples;
    return [
      ExampleSentenceData(
        '这个词是"$word"。',
        'Zhège cí shì "$pinyin".',
        'Từ này có nghĩa là "$meaning".',
      ),
      ExampleSentenceData(
        '请用"$word"说一个完整的句子。',
        'Qǐng yòng "$word" shuō yí ge wánzhěng de jùzi.',
        'Hãy dùng "$word" để nói một câu hoàn chỉnh.',
      ),
    ];
  }

  static bool _matches(VocabEntry entry, String original, String folded) {
    final pinyin = entry.pinyin.toLowerCase().replaceAll(' ', '');
    final compactQuery = folded.replaceAll(' ', '');
    return entry.simplified == original ||
        entry.simplified.startsWith(original) ||
        pinyin.contains(compactQuery) ||
        entry.meaning.toLowerCase().contains(folded) ||
        entry.hanViet.toLowerCase().contains(folded);
  }

  static VocabEntry forFlashcard(
    String word, {
    required String level,
    required String imagePath,
  }) {
    final found = lookupLocal(word);
    final flashcardEntry = _flashcardEntries[word];
    final resolvedImagePath = _flashcardImagePaths[word] ?? imagePath;
    if (flashcardEntry != null) {
      return flashcardEntry.copyWith(
        imagePath: resolvedImagePath,
        level: level,
      );
    }
    if (found == null) {
      return VocabEntry(
        simplified: word,
        pinyin: '',
        meaning: 'Nghĩa tiếng Việt đang cập nhật',
        level: level,
        imagePath: resolvedImagePath,
        examples: [
          ExampleSentenceData(
            '请用"$word"造句。',
            'Qǐng yòng "$word" zàojù.',
            'Hãy đặt câu với từ "$word".',
          ),
        ],
      );
    }
    return found.imagePath == null || _flashcardImagePaths.containsKey(word)
        ? found.copyWith(imagePath: resolvedImagePath, level: level)
        : found.copyWith(level: level);
  }

  static VocabEntry? lookupAt(String text, int start) {
    _ensureBaseIndex();
    for (var len = min(5, text.length - start); len >= 1; len--) {
      final slice = text.substring(start, start + len);
      if (!RegExp(r'^[\u4e00-\u9fff]+$').hasMatch(slice)) continue;
      final entry = _exactEntries[slice];
      if (entry != null) return entry;
    }
    return null;
  }

  static Future<VocabEntry?> lookupRemote(String query) async {
    final q = query.trim();
    if (q.isEmpty) return null;
    if (_cache.containsKey(q)) return _cache[q];
    try {
      final uri = Uri.parse(
        '$apiBaseUrl/dictionary/search?q=${Uri.encodeComponent(q)}',
      );
      final response = await http
          .get(uri)
          .timeout(const Duration(milliseconds: 900));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List || decoded.isEmpty) return null;
      final map = Map<String, dynamic>.from(decoded.first as Map);
      final meaningVi = (map['meaningVi'] ?? map['meaning_vi'] ?? '')
          .toString()
          .trim();
      final meaningEn = (map['meaningEn'] ?? map['meaning_en'] ?? '')
          .toString()
          .trim();
      final meaning = meaningVi.isNotEmpty
          ? meaningVi
          : meaningEn.isEmpty
          ? ''
          : 'Nghĩa Việt đang cập nhật · $meaningEn';
      if (meaning.isEmpty) return null;
      final examples = <ExampleSentenceData>[];
      if (map['examples'] is List) {
        for (final raw in map['examples'] as List) {
          if (raw is Map && examples.length < 3) {
            final cn = (raw['cn'] ?? '').toString();
            final py = (raw['py'] ?? '').toString();
            final vi = (raw['vi'] ?? '').toString();
            if (cn.isNotEmpty && vi.isNotEmpty) {
              examples.add(ExampleSentenceData(cn, py, vi));
            }
          }
        }
      }
      final entry = VocabEntry(
        simplified: (map['simplified'] ?? q).toString(),
        pinyin: (map['pinyin'] ?? '').toString(),
        meaning: meaning,
        hanViet: (map['hanViet'] ?? map['han_viet'] ?? '').toString(),
        level: 'HSK ${map['hskLevel'] ?? map['hsk_level'] ?? 1}',
        wordType: (map['wordType'] ?? map['word_type'] ?? '').toString(),
        examples: examples.isEmpty
            ? [
                ExampleSentenceData(
                  '我今天学习$q。',
                  'Wǒ jīntiān xuéxí $q.',
                  'Hôm nay tôi học từ $q.',
                ),
              ]
            : examples,
      );
      _cache[q] = entry;
      _indexEntries([entry]);
      return entry;
    } catch (_) {
      return null;
    }
  }

  static final entries = <VocabEntry>[
    e(
      '你好',
      'nǐ hǎo',
      'xin chào',
      hanViet: 'nhĩ hảo',
      examples: const [ExampleSentenceData('你好！', 'Nǐ hǎo!', 'Xin chào!')],
    ),
    e(
      '谢谢',
      'xièxie',
      'cảm ơn',
      hanViet: 'tạ tạ',
      examples: const [
        ExampleSentenceData('谢谢你。', 'Xièxie nǐ.', 'Cảm ơn bạn.'),
      ],
    ),
    e(
      '学习',
      'xuéxí',
      'học tập',
      hanViet: 'học tập',
      wordType: 'động từ',
      imagePath: 'assets/images/flashcards/family/033e1fb01c.jpg',
      examples: const [
        ExampleSentenceData(
          '我每天学习汉语。',
          'Wǒ měitiān xuéxí Hànyǔ.',
          'Tôi học tiếng Trung mỗi ngày.',
        ),
      ],
    ),
    e(
      '朋友',
      'péngyou',
      'bạn bè',
      hanViet: 'bằng hữu',
      imagePath: 'assets/images/flashcards/family/427034659a.jpg',
      examples: const [
        ExampleSentenceData(
          '他是我的朋友。',
          'Tā shì wǒ de péngyou.',
          'Anh ấy là bạn của tôi.',
        ),
      ],
    ),
    e(
      '工作',
      'gōngzuò',
      'làm việc, công việc',
      hanViet: 'công tác',
      examples: const [
        ExampleSentenceData(
          '我在公司工作。',
          'Wǒ zài gōngsī gōngzuò.',
          'Tôi làm việc ở công ty.',
        ),
      ],
    ),
    e(
      '喜欢',
      'xǐhuan',
      'thích',
      hanViet: 'hỉ hoan',
      examples: const [
        ExampleSentenceData(
          '我喜欢喝茶。',
          'Wǒ xǐhuan hē chá.',
          'Tôi thích uống trà.',
        ),
      ],
    ),
    e(
      '中国',
      'Zhōngguó',
      'Trung Quốc',
      hanViet: 'Trung Quốc',
      examples: const [
        ExampleSentenceData(
          '我想去中国。',
          'Wǒ xiǎng qù Zhōngguó.',
          'Tôi muốn đi Trung Quốc.',
        ),
      ],
    ),
    e(
      '汉语',
      'Hànyǔ',
      'tiếng Hán, tiếng Trung',
      hanViet: 'Hán ngữ',
      examples: const [
        ExampleSentenceData(
          '你会说汉语吗？',
          'Nǐ huì shuō Hànyǔ ma?',
          'Bạn biết nói tiếng Trung không?',
        ),
      ],
    ),
    e(
      '热闹',
      'rènao',
      'náo nhiệt, đông vui',
      hanViet: 'nhiệt nháo',
      wordType: 'tính từ',
      examples: const [
        ExampleSentenceData(
          '市场里很热闹。',
          'Shìchǎng lǐ hěn rènao.',
          'Trong chợ rất náo nhiệt.',
        ),
        ExampleSentenceData(
          '春节的时候街上很热闹。',
          'Chūnjié de shíhou jiē shang hěn rènao.',
          'Vào dịp Tết, ngoài phố rất đông vui.',
        ),
      ],
    ),
    e(
      '苹果',
      'píngguǒ',
      'quả táo',
      imagePath: 'assets/images/flashcards/food/edfec00f07.jpg',
      examples: const [
        ExampleSentenceData(
          '我买一个苹果。',
          'Wǒ mǎi yí ge píngguǒ.',
          'Tôi mua một quả táo.',
        ),
      ],
    ),
    e(
      '米饭',
      'mǐfàn',
      'cơm',
      imagePath: 'assets/images/flashcards/food/814b1c8d80.jpg',
      examples: const [
        ExampleSentenceData(
          '我喜欢吃米饭。',
          'Wǒ xǐhuan chī mǐfàn.',
          'Tôi thích ăn cơm.',
        ),
      ],
    ),
    e(
      '猫',
      'māo',
      'con mèo',
      imagePath: 'assets/images/flashcards/animals/b655de688e.jpg',
      examples: const [
        ExampleSentenceData(
          '小猫在椅子下面。',
          'Xiǎomāo zài yǐzi xiàmiàn.',
          'Con mèo nhỏ ở dưới ghế.',
        ),
      ],
    ),
    e(
      '狗',
      'gǒu',
      'con chó',
      imagePath: 'assets/images/flashcards/animals/5090e44ef9.jpg',
      examples: const [
        ExampleSentenceData(
          '这只狗很可爱。',
          'Zhè zhī gǒu hěn kěài.',
          'Con chó này rất đáng yêu.',
        ),
      ],
    ),
    e(
      '红色',
      'hóngsè',
      'màu đỏ',
      imagePath: 'assets/images/flashcards/colors/ddb86dd31c.jpg',
      examples: const [
        ExampleSentenceData('我喜欢红色。', 'Wǒ xǐhuan hóngsè.', 'Tôi thích màu đỏ.'),
      ],
    ),
    e(
      '爸爸',
      'bàba',
      'bố, ba',
      imagePath: 'assets/images/flashcards/family/e6c7ee6003.jpg',
      examples: const [
        ExampleSentenceData('爸爸去工作了。', 'Bàba qù gōngzuò le.', 'Bố đi làm rồi.'),
      ],
    ),
    e(
      '妈妈',
      'māma',
      'mẹ',
      imagePath: 'assets/images/flashcards/family/e571dca2d0.jpg',
      examples: const [
        ExampleSentenceData('妈妈做饭。', 'Māma zuò fàn.', 'Mẹ nấu cơm.'),
      ],
    ),
    e(
      '飞机',
      'fēijī',
      'máy bay',
      imagePath: 'assets/images/flashcards/transport/fed19a817b.jpg',
      examples: const [
        ExampleSentenceData(
          '我坐飞机去北京。',
          'Wǒ zuò fēijī qù Běijīng.',
          'Tôi đi máy bay đến Bắc Kinh.',
        ),
      ],
    ),
    e(
      '眼睛',
      'yǎnjing',
      'mắt',
      imagePath: 'assets/images/flashcards/body/e6134a2993.jpg',
      examples: const [
        ExampleSentenceData(
          '她的眼睛很漂亮。',
          'Tā de yǎnjing hěn piàoliang.',
          'Mắt cô ấy rất đẹp.',
        ),
      ],
    ),
    e(
      '经理',
      'jīnglǐ',
      'giám đốc, quản lý',
      level: 'HSK 3',
      examples: const [
        ExampleSentenceData(
          '经理正在开会。',
          'Jīnglǐ zhèngzài kāihuì.',
          'Quản lý đang họp.',
        ),
      ],
    ),
    e(
      '经济',
      'jīngjì',
      'kinh tế',
      level: 'HSK 4',
      examples: const [
        ExampleSentenceData(
          '中国经济发展很快。',
          'Zhōngguó jīngjì fāzhǎn hěn kuài.',
          'Kinh tế Trung Quốc phát triển rất nhanh.',
        ),
      ],
    ),
  ];

  static VocabEntry e(
    String simplified,
    String pinyin,
    String meaning, {
    String hanViet = '',
    String level = 'HSK 1',
    String wordType = '',
    String? imagePath,
    required List<ExampleSentenceData> examples,
  }) {
    return VocabEntry(
      simplified: simplified,
      pinyin: pinyin,
      meaning: meaning,
      hanViet: hanViet,
      level: level,
      wordType: wordType,
      imagePath: imagePath,
      examples: examples,
    );
  }
}

class NotebookStore {
  static const _key = 'vnchinese_notebook_words';

  static Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_key) ?? <String>[]).toSet();
  }

  static Future<Set<String>> toggle(String word) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_key) ?? <String>[]).toSet();
    if (set.contains(word)) {
      set.remove(word);
    } else {
      set.add(word);
    }
    await prefs.setStringList(_key, set.toList()..sort());
    return set;
  }
}

class FlashcardRepository {
  static List<FlashcardTopic>? _cache;

  static List<FlashcardTopic> get fallbackTopics => [
    _topic(
      'hsk1_greeting',
      'HSK 1',
      'Chào hỏi cơ bản',
      Icons.waving_hand_outlined,
      ['你好', '谢谢', '汉语', '朋友'],
      'assets/images/flashcards/family/427034659a.jpg',
    ),
  ];

  static Future<List<FlashcardTopic>> loadTopics() async {
    if (_cache != null) return _cache!;
    await DictionaryRepository.ensureLoaded();
    final plannedTopics = _plans.map((plan) {
      return _topic(
        plan.id,
        plan.level,
        plan.name,
        plan.icon,
        plan.words,
        plan.imagePath,
      );
    }).toList();
    final plannedIds = plannedTopics.map((topic) => topic.id).toSet();
    final assetTopics = await _loadAssetTopics(plannedIds);
    _cache = [...plannedTopics, ...assetTopics];
    return _cache!;
  }

  static Future<List<FlashcardTopic>> _loadAssetTopics(
    Set<String> skipIds,
  ) async {
    try {
      dynamic decoded;
      try {
        final response = await http
            .get(
              Uri.parse(
                '${DictionaryRepository.apiBaseUrl}/content/flashcards',
              ),
            )
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final remote = jsonDecode(response.body);
          if (remote is Map &&
              remote['topics'] is List &&
              (remote['topics'] as List).isNotEmpty) {
            decoded = remote;
          }
        }
      } catch (_) {}
      decoded ??= jsonDecode(
        await rootBundle.loadString('assets/images/flashcards/index.json'),
      );
      if (decoded is! Map || decoded['topics'] is! List) return const [];
      return (decoded['topics'] as List)
          .whereType<Map>()
          .map((raw) => _topicFromAsset(Map<String, dynamic>.from(raw)))
          .whereType<FlashcardTopic>()
          .where((topic) => !skipIds.contains(topic.id))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static FlashcardTopic? _topicFromAsset(Map<String, dynamic> topic) {
    final id = (topic['id'] ?? '').toString().trim();
    final wordsRaw = topic['words'];
    if (id.isEmpty || wordsRaw is! List) return null;
    final level = (topic['level'] ?? _levelForAssetTopic(id)).toString();
    final entries = wordsRaw
        .whereType<Map>()
        .map((raw) {
          final word = (raw['word'] ?? '').toString().trim();
          if (word.isEmpty) return null;
          final image = (raw['image'] ?? '').toString().trim();
          final examples = <ExampleSentenceData>[];
          final rawExamples = raw['examples'];
          if (rawExamples is List) {
            for (final example in rawExamples.whereType<Map>()) {
              final cn = (example['cn'] ?? '').toString().trim();
              final py = (example['py'] ?? '').toString().trim();
              final vi = (example['vi'] ?? '').toString().trim();
              if (cn.isNotEmpty && vi.isNotEmpty) {
                examples.add(ExampleSentenceData(cn, py, vi));
              }
            }
          }
          final fallback = DictionaryRepository.forFlashcard(
            word,
            level: level,
            imagePath: image.isEmpty
                ? 'assets/images/flashcards/family/427034659a.jpg'
                : 'assets/images/flashcards/$id/$image',
          );
          final pinyin = (raw['pinyin'] ?? '').toString().trim();
          final meaning = (raw['meaning'] ?? '').toString().trim();
          return fallback.copyWith(
            pinyin: pinyin.isEmpty ? fallback.pinyin : pinyin,
            meaning: meaning.isEmpty ? fallback.meaning : meaning,
            level: level,
            examples: examples.isEmpty ? fallback.examples : examples,
          );
        })
        .whereType<VocabEntry>()
        .toList();
    if (entries.isEmpty) return null;
    final firstImage = wordsRaw
        .whereType<Map>()
        .map((raw) => (raw['image'] ?? '').toString().trim())
        .firstWhere((image) => image.isNotEmpty, orElse: () => '');
    final imagePath = firstImage.isEmpty
        ? 'assets/images/flashcards/family/427034659a.jpg'
        : 'assets/images/flashcards/$id/$firstImage';
    return FlashcardTopic(
      id: id,
      level: level,
      name: (topic['name'] ?? id).toString(),
      icon: _iconForAssetTopic(id),
      imagePath: imagePath,
      words: entries,
    );
  }

  static String _levelForAssetTopic(String id) {
    return switch (id) {
      'animals' ||
      'body' ||
      'colors' ||
      'family' ||
      'food' ||
      'greeting' ||
      'home' ||
      'weather' => 'HSK 1',
      'clothes' ||
      'daily_life' ||
      'health' ||
      'nature' ||
      'places' ||
      'school' ||
      'shopping' ||
      'transport' => 'HSK 2',
      'city_life' || 'entertainment' || 'sports' => 'HSK 3',
      'media_society' => 'HSK 4',
      _ => 'HSK 2',
    };
  }

  static IconData _iconForAssetTopic(String id) {
    return switch (id) {
      'animals' => Icons.pets_outlined,
      'body' => Icons.accessibility_new_outlined,
      'city_life' => Icons.location_city_outlined,
      'clothes' => Icons.checkroom_outlined,
      'colors' => Icons.palette_outlined,
      'daily_life' => Icons.today_outlined,
      'entertainment' => Icons.movie_creation_outlined,
      'food' => Icons.local_dining_outlined,
      'health' => Icons.health_and_safety_outlined,
      'home' => Icons.chair_outlined,
      'nature' => Icons.terrain_outlined,
      'places' => Icons.place_outlined,
      'school' => Icons.school_outlined,
      'shopping' => Icons.shopping_bag_outlined,
      'sports' => Icons.sports_soccer_outlined,
      'transport' => Icons.directions_bus_outlined,
      'weather' => Icons.wb_sunny_outlined,
      _ => Icons.style_outlined,
    };
  }

  static FlashcardTopic _topic(
    String id,
    String level,
    String name,
    IconData icon,
    List<String> words,
    String imagePath,
  ) {
    final entries = words
        .map(
          (word) => DictionaryRepository.forFlashcard(
            word,
            level: level,
            imagePath: imagePath,
          ),
        )
        .toList();
    final resolvedTopicImagePath = entries
        .map((entry) => entry.imagePath)
        .whereType<String>()
        .firstWhere((path) => path.isNotEmpty, orElse: () => imagePath);
    return FlashcardTopic(
      id: id,
      level: level,
      name: name,
      icon: icon,
      imagePath: resolvedTopicImagePath,
      words: entries,
    );
  }

  static final _plans = <_FlashcardPlan>[
    _FlashcardPlan(
      'hsk1_greeting',
      'HSK 1',
      'Chào hỏi cơ bản',
      Icons.waving_hand_outlined,
      'assets/images/flashcards/family/427034659a.jpg',
      ['你好', '谢谢', '再见', '对不起', '没关系', '请', '你', '我', '他', '她'],
    ),
    _FlashcardPlan(
      'hsk1_family',
      'HSK 1',
      'Gia đình',
      Icons.family_restroom_outlined,
      'assets/images/flashcards/family/e6c7ee6003.jpg',
      ['爸爸', '妈妈', '哥哥', '姐姐', '弟弟', '妹妹', '家', '朋友', '儿子', '女儿'],
    ),
    _FlashcardPlan(
      'hsk1_food',
      'HSK 1',
      'Đồ ăn thường ngày',
      Icons.local_dining_outlined,
      'assets/images/flashcards/food/edfec00f07.jpg',
      ['米饭', '面条', '包子', '苹果', '水果', '茶', '水', '吃', '喝', '好吃'],
    ),
    _FlashcardPlan(
      'hsk1_school',
      'HSK 1',
      'Trường học',
      Icons.school_outlined,
      'assets/images/flashcards/family/033e1fb01c.jpg',
      ['学习', '学生', '老师', '学校', '书', '汉语', '写', '读', '字', '作业'],
    ),
    _FlashcardPlan(
      'hsk1_time',
      'HSK 1',
      'Thời gian và số đếm',
      Icons.schedule_outlined,
      'assets/images/flashcards/colors/9d2d1f62ae.jpg',
      ['今天', '明天', '昨天', '年', '月', '日', '一', '二', '三', '十'],
    ),
    _FlashcardPlan(
      'hsk2_transport',
      'HSK 2',
      'Giao thông',
      Icons.directions_bus_outlined,
      'assets/images/flashcards/transport/fed19a817b.jpg',
      ['飞机', '汽车', '公共汽车', '地铁', '火车', '自行车', '开车', '走', '路', '到'],
    ),
    _FlashcardPlan(
      'hsk2_shopping',
      'HSK 2',
      'Mua sắm',
      Icons.shopping_bag_outlined,
      'assets/images/flashcards/food/e6803e21b9.jpg',
      ['买', '卖', '钱', '贵', '便宜', '商店', '东西', '打折', '买单', '点菜'],
    ),
    _FlashcardPlan(
      'hsk2_health',
      'HSK 2',
      'Sức khỏe và cơ thể',
      Icons.health_and_safety_outlined,
      'assets/images/flashcards/body/e6134a2993.jpg',
      ['身体', '眼睛', '耳朵', '鼻子', '手', '脚', '生病', '医院', '医生', '休息'],
    ),
    _FlashcardPlan(
      'hsk2_weather',
      'HSK 2',
      'Thời tiết',
      Icons.wb_sunny_outlined,
      'assets/images/flashcards/colors/5263651186.jpg',
      ['天气', '热', '冷', '下雨', '雪', '风', '晴', '阴', '春天', '夏天'],
    ),
    _FlashcardPlan(
      'hsk3_work',
      'HSK 3',
      'Công việc và nghề nghiệp',
      Icons.work_outline,
      'assets/images/flashcards/transport/b73c6e34a1.jpg',
      ['工作', '公司', '经理', '同事', '会议', '办公室', '安排', '任务', '完成', '决定'],
    ),
    _FlashcardPlan(
      'hsk3_emotion',
      'HSK 3',
      'Cảm xúc và tâm lý',
      Icons.emoji_emotions_outlined,
      'assets/images/flashcards/colors/97542386a9.jpg',
      ['高兴', '开心', '难过', '担心', '紧张', '生气', '感兴趣', '希望', '愿意', '突然'],
    ),
    _FlashcardPlan(
      'hsk3_travel',
      'HSK 3',
      'Du lịch và khám phá',
      Icons.explore_outlined,
      'assets/images/flashcards/transport/16678800cf.jpg',
      ['旅游', '城市', '地方', '宾馆', '机场', '地图', '出发', '到达', '参观', '风景'],
    ),
    _FlashcardPlan(
      'hsk3_tech',
      'HSK 3',
      'Công nghệ và đời sống',
      Icons.devices_outlined,
      'assets/images/flashcards/body/bf08c05e00.jpg',
      ['手机', '电脑', '上网', '照片', '消息', '电子邮件', '应用', '检查', '联系', '方便'],
    ),
    _FlashcardPlan(
      'hsk4_business',
      'HSK 4',
      'Kinh doanh và kinh tế',
      Icons.business_center_outlined,
      'assets/images/flashcards/transport/e7e95e6813.jpg',
      ['经济', '发展', '市场', '价格', '顾客', '收入', '竞争', '机会', '成功', '管理'],
    ),
    _FlashcardPlan(
      'hsk4_media',
      'HSK 4',
      'Truyền thông và xã hội',
      Icons.newspaper_outlined,
      'assets/images/flashcards/city_life/c8ace4e283.jpg',
      ['新闻', '社会', '文化', '广告', '观众', '影响', '介绍', '讨论', '信息', '网络'],
    ),
    _FlashcardPlan(
      'hsk4_thinking',
      'HSK 4',
      'Tư duy và trình bày',
      Icons.psychology_outlined,
      'assets/images/flashcards/colors/d9bbeb4427.jpg',
      ['认为', '表示', '原因', '结果', '方法', '说明', '经验', '观点', '选择', '计划'],
    ),
  ];
}

class _FlashcardPlan {
  const _FlashcardPlan(
    this.id,
    this.level,
    this.name,
    this.icon,
    this.imagePath,
    this.words,
  );

  final String id;
  final String level;
  final String name;
  final IconData icon;
  final String imagePath;
  final List<String> words;
}

class GrammarRepository {
  static Future<List<GrammarLessonData>>? _loadFuture;

  static Future<List<GrammarLessonData>> loadLessons() {
    return _loadFuture ??= _loadLessons();
  }

  static Future<List<GrammarLessonData>> _loadLessons() async {
    try {
      dynamic decoded;
      try {
        final response = await http
            .get(
              Uri.parse('${DictionaryRepository.apiBaseUrl}/content/grammar'),
            )
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final remote = jsonDecode(utf8.decode(response.bodyBytes));
          if (remote is List && remote.isNotEmpty) decoded = remote;
        }
      } catch (_) {}
      decoded ??= jsonDecode(
        await rootBundle.loadString('assets/data/grammar_hsk14.json'),
      );
      if (decoded is! List) return lessons;
      return decoded
          .whereType<Map>()
          .map((raw) {
            final map = Map<String, dynamic>.from(raw);
            final examples = <ExampleSentenceData>[];
            final rawExamples = map['examples'];
            if (rawExamples is List) {
              for (final rawExample in rawExamples) {
                if (rawExample is Map && examples.length < 3) {
                  final ex = Map<String, dynamic>.from(rawExample);
                  final cn = (ex['cn'] ?? '').toString().trim();
                  final py = (ex['py'] ?? '').toString().trim();
                  final vi = (ex['vi'] ?? '').toString().trim();
                  if (cn.isNotEmpty && vi.isNotEmpty) {
                    examples.add(ExampleSentenceData(cn, py, vi));
                  }
                }
              }
            }
            return GrammarLessonData(
              level: (map['level'] ?? 'HSK 1').toString(),
              title: (map['title'] ?? '').toString(),
              pattern: (map['pattern'] ?? map['title'] ?? '').toString(),
              explanation: (map['explanation'] ?? '').toString(),
              examples: examples,
              note: (map['note'] ?? '').toString(),
            );
          })
          .where((lesson) => lesson.title.isNotEmpty)
          .toList();
    } catch (_) {
      return lessons;
    }
  }

  static const lessons = <GrammarLessonData>[
    GrammarLessonData(
      level: 'HSK 1',
      title: 'Câu phán đoán với 是 (shì)',
      pattern: 'Chủ ngữ + 是 + Danh từ',
      explanation:
          'Dùng để xác định danh tính, nghề nghiệp, quốc tịch hoặc bản chất của sự vật.',
      examples: [
        ExampleSentenceData('我是学生。', 'Wǒ shì xuésheng.', 'Tôi là học sinh.'),
        ExampleSentenceData(
          '他是中国人。',
          'Tā shì Zhōngguó rén.',
          'Anh ấy là người Trung Quốc.',
        ),
      ],
      note: 'Phủ định dùng 不 是: 我不是老师。',
    ),
    GrammarLessonData(
      level: 'HSK 1',
      title: 'Câu hỏi với 吗 (ma)',
      pattern: 'Câu trần thuật + 吗？',
      explanation: 'Thêm 吗 ở cuối câu để tạo câu hỏi có/không.',
      examples: [
        ExampleSentenceData(
          '你是学生吗？',
          'Nǐ shì xuésheng ma?',
          'Bạn là học sinh phải không?',
        ),
        ExampleSentenceData(
          '你喜欢茶吗？',
          'Nǐ xǐhuan chá ma?',
          'Bạn thích trà không?',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 1',
      title: 'Phó từ phủ định 不 (bù)',
      pattern: '不 + Động từ / Tính từ',
      explanation: 'Dùng để phủ định hành động, thói quen hoặc tính chất.',
      examples: [
        ExampleSentenceData('我不去学校。', 'Wǒ bú qù xuéxiào.', 'Tôi không đi học.'),
        ExampleSentenceData('今天不冷。', 'Jīntiān bù lěng.', 'Hôm nay không lạnh.'),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 2',
      title: 'Trợ từ 了 (le)',
      pattern: 'Động từ + 了',
      explanation:
          'Biểu thị hành động đã hoàn thành hoặc tình huống đã thay đổi.',
      examples: [
        ExampleSentenceData('我吃了饭。', 'Wǒ chī le fàn.', 'Tôi ăn cơm rồi.'),
        ExampleSentenceData(
          '他去了北京。',
          'Tā qù le Běijīng.',
          'Anh ấy đã đi Bắc Kinh.',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 2',
      title: 'Câu so sánh với 比 (bǐ)',
      pattern: 'A + 比 + B + Tính từ',
      explanation: 'Dùng để so sánh hơn giữa hai đối tượng.',
      examples: [
        ExampleSentenceData('他比我高。', 'Tā bǐ wǒ gāo.', 'Anh ấy cao hơn tôi.'),
        ExampleSentenceData(
          '今天比昨天热。',
          'Jīntiān bǐ zuótiān rè.',
          'Hôm nay nóng hơn hôm qua.',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 2',
      title: 'Đang làm gì với 在 (zài)',
      pattern: 'Chủ ngữ + 在 + Động từ',
      explanation: 'Diễn tả hành động đang xảy ra tại thời điểm nói.',
      examples: [
        ExampleSentenceData(
          '我在学习汉语。',
          'Wǒ zài xuéxí Hànyǔ.',
          'Tôi đang học tiếng Trung.',
        ),
        ExampleSentenceData('妈妈在做饭。', 'Māma zài zuò fàn.', 'Mẹ đang nấu cơm.'),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 3',
      title: 'Câu 把 (bǎ)',
      pattern: 'Chủ ngữ + 把 + Tân ngữ + Động từ + Kết quả',
      explanation: 'Nhấn mạnh cách xử lý hoặc kết quả tác động lên tân ngữ.',
      examples: [
        ExampleSentenceData(
          '我把书放在桌子上。',
          'Wǒ bǎ shū fàng zài zhuōzi shang.',
          'Tôi đặt sách lên bàn.',
        ),
        ExampleSentenceData(
          '请把门关上。',
          'Qǐng bǎ mén guān shang.',
          'Hãy đóng cửa lại.',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 3',
      title: 'Càng ngày càng 越来越',
      pattern: '越来越 + Tính từ',
      explanation: 'Diễn tả mức độ tăng dần theo thời gian.',
      examples: [
        ExampleSentenceData(
          '天气越来越冷。',
          'Tiānqì yuè lái yuè lěng.',
          'Thời tiết càng ngày càng lạnh.',
        ),
        ExampleSentenceData(
          '我的汉语越来越好。',
          'Wǒ de Hànyǔ yuè lái yuè hǎo.',
          'Tiếng Trung của tôi ngày càng tốt.',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 4',
      title: 'Mặc dù... nhưng... 虽然...但是...',
      pattern: '虽然 + Mệnh đề 1，但是 + Mệnh đề 2',
      explanation: 'Nối hai vế có quan hệ tương phản hoặc nhượng bộ.',
      examples: [
        ExampleSentenceData(
          '虽然汉语很难，但是我很喜欢。',
          'Suīrán Hànyǔ hěn nán, dànshì wǒ hěn xǐhuan.',
          'Mặc dù tiếng Trung khó, nhưng tôi rất thích.',
        ),
        ExampleSentenceData(
          '虽然下雨，但是他还是来了。',
          'Suīrán xià yǔ, dànshì tā háishi lái le.',
          'Dù trời mưa, anh ấy vẫn đến.',
        ),
      ],
    ),
    GrammarLessonData(
      level: 'HSK 4',
      title: 'Không những... mà còn... 不但...而且...',
      pattern: '不但 + Mệnh đề 1，而且 + Mệnh đề 2',
      explanation: 'Dùng để bổ sung ý ở mức độ mạnh hơn.',
      examples: [
        ExampleSentenceData(
          '他不但会说汉语，而且会写汉字。',
          'Tā búdàn huì shuō Hànyǔ, érqiě huì xiě Hànzì.',
          'Anh ấy không những biết nói tiếng Trung mà còn biết viết chữ Hán.',
        ),
        ExampleSentenceData(
          '这里不但热闹，而且很方便。',
          'Zhèlǐ búdàn rènao, érqiě hěn fāngbiàn.',
          'Ở đây không những náo nhiệt mà còn rất tiện.',
        ),
      ],
    ),
  ];
}

class GrammarChecker {
  static GrammarCheckResult check(String text) {
    final normalized = text
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp(r'[。！？!?]$'), '');
    final ruleResult = _checkCommonPatterns(normalized);
    if (ruleResult != null) return ruleResult;
    if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(normalized)) {
      return const GrammarCheckResult(
        score: 35,
        title: 'Cần nhập tiếng Trung',
        summary: 'Chưa nhận ra Hán tự trong câu.',
        correction: '',
        explanation:
            'Hãy nhập câu bằng chữ Hán để hệ thống kiểm tra trật tự từ và mẫu ngữ pháp.',
        errors: ['Không có chữ Hán để phân tích.'],
      );
    }
    if (normalized == '我不学校去') {
      return const GrammarCheckResult(
        score: 58,
        title: 'Cần sửa trật tự',
        summary: 'Phó từ 不 đứng trước động từ 去, địa điểm 学校 đặt sau động từ.',
        correction: '我不去学校。',
        explanation: 'Cấu trúc đúng: Chủ ngữ + 不 + Động từ + Tân ngữ/địa điểm.',
        errors: ['Sai trật tự: 不学校去 nên sửa thành 不去学校.'],
      );
    }
    if (normalized == '我去昨天学校') {
      return const GrammarCheckResult(
        score: 62,
        title: 'Cần sửa trạng ngữ thời gian',
        summary: '昨天 nên đứng trước động từ hoặc sau chủ ngữ.',
        correction: '我昨天去学校。',
        explanation:
            'Trong tiếng Trung, trạng ngữ thời gian thường đứng đầu câu hoặc sau chủ ngữ.',
        errors: [
          'Sai vị trí thời gian: 昨天 không đặt giữa động từ 去 và địa điểm 学校.',
        ],
      );
    }
    if (normalized.contains('很很')) {
      return GrammarCheckResult(
        score: 54,
        title: 'Lặp phó từ',
        summary: 'Không dùng 很 hai lần liên tiếp.',
        correction: normalized.replaceAll('很很', '很'),
        explanation: 'Nếu muốn nhấn mạnh hơn, có thể dùng 非常 hoặc 特别.',
        errors: const ['Lặp từ 很.'],
      );
    }
    return GrammarCheckResult(
      score: 92,
      title: 'Rất tốt',
      summary: 'Câu của bạn khá tự nhiên.',
      correction: normalized.endsWith('。') || normalized.endsWith('？')
          ? normalized
          : '$normalized。',
      explanation:
          'Chưa phát hiện lỗi lớn. Hãy tiếp tục luyện thêm câu dài hơn.',
      errors: const [],
    );
  }

  static GrammarCheckResult? _checkCommonPatterns(String normalized) {
    if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(normalized)) return null;

    var correction = normalized;
    final errors = <String>[];
    var score = 96;

    void issue(String message, {int penalty = 14}) {
      errors.add(message);
      score -= penalty;
    }

    final locationVerb = RegExp(
      r'^(.+?)不(学校|公司|医院|商店|市场|公园|图书馆|机场|北京|中国|越南|家)(去|来|到)$',
    ).firstMatch(correction);
    if (locationVerb != null) {
      correction =
          '${locationVerb.group(1)!}不${locationVerb.group(3)!}${locationVerb.group(2)!}';
      issue(
        'Sai trật tự phủ định với địa điểm: 不 phải đứng trước động từ, rồi mới đến địa điểm. Mẫu đúng: Chủ ngữ + 不 + 去/来/到 + địa điểm.',
        penalty: 30,
      );
    }

    final missingVerbLocation = RegExp(
      r'^(.+?)不(学校|公司|医院|商店|市场|公园|图书馆|机场|北京|中国|越南|家)$',
    ).firstMatch(correction);
    if (missingVerbLocation != null) {
      correction =
          '${missingVerbLocation.group(1)!}不去${missingVerbLocation.group(2)!}';
      issue(
        'Sau 不 cần một động từ rõ ràng. Với địa điểm, thường dùng 不去 + địa điểm.',
        penalty: 22,
      );
    }

    final timeAfterVerb = RegExp(
      r'^(.+?)(去|来|到|学习|工作|吃饭|看书|买东西|开会)(昨天|今天|明天|早上|上午|中午|下午|晚上)(.+)$',
    ).firstMatch(correction);
    if (timeAfterVerb != null) {
      correction =
          '${timeAfterVerb.group(1)!}${timeAfterVerb.group(3)!}${timeAfterVerb.group(2)!}${timeAfterVerb.group(4)!}';
      issue(
        'Trạng ngữ thời gian nên đặt trước động từ hoặc ngay sau chủ ngữ, không đặt kẹp giữa động từ và tân ngữ.',
        penalty: 22,
      );
    }

    if (correction.contains('很很')) {
      correction = correction.replaceAll('很很', '很');
      issue(
        'Không lặp 很 hai lần liên tiếp. Muốn nhấn mạnh có thể dùng 非常, 特别 hoặc 很 + tính từ.',
        penalty: 18,
      );
    }

    final shiAdjective = RegExp(
      r'^(.+?)是(很)?(好|忙|累|高兴|漂亮|热|冷|难|贵|便宜|舒服|开心)$',
    ).firstMatch(correction);
    if (shiAdjective != null) {
      correction =
          '${shiAdjective.group(1)!}${shiAdjective.group(2) ?? '很'}${shiAdjective.group(3)!}';
      issue(
        'Tính từ vị ngữ trong tiếng Trung thường không dùng 是. Nói "我很好", không nói "我是很好".',
        penalty: 18,
      );
    }

    final measureWordFixes = <String, String>{
      '一书': '一本书',
      '一苹果': '一个苹果',
      '一老师': '一位老师',
      '一学生': '一个学生',
      '一朋友': '一个朋友',
      '两书': '两本书',
      '两苹果': '两个苹果',
      '两学生': '两个学生',
    };
    for (final entry in measureWordFixes.entries) {
      if (correction.contains(entry.key)) {
        correction = correction.replaceAll(entry.key, entry.value);
        issue(
          'Danh từ đếm được thường cần lượng từ: ví dụ 一本书, 一个苹果, 一位老师.',
          penalty: 14,
        );
        break;
      }
    }

    if (RegExp(r'(了了|过过|吗吗)').hasMatch(correction)) {
      correction = correction
          .replaceAll('了了', '了')
          .replaceAll('过过', '过')
          .replaceAll('吗吗', '吗');
      issue('Trợ từ ngữ khí/trợ từ thể không nên lặp liên tiếp trong câu này.');
    }

    final hasPredicate = RegExp(
      r'(是|有|在|去|来|到|学|学习|喜欢|想|要|吃|喝|看|买|卖|做|工作|觉得|会|能|可以|很|不|没|吗|了|过|给|请|让|比|把|被|开|住|坐|听|说|读|写)',
    ).hasMatch(correction);
    if (errors.isEmpty && !hasPredicate && correction.length > 2) {
      issue(
        'Câu chưa có vị ngữ rõ ràng. Hãy thêm động từ hoặc tính từ để câu hoàn chỉnh hơn.',
        penalty: 18,
      );
    }

    if (errors.isEmpty) return null;

    score = score.clamp(35, 96);
    final punctuated = correction.endsWith('吗') || correction.endsWith('呢')
        ? '$correction？'
        : '$correction。';
    return GrammarCheckResult(
      score: score,
      title: score < 70 ? 'Cần sửa trước khi dùng' : 'Có điểm cần chỉnh',
      summary: errors.first,
      correction: punctuated,
      explanation:
          'Hãy đọc theo mẫu sửa, sau đó tự thay chủ ngữ, thời gian hoặc địa điểm để luyện lại cấu trúc.',
      errors: errors,
    );
  }
}

class ReadingRepository {
  static Future<List<SentencePractice>> loadSentences() async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '${DictionaryRepository.apiBaseUrl}/content/pronunciation',
            ),
          )
          .timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final remote = jsonDecode(utf8.decode(response.bodyBytes));
        if (remote is List && remote.isNotEmpty) {
          return _sentencesFromList(remote);
        }
      }
    } catch (_) {}
    try {
      final raw = await rootBundle.loadString('assets/data/reading_hsk.json');
      final decoded = jsonDecode(raw);
      if (decoded is! List) return sentences;
      return _sentencesFromList(decoded);
    } catch (_) {
      return sentences;
    }
  }

  static List<SentencePractice> _sentencesFromList(List<dynamic> values) {
    return values
        .whereType<Map>()
        .map((raw) {
          final map = Map<String, dynamic>.from(raw);
          return SentencePractice(
            (map['level'] ?? 'HSK 1').toString(),
            (map['cn'] ?? '').toString(),
            (map['py'] ?? '').toString(),
            (map['vi'] ?? '').toString(),
            topic: (map['topic'] ?? 'Giao tiếp hằng ngày').toString(),
          );
        })
        .where((item) => item.cn.isNotEmpty)
        .toList();
  }

  static Future<List<NewsArticleData>> loadArticles({
    bool includeLive = false,
  }) async {
    final fallback = await _loadSeedArticles();
    if (!includeLive) return fallback;
    try {
      await DictionaryRepository.ensureLoaded().timeout(
        const Duration(milliseconds: 900),
      );
      final uri = Uri.parse('${DictionaryRepository.apiBaseUrl}/reading/news');
      final response = await http
          .get(uri)
          .timeout(const Duration(milliseconds: 6500));
      if (response.statusCode != 200) return fallback;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) return fallback;
      final live = decoded
          .whereType<Map>()
          .map((raw) => _articleFromMap(Map<String, dynamic>.from(raw)))
          .whereType<NewsArticleData>()
          .toList();
      return live.isEmpty ? fallback : [...live, ...fallback];
    } catch (_) {
      return fallback;
    }
  }

  static Future<List<NewsArticleData>> _loadSeedArticles() async {
    try {
      dynamic decoded;
      try {
        final response = await http
            .get(
              Uri.parse('${DictionaryRepository.apiBaseUrl}/content/articles'),
            )
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final remote = jsonDecode(utf8.decode(response.bodyBytes));
          if (remote is List && remote.isNotEmpty) decoded = remote;
        }
      } catch (_) {}
      decoded ??= jsonDecode(
        await rootBundle.loadString('assets/data/reading_news_seed.json'),
      );
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((raw) => _articleFromMap(Map<String, dynamic>.from(raw)))
          .whereType<NewsArticleData>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  static NewsArticleData? _articleFromMap(Map<String, dynamic> map) {
    final title = (map['title'] ?? '').toString().trim();
    final content = (map['content'] ?? map['description'] ?? '')
        .toString()
        .trim();
    if (title.isEmpty || content.isEmpty) return null;
    final rawSentences = map['sentences'];
    final lines = <ArticleSentenceData>[];
    if (rawSentences is List) {
      for (final rawLine in rawSentences) {
        if (rawLine is Map) {
          final line = Map<String, dynamic>.from(rawLine);
          final cn = (line['cn'] ?? '').toString().trim();
          if (cn.isEmpty) continue;
          lines.add(
            ArticleSentenceData(
              cn,
              (line['py'] ?? '').toString().trim(),
              (line['vi'] ?? '').toString().trim(),
            ),
          );
        }
      }
    }
    final source = (map['source'] ?? 'Chinese RSS').toString();
    final link = (map['link'] ?? '').toString();
    final summaryVi = (map['summaryVi'] ?? map['summary_vi'] ?? '').toString();
    return NewsArticleData(
      id: (map['id'] ?? title).toString(),
      level: (map['level'] ?? 'HSK 3').toString(),
      source: source,
      title: title,
      titleVi: (map['titleVi'] ?? map['title_vi'] ?? '').toString(),
      content: content,
      summaryVi: summaryVi.isEmpty ? source : summaryVi,
      link: link,
      sentences: lines.isEmpty ? buildStudyLines(content) : lines,
      live: map['live'] == true || link.startsWith('http'),
      publishedAt: (map['publishedAt'] ?? map['published_at'] ?? '').toString(),
    );
  }

  static List<ArticleSentenceData> buildStudyLines(String text) {
    final normalized = text
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) return const [];
    final matches = RegExp(r'[^。！？!?；;]+[。！？!?；;]?').allMatches(normalized);
    final lines = <ArticleSentenceData>[];
    for (final match in matches) {
      final cn = match.group(0)?.trim() ?? '';
      if (cn.isEmpty || !RegExp(r'[\u4e00-\u9fff]').hasMatch(cn)) continue;
      lines.add(ArticleSentenceData(cn, pinyinFor(cn), meaningHintFor(cn)));
      if (lines.length >= 80) break;
    }
    return lines.isEmpty
        ? [
            ArticleSentenceData(
              normalized,
              pinyinFor(normalized),
              meaningHintFor(normalized),
            ),
          ]
        : lines;
  }

  static String pinyinFor(String text) {
    final parts = <String>[];
    var i = 0;
    while (i < text.length) {
      final char = text.substring(i, i + 1);
      if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(char)) {
        if ('，,。！？!?；;：:'.contains(char) && parts.isNotEmpty) {
          parts[parts.length - 1] = '${parts.last}${_punctToAscii(char)}';
        }
        i++;
        continue;
      }
      final entry = DictionaryRepository.lookupAt(text, i);
      if (entry == null || entry.pinyin.trim().isEmpty) {
        parts.add(char);
        i++;
        continue;
      }
      parts.add(entry.pinyin.trim());
      i += entry.simplified.length;
    }
    return parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static String meaningHintFor(String text) {
    final terms = <String>[];
    final seen = <String>{};
    var i = 0;
    while (i < text.length && terms.length < 5) {
      final char = text.substring(i, i + 1);
      if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(char)) {
        i++;
        continue;
      }
      final entry = DictionaryRepository.lookupAt(text, i);
      if (entry == null) {
        i++;
        continue;
      }
      final word = entry.simplified;
      if (word.length > 1 && !seen.contains(word)) {
        seen.add(word);
        terms.add('$word: ${_shortMeaning(entry.meaning)}');
      }
      i += max(1, word.length);
    }
    if (terms.isEmpty) return 'Dịch nhanh đang cập nhật.';
    return 'Dịch nhanh theo từ khóa: ${terms.join('; ')}.';
  }

  static String _shortMeaning(String meaning) {
    final cleaned = meaning
        .replaceFirst('Nghĩa Việt đang cập nhật · ', '')
        .replaceFirst('Nghĩa tiếng Việt đang cập nhật', 'đang cập nhật')
        .trim();
    final first = cleaned.split(RegExp(r'[;,/]')).first.trim();
    return first.isEmpty ? cleaned : first;
  }

  static String _punctToAscii(String char) {
    switch (char) {
      case '，':
        return ',';
      case '。':
        return '.';
      case '！':
        return '!';
      case '？':
        return '?';
      case '；':
        return ';';
      case '：':
        return ':';
      default:
        return char;
    }
  }

  static const sentences = <SentencePractice>[
    SentencePractice('HSK 1', '大家好！', 'Dàjiā hǎo!', 'Chào mọi người!'),
    SentencePractice('HSK 1', '我是学生。', 'Wǒ shì xuésheng.', 'Tôi là học sinh.'),
    SentencePractice(
      'HSK 1',
      '你叫什么名字？',
      'Nǐ jiào shénme míngzi?',
      'Bạn tên là gì?',
    ),
    SentencePractice(
      'HSK 2',
      '我在学习汉语。',
      'Wǒ zài xuéxí Hànyǔ.',
      'Tôi đang học tiếng Trung.',
    ),
    SentencePractice(
      'HSK 2',
      '今天比昨天热。',
      'Jīntiān bǐ zuótiān rè.',
      'Hôm nay nóng hơn hôm qua.',
    ),
    SentencePractice(
      'HSK 2',
      '我坐飞机去北京。',
      'Wǒ zuò fēijī qù Běijīng.',
      'Tôi đi máy bay đến Bắc Kinh.',
    ),
    SentencePractice(
      'HSK 3',
      '我的汉语越来越好。',
      'Wǒ de Hànyǔ yuè lái yuè hǎo.',
      'Tiếng Trung của tôi ngày càng tốt.',
    ),
    SentencePractice(
      'HSK 3',
      '请把门关上。',
      'Qǐng bǎ mén guān shang.',
      'Hãy đóng cửa lại.',
    ),
    SentencePractice(
      'HSK 4',
      '虽然汉语很难，但是我很喜欢。',
      'Suīrán Hànyǔ hěn nán, dànshì wǒ hěn xǐhuan.',
      'Mặc dù tiếng Trung khó, nhưng tôi rất thích.',
    ),
    SentencePractice(
      'HSK 4',
      '他不但会说汉语，而且会写汉字。',
      'Tā búdàn huì shuō Hànyǔ, érqiě huì xiě Hànzì.',
      'Anh ấy không những biết nói tiếng Trung mà còn biết viết chữ Hán.',
    ),
  ];
}

class VideoRepository {
  static const _unavailableVideoIds = {
    'NjKooVPp8-s',
    'YmTB_nQxJQj',
    'Aqs0VrMEeXQ',
    'jMEW0KcwBdY',
    'MPuvcZCu5f9',
    '8K7BNGGjGiA',
    'hYM-F05V02A',
  };

  static Future<List<VideoLessonData>> loadLessons() async {
    try {
      dynamic decoded;
      try {
        final response = await http
            .get(Uri.parse('${DictionaryRepository.apiBaseUrl}/content/videos'))
            .timeout(const Duration(seconds: 4));
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final remote = jsonDecode(response.body);
          if (remote is List && remote.isNotEmpty) decoded = remote;
        }
      } catch (_) {}
      decoded ??= jsonDecode(
        await rootBundle.loadString('assets/data/video_lessons.json'),
      );
      if (decoded is! List) return lessons;
      final loaded = decoded
          .whereType<Map>()
          .where((raw) => (raw['status'] ?? 'published') == 'published')
          .map((raw) {
            final map = Map<String, dynamic>.from(raw);
            final subtitles = <VideoSubtitleData>[];
            final rawSubtitles = map['subtitles'];
            if (rawSubtitles is List) {
              for (final rawSubtitle in rawSubtitles) {
                if (rawSubtitle is Map) {
                  final sub = Map<String, dynamic>.from(rawSubtitle);
                  final cn = (sub['cn'] ?? '').toString().trim();
                  final py = (sub['py'] ?? '').toString().trim();
                  final vi = (sub['vi'] ?? '').toString().trim();
                  if (cn.isNotEmpty) {
                    final start = (sub['start'] as num?)?.toDouble() ?? 0;
                    final end = (sub['end'] as num?)?.toDouble() ?? 0;
                    subtitles.add(
                      VideoSubtitleData(
                        cn,
                        py,
                        vi,
                        start: start,
                        end: end > start ? end : 0,
                      ),
                    );
                  }
                }
              }
            }
            return VideoLessonData(
              title: (map['title'] ?? '').toString(),
              titleCn: (map['titleCn'] ?? map['title_cn'] ?? '').toString(),
              level: (map['level'] ?? 'HSK 1').toString(),
              youtubeId: (map['youtubeId'] ?? map['youtube_id'] ?? '')
                  .toString(),
              subtitles: subtitles,
              source: (map['source'] ?? 'Little Fox Chinese').toString(),
              transcriptStatus:
                  (map['transcriptStatus'] ??
                          (subtitles.every(
                                (subtitle) => subtitle.end > subtitle.start,
                              )
                              ? 'timed'
                              : 'untimed'))
                      .toString(),
            );
          })
          .where(
            (lesson) =>
                lesson.title.isNotEmpty &&
                lesson.youtubeId.isNotEmpty &&
                lesson.hasTimedSubtitles &&
                !_unavailableVideoIds.contains(lesson.youtubeId),
          )
          .toList();
      return loaded.isEmpty ? lessons : loaded;
    } catch (_) {
      return lessons;
    }
  }

  static const lessons = <VideoLessonData>[
    VideoLessonData(
      title: 'Chào hỏi hằng ngày',
      titleCn: '日常问候',
      level: 'HSK 1',
      youtubeId: 'GN9PYbGJpGY',
      subtitles: [
        VideoSubtitleData('大家好！', 'Dàjiā hǎo!', 'Chào mọi người!'),
        VideoSubtitleData(
          '我叫小明。',
          'Wǒ jiào Xiǎomíng.',
          'Tôi tên là Tiểu Minh.',
        ),
        VideoSubtitleData(
          '很高兴认识你。',
          'Hěn gāoxìng rènshi nǐ.',
          'Rất vui được gặp bạn.',
        ),
        VideoSubtitleData('你好吗？', 'Nǐ hǎo ma?', 'Bạn khỏe không?'),
      ],
    ),
    VideoLessonData(
      title: 'Ở trường học',
      titleCn: '在学校',
      level: 'HSK 1',
      youtubeId: 'Aqs0VrMEeXQ',
      subtitles: [
        VideoSubtitleData(
          '早上好，同学们！',
          'Zǎoshang hǎo, tóngxuémen!',
          'Chào buổi sáng, các bạn học sinh!',
        ),
        VideoSubtitleData(
          '今天我们学习新的汉字。',
          'Jīntiān wǒmen xuéxí xīn de hànzì.',
          'Hôm nay chúng ta học chữ Hán mới.',
        ),
        VideoSubtitleData(
          '请大家打开书。',
          'Qǐng dàjiā dǎkāi shū.',
          'Mọi người hãy mở sách ra.',
        ),
      ],
    ),
    VideoLessonData(
      title: 'Mua sắm ở chợ',
      titleCn: '在市场买东西',
      level: 'HSK 2',
      youtubeId: 'jMEW0KcwBdY',
      subtitles: [
        VideoSubtitleData(
          '这个苹果多少钱？',
          'Zhège píngguǒ duōshao qián?',
          'Táo này bao nhiêu tiền?',
        ),
        VideoSubtitleData('太贵了！', 'Tài guì le!', 'Đắt quá!'),
        VideoSubtitleData('我买两斤。', 'Wǒ mǎi liǎng jīn.', 'Tôi mua hai cân.'),
      ],
    ),
  ];
}

class PronunciationScorer {
  static int score(String target, String recognized) {
    final t = target.replaceAll(RegExp(r'[^\u4e00-\u9fff]'), '');
    final r = recognized.replaceAll(RegExp(r'[^\u4e00-\u9fff]'), '');
    if (t.isEmpty || r.isEmpty) return 0;
    if (t == r) return 100;
    var matches = 0;
    final chars = r.characters.toList();
    for (final char in t.characters) {
      final index = chars.indexOf(char);
      if (index >= 0) {
        matches++;
        chars.removeAt(index);
      }
    }
    final lengthPenalty = min(t.length, r.length) / max(t.length, r.length);
    return ((matches / t.length) * 100 * (0.75 + lengthPenalty * 0.25))
        .round()
        .clamp(0, 100);
  }
}

List<Color> _visualPalette(String key) {
  const palettes = [
    [Color(0xFFE85045), Color(0xFFF4B942)],
    [Color(0xFF1B7F79), Color(0xFF61C3A5)],
    [Color(0xFF2364AA), Color(0xFF73A5E8)],
    [Color(0xFF7A4EAB), Color(0xFFD782BA)],
    [Color(0xFF2F7D4F), Color(0xFF9CCC65)],
    [Color(0xFFB45F06), Color(0xFFFFB74D)],
    [Color(0xFF455A64), Color(0xFF90A4AE)],
    [Color(0xFFAD1457), Color(0xFFF06292)],
  ];
  final index =
      key.codeUnits.fold<int>(0, (sum, code) => sum + code) % palettes.length;
  return palettes[index];
}

Color _pairedVisualColor(Color color) {
  if (color == AppColors.amber) return AppColors.cinnabar;
  if (color == AppColors.blue) return AppColors.jade;
  if (color == AppColors.jade) return AppColors.amber;
  if (color == AppColors.plum) return AppColors.blue;
  return AppColors.amber;
}

IconData _visualIconFor(VocabEntry entry) {
  final text = '${entry.simplified}${entry.meaning}${entry.wordType}';
  if (RegExp(r'吃|喝|饭|菜|水果|苹果|茶|food|cơm|ăn|uống').hasMatch(text)) {
    return Icons.restaurant_outlined;
  }
  if (RegExp(r'飞机|汽车|车|地铁|路|机场|旅游|đi|bay|giao thông').hasMatch(text)) {
    return Icons.travel_explore_outlined;
  }
  if (RegExp(r'学习|学校|老师|学生|书|考试|học|trường').hasMatch(text)) {
    return Icons.school_outlined;
  }
  if (RegExp(r'爸爸|妈妈|家|朋友|同学|bạn|gia đình').hasMatch(text)) {
    return Icons.groups_outlined;
  }
  if (RegExp(r'公司|工作|经理|会议|市场|经济|công việc|kinh tế').hasMatch(text)) {
    return Icons.business_center_outlined;
  }
  if (RegExp(r'天气|热|冷|雨|雪|风|mưa|nóng|lạnh').hasMatch(text)) {
    return Icons.wb_sunny_outlined;
  }
  if (RegExp(r'手机|电脑|网络|信息|ảnh|máy|internet').hasMatch(text)) {
    return Icons.devices_outlined;
  }
  if (RegExp(r'眼睛|手|脚|身体|医院|医生|sức khỏe').hasMatch(text)) {
    return Icons.health_and_safety_outlined;
  }
  return Icons.auto_awesome_outlined;
}

Color _levelColor(String level) {
  switch (level) {
    case 'HSK 1':
      return AppColors.amber;
    case 'HSK 2':
      return AppColors.blue;
    case 'HSK 3':
      return AppColors.jade;
    case 'HSK 4':
      return AppColors.plum;
    default:
      return AppColors.cinnabar;
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
