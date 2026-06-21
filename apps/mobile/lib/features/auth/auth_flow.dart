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
    try {
      await AuthService.instance.logout().timeout(const Duration(seconds: 3));
    } catch (_) {
      // A local logout should still complete even when platform services fail.
    } finally {
      if (mounted) setState(() => _session = null);
    }
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
  StreamSubscription<GoogleIdentity>? _googleSubscription;
  bool _googleReady = false;
  String? _googleSetupError;

  @override
  void initState() {
    super.initState();
    _googleSubscription = AuthService.instance.googleAuthenticationEvents.listen(
      _completeGoogleSignIn,
      onError: _handleGoogleSignInError,
    );
    _prepareGoogleSignIn();
  }

  @override
  void dispose() {
    _googleSubscription?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _prepareGoogleSignIn() async {
    try {
      await AuthService.instance.prepareGoogleSignIn();
      if (mounted) setState(() => _googleReady = true);
    } on GoogleOAuthException catch (error) {
      if (mounted) setState(() => _googleSetupError = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _googleSetupError =
              'Đăng nhập Google chưa sẵn sàng. Vui lòng dùng email hoặc thử lại sau.',
        );
      }
    }
  }

  Future<void> _completeGoogleSignIn(GoogleIdentity identity) async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = await AuthService.instance.completeGoogleSignIn(
        identity: identity,
        remember: _remember,
        targetLevel: _targetLevel,
      );
      if (!mounted) return;
      widget.onContinue(session);
    } on AuthException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Không thể hoàn tất đăng nhập Google. Hãy thử lại bằng email hoặc sau ít phút.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleGoogleSignInError(Object error, StackTrace stackTrace) {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = error is GoogleOAuthException
          ? error.message
          : 'Đăng nhập Google không hoàn tất. Hãy chọn lại tài khoản rồi thử lại.';
    });
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

  Future<void> _continueWithGoogle() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final session = await AuthService.instance.signInWithGoogle(
        remember: _remember,
        targetLevel: _targetLevel,
      );
      if (!mounted) return;
      widget.onContinue(session);
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } on GoogleOAuthException catch (error) {
      if (!mounted) return;
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isRegister ? 'Tạo tài khoản học tập' : 'Chào mừng trở lại';
    final subtitle = _isRegister
        ? 'Lưu tiến độ, mục tiêu HSK và sổ tay từ vựng của bạn.'
        : 'Học tiếng Trung theo HSK với AI hỗ trợ.';

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFFBF7), Color(0xFFF4EFE8), Color(0xFFEAF6F0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 820;
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 20 : 16,
                  isWide ? 18 : 12,
                  isWide ? 20 : 16,
                  28,
                ),
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
                                const Expanded(
                                  flex: 6,
                                  child: AuthVisualPanel(),
                                ),
                                const SizedBox(width: 28),
                                Expanded(
                                  flex: 5,
                                  child: _buildForm(title, subtitle),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildForm(title, subtitle, compact: true),
                              ],
                            ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(String title, String subtitle, {bool compact = false}) {
    return AppCard(
      padding: EdgeInsets.all(compact ? 18 : 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const BrandMark(showText: true),
              const Spacer(),
              if (compact)
                const StatusPill(
                  icon: Icons.school_outlined,
                  label: 'Học tiếng Trung',
                  color: AppColors.jade,
                ),
            ],
          ),
          SizedBox(height: compact ? 14 : 22),
          SegmentTabs(
            labels: const ['Đăng nhập', 'Đăng ký'],
            selectedIndex: _isRegister ? 1 : 0,
            onChanged: (index) => setState(() {
              _isRegister = index == 1;
              _error = null;
            }),
          ),
          SizedBox(height: compact ? 16 : 22),
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          if (!compact) ...[
            const SizedBox(height: 8),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ] else ...[
            const SizedBox(height: 5),
            Text(
              _isRegister
                  ? 'Tạo hồ sơ để lưu tiến độ và từ vựng.'
                  : 'Đăng nhập để tiếp tục bài học của bạn.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          SizedBox(height: compact ? 16 : 22),
          if (_googleReady && AuthService.instance.requiresOfficialGoogleWebButton)
            AbsorbPointer(
              absorbing: _loading,
              child: Opacity(
                opacity: _loading ? 0.55 : 1,
                child: buildGoogleSignInWebButton(),
              ),
            )
          else if (_googleReady)
            OutlinedButton.icon(
              onPressed: _loading ? null : _continueWithGoogle,
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
              label: Text(
                _loading ? 'Đang kết nối Google...' : 'Tiếp tục với Google',
              ),
            )
          else if (_googleSetupError == null)
            const SizedBox(
              height: 48,
              child: Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          if (_googleSetupError != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.10),
                border: Border.all(
                  color: AppColors.amber.withValues(alpha: 0.28),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Google Sign-In đang chờ cấu hình Client ID. Bạn vẫn có thể dùng email để học ngay.',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.line)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'hoặc dùng email',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.line)),
            ],
          ),
          const SizedBox(height: 14),
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
          const SizedBox(height: 6),
          Text(
            'Dữ liệu học thử chỉ được lưu trên thiết bị này.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.muted,
            ),
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
