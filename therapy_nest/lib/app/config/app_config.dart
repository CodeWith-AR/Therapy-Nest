/// App-wide configuration constants.
class AppConfig {
  AppConfig._();

  static const String appName = 'Therapy Nest';
  static const String appVersion = '1.0.0';

  /// Minimum splash screen display time (milliseconds).
  static const int splashDurationMs = 5000;

  /// Default locale for new users.
  static const String defaultLocale = 'en-US';

  /// Default sessions per week for new patients.
  static const int defaultSessionsPerWeek = 3;

  /// Default minutes per session for new patients.
  static const int defaultMinutesPerSession = 20;
}
