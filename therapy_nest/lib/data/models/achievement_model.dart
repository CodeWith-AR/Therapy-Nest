import 'package:flutter/material.dart';

/// Category of achievement for grouping and display.
enum AchievementCategory {
  streak,
  sessionCount,
  accuracy,
  domainMilestone,
}

/// Represents an unlockable achievement / badge.
///
/// Achievements are evaluated locally based on session data
/// and ability estimates. Uses [IconData] instead of Lottie
/// since no custom animation assets exist yet.
class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconData,
    required this.category,
    this.unlockedAt,
    this.isUnlocked = false,
  });

  /// Unique achievement identifier.
  final String id;

  /// Display name (e.g. "7-Day Streak").
  final String name;

  /// Encouraging description (e.g. "Practiced 7 days in a row!").
  final String description;

  /// Material icon for the badge.
  final IconData iconData;

  /// Achievement category for grouping.
  final AchievementCategory category;

  /// When the achievement was unlocked (null if still locked).
  final DateTime? unlockedAt;

  /// Whether the achievement is currently unlocked.
  final bool isUnlocked;

  /// Returns a copy with [isUnlocked] set to true and [unlockedAt] set.
  AchievementModel unlock([DateTime? date]) {
    return AchievementModel(
      id: id,
      name: name,
      description: description,
      iconData: iconData,
      category: category,
      unlockedAt: date ?? DateTime.now(),
      isUnlocked: true,
    );
  }
}
