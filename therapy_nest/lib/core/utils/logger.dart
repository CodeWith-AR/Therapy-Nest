import 'package:flutter/foundation.dart';

/// Simple logger utility wrapping debugPrint for structured logging.
class AppLogger {
  AppLogger._();

  static void debug(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('${_tag(tag)}[DEBUG] $message');
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('${_tag(tag)}[INFO]  $message');
    }
  }

  static void warn(String message, {String? tag}) {
    if (kDebugMode) {
      debugPrint('${_tag(tag)}[WARN]  $message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stack, String? tag}) {
    if (kDebugMode) {
      debugPrint('${_tag(tag)}[ERROR] $message');
      if (error != null) debugPrint('  ↳ $error');
      if (stack != null) debugPrint('  ↳ $stack');
    }
  }

  static String _tag(String? tag) => tag != null ? '[$tag] ' : '';
}
