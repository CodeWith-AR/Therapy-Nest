import 'package:flutter/material.dart';

/// Useful extension methods on framework types.

extension BuildContextX on BuildContext {
  /// Shorthand for `MediaQuery.sizeOf(this)`.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Shorthand for `MediaQuery.paddingOf(this)`.
  EdgeInsets get screenPadding => MediaQuery.paddingOf(this);

  /// Shorthand for `Theme.of(this)`.
  ThemeData get theme => Theme.of(this);

  /// Shorthand for `Theme.of(this).textTheme`.
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Shorthand for `Theme.of(this).colorScheme`.
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}

extension StringX on String {
  /// Capitalize the first letter.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Truncate to [maxLength] with ellipsis.
  String truncate(int maxLength) =>
      length <= maxLength ? this : '${substring(0, maxLength)}…';
}

extension DateTimeX on DateTime {
  /// Whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }
}
