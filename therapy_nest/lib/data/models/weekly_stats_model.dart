/// Per-day activity snapshot used by [WeeklyStatsModel].
class DailyActivityModel {
  const DailyActivityModel({
    required this.date,
    required this.minutesPracticed,
    required this.sessionCount,
    required this.averageAccuracy,
  });

  /// The calendar date for this entry.
  final DateTime date;

  /// Total minutes practiced on this day.
  final int minutesPracticed;

  /// Number of sessions completed on this day.
  final int sessionCount;

  /// Average accuracy across all sessions on this day (0–100).
  final double averageAccuracy;

  /// Creates a [DailyActivityModel] from a JSON map.
  factory DailyActivityModel.fromJson(Map<String, dynamic> json) {
    return DailyActivityModel(
      date: DateTime.parse(json['date'] as String),
      minutesPracticed: json['minutes_practiced'] as int? ?? 0,
      sessionCount: json['session_count'] as int? ?? 0,
      averageAccuracy: (json['average_accuracy'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Converts to a JSON map for persistence.
  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'minutes_practiced': minutesPracticed,
        'session_count': sessionCount,
        'average_accuracy': averageAccuracy,
      };
}

/// Aggregated statistics for the current week.
///
/// Used by the home dashboard and progress overview to show
/// weekly activity, streak count, and daily breakdowns.
class WeeklyStatsModel {
  const WeeklyStatsModel({
    required this.weekStart,
    required this.totalSessions,
    required this.totalMinutes,
    required this.averageAccuracy,
    required this.currentStreak,
    required this.dailyActivity,
  });

  /// The Monday of this stats week.
  final DateTime weekStart;

  /// Total sessions completed this week.
  final int totalSessions;

  /// Total minutes practiced this week.
  final int totalMinutes;

  /// Average accuracy across all sessions this week (0–100).
  final double averageAccuracy;

  /// Current consecutive-day streak.
  final int currentStreak;

  /// Per-day activity breakdown (7 entries, Monday→Sunday).
  final List<DailyActivityModel> dailyActivity;

  /// Creates a [WeeklyStatsModel] from a JSON map.
  factory WeeklyStatsModel.fromJson(Map<String, dynamic> json) {
    final dailyList = (json['daily_activity'] as List?)
            ?.map((e) =>
                DailyActivityModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return WeeklyStatsModel(
      weekStart: DateTime.parse(json['week_start'] as String),
      totalSessions: json['total_sessions'] as int? ?? 0,
      totalMinutes: json['total_minutes'] as int? ?? 0,
      averageAccuracy:
          (json['average_accuracy'] as num?)?.toDouble() ?? 0.0,
      currentStreak: json['current_streak'] as int? ?? 0,
      dailyActivity: dailyList,
    );
  }

  /// Converts to a JSON map for persistence.
  Map<String, dynamic> toJson() => {
        'week_start': weekStart.toIso8601String(),
        'total_sessions': totalSessions,
        'total_minutes': totalMinutes,
        'average_accuracy': averageAccuracy,
        'current_streak': currentStreak,
        'daily_activity': dailyActivity.map((d) => d.toJson()).toList(),
      };
}
