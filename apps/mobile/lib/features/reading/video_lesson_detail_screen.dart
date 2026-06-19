part of '../../main.dart';

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
  late final VideoLearningController _videoController;
  bool _showPinyin = true;
  bool _showVietnamese = true;
  int _lastScrolledLine = -1;

  @override
  void initState() {
    super.initState();
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
    _videoController =
        VideoLearningController(lesson: widget.lesson, player: _ytController)
          ..addListener(_handleVideoControllerChanged)
          ..bind();
  }

  @override
  void dispose() {
    _videoController
      ..removeListener(_handleVideoControllerChanged)
      ..dispose();
    _ytController.close();
    _tts.stop();
    _speech.stop();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleVideoControllerChanged() {
    final current = _videoController.currentIndex;
    if (current < 0 || current == _lastScrolledLine) return;
    _lastScrolledLine = current;
    _scrollToCurrent();
  }

  void _scrollToCurrent() {
    final current = _videoController.currentIndex;
    if (!_scrollController.hasClients || current < 0) return;
    final target = (current * 118.0) - 80;
    _scrollController.animateTo(
      target.clamp(0.0, _scrollController.position.maxScrollExtent).toDouble(),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _playLine(int index) {
    _videoController.playLine(index);
    if (!widget.lesson.hasTimedSubtitles) {
      _tts.speak(widget.lesson.subtitles[index].cn);
    }
  }

  void _toggleVideo() {
    _videoController.toggleVideo();
  }

  Widget _buildYoutubePlayerPane(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = MediaQuery.sizeOf(context).height;
        final maxPlayerHeight = screenHeight < 820 ? 300.0 : 360.0;
        final width = constraints.maxWidth;
        final height = min(width * 9 / 16, maxPlayerHeight);
        final aspectRatio = width / height;

        return Container(
          margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
          height: height,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          clipBehavior: Clip.antiAlias,
          child: YoutubePlayer(
            controller: _ytController,
            aspectRatio: aspectRatio,
          ),
        );
      },
    );
  }

  Widget _buildShadowingPanel(VideoLearningController video) {
    final index = video.activeLineIndex;
    if (index < 0) return const SizedBox.shrink();
    final sub = widget.lesson.subtitles[index];
    final result = video.scoreFor(index);
    final score = result?.score;
    final listeningThisLine = video.isRecording && video.currentIndex == index;
    final scoreColor = score == null
        ? Colors.white54
        : score >= 85
        ? AppColors.jade
        : score >= 65
        ? AppColors.amber
        : AppColors.cinnabar;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                      ? video.isActiveLearning
                            ? 'Video tự dừng ở cuối câu, ghi âm xong sẽ đi tiếp'
                            : 'Đang xem liên tục, video sẽ không tự dừng'
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
              fontSize: 26,
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
          if (video.recognizedText.isNotEmpty &&
              video.currentIndex == index) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Máy nghe được: ${video.recognizedText}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
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
                onPressed: video.isProcessing
                    ? null
                    : listeningThisLine
                    ? () => _stopLine(index)
                    : () => _recordLine(index),
                icon: Icon(
                  video.isProcessing
                      ? Icons.hourglass_top
                      : listeningThisLine
                      ? Icons.stop_circle
                      : video.awaitingRecording && video.currentIndex == index
                      ? Icons.mic
                      : Icons.mic_none,
                ),
                label: Text(
                  video.isProcessing
                      ? 'Đang chấm'
                      : listeningThisLine
                      ? 'Dừng ghi âm'
                      : 'Ghi âm nhại lại',
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
          if (video.isProcessing && video.currentIndex == index) ...[
            const SizedBox(height: 12),
            const LinearProgressIndicator(minHeight: 3),
            const SizedBox(height: 8),
            const Text(
              'Đang chấm điểm phát âm...',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          if (result != null && result.feedback.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              result.feedback,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVideoControls(VideoLearningController video) {
    return Container(
      color: const Color(0xFF10131A),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton.filledTonal(
            tooltip: video.isPlaying ? 'Tạm dừng' : 'Phát video',
            onPressed: _toggleVideo,
            icon: Icon(video.isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          FilterChip(
            selected: video.mode == VideoLearningMode.learningMode,
            showCheckmark: false,
            avatar: const Icon(Icons.pause_circle, size: 18),
            label: Text(
              widget.lesson.hasTimedSubtitles
                  ? VideoLearningMode.learningMode.label
                  : 'Chưa có timing',
            ),
            onSelected: widget.lesson.hasTimedSubtitles
                ? (_) => video.setMode(VideoLearningMode.learningMode)
                : null,
          ),
          FilterChip(
            selected: video.mode == VideoLearningMode.viewingMode,
            showCheckmark: false,
            avatar: const Icon(Icons.play_circle_outline, size: 18),
            label: Text(VideoLearningMode.viewingMode.label),
            onSelected: (_) => video.setMode(VideoLearningMode.viewingMode),
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
    await _videoController.beginRecording(index);
    final available = await _speech.initialize();
    if (!available) {
      _videoController.cancelRecording();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không mở được micro để kiểm tra phát âm.'),
        ),
      );
      return;
    }
    _videoController.updateRecognizedText('');
    await _speech.listen(
      localeId: 'zh-CN',
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      onResult: (result) {
        _videoController.updateRecognizedText(result.recognizedWords);
        if (result.finalResult) unawaited(_finishLine(index));
      },
    );
  }

  Future<void> _stopLine(int index) async {
    await _speech.stop();
    await _finishLine(index);
  }

  Future<void> _finishLine(int index) async {
    if (!mounted) return;
    await _videoController.finishRecordingAndScore(index);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VideoLearningController>.value(
      value: _videoController,
      child: Scaffold(
        backgroundColor: const Color(0xFF10131A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF10131A),
          foregroundColor: Colors.white,
          title: Text(widget.lesson.title),
        ),
        body: Column(
          children: [
            _buildYoutubePlayerPane(context),
            Consumer<VideoLearningController>(
              builder: (context, video, _) {
                return Expanded(
                  child: Column(
                    children: [
                      _buildVideoControls(video),
                      _buildShadowingPanel(video),
                      Container(
                        color: const Color(0xFF1A1D26),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            StatusPill(
                              label: widget.lesson.level,
                              color: AppColors.jade,
                            ),
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
                            final active = index == video.currentIndex;
                            final result = video.scoreFor(index);
                            final score = result?.score;
                            final recordingThisLine =
                                active && video.isRecording;
                            return InkWell(
                              onTap: () => _playLine(index),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: active
                                      ? AppColors.cinnabar.withValues(
                                          alpha: 0.18,
                                        )
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: active
                                        ? AppColors.cinnabar
                                        : Colors.white10,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sub.cn,
                                            style: TextStyle(
                                              color: active
                                                  ? Colors.white
                                                  : Colors.white70,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          if (_showPinyin &&
                                              sub.py.isNotEmpty) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              sub.py,
                                              style: const TextStyle(
                                                color: Color(0xFFFFCC80),
                                              ),
                                            ),
                                          ],
                                          if (_showVietnamese &&
                                              sub.vi.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              sub.vi,
                                              style: const TextStyle(
                                                color: Colors.white54,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),
                                          ],
                                          if (active &&
                                              video
                                                  .recognizedText
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              'Bạn đọc: ${video.recognizedText}',
                                              style: const TextStyle(
                                                color: Colors.white70,
                                              ),
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
                                          tooltip: recordingThisLine
                                              ? 'Dừng ghi âm'
                                              : 'Ghi âm đọc theo',
                                          onPressed: recordingThisLine
                                              ? () => _stopLine(index)
                                              : video.isProcessing
                                              ? null
                                              : () => _recordLine(index),
                                          icon: Icon(
                                            video.isProcessing && active
                                                ? Icons.hourglass_top
                                                : recordingThisLine
                                                ? Icons.stop_circle_outlined
                                                : Icons.mic_none,
                                            color: recordingThisLine
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
              },
            ),
          ],
        ),
      ),
    );
  }
}
