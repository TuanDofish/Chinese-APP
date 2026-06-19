import 'package:flutter/material.dart';
import 'package:mobile/core/services/progress_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final ProgressService _progressService = ProgressService();

  int _streak = 0;
  int _totalLearned = 0;
  int _totalFavorite = 0;
  int _todayWords = 0;
  int _todayMinutes = 0;
  int _goalWords = 10;
  int _goalMinutes = 15;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final streak = await _progressService.getStreak();
    final learned = await _progressService.getLearnedWords();
    final favorites = await _progressService.getFavoriteWords();
    final todayW = await _progressService.getTodayWordsCount();
    final todayM = await _progressService.getTodayMinutes();
    final goalW = await _progressService.getDailyGoalWords();
    final goalM = await _progressService.getDailyGoalMinutes();

    if (mounted) {
      setState(() {
        _streak = streak;
        _totalLearned = learned.length;
        _totalFavorite = favorites.length;
        _todayWords = todayW;
        _todayMinutes = todayM;
        _goalWords = goalW;
        _goalMinutes = goalM;
        _isLoading = false;
      });
    }
  }

  void _showGoalDialog() {
    int tempWords = _goalWords;
    int tempMinutes = _goalMinutes;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("🎯 Đặt mục tiêu hàng ngày"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Words per day
              Row(
                children: [
                  const Icon(Icons.book, color: Color(0xFFD32F2F)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Số từ / ngày",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: tempWords.toDouble(),
                          min: 5,
                          max: 50,
                          divisions: 9,
                          activeColor: const Color(0xFFD32F2F),
                          label: "$tempWords từ",
                          onChanged: (v) =>
                              setDialogState(() => tempWords = v.round()),
                        ),
                        Text(
                          "$tempWords từ",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Minutes per day
              Row(
                children: [
                  const Icon(Icons.timer, color: Color(0xFFFFC107)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Thời gian / ngày",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Slider(
                          value: tempMinutes.toDouble(),
                          min: 5,
                          max: 120,
                          divisions: 23,
                          activeColor: const Color(0xFFFFC107),
                          label: "$tempMinutes phút",
                          onChanged: (v) =>
                              setDialogState(() => tempMinutes = v.round()),
                        ),
                        Text(
                          "$tempMinutes phút",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _progressService.setDailyGoal(
                  words: tempWords,
                  minutes: tempMinutes,
                );
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                _loadStats();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              child: const Text("Lưu"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text("Thống kê học tập")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    double wordProgress = _goalWords > 0
        ? (_todayWords / _goalWords).clamp(0.0, 1.0)
        : 0;
    double minuteProgress = _goalMinutes > 0
        ? (_todayMinutes / _goalMinutes).clamp(0.0, 1.0)
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thống kê học tập"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: _showGoalDialog,
            tooltip: "Đặt mục tiêu",
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // === Streak & Total Cards ===
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "🔥",
                      "$_streak",
                      "Ngày liên tiếp",
                      const Color(0xFFFF5722),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      "📚",
                      "$_totalLearned",
                      "Từ đã học",
                      const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      "⭐",
                      "$_totalFavorite",
                      "Sổ tay",
                      const Color(0xFFFFC107),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // === Daily Goals ===
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "🎯 Mục tiêu hôm nay",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _showGoalDialog,
                          child: const Text(
                            "Chỉnh sửa",
                            style: TextStyle(color: Color(0xFFD32F2F)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Words progress
                    _buildProgressRow(
                      icon: Icons.book,
                      color: const Color(0xFFD32F2F),
                      label: "Từ vựng",
                      current: _todayWords,
                      goal: _goalWords,
                      progress: wordProgress,
                      unit: "từ",
                    ),
                    const SizedBox(height: 16),

                    // Time progress
                    _buildProgressRow(
                      icon: Icons.timer,
                      color: const Color(0xFFFFC107),
                      label: "Thời gian",
                      current: _todayMinutes,
                      goal: _goalMinutes,
                      progress: minuteProgress,
                      unit: "phút",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // === HSK Progress ===
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "📊 Tiến độ HSK",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHskRow("HSK 1", 150, Colors.green),
                    _buildHskRow("HSK 2", 150, Colors.blue),
                    _buildHskRow("HSK 3", 300, Colors.orange),
                    _buildHskRow("HSK 4", 600, Colors.purple),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildProgressRow({
    required IconData icon,
    required Color color,
    required String label,
    required int current,
    required int goal,
    required double progress,
    required String unit,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              "$current/$goal $unit",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: progress >= 1.0 ? Colors.green : Colors.black87,
              ),
            ),
            if (progress >= 1.0)
              const Text(" ✅", style: TextStyle(fontSize: 16)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHskRow(String level, int total, Color color) {
    // For now using total learned as reference (simplified)
    int learned = (_totalLearned * 0.1).round().clamp(0, total);
    double pct = total > 0 ? learned / total : 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              level,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: pct,
                minHeight: 8,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: Text(
              "$learned/$total",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
