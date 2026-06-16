class AppConfig {
  AppConfig._();

  // Override at build/run time:
  // flutter run --dart-define=API_BASE_URL=http://192.168.1.10:3001
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001',
  );

  // Keep API key out of source code.
  // Example:
  // flutter run --dart-define=GEMINI_API_KEY=your_key_here
  static const String geminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );
}
