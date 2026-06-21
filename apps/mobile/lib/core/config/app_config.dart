class AppConfig {
  AppConfig._();

  static const String _vnChineseGoogleWebClientId =
      '567840262106-filnk22a2fdh33vildrem5npg1kb4qmg.apps.googleusercontent.com';

  // Default is only safe for Flutter Web/Desktop running on the same machine
  // as the NestJS API. Override this at build/run time for devices:
  // - Flutter Web/Desktop local: http://localhost:3001
  // - Android emulator:        http://10.0.2.2:3001
  // - Physical phone:          http://<your-lan-ip>:3001
  //
  // Example:
  // flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3001
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001',
  );

  static const String apiBaseUrlHelp =
      'Set API_BASE_URL with --dart-define. Use 10.0.2.2 for Android emulator, or your LAN IP for a physical phone.';

  // Keep API key out of source code.
  // Example:
  // flutter run --dart-define=GEMINI_API_KEY=your_key_here
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  // OAuth client IDs are public identifiers. They remain overridable so each
  // deployment can use its own Google Cloud project without changing source.
  static const String googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: _vnChineseGoogleWebClientId,
  );

  // Android must request an ID token for the Web OAuth client. The Android
  // client itself is selected by Google from applicationId + signing SHA-1.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: _vnChineseGoogleWebClientId,
  );
}
