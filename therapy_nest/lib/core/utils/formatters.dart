import 'package:intl/intl.dart';

/// Common formatting utilities.
class Formatters {
  Formatters._();

  /// Format a [DateTime] as "Jan 15, 2026".
  static String date(DateTime dt) => DateFormat.yMMMd().format(dt);

  /// Format a [DateTime] as "3:30 PM".
  static String time(DateTime dt) => DateFormat.jm().format(dt);

  /// Format a [DateTime] as "Jan 15, 2026, 3:30 PM".
  static String dateTime(DateTime dt) => DateFormat.yMMMd().add_jm().format(dt);

  /// Format a [Duration] as "2m 30s" or "5m".
  static String duration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (seconds == 0) return '${minutes}m';
    return '${minutes}m ${seconds}s';
  }

  /// Format a number as percentage, e.g. 0.75 → "75%".
  static String percent(double value) => '${(value * 100).round()}%';

  /// Capitalize the first letter of a string.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
