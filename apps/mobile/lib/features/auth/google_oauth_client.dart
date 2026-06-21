import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:mobile/core/config/app_config.dart';

class GoogleIdentity {
  const GoogleIdentity({
    required this.idToken,
    required this.email,
    required this.displayName,
    this.avatarUrl = '',
  });

  final String idToken;
  final String email;
  final String displayName;
  final String avatarUrl;
}

class GoogleOAuthException implements Exception {
  const GoogleOAuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GoogleOAuthClient {
  GoogleOAuthClient._();

  static final GoogleOAuthClient instance = GoogleOAuthClient._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final StreamController<GoogleIdentity> _authenticationEvents =
      StreamController<GoogleIdentity>.broadcast();

  Future<void>? _initialization;

  Stream<GoogleIdentity> get authenticationEvents =>
      _authenticationEvents.stream;

  bool get requiresRenderedWebButton =>
      kIsWeb && !_googleSignIn.supportsAuthenticate();

  Future<void> initialize() {
    if (_clientIdForCurrentPlatform.isEmpty) {
      throw const GoogleOAuthException(
        'Đăng nhập Google chưa được cấu hình cho bản app này. Hãy dùng email hoặc cấu hình Google OAuth Client ID.',
      );
    }
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    _googleSignIn.authenticationEvents.listen(
      _handleAuthenticationEvent,
      onError: (Object error, StackTrace stackTrace) {
        if (error is GoogleSignInException &&
            error.code == GoogleSignInExceptionCode.canceled) {
          return;
        }
        _authenticationEvents.addError(
          _friendlyException(error),
          stackTrace,
        );
      },
    );
    await _googleSignIn.initialize(
      clientId: kIsWeb ? AppConfig.googleWebClientId.trim() : null,
      serverClientId: kIsWeb ? null : _androidServerClientId,
    );
    unawaited(_googleSignIn.attemptLightweightAuthentication());
  }

  Future<void> authenticate() async {
    await initialize();
    if (!_googleSignIn.supportsAuthenticate()) {
      throw const GoogleOAuthException(
        'Trên web, hãy dùng nút Google chính thức bên trên để tiếp tục.',
      );
    }
    try {
      await _googleSignIn.authenticate();
    } on GoogleSignInException catch (error) {
      throw _friendlyException(error);
    } catch (_) {
      throw const GoogleOAuthException(
        'Không thể mở đăng nhập Google lúc này. Hãy thử lại sau.',
      );
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Removing the local VNChinese session must still succeed.
    }
  }

  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    if (event is! GoogleSignInAuthenticationEventSignIn) return;
    final user = event.user;
    final idToken = user.authentication.idToken?.trim() ?? '';
    if (idToken.isEmpty) {
      _authenticationEvents.addError(
        const GoogleOAuthException(
          'Google chưa trả về mã xác thực. Hãy chọn lại tài khoản rồi thử lại.',
        ),
      );
      return;
    }
    _authenticationEvents.add(
      GoogleIdentity(
        idToken: idToken,
        email: user.email,
        displayName: user.displayName ?? user.email.split('@').first,
        avatarUrl: user.photoUrl ?? '',
      ),
    );
  }

  String get _clientIdForCurrentPlatform {
    if (kIsWeb) return AppConfig.googleWebClientId.trim();
    return _androidServerClientId;
  }

  String get _androidServerClientId =>
      AppConfig.googleServerClientId.trim().isEmpty
      ? AppConfig.googleWebClientId.trim()
      : AppConfig.googleServerClientId.trim();

  GoogleOAuthException _friendlyException(Object error) {
    if (error is! GoogleSignInException) {
      return const GoogleOAuthException(
        'Google không thể xác thực tài khoản lúc này. Hãy thử lại.',
      );
    }
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return const GoogleOAuthException(
          'Bạn đã đóng cửa sổ chọn tài khoản Google.',
        );
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return const GoogleOAuthException(
          'Google Sign-In chưa khớp cấu hình ứng dụng. Vui lòng kiểm tra package, SHA-1 và Client ID.',
        );
      case GoogleSignInExceptionCode.uiUnavailable:
        return const GoogleOAuthException(
          'Không thể mở cửa sổ Google Sign-In. Hãy thử lại.',
        );
      default:
        return const GoogleOAuthException(
          'Đăng nhập Google không hoàn tất. Hãy chọn lại tài khoản và thử lại.',
        );
    }
  }
}
