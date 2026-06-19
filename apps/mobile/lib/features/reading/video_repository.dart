part of '../../main.dart';

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
          .toList();
      final ready = _selectPracticeReadyLessons(loaded);
      return ready.isEmpty ? lessons : ready;
    } catch (_) {
      return lessons;
    }
  }

  static List<VideoLessonData> _selectPracticeReadyLessons(
    List<VideoLessonData> loaded,
  ) {
    final byYoutubeId = <String, VideoLessonData>{};
    for (final lesson in loaded.where(_isPracticeReady)) {
      final current = byYoutubeId[lesson.youtubeId];
      if (current == null || _qualityScore(lesson) > _qualityScore(current)) {
        byYoutubeId[lesson.youtubeId] = lesson;
      }
    }
    return byYoutubeId.values.toList();
  }

  static bool _isPracticeReady(VideoLessonData lesson) {
    return lesson.title.isNotEmpty &&
        lesson.youtubeId.isNotEmpty &&
        lesson.hasTimedSubtitles &&
        !_unavailableVideoIds.contains(lesson.youtubeId) &&
        lesson.subtitles.length >= 8 &&
        _transcriptSpanSeconds(lesson) >= 20;
  }

  static int _qualityScore(VideoLessonData lesson) {
    return lesson.subtitles.length * 1000 +
        _transcriptSpanSeconds(lesson).round();
  }

  static double _transcriptSpanSeconds(VideoLessonData lesson) {
    if (lesson.subtitles.isEmpty) return 0;
    final starts = lesson.subtitles.map((subtitle) => subtitle.start);
    final ends = lesson.subtitles.map((subtitle) => subtitle.end);
    return ends.reduce(max) - starts.reduce(min);
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
