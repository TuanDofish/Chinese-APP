import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Model một dòng phụ đề trong video
class VideoSubtitle {
  final String cn;
  final String py;
  final String vi;
  final double start;
  final double end;

  const VideoSubtitle({
    required this.cn,
    required this.py,
    required this.vi,
    required this.start,
    required this.end,
  });

  factory VideoSubtitle.fromJson(Map<String, dynamic> json) {
    return VideoSubtitle(
      cn: json['cn'] ?? '',
      py: json['py'] ?? '',
      vi: json['vi'] ?? '',
      start: (json['start'] as num).toDouble(),
      end: (json['end'] as num).toDouble(),
    );
  }
}

/// Model bài học video
class VideoLesson {
  final String id;
  final String title;
  final String titleCn;
  final String level;
  final String youtubeId;
  final String thumbnail;
  final int duration;
  final List<VideoSubtitle> subtitles;

  const VideoLesson({
    required this.id,
    required this.title,
    required this.titleCn,
    required this.level,
    required this.youtubeId,
    required this.thumbnail,
    required this.duration,
    required this.subtitles,
  });

  factory VideoLesson.fromJson(Map<String, dynamic> json) {
    return VideoLesson(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      titleCn: json['titleCn'] ?? '',
      level: json['level'] ?? 'HSK 1',
      youtubeId: json['youtubeId'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      subtitles: (json['subtitles'] as List<dynamic>? ?? [])
          .map((e) => VideoSubtitle.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─── Màn hình chọn bài đọc video ────────────────────────────────────────────

class VideoReadingScreen extends StatefulWidget {
  const VideoReadingScreen({super.key});

  @override
  State<VideoReadingScreen> createState() => _VideoReadingScreenState();
}

class _VideoReadingScreenState extends State<VideoReadingScreen> {
  List<VideoLesson> _lessons = [];
  bool _isLoading = true;
  String _selectedLevel = 'Tất cả';

  static const _levels = ['Tất cả', 'HSK 1', 'HSK 2', 'HSK 3'];

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    try {
      final raw = await rootBundle.loadString('assets/data/video_lessons.json');
      final List<dynamic> data = jsonDecode(raw);
      setState(() {
        _lessons = data.map((e) => VideoLesson.fromJson(e)).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading video lessons: $e');
      setState(() => _isLoading = false);
    }
  }

  List<VideoLesson> get _filtered {
    if (_selectedLevel == 'Tất cả') return _lessons;
    return _lessons.where((l) => l.level == _selectedLevel).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ───────────────────────────────────────────────
            _buildHeader(context),
            // ─── Level filter ─────────────────────────────────────────
            _buildLevelFilter(),
            // ─── Danh sách bài ────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF4444),
                      ),
                    )
                  : _filtered.isEmpty
                  ? _buildEmpty()
                  : _buildLessonList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFB71C1C).withValues(alpha: 0.9),
            const Color(0xFF1A237E).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.play_circle_filled,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đọc qua Video',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                'Phụ đề đồng bộ Hán–Pinyin–Việt',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelFilter() {
    return Container(
      height: 48,
      color: const Color(0xFF1A1D26),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _levels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final lvl = _levels[i];
          final selected = lvl == _selectedLevel;
          return GestureDetector(
            onTap: () => setState(() => _selectedLevel = lvl),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFFF4444)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFFFF4444)
                      : Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                lvl,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white60,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _buildLessonCard(_filtered[i]),
    );
  }

  Widget _buildLessonCard(VideoLesson lesson) {
    final levelColor = _levelColor(lesson.level);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(lesson: lesson)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E2132),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    lesson.thumbnail,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: const Color(0xFF2A2D3E),
                      child: const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white38,
                          size: 64,
                        ),
                      ),
                    ),
                  ),
                ),
                // Play overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.subtitles,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${lesson.subtitles.length} câu',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Level badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      lesson.level,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                // Big play button
                const Positioned.fill(
                  child: Center(
                    child: Icon(
                      Icons.play_circle_filled,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lesson.titleCn,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _infoChip(
                        Icons.play_arrow,
                        '${lesson.subtitles.length} câu phụ đề',
                      ),
                      const SizedBox(width: 8),
                      _infoChip(Icons.translate, 'Hán–Pinyin–Việt'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 13),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.video_library_outlined,
            color: Colors.white24,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có bài học cho cấp độ này',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Color _levelColor(String level) {
    switch (level) {
      case 'HSK 1':
        return Colors.green[700]!;
      case 'HSK 2':
        return Colors.blue[700]!;
      case 'HSK 3':
        return Colors.purple[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}

// ─── Màn hình phát video + phụ đề đồng bộ ───────────────────────────────────

class VideoPlayerScreen extends StatefulWidget {
  final VideoLesson lesson;
  const VideoPlayerScreen({super.key, required this.lesson});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _progressController;
  late YoutubePlayerController _ytController;

  int _currentIndex = -1;
  bool _isPlaying = false;
  bool _practiceMode = false; // Tự động tạm dừng sau mỗi câu
  bool _isPaused = false;
  bool _showPinyin = true;
  bool _showVietnamese = true;
  double _elapsedSeconds = 0.0;
  StreamSubscription? _playerSubscription;
  Timer? _positionTimer;
  bool _pollingPosition = false;

  List<VideoSubtitle> get _subs => widget.lesson.subtitles;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initYoutubePlayer();
  }

  void _initYoutubePlayer() {
    _ytController = YoutubePlayerController.fromVideoId(
      videoId: widget.lesson.youtubeId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
      ),
    );

    // Lắng nghe trạng thái video để đồng bộ subtitle
    _playerSubscription = _ytController.listen((event) {
      if (!mounted) return;

      final isPlaying = event.playerState == PlayerState.playing;

      setState(() {
        if (event.playerState != PlayerState.buffering &&
            event.playerState != PlayerState.unStarted &&
            event.playerState != PlayerState.unknown) {
          _isPlaying = isPlaying;
          _isPaused = !isPlaying;
        }
      });

      if (isPlaying) {
        _startPositionTimer();
      } else {
        _stopPositionTimer();
        _pollPosition();
      }
    });
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
      final position = await _ytController.currentTime;
      if (mounted) _syncSubtitlePosition(position);
    } catch (_) {
      // YouTube iframe có thể chưa sẵn sàng khi vừa chuyển trạng thái.
    } finally {
      _pollingPosition = false;
    }
  }

  void _syncSubtitlePosition(double seconds) {
    if (_subs.isEmpty) return;
    var shouldScroll = false;
    var shouldPause = false;
    setState(() {
      _elapsedSeconds = seconds;

      int newIndex = -1;
      for (int i = 0; i < _subs.length; i++) {
        if (_elapsedSeconds >= _subs[i].start &&
            _elapsedSeconds <= _subs[i].end) {
          newIndex = i;
          break;
        }
      }

      if (newIndex != -1 && newIndex != _currentIndex) {
        _currentIndex = newIndex;
        shouldScroll = true;
      } else if (newIndex == -1 && _currentIndex != -1) {
        var isBetween = false;
        for (int i = 0; i < _subs.length - 1; i++) {
          if (_elapsedSeconds > _subs[i].end &&
              _elapsedSeconds < _subs[i + 1].start) {
            isBetween = true;
            _currentIndex = -1;
            break;
          }
        }
        if (!isBetween && _elapsedSeconds > _subs.last.end) {
          _currentIndex = -1;
        }
      }

      if (_practiceMode && _currentIndex >= 0 && _currentIndex < _subs.length) {
        final sub = _subs[_currentIndex];
        shouldPause =
            _elapsedSeconds >= sub.end - 0.2 &&
            _elapsedSeconds <= sub.end + 0.5 &&
            _isPlaying;
        if (shouldPause) {
          _isPaused = true;
          _isPlaying = false;
        }
      }
    });
    if (shouldScroll) _scrollToCurrentSubtitle();
    if (shouldPause) {
      _stopPositionTimer();
      _ytController.pauseVideo();
    }
  }

  void _playSubtitle(int index) {
    if (index < 0 || index >= _subs.length) return;
    setState(() {
      _currentIndex = index;
    });
    _ytController.seekTo(seconds: _subs[index].start, allowSeekAhead: true);
    _ytController.playVideo();
    _startPositionTimer();
  }

  void _playNext() {
    int next = _currentIndex + 1;
    if (next >= _subs.length) return;
    _playSubtitle(next);
  }

  void _scrollToCurrentSubtitle() {
    if (!_scrollController.hasClients || _currentIndex < 0) return;
    // Mỗi card ước tính ~100px
    final offset = (_currentIndex * 100.0) - 100;
    _scrollController.animateTo(
      offset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _playerSubscription?.cancel();
    _stopPositionTimer();
    _ytController.close();
    _progressController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Column(
          children: [
            // ─── AppBar ──────────────────────────────────────────────
            _buildAppBar(),
            // ─── YouTube Player ──────────────────────────────────────
            _buildVideoArea(),
            // ─── Divider ─────────────────────────────────────────────
            const SizedBox(height: 8),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            // ─── Toggle options ───────────────────────────────────────
            _buildToggleBar(),
            // ─── Subtitles list ───────────────────────────────────────
            Expanded(child: _buildSubtitleList()),
            // ─── Practice Mode continue button ────────────────────────
            if (_practiceMode &&
                _isPaused &&
                _currentIndex >= 0 &&
                _currentIndex < _subs.length)
              _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.lesson.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.lesson.titleCn,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
          // Practice mode toggle
          GestureDetector(
            onTap: () => setState(() => _practiceMode = !_practiceMode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _practiceMode
                    ? const Color(0xFFFF4444)
                    : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _practiceMode ? Icons.pause_circle : Icons.fitness_center,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Luyện',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
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

  Widget _buildVideoArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black,
      child: YoutubePlayer(controller: _ytController, aspectRatio: 16 / 9),
    );
  }

  Widget _buildToggleBar() {
    return Container(
      color: const Color(0xFF1A1D26),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Hiện:',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(width: 10),
          _toggleChip(
            'Pinyin',
            _showPinyin,
            () => setState(() => _showPinyin = !_showPinyin),
          ),
          const SizedBox(width: 8),
          _toggleChip(
            'Tiếng Việt',
            _showVietnamese,
            () => setState(() => _showVietnamese = !_showVietnamese),
          ),
          const Spacer(),
          Text(
            '${_subs.length} câu',
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _toggleChip(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFFFF4444).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? const Color(0xFFFF4444).withValues(alpha: 0.6)
                : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFFFF8080) : Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitleList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _subs.length,
      itemBuilder: (_, i) => _buildSubtitleTile(i),
    );
  }

  Widget _buildSubtitleTile(int index) {
    final sub = _subs[index];
    final isActive = index == _currentIndex;

    return GestureDetector(
      onTap: () => _playSubtitle(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFFFF4444).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? const Color(0xFFFF4444).withValues(alpha: 0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Index number
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 10, top: 2),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFFF4444)
                    : Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isActive
                    ? const Icon(Icons.volume_up, color: Colors.white, size: 14)
                    : Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sub.cn,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontSize: 18,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                  if (_showPinyin && sub.py.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      sub.py,
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFFFFCC80)
                            : Colors.white38,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  if (_showVietnamese && sub.vi.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub.vi,
                      style: TextStyle(
                        color: isActive ? Colors.white60 : Colors.white24,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Speaker icon
            Icon(
              Icons.play_circle_outline,
              color: isActive ? const Color(0xFFFF4444) : Colors.white12,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      color: const Color(0xFF1A1D26),
      child: ElevatedButton.icon(
        onPressed: _playNext,
        icon: const Icon(Icons.arrow_forward_ios, size: 16),
        label: const Text('Câu tiếp theo'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF4444),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
    );
  }
}
