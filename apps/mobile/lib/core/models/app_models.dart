part of '../../main.dart';

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
