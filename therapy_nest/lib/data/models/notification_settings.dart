import 'package:flutter/material.dart';

/// Immutable notification settings data model.
/// Persisted via SharedPreferences through [AccessibilityViewModel].
class NotificationSettings {
  const NotificationSettings({
    this.dailyReminder = true,
    this.dailyReminderTime = const TimeOfDay(hour: 9, minute: 0),
    this.milestoneNotifications = true,
    this.weeklySummary = true,
    this.inactivityReminder = true,
  });

  /// Whether a daily practice reminder is enabled.
  final bool dailyReminder;

  /// What time the daily reminder fires.
  final TimeOfDay dailyReminderTime;

  /// Whether to notify on milestone achievements.
  final bool milestoneNotifications;

  /// Whether to send a weekly summary every Sunday evening.
  final bool weeklySummary;

  /// Whether to remind the user after 3 days of no sessions.
  final bool inactivityReminder;

  NotificationSettings copyWith({
    bool? dailyReminder,
    TimeOfDay? dailyReminderTime,
    bool? milestoneNotifications,
    bool? weeklySummary,
    bool? inactivityReminder,
  }) {
    return NotificationSettings(
      dailyReminder: dailyReminder ?? this.dailyReminder,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      milestoneNotifications:
          milestoneNotifications ?? this.milestoneNotifications,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      inactivityReminder: inactivityReminder ?? this.inactivityReminder,
    );
  }
}
