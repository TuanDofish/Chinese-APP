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

import 'grammar_ai_service.dart';

void main() {
  runApp(const VNChineseApp());
}

class AppColors {
  static const ink = Color(0xFF17202A);
  static const muted = Color(0xFF667085);
  static const paper = Color(0xFFF7F4EF);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFE7DDD0);
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
        fontFamily: 'Arial',
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.cinnabar,
          primary: AppColors.cinnabar,
          secondary: AppColors.jade,
          surface: AppColors.surface,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 34,
            height: 1.08,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
          headlineMedium: TextStyle(
            fontSize: 26,
            height: 1.16,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
          titleLarge: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          bodyLarge: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: AppColors.ink,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.45,
            color: AppColors.muted,
          ),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.paper,
          foregroundColor: AppColors.ink,
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
            textStyle: const TextStyle(fontWeight: FontWeight.w900),
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
            textStyle: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _entered = false;

  @override
  Widget build(BuildContext context) {
    if (_entered) {
      return MainScreen(onLogout: () => setState(() => _entered = false));
    }
    return AuthScreen(onContinue: () => setState(() => _entered = true));
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onContinue});

  final VoidCallback onContinue;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isRegister = false;
  bool _remember = true;
  String _targetLevel = 'HSK 2';

  @override
  Widget build(BuildContext context) {
    final title = _isRegister ? 'Tạo tài khoản học tập' : 'Chào mừng trở lại';
    final subtitle = _isRegister
        ? 'Lưu tiến độ, mục tiêu HSK và sổ tay từ vựng trên thiết bị.'
        : 'Tiếp tục lộ trình tiếng Trung cá nhân hóa cho người Việt.';

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 820;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 46,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    child: isWide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(flex: 6, child: AuthVisualPanel()),
                              const SizedBox(width: 28),
                              Expanded(
                                flex: 5,
                                child: _buildForm(title, subtitle),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              const AuthVisualPanel(),
                              const SizedBox(height: 20),
                              _buildForm(title, subtitle),
                            ],
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildForm(String title, String subtitle) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BrandMark(showText: true),
          const SizedBox(height: 22),
          SegmentTabs(
            labels: const ['Đăng nhập', 'Đăng ký'],
            selectedIndex: _isRegister ? 1 : 0,
            onChanged: (index) => setState(() => _isRegister = index == 1),
          ),
          const SizedBox(height: 22),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 22),
          if (_isRegister) ...[
            const TextField(
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Họ tên',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const TextField(
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'ban@example.com',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 12),
          const TextField(
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: Icon(Icons.lock_outline),
              suffixIcon: Icon(Icons.visibility_off_outlined),
            ),
          ),
          if (_isRegister) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _targetLevel,
              items: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4']
                  .map(
                    (level) =>
                        DropdownMenuItem(value: level, child: Text(level)),
                  )
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Mục tiêu hiện tại',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              onChanged: (value) =>
                  setState(() => _targetLevel = value ?? 'HSK 2'),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Checkbox(
                value: _remember,
                onChanged: (value) => setState(() => _remember = value ?? true),
              ),
              const Expanded(
                child: Text('Ghi nhớ phiên học trên thiết bị này'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: widget.onContinue,
            icon: Icon(_isRegister ? Icons.person_add_alt_1 : Icons.login),
            label: Text(_isRegister ? 'Tạo tài khoản' : 'Đăng nhập'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: widget.onContinue,
            icon: const Icon(Icons.school_outlined),
            label: const Text('Học thử không cần tài khoản'),
          ),
        ],
      ),
    );
  }
}

class AuthVisualPanel extends StatelessWidget {
  const AuthVisualPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF2D2722), Color(0xFF522E29), Color(0xFF1F4E45)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BrandMark(inverted: true, showText: true),
          const SizedBox(height: 54),
          Text(
            'VNChinese',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: Colors.white,
              fontSize: 44,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ứng dụng học tiếng Trung cho người Việt: từ vựng HSK, AI ngữ pháp, luyện phát âm, đọc bài và video ngắn.',
            style: TextStyle(
              color: Color(0xFFEFE7DC),
              fontSize: 16,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 26),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              VisualBadge(icon: Icons.translate, label: 'Từ điển Trung - Việt'),
              VisualBadge(icon: Icons.auto_awesome, label: 'AI ngữ pháp'),
              VisualBadge(icon: Icons.mic_none, label: 'Chấm phát âm'),
              VisualBadge(
                icon: Icons.menu_book_outlined,
                label: 'Sổ tay từ mới',
              ),
            ],
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: const Row(
              children: [
                CharacterTile(text: '学', color: AppColors.cinnabar),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'xué',
                        style: TextStyle(
                          color: Color(0xFFFFE1A8),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'học, học tập',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '我每天学习中文。',
                        style: TextStyle(color: Color(0xFFEFE7DC)),
                      ),
                    ],
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

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final List<Widget?> _screens = List<Widget?>.filled(5, null);

  @override
  void initState() {
    super.initState();
    _screens[0] = _buildScreen(0);
  }

  Widget _buildScreen(int index) {
    switch (index) {
      case 0:
        return HomeScreen(onOpenTab: _selectTab);
      case 1:
        return const VocabularyScreen();
      case 2:
        return const GrammarScreen();
      case 3:
        return const ReadingPracticeScreen();
      case 4:
        return ProfileScreen(onLogout: widget.onLogout);
      default:
        return const SizedBox.shrink();
    }
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      _screens[index] ??= _buildScreen(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    _screens[_selectedIndex] ??= _buildScreen(_selectedIndex);

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
          _screens.length,
          (index) => _screens[index] ?? const SizedBox.shrink(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        height: 72,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Hôm nay',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Từ vựng',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Ngữ pháp',
          ),
          NavigationDestination(
            icon: Icon(Icons.record_voice_over_outlined),
            selectedIcon: Icon(Icons.record_voice_over),
            label: 'Đọc',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Tài khoản',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onOpenTab});

  final ValueChanged<int> onOpenTab;

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Hôm nay học gì?',
      subtitle: 'Lộ trình HSK 2, mục tiêu 25 phút và 18 từ mới.',
      trailing: const UserAvatar(),
      children: [
        AppCard(
          gradient: const LinearGradient(
            colors: [Color(0xFFFAF1E6), Color(0xFFE7F2EC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Stack(
            children: [
              Positioned(
                right: 12,
                top: -26,
                child: Text(
                  '语',
                  style: TextStyle(
                    fontSize: 144,
                    fontWeight: FontWeight.w900,
                    color: AppColors.cinnabar.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusPill(
                    icon: Icons.flag_outlined,
                    label: 'Đang học HSK 2',
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Hoàn thành bài Gia đình và thời gian',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ôn 8 từ đã lưu, luyện một câu phát âm và kiểm tra ngữ pháp bằng AI để giữ streak.',
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: () => onOpenTab(1),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Học tiếp'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => onOpenTab(1),
                        icon: const Icon(Icons.bookmark_border),
                        label: const Text('Mở sổ tay'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const MetricWrap(
          metrics: [
            DashboardMetric(
              '12',
              'Ngày streak',
              Icons.local_fire_department_outlined,
              AppColors.cinnabar,
            ),
            DashboardMetric(
              '18/20',
              'Từ hôm nay',
              Icons.style_outlined,
              AppColors.jade,
            ),
            DashboardMetric(
              '24 phút',
              'Thời gian học',
              Icons.timer_outlined,
              AppColors.amber,
            ),
            DashboardMetric(
              '3',
              'Lượt AI sửa câu',
              Icons.auto_fix_high_outlined,
              AppColors.blue,
            ),
          ],
        ),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Tính năng chính',
          subtitle:
              'Các màn hình đã được tách đúng nhóm chức năng: từ điển, sổ tay, flashcard, ngữ pháp, đọc và phát âm.',
        ),
        FeatureGrid(
          items: [
            FeatureItem(
              'Từ vựng HSK',
              'Tra từ, học theo chủ đề và lưu sổ tay.',
              Icons.translate,
              AppColors.cinnabar,
              () => onOpenTab(1),
            ),
            FeatureItem(
              'AI ngữ pháp',
              'Nhập câu, xem lỗi, câu sửa và mẹo học.',
              Icons.psychology_alt_outlined,
              AppColors.blue,
              () => onOpenTab(2),
            ),
            FeatureItem(
              'Phát âm',
              'Nghe mẫu, ghi âm và nhận điểm tương đồng.',
              Icons.mic_none,
              AppColors.jade,
              () => onOpenTab(3),
            ),
            FeatureItem(
              'Đọc và video',
              'Đọc câu theo HSK, luyện phụ đề Little Fox.',
              Icons.ondemand_video_outlined,
              AppColors.plum,
              () => onOpenTab(3),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeader(title: 'Lộ trình HSK'),
        const HskRoadmap(),
      ],
    );
  }
}

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  int _tab = 0;
  Set<String> _saved = {};

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final saved = await NotebookStore.load();
    if (mounted) setState(() => _saved = saved);
  }

  Future<void> _toggleSaved(String word) async {
    final saved = await NotebookStore.toggle(word);
    if (mounted) setState(() => _saved = saved);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Từ vựng HSK',
      subtitle:
          'Tra từ Trung - Việt, học flashcard theo chủ đề và quản lý sổ tay.',
      trailing: IconButton.filledTonal(
        tooltip: 'Đồng bộ sổ tay',
        onPressed: _loadSaved,
        icon: const Icon(Icons.cloud_sync_outlined),
      ),
      children: [
        SegmentTabs(
          labels: const ['Từ điển', 'Bài học', 'Sổ tay'],
          selectedIndex: _tab,
          onChanged: (index) => setState(() => _tab = index),
        ),
        const SizedBox(height: 16),
        if (_tab == 0)
          DictionaryPanel(saved: _saved, onToggleSaved: _toggleSaved),
        if (_tab == 1)
          FlashcardTopicsPanel(saved: _saved, onToggleSaved: _toggleSaved),
        if (_tab == 2)
          NotebookPanel(saved: _saved, onToggleSaved: _toggleSaved),
      ],
    );
  }
}

class DictionaryPanel extends StatefulWidget {
  const DictionaryPanel({
    super.key,
    required this.saved,
    required this.onToggleSaved,
  });

  final Set<String> saved;
  final ValueChanged<String> onToggleSaved;

  @override
  State<DictionaryPanel> createState() => _DictionaryPanelState();
}

class _DictionaryPanelState extends State<DictionaryPanel> {
  final TextEditingController _controller = TextEditingController();
  final FlutterTts _tts = FlutterTts();
  VocabEntry? _result;
  bool _loading = false;
  bool _dictionaryReady = false;
  String _message = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    DictionaryRepository.ensureLoaded().then((_) {
      if (mounted) setState(() => _dictionaryReady = true);
    });
    _controller.addListener(() {
      _debounce?.cancel();
      final q = _controller.text.trim();
      if (q.isEmpty) return;
      _debounce = Timer(
        const Duration(milliseconds: 260),
        () => _search(q, quick: true),
      );
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _search(String query, {bool quick = false}) async {
    final q = query.trim();
    if (q.isEmpty) return;
    setState(() {
      _loading = true;
      _message = '';
    });

    await DictionaryRepository.ensureLoaded();
    final local = DictionaryRepository.lookupLocal(q);
    if (local != null) {
      setState(() {
        _result = local;
        _loading = false;
      });
      return;
    }

    final remote = await DictionaryRepository.lookupRemote(q);
    if (!mounted) return;
    setState(() {
      _result = remote ?? local;
      _loading = false;
      _message = _result == null
          ? 'Không tìm thấy từ phù hợp. Hãy thử Hán tự, pinyin hoặc nghĩa tiếng Việt.'
          : '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                decoration: InputDecoration(
                  hintText: _dictionaryReady
                      ? '突然 / học / xuexi'
                      : 'Đang nạp từ điển HSK...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.cinnabar,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Xóa',
                          icon: const Icon(Icons.cancel_rounded),
                          onPressed: () => setState(() {
                            _controller.clear();
                            _result = null;
                            _message = '';
                          }),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: _loading ? null : () => _search(_controller.text),
              child: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Tra'),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Từ thịnh hành',
          style: TextStyle(color: AppColors.muted, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DictionaryRepository.trending.map((word) {
            return ActionChip(
              label: Text(word),
              onPressed: () {
                _controller.text = word;
                _search(word);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        if (_message.isNotEmpty)
          EmptyState(
            icon: Icons.search_off,
            title: 'Chưa có kết quả',
            message: _message,
          ),
        if (_result != null)
          DictionaryResultCard(
            entry: _result!,
            saved: widget.saved.contains(_result!.simplified),
            onSpeak: () => _tts.speak(_result!.simplified),
            onToggleSaved: () => widget.onToggleSaved(_result!.simplified),
          ),
      ],
    );
  }
}

class DictionaryResultCard extends StatelessWidget {
  const DictionaryResultCard({
    super.key,
    required this.entry,
    required this.saved,
    required this.onSpeak,
    required this.onToggleSaved,
  });

  final VocabEntry entry;
  final bool saved;
  final VoidCallback onSpeak;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        entry.simplified,
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        entry.pinyin,
                        style: const TextStyle(
                          fontSize: 24,
                          color: AppColors.cinnabar,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Nghe phát âm',
                  onPressed: onSpeak,
                  icon: const Icon(
                    Icons.volume_up_outlined,
                    color: AppColors.amber,
                  ),
                ),
                IconButton(
                  tooltip: saved ? 'Bỏ khỏi sổ tay' : 'Lưu vào sổ tay',
                  onPressed: onToggleSaved,
                  icon: Icon(
                    saved ? Icons.bookmark : Icons.bookmark_border,
                    color: saved ? AppColors.cinnabar : AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoLine(
                  icon: Icons.translate,
                  label: 'Nghĩa tiếng Việt',
                  value: entry.meaning,
                ),
                if (entry.hanViet.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InfoLine(
                    icon: Icons.spellcheck,
                    label: 'Hán Việt',
                    value: entry.hanViet,
                  ),
                ],
                if (entry.wordType.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  InfoLine(
                    icon: Icons.category_outlined,
                    label: 'Loại từ',
                    value: entry.wordType,
                  ),
                ],
                const SizedBox(height: 18),
                const Text(
                  'Ví dụ câu',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                ...entry.examples.map((ex) => ExampleTile(example: ex)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FlashcardTopicsPanel extends StatefulWidget {
  const FlashcardTopicsPanel({
    super.key,
    required this.saved,
    required this.onToggleSaved,
  });

  final Set<String> saved;
  final ValueChanged<String> onToggleSaved;

  @override
  State<FlashcardTopicsPanel> createState() => _FlashcardTopicsPanelState();
}

class _FlashcardTopicsPanelState extends State<FlashcardTopicsPanel> {
  String _level = 'HSK 1';
  late final Future<List<FlashcardTopic>> _topicsFuture;

  @override
  void initState() {
    super.initState();
    _topicsFuture = FlashcardRepository.loadTopics();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FlashcardTopic>>(
      future: _topicsFuture,
      builder: (context, snapshot) {
        final allTopics = snapshot.data ?? FlashcardRepository.fallbackTopics;
        final topics = allTopics
            .where((topic) => topic.level == _level)
            .toList();
        if (!snapshot.hasData && allTopics.isEmpty) {
          return const AppCard(
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildTopicList(topics);
      },
    );
  }

  Widget _buildTopicList(List<FlashcardTopic> topics) {
    final allWords = topics
        .expand((topic) => topic.words.map((word) => word.simplified))
        .toSet();
    final learned = widget.saved.intersection(allWords).length;

    return Column(
      children: [
        LevelSelector(
          levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
          selected: _level,
          onSelected: (level) => setState(() => _level = level),
        ),
        const SizedBox(height: 16),
        AppCard(
          gradient: LinearGradient(
            colors: [
              _levelColor(_level).withValues(alpha: 0.86),
              _levelColor(_level).withValues(alpha: 0.68),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _level,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$learned/${allWords.length} từ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  StatusPill(
                    label:
                        '${allWords.isEmpty ? 0 : (learned / allWords.length * 100).round()}%',
                    color: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 7,
                  value: allWords.isEmpty ? 0 : learned / allWords.length,
                  backgroundColor: Colors.white.withValues(alpha: 0.28),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Mỗi chủ đề là một bài học flashcard có ảnh, nghe mẫu và quiz ngắn.',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...topics.map(
          (topic) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TopicCard(
              topic: topic,
              savedCount: topic.words
                  .where((word) => widget.saved.contains(word.simplified))
                  .length,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => FlashcardLessonScreen(
                      topic: topic,
                      saved: widget.saved,
                      onToggleSaved: widget.onToggleSaved,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class NotebookPanel extends StatelessWidget {
  const NotebookPanel({
    super.key,
    required this.saved,
    required this.onToggleSaved,
  });

  final Set<String> saved;
  final ValueChanged<String> onToggleSaved;

  @override
  Widget build(BuildContext context) {
    final words = saved
        .map(DictionaryRepository.lookupLocal)
        .whereType<VocabEntry>()
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          color: const Color(0xFFFFFAF0),
          child: Row(
            children: [
              const Icon(Icons.bookmark_added_outlined, color: AppColors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sổ tay hiện có ${saved.length} từ. Danh sách này được lưu tự động trên thiết bị.',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (words.isEmpty)
          const EmptyState(
            icon: Icons.bookmark_border,
            title: 'Chưa có từ nào',
            message: 'Hãy lưu từ khi tra cứu hoặc học theo chủ đề.',
          )
        else
          ...words.map(
            (word) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CompactWordCard(
                entry: word,
                onRemove: () => onToggleSaved(word.simplified),
              ),
            ),
          ),
      ],
    );
  }
}

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  int _tab = 0;
  String _level = 'HSK 1';
  final TextEditingController _controller = TextEditingController(
    text: '我不学校去',
  );
  GrammarCheckResult? _result;
  bool _checking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _check() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checking = true;
      _result = null;
    });
    GrammarCheckResult result;
    try {
      final ai = await GrammarAiService.checkGrammar(text);
      result = _grammarResultFromAi(ai, text);
    } catch (error) {
      result = GrammarCheckResult(
        score: 35,
        title: 'Chưa kết nối được AI',
        summary: 'Không gọi được API Google AI Studio qua backend.',
        correction: text,
        explanation:
            'Hãy kiểm tra backend đang chạy và đã có GEMINI_API_KEY. Hệ thống không tự chấm 92 khi API lỗi.',
        errors: ['Lỗi API: $error'],
      );
    }
    if (!mounted) return;
    setState(() {
      _result = result;
      _checking = false;
    });
  }

  GrammarCheckResult _grammarResultFromAi(
    Map<String, dynamic> data,
    String original,
  ) {
    final rawScore = data['score'];
    final score = rawScore is num ? rawScore.round().clamp(0, 100) : 0;
    final correction = data['correction'];
    final correctionCn = correction is Map
        ? (correction['cn'] ?? correction['chinese'] ?? original).toString()
        : (data['correctionCn'] ?? data['corrected'] ?? original).toString();
    final correctionVi = correction is Map
        ? (correction['vi'] ?? '').toString()
        : (data['vi'] ?? '').toString();
    final errors = <String>[];
    final rawErrors = data['errors'];
    if (rawErrors is List) {
      for (final item in rawErrors) {
        if (item is Map) {
          final type = (item['type'] ?? 'Lỗi').toString();
          final explanation = (item['explanation'] ?? item['message'] ?? '')
              .toString();
          final fix = (item['fix'] ?? item['suggestion'] ?? '').toString();
          errors.add(
            [
              type,
              explanation,
              fix,
            ].where((part) => part.trim().isNotEmpty).join(': '),
          );
        } else {
          errors.add(item.toString());
        }
      }
    }
    final isCorrect = data['isCorrect'] == true || score >= 85;
    if (score <= 0 && errors.isNotEmpty) {
      return GrammarCheckResult(
        score: 35,
        title: 'AI chưa phản hồi được',
        summary: errors.first,
        correction: original,
        explanation:
            (data['style_tips'] ??
                    'Kiểm tra backend và GEMINI_API_KEY rồi thử lại.')
                .toString(),
        errors: errors,
      );
    }
    return GrammarCheckResult(
      score: score == 0 ? (isCorrect ? 90 : 60) : score,
      title: isCorrect ? 'Câu dùng được' : 'AI đề xuất sửa',
      summary:
          (data['summary'] ??
                  data['style_tips'] ??
                  (isCorrect
                      ? 'AI không phát hiện lỗi lớn.'
                      : 'AI phát hiện điểm cần chỉnh.'))
              .toString(),
      correction: correctionCn,
      explanation: correctionVi.isNotEmpty
          ? correctionVi
          : (data['explanation'] ?? data['style_tips'] ?? '').toString(),
      errors: errors,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Ngữ pháp và AI',
      subtitle: 'Xem mẫu câu theo HSK, nhập câu tiếng Trung để nhận phản hồi.',
      trailing: IconButton.filledTonal(
        tooltip: 'Lịch sử kiểm tra',
        onPressed: () {},
        icon: const Icon(Icons.history),
      ),
      children: [
        SegmentTabs(
          labels: const ['Bài học', 'AI kiểm tra'],
          selectedIndex: _tab,
          onChanged: (index) => setState(() => _tab = index),
        ),
        const SizedBox(height: 16),
        if (_tab == 0) _buildLessons(),
        if (_tab == 1) _buildChecker(),
      ],
    );
  }

  Widget _buildLessons() {
    return FutureBuilder<List<GrammarLessonData>>(
      future: GrammarRepository.loadLessons(),
      builder: (context, snapshot) {
        final lessons = (snapshot.data ?? GrammarRepository.lessons)
            .where((lesson) => lesson.level == _level)
            .toList();
        return Column(
          children: [
            LevelSelector(
              levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
              selected: _level,
              onSelected: (level) => setState(() => _level = level),
            ),
            const SizedBox(height: 16),
            if (!snapshot.hasData)
              const AppCard(child: Center(child: CircularProgressIndicator())),
            ...lessons.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: GrammarLessonCard(
                  index: entry.key + 1,
                  lesson: entry.value,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChecker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppColors.blue),
                  SizedBox(width: 8),
                  Text(
                    'AI sửa câu tiếng Trung',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _controller,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Nhập câu cần kiểm tra, ví dụ: 我不学校去',
                ),
              ),
              const SizedBox(height: 14),
              FilledButton.icon(
                onPressed: _checking ? null : _check,
                icon: _checking
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.fact_check_outlined),
                label: Text(
                  _checking ? 'Đang kiểm tra...' : 'Kiểm tra ngữ pháp',
                ),
              ),
            ],
          ),
        ),
        if (_result != null) ...[
          const SizedBox(height: 16),
          GrammarResultCard(result: _result!),
        ],
      ],
    );
  }
}

class ReadingPracticeScreen extends StatefulWidget {
  const ReadingPracticeScreen({super.key});

  @override
  State<ReadingPracticeScreen> createState() => _ReadingPracticeScreenState();
}

class _ReadingPracticeScreenState extends State<ReadingPracticeScreen> {
  int _tab = 0;
  String _level = 'HSK 1';
  int _sentenceIndex = 0;
  bool _listening = false;
  String _recognized = '';
  int? _score;
  bool _contentLoading = true;
  List<SentencePractice> _practiceSentences = ReadingRepository.sentences;
  List<NewsArticleData> _articles = const [];
  List<VideoLessonData> _videoLessons = VideoRepository.lessons;
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.45);
    _loadContent();
  }

  @override
  void dispose() {
    _tts.stop();
    _speech.stop();
    super.dispose();
  }

  Future<void> _loadContent({bool includeLiveNews = false}) async {
    final results = await Future.wait([
      ReadingRepository.loadSentences(),
      ReadingRepository.loadArticles(includeLive: includeLiveNews),
      VideoRepository.loadLessons(),
    ]);
    if (!mounted) return;
    setState(() {
      _practiceSentences = results[0] as List<SentencePractice>;
      _articles = results[1] as List<NewsArticleData>;
      _videoLessons = results[2] as List<VideoLessonData>;
      _contentLoading = false;
    });
  }

  List<SentencePractice> get _sentences =>
      _practiceSentences.where((s) => s.level == _level).toList();

  Future<void> _startListening(SentencePractice current) async {
    final available = await _speech.initialize();
    if (!available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Trình duyệt chưa cấp quyền micro hoặc không hỗ trợ nhận dạng giọng nói.',
          ),
        ),
      );
      return;
    }
    setState(() {
      _listening = true;
      _recognized = '';
      _score = null;
    });
    await _speech.listen(
      localeId: 'zh-CN',
      listenFor: const Duration(seconds: 8),
      pauseFor: const Duration(seconds: 2),
      onResult: (result) {
        setState(() => _recognized = result.recognizedWords);
        if (result.finalResult) _finishPronunciation(current);
      },
    );
  }

  Future<void> _stopListening(SentencePractice current) async {
    await _speech.stop();
    _finishPronunciation(current);
  }

  void _finishPronunciation(SentencePractice current) {
    if (!mounted) return;
    setState(() {
      _listening = false;
      _score = PronunciationScorer.score(current.cn, _recognized);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      title: 'Luyện đọc và phát âm',
      subtitle:
          'Đọc báo tiếng Trung, tra từ trong bài và luyện phụ đề video ngắn.',
      trailing: IconButton.filledTonal(
        tooltip: 'Làm mới',
        onPressed: () {
          setState(() {
            _recognized = '';
            _score = null;
            _contentLoading = true;
          });
          _loadContent(includeLiveNews: true);
        },
        icon: const Icon(Icons.refresh),
      ),
      children: [
        SegmentTabs(
          labels: const ['Phát âm', 'Đọc báo', 'Video'],
          selectedIndex: _tab,
          onChanged: (index) => setState(() => _tab = index),
        ),
        const SizedBox(height: 16),
        if (_tab == 0) _buildPronunciation(),
        if (_tab == 1) _buildReadingList(),
        if (_tab == 2) _buildVideos(),
      ],
    );
  }

  Widget _buildPronunciation() {
    final sentences = _sentences;
    return Column(
      children: [
        LevelSelector(
          levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
          selected: _level,
          onSelected: (level) => setState(() {
            _level = level;
            _sentenceIndex = 0;
            _recognized = '';
            _score = null;
          }),
        ),
        const SizedBox(height: 16),
        if (_contentLoading)
          const AppCard(child: Center(child: CircularProgressIndicator())),
        if (!_contentLoading && sentences.isEmpty)
          const EmptyState(
            icon: Icons.record_voice_over_outlined,
            title: 'Chưa có câu luyện',
            message: 'Dữ liệu luyện phát âm cho cấp này đang được cập nhật.',
          ),
        if (!_contentLoading && sentences.isNotEmpty)
          _PronunciationPracticeCard(
            current: sentences[_sentenceIndex % sentences.length],
            currentIndex: _sentenceIndex,
            total: sentences.length,
            listening: _listening,
            recognized: _recognized,
            score: _score,
            onSpeak: () =>
                _tts.speak(sentences[_sentenceIndex % sentences.length].cn),
            onRecord: () {
              final current = sentences[_sentenceIndex % sentences.length];
              return _listening
                  ? _stopListening(current)
                  : _startListening(current);
            },
            onNext: () => setState(() {
              _sentenceIndex++;
              _recognized = '';
              _score = null;
            }),
          ),
      ],
    );
  }

  Widget _buildReadingList() {
    final items = _articles
        .where((article) => article.level == _level)
        .toList();
    final liveCount = _articles.where((article) => article.live).length;
    return Column(
      children: [
        LevelSelector(
          levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
          selected: _level,
          onSelected: (level) => setState(() => _level = level),
        ),
        const SizedBox(height: 16),
        AppCard(
          color: const Color(0xFFFFFAEA),
          child: Row(
            children: [
              const Icon(Icons.rss_feed, color: AppColors.amber),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  liveCount > 0
                      ? 'Đã cập nhật $liveCount tin mới từ RSS. Mở bài để đọc từng câu kèm pinyin, dịch nhanh và tra từ.'
                      : 'Đọc báo có câu tiếng Trung, pinyin, dịch nhanh và tra từ ngay trong bài.',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() => _contentLoading = true);
                  _loadContent(includeLiveNews: true);
                },
                icon: const Icon(Icons.sync),
                label: const Text('Tải mới'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (_contentLoading)
          const AppCard(child: Center(child: CircularProgressIndicator())),
        ...items.asMap().entries.map((entry) {
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AppCard(
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NewsArticleReaderScreen(article: item),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: AppColors.blue.withValues(alpha: 0.12),
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              StatusPill(
                                label: item.live ? 'Tin mới' : item.level,
                                color: item.live
                                    ? AppColors.jade
                                    : _levelColor(item.level),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item.source,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          if (item.titleVi.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              item.titleVi,
                              style: const TextStyle(
                                color: AppColors.blue,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            item.summaryVi,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Nghe tiêu đề',
                      onPressed: () => _tts.speak(item.title),
                      icon: const Icon(Icons.volume_up_outlined),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (!_contentLoading && items.isEmpty)
          const EmptyState(
            icon: Icons.newspaper_outlined,
            title: 'Chưa có bài đọc',
            message: 'Nguồn đọc báo cho cấp này đang được cập nhật.',
          ),
      ],
    );
  }

  Widget _buildVideos() {
    final lessons = _videoLessons
        .where((lesson) => lesson.level == _level)
        .toList();
    return Column(
      children: [
        LevelSelector(
          levels: const ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'],
          selected: _level,
          onSelected: (level) => setState(() => _level = level),
        ),
        const SizedBox(height: 16),
        ...lessons.map((lesson) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: VideoLessonCard(
              lesson: lesson,
              onOpen: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => VideoLessonDetailScreen(lesson: lesson),
                ),
              ),
            ),
          );
        }),
        if (!_contentLoading && lessons.isEmpty)
          const EmptyState(
            icon: Icons.video_library_outlined,
            title: 'Chưa có video',
            message: 'Video cho cấp này đang được cập nhật.',
          ),
      ],
    );
  }
}

class _PronunciationPracticeCard extends StatelessWidget {
  const _PronunciationPracticeCard({
    required this.current,
    required this.currentIndex,
    required this.total,
    required this.listening,
    required this.recognized,
    required this.score,
    required this.onSpeak,
    required this.onRecord,
    required this.onNext,
  });

  final SentencePractice current;
  final int currentIndex;
  final int total;
  final bool listening;
  final String recognized;
  final int? score;
  final VoidCallback onSpeak;
  final Future<void> Function() onRecord;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          gradient: const LinearGradient(
            colors: [Color(0xFFEAF6F0), Color(0xFFFFF7E8)],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  StatusPill(
                    icon: Icons.record_voice_over_outlined,
                    label: 'Câu ${currentIndex + 1}/$total',
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    tooltip: 'Nghe mẫu',
                    onPressed: onSpeak,
                    icon: const Icon(Icons.volume_up_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                current.cn,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                current.py,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                current.vi,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
              const SizedBox(height: 26),
              GestureDetector(
                onTap: () => onRecord(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: listening ? AppColors.cinnabar : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (listening ? AppColors.cinnabar : AppColors.blue)
                            .withValues(alpha: 0.22),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    listening ? Icons.stop : Icons.mic,
                    size: 40,
                    color: listening ? Colors.white : AppColors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                listening ? 'Đang nghe... bấm để dừng' : 'Bấm để bắt đầu đọc',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        if (recognized.isNotEmpty) ...[
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn đã đọc:',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recognized,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (score != null) ...[
          const SizedBox(height: 14),
          PronunciationScoreCard(score: score!, onNext: onNext),
        ],
      ],
    );
  }
}

class NewsArticleReaderScreen extends StatefulWidget {
  const NewsArticleReaderScreen({super.key, required this.article});

  final NewsArticleData article;

  @override
  State<NewsArticleReaderScreen> createState() =>
      _NewsArticleReaderScreenState();
}

class _NewsArticleReaderScreenState extends State<NewsArticleReaderScreen> {
  final FlutterTts _tts = FlutterTts();
  int _currentSentence = 0;

  @override
  void initState() {
    super.initState();
    _tts.setLanguage('zh-CN');
    _tts.setSpeechRate(0.45);
    DictionaryRepository.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  void _showWord(VocabEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  entry.simplified,
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.pinyin,
                    style: const TextStyle(
                      color: AppColors.cinnabar,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _tts.speak(entry.simplified),
                  icon: const Icon(Icons.volume_up_outlined),
                ),
              ],
            ),
            const SizedBox(height: 8),
            InfoLine(
              icon: Icons.translate,
              label: 'Nghĩa',
              value: entry.meaning,
            ),
            if (entry.examples.isNotEmpty) ...[
              const SizedBox(height: 14),
              ExampleTile(example: entry.examples.first),
            ],
          ],
        ),
      ),
    );
  }

  List<InlineSpan> _buildSpans(String text) {
    final spans = <InlineSpan>[];
    var i = 0;
    while (i < text.length) {
      final char = text.substring(i, i + 1);
      if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(char)) {
        spans.add(TextSpan(text: char));
        i++;
        continue;
      }
      final entry = DictionaryRepository.lookupAt(text, i);
      if (entry == null) {
        spans.add(TextSpan(text: char));
        i++;
        continue;
      }
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.ideographic,
          child: InkWell(
            onTap: () => _showWord(entry),
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Text(
                entry.simplified,
                style: const TextStyle(
                  fontSize: 23,
                  height: 1.65,
                  color: AppColors.blue,
                  fontWeight: FontWeight.w800,
                  decoration: TextDecoration.underline,
                  decorationThickness: 0.8,
                ),
              ),
            ),
          ),
        ),
      );
      i += entry.simplified.length;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.article.sentences.isEmpty
        ? ReadingRepository.buildStudyLines(widget.article.content)
        : widget.article.sentences;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article.level),
        actions: [
          IconButton(
            tooltip: 'Nghe bài',
            onPressed: () => _tts.speak(widget.article.content),
            icon: const Icon(Icons.volume_up_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StatusPill(
                  icon: Icons.newspaper_outlined,
                  label: widget.article.source,
                ),
                if (widget.article.live) ...[
                  const SizedBox(height: 8),
                  const StatusPill(label: 'RSS mới', color: AppColors.jade),
                ],
                const SizedBox(height: 14),
                Text(
                  widget.article.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (widget.article.titleVi.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    widget.article.titleVi,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                ...lines.asMap().entries.map((entry) {
                  final index = entry.key;
                  final line = entry.value;
                  return ArticleSentenceCard(
                    index: index,
                    active: index == _currentSentence,
                    line: line,
                    onSpeak: () {
                      setState(() => _currentSentence = index);
                      _tts.speak(line.cn);
                    },
                    spans: _buildSpans(line.cn),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ArticleSentenceCard extends StatelessWidget {
  const ArticleSentenceCard({
    super.key,
    required this.index,
    required this.active,
    required this.line,
    required this.spans,
    required this.onSpeak,
  });

  final int index;
  final bool active;
  final ArticleSentenceData line;
  final List<InlineSpan> spans;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: active
            ? AppColors.cinnabar.withValues(alpha: 0.08)
            : const Color(0xFFFFFBF6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? AppColors.cinnabar : AppColors.line,
          width: active ? 1.4 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: active ? AppColors.cinnabar : AppColors.line,
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: active ? Colors.white : AppColors.muted,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 23,
                      height: 1.55,
                      fontWeight: FontWeight.w800,
                    ),
                    children: spans,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Nghe câu',
                onPressed: onSpeak,
                icon: const Icon(Icons.volume_up_outlined),
              ),
            ],
          ),
          if (line.py.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              line.py,
              style: const TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ],
          if (line.vi.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              line.vi,
              style: const TextStyle(
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
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
    streakDays: 12,
    weeklyProgress: 0.68,
    savedWords: 42,
    speakingScore: 91,
    readingArticles: 4,
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

class ProfileRepository {
  static Uri _uri(String path) =>
      Uri.parse('${DictionaryRepository.apiBaseUrl}$path');

  static Future<ProfileData> load() async {
    final response = await http
        .get(_uri('/profile'))
        .timeout(const Duration(seconds: 3));
    if (response.statusCode != 200) {
      throw Exception('Profile API ${response.statusCode}');
    }
    return ProfileData.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  static Future<ProfileData> updateGoal({
    required String level,
    required int words,
    required int minutes,
  }) async {
    final response = await http
        .post(
          _uri('/profile/goal'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'level': level,
            'words': words,
            'minutes': minutes,
          }),
        )
        .timeout(const Duration(seconds: 5));
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Profile API ${response.statusCode}');
    }
    return ProfileData.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
        const SnackBar(content: Text('Đã cập nhật mục tiêu qua API.')),
      );
    } catch (error) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Chưa gọi được API tài khoản: $error')),
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
                        label: const Text('Lưu qua API'),
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
                        _showRowMessage('Sổ tay đang đồng bộ từ API hồ sơ.'),
                  ),
                  const Divider(height: 20),
                  ProfileActionRow(
                    icon: Icons.record_voice_over_outlined,
                    title: 'Luyện nói',
                    value: 'Điểm trung bình ${profile.speakingScore}',
                    color: AppColors.jade,
                    onTap: () =>
                        _showRowMessage('Điểm phát âm đã lấy từ API hồ sơ.'),
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
                    onTap: () => _showRowMessage(
                      'API nhắc học hiện trả về ${profile.reminderTime}.',
                    ),
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
                          ? () => Navigator.pop(context)
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
  double _videoDurationSeconds = 0;
  String _recognized = '';
  final Map<int, int> _scores = {};

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
    _playerSubscription = _ytController.listen((event) {
      if (!mounted) return;
      final playing = event.playerState == PlayerState.playing;
      final durationSeconds =
          event.metaData.duration.inMilliseconds /
          Duration.millisecondsPerSecond;
      final hasNewDuration =
          durationSeconds > 0 &&
          (durationSeconds - _videoDurationSeconds).abs() > 0.5;
      if (playing) {
        _startPositionTimer();
      } else {
        _stopPositionTimer();
      }
      if (playing != _isPlaying || hasNewDuration) {
        setState(() {
          _isPlaying = playing;
          if (hasNewDuration) _videoDurationSeconds = durationSeconds;
        });
      }
    });
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

  double get _subtitleFallbackDuration {
    final count = max(1, widget.lesson.subtitles.length);
    final estimated = count * 3.2;
    final knownDuration = _videoDurationSeconds > 0
        ? _videoDurationSeconds
        : estimated;
    return max(count * 2.2, knownDuration);
  }

  double get _generatedLineSpan {
    final count = max(1, widget.lesson.subtitles.length);
    return max(2.2, _subtitleFallbackDuration / count);
  }

  double _lineStart(int index) {
    final sub = widget.lesson.subtitles[index];
    if (sub.end > sub.start) return sub.start;
    return index * _generatedLineSpan;
  }

  double _lineEnd(int index) {
    final sub = widget.lesson.subtitles[index];
    final start = _lineStart(index);
    if (sub.end > sub.start) return max(start + 0.8, sub.end);
    return min(_subtitleFallbackDuration, start + _generatedLineSpan * 0.92);
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
      if (mounted) _syncActiveLine(seconds, _isPlaying);
    } catch (_) {
      // The iframe can briefly reject currentTime while the video is loading.
    } finally {
      _pollingPosition = false;
    }
  }

  void _syncActiveLine(double seconds, bool playing) {
    if (widget.lesson.subtitles.isEmpty) return;
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
      final approximate = (seconds / _generatedLineSpan).floor();
      newIndex = approximate
          .clamp(0, widget.lesson.subtitles.length - 1)
          .toInt();
    }

    final shouldPause =
        _autoPause &&
        playing &&
        newIndex >= 0 &&
        seconds >= _lineEnd(newIndex) - 0.12 &&
        !_pausedAtLineEnd;

    if (newIndex != _current || playing != _isPlaying || shouldPause) {
      setState(() {
        _current = newIndex;
        _isPlaying = playing;
        if (shouldPause) {
          _pausedAtLineEnd = true;
          _isPlaying = false;
        }
      });
      if (newIndex >= 0) _scrollToCurrent();
    }

    if (shouldPause) {
      _stopPositionTimer();
      _ytController.pauseVideo();
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
      _pausedAtLineEnd = false;
    });
    _ytController.seekTo(seconds: _lineStart(index), allowSeekAhead: true);
    _ytController.playVideo();
    _startPositionTimer();
  }

  void _toggleVideo() {
    _pausedAtLineEnd = false;
    if (_isPlaying) {
      _ytController.pauseVideo();
      _stopPositionTimer();
    } else {
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
              const Expanded(
                child: Text(
                  'Nghe video, dừng từng câu rồi nhại lại',
                  style: TextStyle(
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
                icon: Icon(listeningThisLine ? Icons.stop_circle : Icons.mic),
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
            selected: _autoPause,
            showCheckmark: false,
            avatar: Icon(
              _autoPause ? Icons.pause_circle : Icons.play_circle_outline,
              size: 18,
            ),
            label: const Text('Tự dừng'),
            onSelected: (value) => setState(() {
              _autoPause = value;
              _pausedAtLineEnd = false;
            }),
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
    setState(() {
      _listening = false;
      _scores[index] = PronunciationScorer.score(target, _recognized);
    });
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

class HskRoadmap extends StatelessWidget {
  const HskRoadmap({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('HSK 1', 150, 150, AppColors.jade),
      ('HSK 2', 300, 204, AppColors.cinnabar),
      ('HSK 3', 600, 156, AppColors.blue),
      ('HSK 4', 1200, 96, AppColors.plum),
    ];
    return AppCard(
      child: Column(
        children: rows.map((row) {
          final progress = row.$3 / row.$2;
          return Padding(
            padding: const EdgeInsets.only(bottom: 13),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.school_outlined, color: row.$4),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        row.$1,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      '${row.$3}/${row.$2} từ',
                      style: TextStyle(
                        color: row.$4,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.line,
                    valueColor: AlwaysStoppedAnimation<Color>(row.$4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
    final samples = topic.words.take(2).map((word) => word.simplified).toList();
    return Container(
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
          Positioned(
            left: 7,
            bottom: 6,
            right: 7,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: samples
                  .map(
                    (sample) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        sample,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StatusPill(label: 'Flashcard', color: color),
                      const SizedBox(width: 6),
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

  void _showImageSource(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: FutureBuilder<FlashcardImageSuggestion>(
              future: FlashcardImageRepository.suggest(entry),
              builder: (context, snapshot) {
                final suggestion =
                    snapshot.data ??
                    (snapshot.hasError
                        ? FlashcardImageSuggestion.fallback(entry)
                        : null);
                if (suggestion == null) {
                  return const SizedBox(
                    height: 160,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nguồn ảnh flashcard',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ProfileActionRow(
                      icon: Icons.image_search_outlined,
                      title: suggestion.provider,
                      value: suggestion.keyword,
                      color: AppColors.amber,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      suggestion.style,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      suggestion.flaticonSearchUrl,
                      style: const TextStyle(color: AppColors.blue),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      suggestion.note,
                      style: const TextStyle(color: AppColors.muted),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onFlip,
          borderRadius: BorderRadius.circular(8),
          child: AppCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: FlashcardWordArt(entry: entry),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  entry.pinyin,
                  style: const TextStyle(
                    fontSize: 22,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.simplified,
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 16),
                if (showBack)
                  Column(
                    children: [
                      Text(
                        entry.meaning,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cinnabar,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ExampleTile(example: entry.examples.first),
                    ],
                  )
                else
                  const Text(
                    'Chạm thẻ để xem nghĩa và ví dụ',
                    style: TextStyle(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Nghe mẫu',
                      onPressed: onSpeak,
                      icon: const Icon(Icons.volume_up_outlined),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      tooltip: saved ? 'Bỏ khỏi sổ tay' : 'Lưu vào sổ tay',
                      onPressed: onToggleSaved,
                      icon: Icon(
                        saved ? Icons.bookmark : Icons.bookmark_border,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      tooltip: 'Nguồn ảnh minh họa',
                      onPressed: () => _showImageSource(context),
                      icon: const Icon(Icons.image_search_outlined),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
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
    final good = result.score >= 85;
    final color = good
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
                  '${result.score}',
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
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
                  StatusPill(
                    icon: Icons.ondemand_video_outlined,
                    label: lesson.source,
                    color: AppColors.cinnabar,
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
  });

  final int score;
  final String title;
  final String summary;
  final String correction;
  final String explanation;
  final List<String> errors;
}

class SentencePractice {
  const SentencePractice(this.level, this.cn, this.py, this.vi);
  final String level;
  final String cn;
  final String py;
  final String vi;
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
  });

  final String title;
  final String titleCn;
  final String level;
  final String youtubeId;
  final List<VideoSubtitleData> subtitles;
  final String source;
  String get thumbnail => 'https://img.youtube.com/vi/$youtubeId/mqdefault.jpg';
  String get youtubeUrl => 'https://www.youtube.com/watch?v=$youtubeId';
}

class DictionaryRepository {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:3001',
  );
  static final Map<String, VocabEntry> _cache = {};
  static final Map<String, VocabEntry> _exactEntries = {};
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
                  '我今天学习“$word”。',
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
                '我今天学习“$word”。',
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
    if (found == null) {
      return VocabEntry(
        simplified: word,
        pinyin: '',
        meaning: 'Nghĩa tiếng Việt đang cập nhật',
        level: level,
        imagePath: imagePath,
        examples: [
          ExampleSentenceData(
            '请用“$word”造句。',
            'Qǐng yòng "$word" zàojù.',
            'Hãy đặt câu với từ "$word".',
          ),
        ],
      );
    }
    return found.imagePath == null
        ? found.copyWith(imagePath: imagePath, level: level)
        : found;
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
    _cache = _plans.map((plan) {
      return _topic(
        plan.id,
        plan.level,
        plan.name,
        plan.icon,
        plan.words,
        plan.imagePath,
      );
    }).toList();
    return _cache!;
  }

  static FlashcardTopic _topic(
    String id,
    String level,
    String name,
    IconData icon,
    List<String> words,
    String imagePath,
  ) {
    return FlashcardTopic(
      id: id,
      level: level,
      name: name,
      icon: icon,
      imagePath: imagePath,
      words: words
          .map(
            (word) => DictionaryRepository.forFlashcard(
              word,
              level: level,
              imagePath: imagePath,
            ),
          )
          .toList(),
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
      'assets/images/flashcards/family/39af35e7b7.jpg',
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
      final raw = await rootBundle.loadString('assets/data/grammar_hsk14.json');
      final decoded = jsonDecode(raw);
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
        'Tính từ vị ngữ trong tiếng Trung thường không dùng 是. Nói “我很好”, không nói “我是很好”.',
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
      final raw = await rootBundle.loadString('assets/data/reading_hsk.json');
      final decoded = jsonDecode(raw);
      if (decoded is! List) return sentences;
      return decoded
          .whereType<Map>()
          .map((raw) {
            final map = Map<String, dynamic>.from(raw);
            return SentencePractice(
              (map['level'] ?? 'HSK 1').toString(),
              (map['cn'] ?? '').toString(),
              (map['py'] ?? '').toString(),
              (map['vi'] ?? '').toString(),
            );
          })
          .where((item) => item.cn.isNotEmpty)
          .toList();
    } catch (_) {
      return sentences;
    }
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
      final raw = await rootBundle.loadString(
        'assets/data/reading_news_seed.json',
      );
      final decoded = jsonDecode(raw);
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
      sentences: lines.isEmpty
          ? buildStudyLines([title, content].join('。'))
          : lines,
      live: map['live'] == true || link.startsWith('http'),
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
      if (lines.length >= 18) break;
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
  static Future<List<VideoLessonData>> loadLessons() async {
    try {
      final raw = await rootBundle.loadString('assets/data/video_lessons.json');
      final decoded = jsonDecode(raw);
      if (decoded is! List) return lessons;
      final loaded = decoded
          .whereType<Map>()
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
                    final index = subtitles.length;
                    final start =
                        (sub['start'] as num?)?.toDouble() ?? index * 3.2;
                    final end = (sub['end'] as num?)?.toDouble() ?? start + 2.9;
                    subtitles.add(
                      VideoSubtitleData(
                        cn,
                        py,
                        vi,
                        start: start,
                        end: max(start + 0.8, end),
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
            );
          })
          .where(
            (lesson) => lesson.title.isNotEmpty && lesson.youtubeId.isNotEmpty,
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
