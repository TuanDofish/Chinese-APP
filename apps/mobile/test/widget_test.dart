import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VNChineseApp());
    expect(find.byType(VNChineseApp), findsOneWidget);
  });

  testWidgets('Learning dashboard fits a mobile viewport', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final days = List.generate(
      7,
      (index) => LearningDayStat(
        date: DateTime(2026, 6, 7 + index),
        learnedWords: index,
        studyMinutes: index * 6,
      ),
    );
    final progress = LearningProgressSnapshot(
      targetLevel: 'HSK 2',
      dailyGoalWords: 18,
      dailyGoalMinutes: 25,
      savedWords: 12,
      todayWords: 5,
      studyMinutesToday: 24,
      grammarChecksToday: 2,
      readingArticlesThisWeek: 3,
      speakingScore: 82,
      streakDays: 6,
      weeklyStudyMinutes: 126,
      weeklyWords: 28,
      weeklyReviews: 14,
      activeDaysThisWeek: 6,
      accuracy: 88,
      totalLearnedWords: 210,
      totalMasteredWords: 94,
      dueReviewWords: 17,
      vocabularyScore: 70,
      grammarScore: 86,
      readingScore: 76,
      lastSevenDays: days,
      roadmap: const [
        HskLevelProgress(
          level: 'HSK 1',
          totalWords: 150,
          learnedWords: 150,
          masteredWords: 120,
        ),
        HskLevelProgress(
          level: 'HSK 2',
          totalWords: 300,
          learnedWords: 60,
          masteredWords: 24,
          dueReview: 17,
        ),
        HskLevelProgress(level: 'HSK 3', totalWords: 600, learnedWords: 0),
        HskLevelProgress(level: 'HSK 4', totalWords: 1200, learnedWords: 0),
      ],
      recentActivities: [
        LearningActivityItem(
          kind: 'grammar',
          title: 'Kiểm tra ngữ pháp',
          detail: '92 điểm · Câu hoàn toàn chính xác',
          occurredAt: DateTime(2026, 6, 13, 15, 30),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LearningJourneyDashboard(
              progress: progress,
              onOpenVocabulary: () {},
              onOpenPractice: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('7 ngày gần nhất'), findsOneWidget);
    expect(find.text('Lộ trình HSK'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
