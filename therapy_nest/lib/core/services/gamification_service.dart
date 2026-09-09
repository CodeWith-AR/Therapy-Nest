import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../../data/local_db/app_database.dart';
import '../../data/models/achievement_definitions.dart';
import '../../data/storage/local_store.dart';
import 'package:drift/drift.dart' show Value;

/// Evaluates achievement thresholds and tracks newly unlocked badges.
///
/// Called from [TherapySessionViewModel.endSession()] to check whether
/// the just-completed session unlocked any new achievements.
///
/// Follows the architecture rule: service class — no UI logic, no navigation.
class GamificationService {
  GamificationService(this._db, this._store);

  final AppDatabase _db;
  final LocalStore _store;

  SupabaseClient get _client => Supabase.instance.client;

  // ── SharedPreferences Key ───────────────────────────────────────────
  static const String _kUnlockedCodes = 'gamification_unlocked_codes';

  // ── Streak Computation ──────────────────────────────────────────────

  /// Counts consecutive days (from today backwards) that have at least
  /// one completed session.
  ///
  /// Implements the exact logic from the Module 14 prompt spec:
  /// walks backward from today, allowing today to be missing (not yet
  /// practiced), and breaks on the first gap.
  int computeCurrentStreak(List<DateTime> sessionDates) {
    if (sessionDates.isEmpty) return 0;

    // Normalise to date-only and collect unique days
    final Set<String> sessionDays = {};
    for (final date in sessionDates) {
      sessionDays.add(_dayKey(date));
    }

    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final day = now.subtract(Duration(days: i));
      final key = _dayKey(day);
      if (sessionDays.contains(key)) {
        streak++;
      } else {
        // Allow today to be missing (not yet practiced)
        if (i == 0) continue;
        break;
      }
    }

    return streak;
  }

  // ── Achievement Check ───────────────────────────────────────────────

  /// Evaluates all achievement thresholds and returns any **newly** unlocked
  /// achievements that were not previously unlocked.
  ///
  /// Parameters:
  /// - [currentStreak]: consecutive practice days
  /// - [totalSessions]: lifetime completed sessions
  /// - [sessionAccuracy]: accuracy of the just-completed session (0.0–100.0)
  /// - [overallAccuracy]: lifetime average accuracy (0.0–100.0)
  /// - [isPerfectSession]: whether the just-completed session was 100%
  Future<List<AchievementDef>> checkAchievements({
    required int currentStreak,
    required int totalSessions,
    required double sessionAccuracy,
    required double overallAccuracy,
    required bool isPerfectSession,
  }) async {
    // Load previously unlocked codes from local storage
    final previouslyUnlocked = await _getUnlockedCodes();

    // Evaluate each achievement
    final nowUnlocked = <String>{};

    for (final achievement in kAchievements) {
      bool unlocked = false;

      switch (achievement.type) {
        case AchievementType.streak:
          unlocked = currentStreak >= achievement.threshold;
          break;
        case AchievementType.sessionCount:
          unlocked = totalSessions >= achievement.threshold;
          break;
        case AchievementType.accuracy:
          if (achievement.code == 'perfect_session') {
            unlocked = isPerfectSession;
          } else if (achievement.code == 'accuracy_90') {
            unlocked = overallAccuracy >= 90;
          }
          break;
        case AchievementType.domainMilestone:
          // Domain milestones are checked via ProgressRepository
          break;
      }

      if (unlocked) {
        nowUnlocked.add(achievement.code);
      }
    }

    // Determine newly unlocked (not in previouslyUnlocked)
    final newlyUnlocked = nowUnlocked
        .where((code) => !previouslyUnlocked.contains(code))
        .toList();

    if (newlyUnlocked.isEmpty) return [];

    // Persist newly unlocked achievements
    final allUnlocked = {...previouslyUnlocked, ...nowUnlocked};
    await _saveUnlockedCodes(allUnlocked);

    // Save to local Drift DB
    for (final code in newlyUnlocked) {
      final def = kAchievements.firstWhere((a) => a.code == code);
      await _db.saveAchievement(LocalAchievementsCompanion(
        id: Value(def.code),
        name: Value(def.name),
        description: Value(def.description),
        iconCodePoint: Value(def.iconData.codePoint),
        category: Value(def.type.name),
        isUnlocked: const Value(true),
        unlockedAt: Value(DateTime.now()),
      ));
    }

    // Save to Supabase (best-effort, non-blocking)
    _saveToSupabase(newlyUnlocked);

    // Return the newly unlocked definitions
    return newlyUnlocked
        .map((code) => kAchievements.firstWhere((a) => a.code == code))
        .toList();
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  String _dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  String _userUnlockedKey() {
    final uid = _client.auth.currentUser?.id;
    return uid != null ? '${_kUnlockedCodes}_$uid' : _kUnlockedCodes;
  }

  Future<Set<String>> _getUnlockedCodes() async {
    final raw = await _store.getString(_userUnlockedKey());
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').toSet();
  }

  Future<void> _saveUnlockedCodes(Set<String> codes) async {
    await _store.setString(_userUnlockedKey(), codes.join(','));
  }

  /// Best-effort sync of new achievements to Supabase.
  void _saveToSupabase(List<String> codes) {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    for (final code in codes) {
      _client
          .from('patient_achievements')
          .upsert({
            'patient_id': userId,
            'achievement_code': code,
            'unlocked_at': DateTime.now().toIso8601String(),
          })
          .then((_) => AppLogger.info(
                'Achievement synced: $code',
                tag: 'GamificationService',
              ))
          .catchError((e) => AppLogger.error(
                'Achievement sync failed: $code',
                error: e,
                tag: 'GamificationService',
              ));
    }
  }
}
