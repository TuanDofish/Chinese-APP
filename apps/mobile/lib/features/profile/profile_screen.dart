part of '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onLogout});

  final Future<void> Function() onLogout;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileData> _profileFuture;
  ProfileData _profile = ProfileData.fallback;
  bool _loggingOut = false;

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

  Future<void> _confirmLogout() async {
    if (_loggingOut) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đăng xuất?'),
        content: const Text(
          'Phiên học trên thiết bị này sẽ được kết thúc. Tiến độ đã đồng bộ vẫn được giữ lại.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Ở lại'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loggingOut = true);
    try {
      await widget.onLogout();
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
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
                    onPressed: _loggingOut ? null : _confirmLogout,
                    icon: _loggingOut
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
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
              onPressed: _loggingOut ? null : _confirmLogout,
              icon: _loggingOut
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
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
