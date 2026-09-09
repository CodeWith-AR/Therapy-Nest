import 'package:flutter/material.dart';

/// Category of achievement for grouping and display.
enum AchievementType {
  streak,
  sessionCount,
  accuracy,
  domainMilestone,
}

/// Immutable definition of an achievable badge / milestone.
///
/// All definitions are declared as constants in [kAchievements] below.
/// The [threshold] field is the numeric value that triggers the achievement
/// (e.g. streak days, session count). For boolean checks (perfect session),
/// [threshold] is 0 and the check is code-driven.
class AchievementDef {
  const AchievementDef({
    required this.code,
    required this.name,
    required this.description,
    required this.iconData,
    required this.type,
    this.threshold = 0,
  });

  /// Unique code identifier (e.g. 'streak_7').
  final String code;

  /// Display name (e.g. 'One Week Strong').
  final String name;

  /// Encouraging description for the unlock dialog.
  final String description;

  /// Material icon for the badge.
  final IconData iconData;

  /// Achievement category for grouping.
  final AchievementType type;

  /// Numeric threshold that triggers unlock (0 for boolean checks).
  final int threshold;
}

/// Master list of all unlockable achievements.
///
/// Domain milestones are auto-generated from
/// [ProgressRepository._milestoneDefs] and merged at runtime by
/// [GamificationService].
const List<AchievementDef> kAchievements = [
  // ── Streaks ──────────────────────────────────────────────────────
  AchievementDef(
    code: 'streak_3',
    name: 'Getting Started',
    description: 'Practiced 3 days in a row!',
    iconData: Icons.local_fire_department_rounded,
    type: AchievementType.streak,
    threshold: 3,
  ),
  AchievementDef(
    code: 'streak_7',
    name: 'One Week Strong',
    description: 'A whole week of daily practice!',
    iconData: Icons.local_fire_department_rounded,
    type: AchievementType.streak,
    threshold: 7,
  ),
  AchievementDef(
    code: 'streak_30',
    name: 'Monthly Warrior',
    description: 'Thirty days of dedication — incredible!',
    iconData: Icons.local_fire_department_rounded,
    type: AchievementType.streak,
    threshold: 30,
  ),
  AchievementDef(
    code: 'streak_100',
    name: 'Century Champion',
    description: '100 days of practice — you are unstoppable!',
    iconData: Icons.local_fire_department_rounded,
    type: AchievementType.streak,
    threshold: 100,
  ),

  // ── Session Count ────────────────────────────────────────────────
  AchievementDef(
    code: 'sessions_1',
    name: 'First Step',
    description: 'Completed your very first session!',
    iconData: Icons.star_rounded,
    type: AchievementType.sessionCount,
    threshold: 1,
  ),
  AchievementDef(
    code: 'sessions_10',
    name: 'Building Habits',
    description: 'Ten sessions completed — great momentum!',
    iconData: Icons.star_rounded,
    type: AchievementType.sessionCount,
    threshold: 10,
  ),
  AchievementDef(
    code: 'sessions_50',
    name: 'Dedicated Practitioner',
    description: 'Fifty sessions — amazing commitment!',
    iconData: Icons.emoji_events_rounded,
    type: AchievementType.sessionCount,
    threshold: 50,
  ),

  // ── Accuracy ─────────────────────────────────────────────────────
  AchievementDef(
    code: 'perfect_session',
    name: 'Perfect Session',
    description: '100% accuracy in a session — flawless!',
    iconData: Icons.diamond_rounded,
    type: AchievementType.accuracy,
  ),
  AchievementDef(
    code: 'accuracy_90',
    name: 'Sharp Mind',
    description: '90%+ overall accuracy — brilliant!',
    iconData: Icons.psychology_rounded,
    type: AchievementType.accuracy,
  ),
];
