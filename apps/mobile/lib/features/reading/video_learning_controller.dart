part of '../../main.dart';

const Object _videoLearningUnset = Object();

enum VideoLearningMode { learningMode, viewingMode }

extension VideoLearningModeLabel on VideoLearningMode {
  String get label => switch (this) {
    VideoLearningMode.learningMode => 'Học chủ động',
    VideoLearningMode.viewingMode => 'Xem liên tục',
  };
}

class VideoPronunciationScore {
  const VideoPronunciationScore({
    required this.score,
    required this.feedback,
    required this.source,
  });

  final int score;
  final String feedback;
  final String source;

  factory VideoPronunciationScore.fromJson(Map<String, dynamic> json) {
    return VideoPronunciationScore(
      score: ((json['score'] as num?)?.round() ?? 0).clamp(0, 100),
      feedback: (json['feedback'] ?? '').toString(),
      source: (json['source'] ?? 'api').toString(),
    );
  }

  factory VideoPronunciationScore.localFallback({
    required String target,
    String targetPinyin = '',
    required String recognized,
    Object? error,
  }) {
    final score = PronunciationScorer.score(
      target,
      recognized,
      targetPinyin: targetPinyin,
    );
    return VideoPronunciationScore(
      score: score,
      feedback: error == null
          ? _feedbackFor(score, recognized.trim().isNotEmpty)
          : 'Backend chưa phản hồi, app đã chấm tạm trên thiết bị.',
      source: error == null ? 'local-scorer' : 'local-fallback',
    );
  }

  static String _feedbackFor(int score, bool hasRecognizedText) {
    if (!hasRecognizedText) {
      return 'Máy chưa nhận được giọng đọc. Hãy đưa micro gần hơn và thử lại.';
    }
    if (score >= 90) return 'Rất tốt. Nhịp đọc và âm chính khá sát câu mẫu.';
    if (score >= 75) return 'Tốt. Hãy đọc chậm hơn một chút để rõ từng âm.';
    if (score >= 55) return 'Tạm ổn. Nên nghe lại câu mẫu rồi nhại từng cụm.';
    return 'Cần luyện lại. Hãy bấm nghe câu mẫu trước khi ghi âm lần nữa.';
  }
}

class VideoLearningState {
  const VideoLearningState({
    required this.mode,
    required this.currentIndex,
    required this.isPlaying,
    required this.isRecording,
    required this.isProcessing,
    required this.awaitingRecording,
    required this.pausedAtLineEnd,
    required this.durationSeconds,
    required this.lastPositionSeconds,
    required this.lockedLine,
    required this.recognizedText,
    required this.scores,
    required this.errorMessage,
  });

  factory VideoLearningState.initial(VideoLessonData lesson) {
    final hasTimedSubtitles = lesson.hasTimedSubtitles;
    return VideoLearningState(
      mode: hasTimedSubtitles
          ? VideoLearningMode.learningMode
          : VideoLearningMode.viewingMode,
      currentIndex: lesson.subtitles.isEmpty ? -1 : 0,
      isPlaying: false,
      isRecording: false,
      isProcessing: false,
      awaitingRecording: false,
      pausedAtLineEnd: false,
      durationSeconds: 0,
      lastPositionSeconds: 0,
      lockedLine: null,
      recognizedText: '',
      scores: const {},
      errorMessage: null,
    );
  }

  final VideoLearningMode mode;
  final int currentIndex;
  final bool isPlaying;
  final bool isRecording;
  final bool isProcessing;
  final bool awaitingRecording;
  final bool pausedAtLineEnd;
  final double durationSeconds;
  final double lastPositionSeconds;
  final int? lockedLine;
  final String recognizedText;
  final Map<int, VideoPronunciationScore> scores;
  final String? errorMessage;

  bool get isActiveLearning => mode == VideoLearningMode.learningMode;
  bool get isContinuousViewing => mode == VideoLearningMode.viewingMode;

  VideoLearningState copyWith({
    VideoLearningMode? mode,
    int? currentIndex,
    bool? isPlaying,
    bool? isRecording,
    bool? isProcessing,
    bool? awaitingRecording,
    bool? pausedAtLineEnd,
    double? durationSeconds,
    double? lastPositionSeconds,
    Object? lockedLine = _videoLearningUnset,
    String? recognizedText,
    Map<int, VideoPronunciationScore>? scores,
    Object? errorMessage = _videoLearningUnset,
  }) {
    return VideoLearningState(
      mode: mode ?? this.mode,
      currentIndex: currentIndex ?? this.currentIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      isRecording: isRecording ?? this.isRecording,
      isProcessing: isProcessing ?? this.isProcessing,
      awaitingRecording: awaitingRecording ?? this.awaitingRecording,
      pausedAtLineEnd: pausedAtLineEnd ?? this.pausedAtLineEnd,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      lastPositionSeconds: lastPositionSeconds ?? this.lastPositionSeconds,
      lockedLine: identical(lockedLine, _videoLearningUnset)
          ? this.lockedLine
          : lockedLine as int?,
      recognizedText: recognizedText ?? this.recognizedText,
      scores: scores ?? this.scores,
      errorMessage: identical(errorMessage, _videoLearningUnset)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class VideoLearningController extends ChangeNotifier {
  VideoLearningController({
    required VideoLessonData lesson,
    required YoutubePlayerController player,
    Duration pollInterval = const Duration(milliseconds: 120),
    double pauseToleranceSeconds = 0.08,
  }) : _lesson = lesson,
       _player = player,
       _pollInterval = pollInterval,
       _pauseToleranceSeconds = pauseToleranceSeconds,
       _state = VideoLearningState.initial(lesson);

  final VideoLessonData _lesson;
  final YoutubePlayerController _player;
  final Duration _pollInterval;
  final double _pauseToleranceSeconds;

  VideoLearningState _state;
  StreamSubscription<YoutubePlayerValue>? _playerSubscription;
  Timer? _positionTimer;
  Timer? _resumeTimer;
  bool _pollingPosition = false;
  bool _disposed = false;

  VideoLearningState get state => _state;
  VideoLearningMode get mode => _state.mode;
  int get currentIndex => _state.currentIndex;
  bool get isPlaying => _state.isPlaying;
  bool get isRecording => _state.isRecording;
  bool get isProcessing => _state.isProcessing;
  bool get awaitingRecording => _state.awaitingRecording;
  double get lastPositionSeconds => _state.lastPositionSeconds;
  String get recognizedText => _state.recognizedText;
  String? get errorMessage => _state.errorMessage;
  bool get canUseActiveLearning => _lesson.hasTimedSubtitles;

  bool get isActiveLearning =>
      canUseActiveLearning && mode == VideoLearningMode.learningMode;

  int get activeLineIndex {
    if (_lesson.subtitles.isEmpty) return -1;
    return currentIndex.clamp(0, _lesson.subtitles.length - 1);
  }

  double lineStart(int index) {
    final sub = _lesson.subtitles[index];
    return sub.end > sub.start ? sub.start : 0;
  }

  double lineEnd(int index) {
    final sub = _lesson.subtitles[index];
    final start = lineStart(index);
    return sub.end > sub.start ? max(start + 0.8, sub.end) : 0;
  }

  double? get targetTimestamp {
    final locked = _state.lockedLine;
    if (locked != null) return lineEnd(locked);
    final index = activeLineIndex;
    if (index < 0 || !_lesson.hasTimedSubtitles) return null;
    return lineEnd(index);
  }

  VideoPronunciationScore? scoreFor(int index) => _state.scores[index];

  void bind() {
    _playerSubscription ??= _player.listen(_handlePlayerValue);
    startPositionTimer();
  }

  void setMode(VideoLearningMode nextMode) {
    final mode =
        nextMode == VideoLearningMode.learningMode && !canUseActiveLearning
        ? VideoLearningMode.viewingMode
        : nextMode;
    final shouldLockCurrent =
        mode == VideoLearningMode.learningMode && _state.isPlaying;
    _emit(
      _state.copyWith(
        mode: mode,
        awaitingRecording: false,
        pausedAtLineEnd: false,
        lockedLine: shouldLockCurrent && activeLineIndex >= 0
            ? activeLineIndex
            : null,
      ),
    );
  }

  void startPositionTimer() {
    if (_positionTimer != null) return;
    _positionTimer = Timer.periodic(_pollInterval, (_) => _pollPosition());
  }

  void stopPositionTimer() {
    _positionTimer?.cancel();
    _positionTimer = null;
  }

  void selectLine(int index) {
    if (!_isValidLine(index)) return;
    _emit(
      _state.copyWith(
        currentIndex: index,
        awaitingRecording: false,
        pausedAtLineEnd: false,
        lockedLine: null,
      ),
    );
  }

  void playLine(int index) {
    if (!_isValidLine(index)) return;
    _resumeTimer?.cancel();
    _emit(
      _state.copyWith(
        currentIndex: index,
        isPlaying: _lesson.hasTimedSubtitles,
        isRecording: false,
        awaitingRecording: false,
        pausedAtLineEnd: false,
        recognizedText: '',
        errorMessage: null,
        lockedLine: isActiveLearning ? index : null,
      ),
    );
    if (!_lesson.hasTimedSubtitles) return;
    unawaited(_player.seekTo(seconds: lineStart(index), allowSeekAhead: true));
    unawaited(_player.playVideo());
    startPositionTimer();
  }

  void toggleVideo() {
    _emit(_state.copyWith(pausedAtLineEnd: false));
    if (_state.isPlaying) {
      _emit(_state.copyWith(isPlaying: false));
      unawaited(_player.pauseVideo());
      return;
    }

    var nextIndex = activeLineIndex;
    if (nextIndex < 0 && _lesson.subtitles.isNotEmpty) nextIndex = 0;
    _emit(
      _state.copyWith(
        currentIndex: nextIndex,
        isPlaying: true,
        lockedLine: isActiveLearning && nextIndex >= 0 ? nextIndex : null,
      ),
    );
    unawaited(_player.playVideo());
    startPositionTimer();
  }

  Future<void> beginRecording(int index) async {
    if (!_isValidLine(index)) return;
    _resumeTimer?.cancel();
    await _player.pauseVideo();
    stopPositionTimer();
    _emit(
      _state.copyWith(
        currentIndex: index,
        isPlaying: false,
        isRecording: true,
        awaitingRecording: false,
        isProcessing: false,
        recognizedText: '',
        scores: _scoresWithout(index),
        errorMessage: null,
        lockedLine: null,
      ),
    );
  }

  void cancelRecording() {
    _emit(_state.copyWith(isRecording: false, isProcessing: false));
  }

  void updateRecognizedText(String value) {
    _emit(_state.copyWith(recognizedText: value));
  }

  void beginProcessing() {
    _emit(_state.copyWith(isRecording: false, isProcessing: true));
  }

  Future<VideoPronunciationScore?> finishRecordingAndScore(
    int index, {
    Duration resumeDelay = const Duration(milliseconds: 700),
  }) async {
    if (!_isValidLine(index) || _state.isProcessing) return scoreFor(index);
    final target = _lesson.subtitles[index].cn;
    final recognized = _state.recognizedText;
    _emit(
      _state.copyWith(
        currentIndex: index,
        isRecording: false,
        isProcessing: true,
        awaitingRecording: false,
        errorMessage: null,
      ),
    );
    final result = await _scorePronunciation(
      index: index,
      target: target,
      recognized: recognized,
    );
    final nextScores = Map<int, VideoPronunciationScore>.from(_state.scores)
      ..[index] = result;
    _emit(
      _state.copyWith(
        currentIndex: index,
        isRecording: false,
        isProcessing: false,
        awaitingRecording: false,
        scores: nextScores,
        errorMessage: result.source == 'local-fallback'
            ? 'Backend chưa phản hồi, app đã chấm tạm trên thiết bị.'
            : null,
      ),
    );
    unawaited(LearningProgressStore.recordSpeakingScore(result.score));
    _resumeAfterScore(index, resumeDelay: resumeDelay);
    return result;
  }

  void _resumeAfterScore(
    int index, {
    Duration resumeDelay = const Duration(milliseconds: 700),
  }) {
    if (!isActiveLearning || index >= _lesson.subtitles.length - 1) return;
    _resumeTimer?.cancel();
    _resumeTimer = Timer(resumeDelay, () {
      if (_disposed || _state.isRecording || _state.currentIndex != index) {
        return;
      }
      playLine(index + 1);
    });
  }

  Map<int, VideoPronunciationScore> _scoresWithout(int index) {
    final nextScores = Map<int, VideoPronunciationScore>.from(_state.scores);
    nextScores.remove(index);
    return nextScores;
  }

  Future<VideoPronunciationScore> _scorePronunciation({
    required int index,
    required String target,
    required String recognized,
  }) async {
    final targetPinyin = index >= 0 && index < _lesson.subtitles.length
        ? _lesson.subtitles[index].py
        : '';
    try {
      final response = await http
          .post(
            Uri.parse('${DictionaryRepository.apiBaseUrl}/pronunciation/score'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode({
              'target': target,
              'targetPinyin': targetPinyin,
              'recognized': recognized,
              'lessonId': _lesson.youtubeId,
              'lineIndex': index,
            }),
          )
          .timeout(const Duration(seconds: 8));
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode >= 200 &&
          response.statusCode < 300 &&
          data is Map) {
        return VideoPronunciationScore.fromJson(
          Map<String, dynamic>.from(data),
        );
      }
      throw Exception(
        data is Map ? data['message'] ?? 'Score API failed' : response.body,
      );
    } catch (error) {
      return VideoPronunciationScore.localFallback(
        target: target,
        targetPinyin: targetPinyin,
        recognized: recognized,
        error: error,
      );
    }
  }

  void _handlePlayerValue(YoutubePlayerValue event) {
    final playing = event.playerState == PlayerState.playing;
    final durationSeconds =
        event.metaData.duration.inMilliseconds / Duration.millisecondsPerSecond;
    final hasNewDuration =
        durationSeconds > 0 &&
        (durationSeconds - _state.durationSeconds).abs() > 0.5;
    startPositionTimer();
    if (playing != _state.isPlaying || hasNewDuration) {
      _emit(
        _state.copyWith(
          isPlaying: playing,
          durationSeconds: hasNewDuration ? durationSeconds : null,
        ),
      );
    }
  }

  Future<void> _pollPosition() async {
    if (_pollingPosition || _disposed) return;
    _pollingPosition = true;
    try {
      if (_state.durationSeconds <= 0) {
        final duration = await _player.duration;
        if (duration > 0) {
          _emit(_state.copyWith(durationSeconds: duration));
        }
      }
      final seconds = await _player.currentTime;
      final playerState = await _player.playerState;
      _syncPosition(seconds, playerState == PlayerState.playing);
    } catch (_) {
      // The iframe can briefly reject currentTime while the video is loading.
    } finally {
      _pollingPosition = false;
    }
  }

  void _syncPosition(double seconds, bool playing) {
    if (_lesson.subtitles.isEmpty) {
      _emit(_state.copyWith(isPlaying: playing, lastPositionSeconds: seconds));
      return;
    }

    if (!_lesson.hasTimedSubtitles) {
      _emit(_state.copyWith(isPlaying: playing, lastPositionSeconds: seconds));
      return;
    }

    final locked = _state.lockedLine;
    if (locked != null) {
      final shouldPause = _shouldAutoPauseLine(
        locked,
        seconds,
        playing,
        allowLatePause: true,
      );

      _emit(
        _state.copyWith(
          currentIndex: locked,
          isPlaying: shouldPause ? false : playing,
          lastPositionSeconds: seconds,
          awaitingRecording: shouldPause ? true : null,
          pausedAtLineEnd: shouldPause ? true : null,
          lockedLine: shouldPause ? null : locked,
        ),
      );

      if (shouldPause) unawaited(_player.pauseVideo());
      return;
    }

    final newIndex = _findLineIndex(seconds);
    final shouldPause = _shouldAutoPauseLine(newIndex, seconds, playing);
    _emit(
      _state.copyWith(
        currentIndex: newIndex,
        isPlaying: shouldPause ? false : playing,
        lastPositionSeconds: seconds,
        awaitingRecording: shouldPause ? true : null,
        pausedAtLineEnd: shouldPause
            ? true
            : newIndex != _state.currentIndex
            ? false
            : null,
      ),
    );
    if (shouldPause) unawaited(_player.pauseVideo());
  }

  bool _shouldAutoPauseLine(
    int index,
    double seconds,
    bool playing, {
    bool allowLatePause = false,
  }) {
    if (!_isValidLine(index)) return false;
    final target = lineEnd(index);
    if (target <= 0) return false;
    final passedTarget = seconds >= target - _pauseToleranceSeconds;
    final stillNearTarget = allowLatePause || seconds <= target + 0.7;
    return isActiveLearning &&
        playing &&
        passedTarget &&
        stillNearTarget &&
        !_state.pausedAtLineEnd &&
        !_state.isRecording &&
        !_state.isProcessing;
  }

  int _findLineIndex(double seconds) {
    var newIndex = activeLineIndex;
    var matched = false;
    for (var i = 0; i < _lesson.subtitles.length; i++) {
      if (seconds >= lineStart(i) && seconds <= lineEnd(i)) {
        newIndex = i;
        matched = true;
        break;
      }
    }
    if (!matched) {
      newIndex = 0;
      for (var i = 0; i < _lesson.subtitles.length; i++) {
        if (lineStart(i) <= seconds) newIndex = i;
      }
    }
    return newIndex;
  }

  bool _isValidLine(int index) =>
      index >= 0 && index < _lesson.subtitles.length;

  void _emit(VideoLearningState nextState) {
    if (_disposed) return;
    _state = nextState;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _resumeTimer?.cancel();
    stopPositionTimer();
    _playerSubscription?.cancel();
    super.dispose();
  }
}
