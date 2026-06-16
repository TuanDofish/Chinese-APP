part of '../../main.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  AuthSession? _session;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = await AuthService.instance.restoreSession();
    if (!mounted) return;
    setState(() {
      _session = session;
      _loading = false;
    });
  }

  void _enter(AuthSession session) {
    setState(() => _session = session);
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    setState(() => _session = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_session != null) {
      return MainScreen(onLogout: () => _logout());
    }
    return AuthScreen(onContinue: _enter);
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.onContinue});

  final ValueChanged<AuthSession> onContinue;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isRegister = false;
  bool _remember = true;
  bool _obscurePassword = true;
  bool _loading = false;
  String _targetLevel = 'HSK 2';
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = _isRegister
          ? await _register()
          : await AuthService.instance.login(
              email: _emailController.text,
              password: _passwordController.text,
              remember: _remember,
              targetLevel: _targetLevel,
            );
      if (!mounted) return;
      widget.onContinue(session);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Chưa thể xử lý tài khoản. Hãy thử lại sau.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<AuthSession> _register() {
    if (_passwordController.text != _confirmController.text) {
      throw const AuthException('Mật khẩu xác nhận chưa trùng khớp.');
    }
    return AuthService.instance.register(
      displayName: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      remember: _remember,
      targetLevel: _targetLevel,
    );
  }

  Future<void> _continueAsGuest() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = await AuthService.instance.continueAsGuest(
        remember: _remember,
      );
      if (!mounted) return;
      widget.onContinue(session);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

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
            onChanged: (index) => setState(() {
              _isRegister = index == 1;
              _error = null;
            }),
          ),
          const SizedBox(height: 22),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 22),
          if (_isRegister) ...[
            TextField(
              controller: _nameController,
              enabled: !_loading,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Họ tên',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _emailController,
            enabled: !_loading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'ban@example.com',
              prefixIcon: Icon(Icons.mail_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            enabled: !_loading,
            obscureText: _obscurePassword,
            textInputAction: _isRegister
                ? TextInputAction.next
                : TextInputAction.done,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                tooltip: _obscurePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
          ),
          if (_isRegister) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _confirmController,
              enabled: !_loading,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nhập lại mật khẩu',
                prefixIcon: Icon(Icons.lock_reset_outlined),
              ),
            ),
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
              onChanged: _loading
                  ? null
                  : (value) => setState(() => _targetLevel = value ?? 'HSK 2'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cinnabar.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.cinnabar.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: AppColors.cinnabar,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Row(
            children: [
              Checkbox(
                value: _remember,
                onChanged: _loading
                    ? null
                    : (value) => setState(() => _remember = value ?? true),
              ),
              const Expanded(
                child: Text('Ghi nhớ phiên học trên thiết bị này'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_isRegister ? Icons.person_add_alt_1 : Icons.login),
            label: Text(_isRegister ? 'Tạo tài khoản' : 'Đăng nhập'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _loading ? null : _continueAsGuest,
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
