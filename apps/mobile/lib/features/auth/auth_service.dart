import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/core/config/app_config.dart';

class AuthSession {
  const AuthSession({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.token,
    required this.isGuest,
    required this.targetLevel,
  });

  final String id;
  final String email;
  final String displayName;
  final String role;
  final String token;
  final bool isGuest;
  final String targetLevel;

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'displayName': displayName,
    'role': role,
    'token': token,
    'isGuest': isGuest,
    'targetLevel': targetLevel,
  };

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    id: '${json['id'] ?? 'local'}',
    email: '${json['email'] ?? ''}',
    displayName: _cleanName(json['displayName']),
    role: '${json['role'] ?? 'user'}',
    token: '${json['token'] ?? ''}',
    isGuest: json['isGuest'] == true,
    targetLevel: '${json['targetLevel'] ?? 'HSK 2'}',
  );

  factory AuthSession.fromApi(Map<String, dynamic> json, String targetLevel) {
    final user = (json['user'] as Map?)?.cast<String, dynamic>() ?? {};
    return AuthSession(
      id: '${user['id'] ?? 'api'}',
      email: '${user['email'] ?? ''}',
      displayName: _cleanName(user['displayName']),
      role: '${user['role'] ?? 'user'}',
      token: '${json['token'] ?? ''}',
      isGuest: false,
      targetLevel: '${user['targetLevel'] ?? targetLevel}',
    );
  }

  static String _cleanName(Object? value) {
    final name = (value ?? '').toString().trim();
    return name.isEmpty || name == 'null' ? 'Người học VNChinese' : name;
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  static const _sessionKey = 'vnchinese_auth_session_v1';
  static const _usersKey = 'vnchinese_local_users_v1';

  Future<AuthSession?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await prefs.remove(_sessionKey);
      return null;
    }
  }

  Future<AuthSession> login({
    required String email,
    required String password,
    required bool remember,
    String targetLevel = 'HSK 2',
  }) async {
    final cleanEmail = _normalizeEmail(email);
    _validateEmail(cleanEmail);
    _validatePassword(password);

    final apiSession = await _postAuth(
      path: '/auth/login',
      body: {'email': cleanEmail, 'password': password},
      targetLevel: targetLevel,
    );
    if (apiSession != null) {
      await _persist(apiSession, remember);
      return apiSession;
    }

    final users = await _loadLocalUsers();
    final record = users[cleanEmail];
    if (record == null || record['password'] != _fingerprint(password)) {
      throw const AuthException(
        'Email hoặc mật khẩu chưa đúng. Nếu chưa có tài khoản, hãy chuyển sang Đăng ký.',
      );
    }

    final session = AuthSession(
      id: '${record['id'] ?? cleanEmail}',
      email: cleanEmail,
      displayName: '${record['displayName'] ?? cleanEmail.split('@').first}',
      role: '${record['role'] ?? 'user'}',
      token: 'local-${DateTime.now().millisecondsSinceEpoch}',
      isGuest: false,
      targetLevel: '${record['targetLevel'] ?? targetLevel}',
    );
    await _persist(session, remember);
    return session;
  }

  Future<AuthSession> register({
    required String displayName,
    required String email,
    required String password,
    required bool remember,
    required String targetLevel,
  }) async {
    final cleanEmail = _normalizeEmail(email);
    final cleanName = displayName.trim();
    if (cleanName.length < 2) {
      throw const AuthException('Hãy nhập họ tên tối thiểu 2 ký tự.');
    }
    _validateEmail(cleanEmail);
    _validatePassword(password);

    final apiSession = await _postAuth(
      path: '/auth/register',
      body: {
        'displayName': cleanName,
        'email': cleanEmail,
        'password': password,
        'targetLevel': targetLevel,
      },
      targetLevel: targetLevel,
    );
    if (apiSession != null) {
      await _persist(apiSession, remember);
      return apiSession;
    }

    final users = await _loadLocalUsers();
    if (users.containsKey(cleanEmail)) {
      throw const AuthException('Email này đã được đăng ký trên thiết bị.');
    }

    users[cleanEmail] = {
      'id': 'local-${DateTime.now().millisecondsSinceEpoch}',
      'email': cleanEmail,
      'displayName': cleanName,
      'password': _fingerprint(password),
      'role': 'user',
      'targetLevel': targetLevel,
    };
    await _saveLocalUsers(users);

    final session = AuthSession(
      id: '${users[cleanEmail]?['id']}',
      email: cleanEmail,
      displayName: cleanName,
      role: 'user',
      token: 'local-${DateTime.now().millisecondsSinceEpoch}',
      isGuest: false,
      targetLevel: targetLevel,
    );
    await _persist(session, remember);
    return session;
  }

  Future<AuthSession> continueAsGuest({required bool remember}) async {
    final session = AuthSession(
      id: 'guest',
      email: '',
      displayName: 'Học thử VNChinese',
      role: 'guest',
      token: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      isGuest: true,
      targetLevel: 'HSK 1',
    );
    await _persist(session, remember);
    return session;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  Future<AuthSession?> _postAuth({
    required String path,
    required Map<String, dynamic> body,
    required String targetLevel,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${AppConfig.apiBaseUrl}$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 3));

      final data = response.body.isNotEmpty
          ? jsonDecode(response.body) as Map<String, dynamic>
          : <String, dynamic>{};

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return AuthSession.fromApi(data, targetLevel);
      }

      throw AuthException(
        '${data['message'] ?? 'Thông tin tài khoản chưa hợp lệ.'}',
      );
    } on AuthException {
      rethrow;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist(AuthSession session, bool remember) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
    } else {
      await prefs.remove(_sessionKey);
    }
  }

  Future<Map<String, Map<String, dynamic>>> _loadLocalUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, (value as Map).cast<String, dynamic>()),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> _saveLocalUsers(Map<String, Map<String, dynamic>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  String _normalizeEmail(String value) => value.trim().toLowerCase();

  void _validateEmail(String email) {
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      throw const AuthException('Email chưa đúng định dạng.');
    }
  }

  void _validatePassword(String password) {
    if (password.length < 6) {
      throw const AuthException('Mật khẩu cần tối thiểu 6 ký tự.');
    }
  }

  String _fingerprint(String value) {
    var hash = 0x811c9dc5;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}
