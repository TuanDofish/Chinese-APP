part of '../../main.dart';

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
    final nextWordsToday = (prefs.getInt(_todayWordsKey) ?? 0) + 1;
    // Marking a word as learned is not automatically two minutes of study.
    // Award one minute only after every five distinct words completed.
    final studyMinutes = nextWordsToday % 5 == 0 ? 1 : 0;
    await prefs.setInt(_todayWordsKey, nextWordsToday);
    if (studyMinutes > 0) {
      await prefs.setInt(
        _todayMinutesKey,
        (prefs.getInt(_todayMinutesKey) ?? 0) + studyMinutes,
      );
    }
    if (cleanWord.isNotEmpty) {
      await prefs.setStringList(learnedKey, learnedWords.toList()..sort());
    }
    final levelKey = '$_learnedLevelPrefix$safeLevel';
    await prefs.setInt(levelKey, (prefs.getInt(levelKey) ?? 0) + 1);
    await _recordDaily(
      prefs,
      learnedWords: 1,
      studyMinutes: studyMinutes,
    );
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
      (prefs.getInt(_todayMinutesKey) ?? 0) + 1,
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
      studyMinutes: 1,
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
      'durationSeconds': 60,
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
    required int minutes,
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
    if (minutes > 0) {
      await prefs.setInt(
        _todayMinutesKey,
        (prefs.getInt(_todayMinutesKey) ?? 0) + minutes,
      );
    }
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
      (prefs.getInt(_todayMinutesKey) ?? 0) + 1,
    );
    await _recordDaily(
      prefs,
      studyMinutes: 1,
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
      'durationSeconds': 60,
    });
  }

  static Future<void> recordQuizResult({
    required int score,
    required int correctCount,
    required int totalCount,
    int minutes = 2,
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
