import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../local_db/app_database.dart';
import '../models/achievement_model.dart';
import '../models/domain_ability_model.dart';
import '../models/functional_milestone_model.dart';
import '../models/review_item_model.dart';
import '../models/weekly_stats_model.dart';
import 'attention_exercise_seed_data.dart';
import 'language_exercise_seed_data.dart';
import 'memory_exercise_seed_data.dart';
import 'reading_writing_exercise_seed_data.dart';
import 'speech_exercise_seed_data.dart';
import 'math_exercise_seed_data.dart';

/// Data access layer for all progress / dashboard queries.
///
/// Offline-first: queries Drift local database as authoritative source,
/// falling back to or merging with [Supabase.instance.client].
class ProgressRepository {
  ProgressRepository(this._db);

  final AppDatabase _db;
  SupabaseClient get _client => Supabase.instance.client;

  static final Map<String, String> _itemTypeMap = _buildItemTypeMap();

  static Map<String, String> _buildItemTypeMap() {
    final map = <String, String>{};
    for (final item in languageExerciseSeedData) {
      map[item.id] = item.exerciseTypeCode;
    }
    for (final item in readingWritingExerciseSeedData) {
      map[item.id] = item.exerciseTypeCode;
    }
    for (int i = 1; i <= 8; i++) {
      map['comp_ex_0$i'] = 'sentence_completion';
    }
    for (final item in memoryExerciseSeedData) {
      map[item.id] = item.exerciseTypeCode;
    }
    for (final item in attentionExerciseSeedData) {
      map[item.id] = item.exerciseTypeCode;
    }
    for (final item in speechExerciseSeedData) {
      map[item.id] = item.exerciseTypeCode;
    }
    for (final item in mathExerciseSeedData) {
      map[item.id] = item.exerciseTypeCode;
    }
    return map;
  }

  // ── Weekly Stats ──────────────────────────────────────────────────

  /// Aggregates `therapy_sessions` and `exercise_attempts` for the last 7 days.
  Future<WeeklyStatsModel> getWeeklyStats() async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDate =
          DateTime(weekStart.year, weekStart.month, weekStart.day);
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final Map<String, _DayBucket> dayBuckets = {};
      final Set<String> processedSessionIds = {};
      final userId = _client.auth.currentUser?.id;

      // 1. Process local completed sessions from Drift SQLite
      final localSessions = await _db.getCompletedSessions(limit: 100, patientId: userId);
      for (final s in localSessions) {
        if (s.startedAt.isBefore(sevenDaysAgo)) continue;
        processedSessionIds.add(s.id);
        final endedAt = s.endedAt ?? s.startedAt.add(const Duration(minutes: 5));
        final dayKey =
            '${s.startedAt.year}-${s.startedAt.month.toString().padLeft(2, '0')}-${s.startedAt.day.toString().padLeft(2, '0')}';
        final bucket =
            dayBuckets.putIfAbsent(dayKey, () => _DayBucket(s.startedAt));
        bucket.sessionCount++;
        bucket.totalMinutes += endedAt.difference(s.startedAt).inMinutes;

        final attempts = await _db.getAttemptsForSession(s.id);
        bucket.totalItems += attempts.length;
        bucket.correctItems += attempts.where((a) => a.isCorrect).length;
      }

      // 2. Merge remote sessions if available
      try {
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          final sessions = await _client
              .from('therapy_sessions')
              .select()
              .eq('patient_id', userId)
              .gte('started_at', sevenDaysAgo.toIso8601String())
              .order('started_at');

          final sessionIds = (sessions as List)
              .map((s) => s['id'] as String)
              .where((id) => !processedSessionIds.contains(id))
              .toList();

          if (sessionIds.isNotEmpty) {
            final attempts = await _client
                .from('exercise_attempts')
                .select()
                .inFilter('session_id', sessionIds);

            for (final s in sessions) {
              final sid = s['id'] as String;
              if (processedSessionIds.contains(sid)) continue;
              final startedAt = DateTime.parse(s['started_at'] as String);
              final endedAt = s['ended_at'] != null
                  ? DateTime.parse(s['ended_at'] as String)
                  : startedAt.add(const Duration(minutes: 5));
              final dayKey =
                  '${startedAt.year}-${startedAt.month.toString().padLeft(2, '0')}-${startedAt.day.toString().padLeft(2, '0')}';
              final bucket =
                  dayBuckets.putIfAbsent(dayKey, () => _DayBucket(startedAt));
              bucket.sessionCount++;
              bucket.totalMinutes += endedAt.difference(startedAt).inMinutes;

              final sAttempts = (attempts as List)
                  .where((a) => a['session_id'] == sid)
                  .toList();
              bucket.totalItems += sAttempts.length;
              bucket.correctItems +=
                  sAttempts.where((a) => a['is_correct'] == true).length;
            }
          }
        }
      } catch (_) {}

      // Build daily activity list
      final dailyActivity = <DailyActivityModel>[];
      for (int i = 6; i >= 0; i--) {
        final day = now.subtract(Duration(days: i));
        final dayKey =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final bucket = dayBuckets[dayKey];
        dailyActivity.add(DailyActivityModel(
          date: DateTime(day.year, day.month, day.day),
          minutesPracticed: bucket?.totalMinutes ?? 0,
          sessionCount: bucket?.sessionCount ?? 0,
          averageAccuracy: bucket != null && bucket.totalItems > 0
              ? (bucket.correctItems / bucket.totalItems * 100)
              : 0.0,
        ));
      }

      final totalSessions =
          dayBuckets.values.fold<int>(0, (sum, b) => sum + b.sessionCount);
      final totalMinutes =
          dayBuckets.values.fold<int>(0, (sum, b) => sum + b.totalMinutes);
      final totalItems =
          dayBuckets.values.fold<int>(0, (sum, b) => sum + b.totalItems);
      final totalCorrect =
          dayBuckets.values.fold<int>(0, (sum, b) => sum + b.correctItems);
      final avgAccuracy =
          totalItems > 0 ? (totalCorrect / totalItems * 100) : 0.0;

      final streak = await computeStreak();

      return WeeklyStatsModel(
        weekStart: weekStartDate,
        totalSessions: totalSessions,
        totalMinutes: totalMinutes,
        averageAccuracy: avgAccuracy,
        currentStreak: streak,
        dailyActivity: dailyActivity,
      );
    } catch (e) {
      AppLogger.error(
        'Failed to load weekly stats',
        error: e,
        tag: 'ProgressRepository',
      );
      return _emptyWeeklyStats();
    }
  }

  // ── Session History ───────────────────────────────────────────────

  /// Paginated session list with computed accuracy — offline-first.
  Future<List<SessionHistoryModel>> getSessionHistory({
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final Map<String, SessionHistoryModel> sessionMap = {};
      final userId = _client.auth.currentUser?.id;

      // 1. First read all local completed sessions from Drift SQLite
      final localSessions = await _db.getCompletedSessions(limit: limit + offset + 20, patientId: userId);
      for (final s in localSessions) {
        final attempts = await _db.getAttemptsForSession(s.id);
        final total = attempts.length;
        final correct = attempts.where((a) => a.isCorrect).length;
        final accuracy = total > 0 ? (correct / total * 100) : 0.0;
        final durationMs = s.endedAt != null
            ? s.endedAt!.difference(s.startedAt).inMilliseconds
            : (s.targetItemCount * 15000);

        List<String> domains = [];
        try {
          domains = List<String>.from(jsonDecode(s.targetDomainsJson) as List);
        } catch (_) {
          domains = [];
        }

        sessionMap[s.id] = SessionHistoryModel(
          sessionId: s.id,
          date: s.startedAt,
          domains: domains,
          totalItems: total,
          correctItems: correct,
          accuracy: accuracy,
          durationMs: durationMs,
        );
      }

      // 2. Try fetching from Supabase to merge any remote sessions
      try {
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          final remoteSessions = await _client
              .from('therapy_sessions')
              .select()
              .eq('patient_id', userId)
              .not('ended_at', 'is', null)
              .order('started_at', ascending: false)
              .range(offset, offset + limit + 10);

          for (final s in remoteSessions as List) {
            final sid = s['id'] as String;
            // If we already have local attempts for this session and total > 0, preserve local authoritative data
            if (sessionMap.containsKey(sid) && sessionMap[sid]!.totalItems > 0) {
              continue;
            }

            final startedAt = DateTime.parse(s['started_at'] as String);
            final endedAt = s['ended_at'] != null
                ? DateTime.parse(s['ended_at'] as String)
                : startedAt;
            final domains =
                List<String>.from(s['target_domains'] as List? ?? []);

            final attempts = await _client
                .from('exercise_attempts')
                .select('is_correct')
                .eq('session_id', sid);

            final total = (attempts as List).length;
            final correct =
                attempts.where((a) => a['is_correct'] == true).length;
            final accuracy = total > 0 ? (correct / total * 100) : 0.0;

            sessionMap[sid] = SessionHistoryModel(
              sessionId: sid,
              date: startedAt,
              domains: domains,
              totalItems: total,
              correctItems: correct,
              accuracy: accuracy,
              durationMs: endedAt.difference(startedAt).inMilliseconds,
            );
          }
        }
      } catch (e) {
        AppLogger.warn(
          'Remote session history fetch skipped/failed: $e',
          tag: 'ProgressRepository',
        );
      }

      final sorted = sessionMap.values.toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (offset >= sorted.length) return [];
      return sorted.skip(offset).take(limit).toList();
    } catch (e) {
      AppLogger.error(
        'Failed to load session history',
        error: e,
        tag: 'ProgressRepository',
      );
      return [];
    }
  }

  // ── Domain Abilities ──────────────────────────────────────────────

  /// Reads current θ from local SQLite and Supabase patient_profiles,
  /// counts sessions accurately per domain.
  Future<List<DomainAbilityModel>> getDomainAbilities() async {
    try {
      final userId = _client.auth.currentUser?.id;

      // 1. Initial θ baseline & current θ from patient_profiles.theta_scores
      final Map<String, double> initialThetas = {};
      final Map<String, double> currentThetas = {};

      if (userId != null) {
        try {
          final profileData = await _client
              .from('patient_profiles')
              .select('theta_scores')
              .eq('user_id', userId)
              .maybeSingle();

          if (profileData != null && profileData['theta_scores'] != null) {
            final thetaScores =
                profileData['theta_scores'] as Map<String, dynamic>;
            for (final entry in thetaScores.entries) {
              final domainData = entry.value;
              if (domainData is Map<String, dynamic>) {
                final th = (domainData['theta'] as num?)?.toDouble() ?? 0.0;
                initialThetas[entry.key] = th;
                currentThetas[entry.key] = th;
              }
            }
          }
        } catch (_) {}
      }

      // 2. Overlay authoritative local ability estimates from SQLite
      final localEstimates = await _db.getAllAbilityEstimates();
      for (final est in localEstimates) {
        currentThetas[est.domain] = est.theta;
      }

      // 3. Count sessions per domain (both local & remote)
      final Map<String, int> sessionCounts = {};
      final Map<String, DateTime> lastPracticed = {};

      // Local completed sessions
      final localSessions = await _db.getCompletedSessions(limit: 200, patientId: userId);
      final Set<String> processedSessionIds = {};
      for (final s in localSessions) {
        processedSessionIds.add(s.id);
        try {
          final domains =
              List<String>.from(jsonDecode(s.targetDomainsJson) as List);
          for (final d in domains) {
            sessionCounts[d] = (sessionCounts[d] ?? 0) + 1;
            if (lastPracticed[d] == null || s.startedAt.isAfter(lastPracticed[d]!)) {
              lastPracticed[d] = s.startedAt;
            }
          }
        } catch (_) {}
      }

      // Remote sessions
      if (userId != null) {
        try {
          final remoteSessions = await _client
              .from('therapy_sessions')
              .select('id, target_domains, started_at')
              .eq('patient_id', userId)
              .not('ended_at', 'is', null);

          for (final s in remoteSessions as List) {
            final sid = s['id'] as String;
            if (processedSessionIds.contains(sid)) continue;
            final domains =
                List<String>.from(s['target_domains'] as List? ?? []);
            final date = DateTime.parse(s['started_at'] as String);
            for (final d in domains) {
              sessionCounts[d] = (sessionCounts[d] ?? 0) + 1;
              if (lastPracticed[d] == null || date.isAfter(lastPracticed[d]!)) {
                lastPracticed[d] = date;
              }
            }
          }
        } catch (_) {}
      }

      const domainLabels = {
        'language': 'Language',
        'memory': 'Memory',
        'attention': 'Attention',
        'speech': 'Speech',
        'reading_writing': 'Reading & Writing',
        'math': 'Math',
      };

      final abilities = <DomainAbilityModel>[];
      for (final entry in domainLabels.entries) {
        final code = entry.key;
        double curTheta = currentThetas[code] ?? initialThetas[code] ?? 0.0;

        // Baseline starting θ: from earliest attempt, profile initial, or intake baseline
        double initTheta = initialThetas[code] ?? 0.0;
        final domainAttempts = await _db.getAttemptsForDomain(code);
        if (domainAttempts.isNotEmpty) {
          initTheta = domainAttempts.first.thetaBefore;
          if (initTheta >= 2.9) {
            initTheta = 0.0;
          }
        } else if (!initialThetas.containsKey(code)) {
          initTheta = 0.0; // Default baseline intake anchor
        }

        // Self-heal corrupted ceiling theta (old 32.0 Elo kFactor bug)
        if (domainAttempts.isEmpty) {
          curTheta = initTheta;
          if ((currentThetas[code] ?? 0.0) >= 2.9) {
            await _db.updateAbilityEstimate(code, curTheta, 0.5);
          }
        } else if (curTheta >= 2.9 && domainAttempts.length <= 20) {
          double replayedTheta = initTheta;
          for (final att in domainAttempts) {
            final diff = (0.0 - replayedTheta).clamp(-7.0, 7.0);
            final expected = 1.0 / (1.0 + exp(diff));
            final score = att.partialScore;
            replayedTheta =
                (replayedTheta + 0.20 * (score - expected)).clamp(-3.0, 3.0);
          }
          curTheta = replayedTheta;
          await _db.updateAbilityEstimate(code, curTheta, 0.5);
        }

        abilities.add(DomainAbilityModel(
          domainCode: code,
          domainLabel: entry.value,
          theta: curTheta,
          initialTheta: initTheta,
          sessionCount: sessionCounts[code] ?? 0,
          lastPracticed: lastPracticed[code],
        ));
      }

      abilities.sort((a, b) => a.domainLabel.compareTo(b.domainLabel));
      return abilities;
    } catch (e) {
      AppLogger.error(
        'Failed to load domain abilities',
        error: e,
        tag: 'ProgressRepository',
      );
      return [];
    }
  }

  // ── Accuracy Trend ────────────────────────────────────────────────

  /// Per-domain accuracy over the last N sessions (oldest first).
  Future<List<double>> getAccuracyTrend(String domainCode,
      {int sessions = 30}) async {
    try {
      // 1. Get all local attempts for this domain from SQLite
      final localAttempts = await _db.getAttemptsForDomain(domainCode);
      final Map<String, List<LocalAttempt>> sessionGroups = {};
      for (final a in localAttempts) {
        sessionGroups.putIfAbsent(a.sessionId, () => []).add(a);
      }

      final accuracies = <double>[];
      for (final sid in sessionGroups.keys) {
        final atts = sessionGroups[sid]!;
        final total = atts.length;
        final correct = atts.where((a) => a.isCorrect).length;
        if (total > 0) {
          accuracies.add(correct / total * 100);
        }
      }

      if (accuracies.isNotEmpty) {
        if (accuracies.length > sessions) {
          return accuracies.sublist(accuracies.length - sessions);
        }
        return accuracies;
      }

      // 2. Remote fallback if local is empty
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final filteredSessions = await _client
          .from('therapy_sessions')
          .select('id')
          .eq('patient_id', userId)
          .not('ended_at', 'is', null)
          .contains('target_domains', [domainCode])
          .order('started_at', ascending: false)
          .limit(sessions);

      final ids =
          (filteredSessions as List).map((s) => s['id'] as String).toList();
      if (ids.isEmpty) return [];

      final remoteAccuracies = <double>[];
      for (final id in ids) {
        final attempts = await _client
            .from('exercise_attempts')
            .select('is_correct')
            .eq('session_id', id)
            .eq('domain', domainCode);

        final total = (attempts as List).length;
        final correct =
            attempts.where((a) => a['is_correct'] == true).length;
        if (total > 0) {
          remoteAccuracies.add(correct / total * 100);
        }
      }

      return remoteAccuracies.reversed.toList();
    } catch (e) {
      AppLogger.error(
        'Failed to load accuracy trend',
        error: e,
        tag: 'ProgressRepository',
      );
      return [];
    }
  }

  // ── Streak ────────────────────────────────────────────────────────

  /// Counts consecutive days with at least 1 completed session.
  Future<int> computeStreak() async {
    try {
      final Set<String> sessionDays = {};
      final userId = _client.auth.currentUser?.id;

      // Local session days
      final localSessions = await _db.getCompletedSessions(limit: 200, patientId: userId);
      for (final s in localSessions) {
        sessionDays.add(
            '${s.startedAt.year}-${s.startedAt.month.toString().padLeft(2, '0')}-${s.startedAt.day.toString().padLeft(2, '0')}');
      }

      // Remote session days
      try {
        final userId = _client.auth.currentUser?.id;
        if (userId != null) {
          final sessions = await _client
              .from('therapy_sessions')
              .select('started_at')
              .eq('patient_id', userId)
              .not('ended_at', 'is', null)
              .order('started_at', ascending: false);

          for (final s in sessions as List) {
            final date = DateTime.parse(s['started_at'] as String);
            sessionDays.add(
                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
          }
        }
      } catch (_) {}

      if (sessionDays.isEmpty) return 0;

      // Count consecutive days from today backwards
      int streak = 0;
      final now = DateTime.now();
      for (int i = 0; i < 365; i++) {
        final day = now.subtract(Duration(days: i));
        final dayKey =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        if (sessionDays.contains(dayKey)) {
          streak++;
        } else {
          // Allow today to be missing (not yet practiced)
          if (i == 0) continue;
          break;
        }
      }

      return streak;
    } catch (e) {
      AppLogger.error(
        'Failed to compute streak',
        error: e,
        tag: 'ProgressRepository',
      );
      return 0;
    }
  }

  // ── Functional Milestones ─────────────────────────────────────────

  /// Checks current θ against hardcoded milestone thresholds.
  Future<List<FunctionalMilestoneModel>> getFunctionalMilestones() async {
    try {
      final abilities = await getDomainAbilities();
      final Map<String, double> thetaMap = {
        for (final a in abilities) a.domainCode: a.theta,
      };

      return _milestoneDefs.map((def) {
        final currentTheta = thetaMap[def.domainCode] ?? -3.0;
        if (currentTheta >= def.thetaThreshold) {
          return def.markAchieved();
        }
        return def;
      }).toList();
    } catch (e) {
      AppLogger.error(
        'Failed to load milestones',
        error: e,
        tag: 'ProgressRepository',
      );
      return [];
    }
  }

  // ── Achievements ──────────────────────────────────────────────────

  /// Evaluates streak, session count, and accuracy achievements.
  ///
  /// Uses a single batch [inFilter] query instead of N sequential queries,
  /// and persists unlock dates via [SharedPreferences] so achievements
  /// retain their original unlock date across sessions.
  Future<List<AchievementModel>> getAchievements() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return _achievementDefs;

      final streak = await computeStreak();

      // 1. Total session count
      final sessionCount = await _client
          .from('therapy_sessions')
          .select('id')
          .eq('patient_id', userId)
          .not('ended_at', 'is', null);

      final totalSessions = (sessionCount as List).length;

      // 2. Batch fetch attempts for last 50 sessions (1 query instead of 50)
      bool hasPerfectSession = false;
      double overallAvgAccuracy = 0.0;

      if (totalSessions > 0) {
        final recentSessions = await _client
            .from('therapy_sessions')
            .select('id')
            .eq('patient_id', userId)
            .not('ended_at', 'is', null)
            .order('started_at', ascending: false)
            .limit(50);

        final sessionIds =
            (recentSessions as List).map((s) => s['id'] as String).toList();

        if (sessionIds.isNotEmpty) {
          final attempts = await _client
              .from('exercise_attempts')
              .select('session_id, is_correct')
              .inFilter('session_id', sessionIds);

          final Map<String, List<bool>> sessionAttempts = {};
          int totalCorrect = 0;

          for (final a in attempts as List) {
            final sid = a['session_id'] as String;
            final isCorrect = a['is_correct'] == true;
            sessionAttempts.putIfAbsent(sid, () => []).add(isCorrect);
            if (isCorrect) totalCorrect++;
          }

          for (final list in sessionAttempts.values) {
            if (list.isNotEmpty && list.every((c) => c)) {
              hasPerfectSession = true;
              break;
            }
          }

          if (attempts.isNotEmpty) {
            overallAvgAccuracy = totalCorrect / attempts.length * 100;
          }
        }
      }

      // 3. Load persisted unlock dates from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final unlockMapKey = 'user_achievements_$userId';
      final rawMap = prefs.getString(unlockMapKey);
      final Map<String, dynamic> unlockedDates =
          rawMap != null ? jsonDecode(rawMap) as Map<String, dynamic> : {};
      bool mapUpdated = false;

      // 4. Evaluate achievements
      final result = _achievementDefs.map((def) {
        bool shouldUnlock = switch (def.id) {
          'streak_3' => streak >= 3,
          'streak_7' => streak >= 7,
          'streak_30' => streak >= 30,
          'streak_100' => streak >= 100,
          'sessions_1' => totalSessions >= 1,
          'sessions_10' => totalSessions >= 10,
          'sessions_50' => totalSessions >= 50,
          'sessions_100' => totalSessions >= 100,
          'accuracy_perfect' => hasPerfectSession,
          'accuracy_sharp' => overallAvgAccuracy >= 90,
          _ => false,
        };

        if (shouldUnlock) {
          DateTime unlockDate;
          if (unlockedDates.containsKey(def.id)) {
            unlockDate = DateTime.tryParse(unlockedDates[def.id] as String) ??
                DateTime.now();
          } else {
            unlockDate = DateTime.now();
            unlockedDates[def.id] = unlockDate.toIso8601String();
            mapUpdated = true;
          }
          return def.unlock(unlockDate);
        }
        return def;
      }).toList();

      if (mapUpdated) {
        await prefs.setString(unlockMapKey, jsonEncode(unlockedDates));
      }

      return result;
    } catch (e) {
      AppLogger.error(
        'Failed to load achievements',
        error: e,
        tag: 'ProgressRepository',
      );
      return _achievementDefs;
    }
  }

  // ── Domain Detail ─────────────────────────────────────────────────

  /// Fetches per-domain accuracy breakdown by exercise type.
  Future<Map<String, double>> getExerciseTypeAccuracy(
      String domainCode) async {
    try {
      final Map<String, int> totals = {};
      final Map<String, int> corrects = {};

      // 1. Check local attempts from SQLite
      final localAttempts = await _db.getAttemptsForDomain(domainCode);
      for (final a in localAttempts) {
        final type = _itemTypeMap[a.exerciseItemId] ?? 'general';
        totals[type] = (totals[type] ?? 0) + 1;
        if (a.isCorrect) {
          corrects[type] = (corrects[type] ?? 0) + 1;
        }
      }

      // 2. If local attempts had data, return calculated accuracy
      if (totals.isNotEmpty) {
        return {
          for (final entry in totals.entries)
            entry.key: entry.value > 0
                ? (corrects[entry.key] ?? 0) / entry.value * 100
                : 0.0,
        };
      }

      // 3. Fallback to Supabase
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return {};

      final sessions = await _client
          .from('therapy_sessions')
          .select('id')
          .eq('patient_id', userId);
      final sessionIds = (sessions as List).map((s) => s['id'] as String).toList();
      if (sessionIds.isEmpty) return {};

      final attempts = await _client
          .from('exercise_attempts')
          .select('exercise_item_id, response, is_correct')
          .inFilter('session_id', sessionIds)
          .eq('domain', domainCode);

      for (final a in attempts as List) {
        final resp = a['response'] as Map<String, dynamic>? ?? {};
        final itemId = (a['exercise_item_id'] as String?) ??
            (resp['exercise_item_id'] as String?) ??
            '';
        final type = _itemTypeMap[itemId] ?? 'general';
        totals[type] = (totals[type] ?? 0) + 1;
        if (a['is_correct'] == true) {
          corrects[type] = (corrects[type] ?? 0) + 1;
        }
      }

      return {
        for (final entry in totals.entries)
          entry.key: entry.value > 0
              ? (corrects[entry.key] ?? 0) / entry.value * 100
              : 0.0,
      };
    } catch (e) {
      AppLogger.error(
        'Failed to load exercise type accuracy',
        error: e,
        tag: 'ProgressRepository',
      );
      return {};
    }
  }

  /// Fetches items where the patient required 2+ hints for the given domain.
  Future<List<ReviewItemModel>> getReviewItems(
    String domainCode, {
    int minHints = 2,
    int limit = 20,
  }) async {
    try {
      final reviewAttempts = await _db.getReviewItemsForDomain(
        domainCode,
        minHints: minHints,
        limit: limit,
      );

      final result = <ReviewItemModel>[];
      final Set<String> seenItemIds = {};

      for (final a in reviewAttempts) {
        if (seenItemIds.contains(a.exerciseItemId)) continue;
        seenItemIds.add(a.exerciseItemId);

        String prompt = '';
        String targetWord = '';
        try {
          final resp = jsonDecode(a.responseJson) as Map<String, dynamic>;
          prompt =
              (resp['prompt'] ?? resp['selected'] ?? resp['word'] ?? '') as String;
          targetWord =
              (resp['targetWord'] ?? resp['answer'] ?? '') as String;
        } catch (_) {}

        final subtype = _itemTypeMap[a.exerciseItemId] ?? 'general';
        if (prompt.isEmpty) {
          prompt = 'Exercise item: ${a.exerciseItemId}';
        }

        result.add(ReviewItemModel(
          id: a.id,
          exerciseItemId: a.exerciseItemId,
          domain: a.domain,
          exerciseTypeCode: subtype,
          prompt: prompt,
          hintCount: a.hintCount,
          isCorrect: a.isCorrect,
          createdAt: a.createdAt,
          targetWord: targetWord,
        ));
      }

      return result;
    } catch (e) {
      AppLogger.error(
        'Failed to load review items',
        error: e,
        tag: 'ProgressRepository',
      );
      return [];
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────

  WeeklyStatsModel _emptyWeeklyStats() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return WeeklyStatsModel(
      weekStart: DateTime(weekStart.year, weekStart.month, weekStart.day),
      totalSessions: 0,
      totalMinutes: 0,
      averageAccuracy: 0.0,
      currentStreak: 0,
      dailyActivity: List.generate(
        7,
        (i) => DailyActivityModel(
          date: now.subtract(Duration(days: 6 - i)),
          minutesPracticed: 0,
          sessionCount: 0,
          averageAccuracy: 0.0,
        ),
      ),
    );
  }

  // ── Hardcoded Milestone Definitions ───────────────────────────────

  static final List<FunctionalMilestoneModel> _milestoneDefs = [
    // ── Language ─────────────────────────────────────────
    const FunctionalMilestoneModel(
      id: 'lang_recognize_objects',
      domainCode: 'language',
      name: 'Recognize Common Objects',
      description: 'You can accurately identify everyday objects and tools!',
      thetaThreshold: -2.0,
    ),
    const FunctionalMilestoneModel(
      id: 'lang_name_objects',
      domainCode: 'language',
      name: 'Name Common Objects',
      description: 'You can reliably retrieve and speak names of items!',
      thetaThreshold: -1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'lang_sentences',
      domainCode: 'language',
      name: 'Build Simple Sentences',
      description: 'You can form clear subject-verb sentences with confidence!',
      thetaThreshold: 0.0,
    ),
    const FunctionalMilestoneModel(
      id: 'lang_instructions',
      domainCode: 'language',
      name: 'Follow Multi-Step Instructions',
      description: 'You can comprehend and carry out multi-step requests!',
      thetaThreshold: 1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'lang_conversation',
      domainCode: 'language',
      name: 'Hold a Fluid Conversation',
      description: 'You can engage in natural, spontaneous everyday dialogue!',
      thetaThreshold: 1.8,
    ),
    const FunctionalMilestoneModel(
      id: 'lang_nuanced_expression',
      domainCode: 'language',
      name: 'Express Nuanced Ideas',
      description: 'You can convey complex stories and abstract concepts effortlessly!',
      thetaThreshold: 2.4,
    ),

    // ── Memory ───────────────────────────────────────────
    const FunctionalMilestoneModel(
      id: 'mem_simple_cues',
      domainCode: 'memory',
      name: 'Recall Immediate Cues',
      description: 'You can retain and recall visual and verbal prompts!',
      thetaThreshold: -2.0,
    ),
    const FunctionalMilestoneModel(
      id: 'mem_short_seq',
      domainCode: 'memory',
      name: 'Remember Short Sequences',
      description: 'You can recall sequences of 3-4 items in order!',
      thetaThreshold: -1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'mem_daily_tasks',
      domainCode: 'memory',
      name: 'Remember Daily Tasks',
      description: 'You can remember appointments and daily routines reliably!',
      thetaThreshold: 0.0,
    ),
    const FunctionalMilestoneModel(
      id: 'mem_working_span',
      domainCode: 'memory',
      name: 'Working Memory Mastery',
      description: 'You can mentally hold and manipulate multiple pieces of information!',
      thetaThreshold: 1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'mem_delayed_recall',
      domainCode: 'memory',
      name: 'Delayed Memory Recall',
      description: 'You can recall details and events after long delays without cues!',
      thetaThreshold: 1.8,
    ),
    const FunctionalMilestoneModel(
      id: 'mem_complex_episodic',
      domainCode: 'memory',
      name: 'Complex Episodic Recall',
      description: 'You can remember intricate narratives and multi-faceted experiences!',
      thetaThreshold: 2.4,
    ),

    // ── Attention ────────────────────────────────────────
    const FunctionalMilestoneModel(
      id: 'att_visual_tracking',
      domainCode: 'attention',
      name: 'Visual Scanning & Tracking',
      description: 'You can scan environments and lock focus on targets!',
      thetaThreshold: -2.0,
    ),
    const FunctionalMilestoneModel(
      id: 'att_focus',
      domainCode: 'attention',
      name: 'Sustained Task Focus',
      description: 'You can maintain steady focus on a single task without drifting!',
      thetaThreshold: -1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'att_selective_filter',
      domainCode: 'attention',
      name: 'Filter Out Distractions',
      description: 'You can tune out background noise and visual clutter effectively!',
      thetaThreshold: 0.0,
    ),
    const FunctionalMilestoneModel(
      id: 'att_multitask',
      domainCode: 'attention',
      name: 'Divided Attention',
      description: 'You can track and manage two activities simultaneously!',
      thetaThreshold: 1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'att_rapid_switching',
      domainCode: 'attention',
      name: 'Cognitive Task Switching',
      description: 'You can switch between different mental tasks quickly and accurately!',
      thetaThreshold: 1.8,
    ),
    const FunctionalMilestoneModel(
      id: 'att_peak_control',
      domainCode: 'attention',
      name: 'Peak Attentional Control',
      description: 'You sustain razor-sharp concentration in challenging environments!',
      thetaThreshold: 2.4,
    ),

    // ── Speech ───────────────────────────────────────────
    const FunctionalMilestoneModel(
      id: 'speech_phonemes',
      domainCode: 'speech',
      name: 'Sound & Syllable Clarity',
      description: 'You can clearly articulate fundamental speech sounds and syllables!',
      thetaThreshold: -2.0,
    ),
    const FunctionalMilestoneModel(
      id: 'speech_words',
      domainCode: 'speech',
      name: 'Speak Common Words',
      description: 'You can pronounce common everyday words with clear articulation!',
      thetaThreshold: -1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'speech_phrases',
      domainCode: 'speech',
      name: 'Speak in Short Phrases',
      description: 'You can smoothly speak functional phrases and short sentences!',
      thetaThreshold: 0.0,
    ),
    const FunctionalMilestoneModel(
      id: 'speech_cadence',
      domainCode: 'speech',
      name: 'Natural Cadence & Rhythm',
      description: 'You maintain natural speech pacing, rhythm, and vocal inflection!',
      thetaThreshold: 1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'speech_fluent_sentences',
      domainCode: 'speech',
      name: 'Fluent Complex Sentences',
      description: 'You can articulate longer thoughts and full sentences without hesitation!',
      thetaThreshold: 1.8,
    ),
    const FunctionalMilestoneModel(
      id: 'speech_conversational_speed',
      domainCode: 'speech',
      name: 'Conversational Fluency',
      description: 'You speak with effortless articulation at natural conversation speeds!',
      thetaThreshold: 2.4,
    ),

    // ── Reading & Writing ────────────────────────────────
    const FunctionalMilestoneModel(
      id: 'rw_letters_symbols',
      domainCode: 'reading_writing',
      name: 'Letter & Word Recognition',
      description: 'You can recognize letters, sight words, and common symbols!',
      thetaThreshold: -2.0,
    ),
    const FunctionalMilestoneModel(
      id: 'rw_words',
      domainCode: 'reading_writing',
      name: 'Read Familiar Words',
      description: 'You can quickly read and comprehend everyday vocabulary!',
      thetaThreshold: -1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'rw_sentences',
      domainCode: 'reading_writing',
      name: 'Read Functional Sentences',
      description: 'You can read and understand complete instructions and statements!',
      thetaThreshold: 0.0,
    ),
    const FunctionalMilestoneModel(
      id: 'rw_short_messages',
      domainCode: 'reading_writing',
      name: 'Write Short Messages',
      description: 'You can spell words accurately and compose short notes and texts!',
      thetaThreshold: 1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'rw_paragraphs',
      domainCode: 'reading_writing',
      name: 'Read Paragraphs & Articles',
      description: 'You can comfortably read and summarize full paragraphs and news passages!',
      thetaThreshold: 1.8,
    ),
    const FunctionalMilestoneModel(
      id: 'rw_advanced_composition',
      domainCode: 'reading_writing',
      name: 'Advanced Literacy & Composition',
      description: 'You can write cohesive paragraphs and comprehend in-depth reading materials!',
      thetaThreshold: 2.4,
    ),

    // ── Math ─────────────────────────────────────────────
    const FunctionalMilestoneModel(
      id: 'math_numbers_counting',
      domainCode: 'math',
      name: 'Number Recognition & Counting',
      description: 'You can recognize numerals and accurately count items!',
      thetaThreshold: -2.0,
    ),
    const FunctionalMilestoneModel(
      id: 'math_basic',
      domainCode: 'math',
      name: 'Basic Addition & Subtraction',
      description: 'You can solve single-digit math equations quickly and accurately!',
      thetaThreshold: -1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'math_everyday',
      domainCode: 'math',
      name: 'Everyday Money & Change',
      description: 'You can handle real-world transactions and count change confidently!',
      thetaThreshold: 0.0,
    ),
    const FunctionalMilestoneModel(
      id: 'math_time_calendar',
      domainCode: 'math',
      name: 'Time & Calendar Math',
      description: 'You can calculate elapsed time, read analog clocks, and schedule dates!',
      thetaThreshold: 1.0,
    ),
    const FunctionalMilestoneModel(
      id: 'math_multi_step',
      domainCode: 'math',
      name: 'Multi-Step Math Problems',
      description: 'You can solve everyday word problems and calculate percentages!',
      thetaThreshold: 1.8,
    ),
    const FunctionalMilestoneModel(
      id: 'math_numerical_mastery',
      domainCode: 'math',
      name: 'Numerical Reasoning Mastery',
      description: 'You can rapidly execute complex mental math and financial budgeting!',
      thetaThreshold: 2.4,
    ),
  ];

  // ── Hardcoded Achievement Definitions ─────────────────────────────

  static final List<AchievementModel> _achievementDefs = [
    const AchievementModel(
      id: 'streak_3',
      name: '3-Day Streak',
      description: 'Practiced 3 days in a row!',
      iconData: Icons.local_fire_department,
      category: AchievementCategory.streak,
    ),
    const AchievementModel(
      id: 'streak_7',
      name: '7-Day Streak',
      description: 'A whole week of practice!',
      iconData: Icons.local_fire_department,
      category: AchievementCategory.streak,
    ),
    const AchievementModel(
      id: 'streak_30',
      name: '30-Day Streak',
      description: 'A month of dedication!',
      iconData: Icons.local_fire_department,
      category: AchievementCategory.streak,
    ),
    const AchievementModel(
      id: 'streak_100',
      name: '100-Day Streak',
      description: 'Incredible — 100 days of practice!',
      iconData: Icons.local_fire_department,
      category: AchievementCategory.streak,
    ),
    const AchievementModel(
      id: 'sessions_1',
      name: 'First Session',
      description: 'Completed your very first session!',
      iconData: Icons.star_rounded,
      category: AchievementCategory.sessionCount,
    ),
    const AchievementModel(
      id: 'sessions_10',
      name: '10 Sessions',
      description: 'Ten sessions completed — great momentum!',
      iconData: Icons.star_rounded,
      category: AchievementCategory.sessionCount,
    ),
    const AchievementModel(
      id: 'sessions_50',
      name: '50 Sessions',
      description: 'Fifty sessions — amazing commitment!',
      iconData: Icons.star_rounded,
      category: AchievementCategory.sessionCount,
    ),
    const AchievementModel(
      id: 'sessions_100',
      name: '100 Sessions',
      description: 'One hundred sessions completed!',
      iconData: Icons.emoji_events_rounded,
      category: AchievementCategory.sessionCount,
    ),
    const AchievementModel(
      id: 'accuracy_perfect',
      name: 'Perfect Session',
      description: '100% accuracy in a session!',
      iconData: Icons.diamond_rounded,
      category: AchievementCategory.accuracy,
    ),
    const AchievementModel(
      id: 'accuracy_sharp',
      name: 'Sharp Mind',
      description: '90%+ average accuracy — brilliant!',
      iconData: Icons.psychology_rounded,
      category: AchievementCategory.accuracy,
    ),
  ];
}

/// Session history entry for the progress page list.
class SessionHistoryModel {
  const SessionHistoryModel({
    required this.sessionId,
    required this.date,
    required this.domains,
    required this.totalItems,
    required this.correctItems,
    required this.accuracy,
    required this.durationMs,
  });

  final String sessionId;
  final DateTime date;
  final List<String> domains;
  final int totalItems;
  final int correctItems;
  final double accuracy;
  final int durationMs;

  /// Positive framing: shows correct count, never wrong count.
  String get positiveResultText {
    if (totalItems == 0) return 'Session completed!';
    return '$correctItems of $totalItems correct — great practice!';
  }

  /// Formatted duration (e.g. "5:32").
  String get formattedDuration {
    final minutes = durationMs ~/ 60000;
    final seconds = (durationMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Internal helper for aggregating daily stats.
class _DayBucket {
  _DayBucket(this.date);
  final DateTime date;
  int sessionCount = 0;
  int totalMinutes = 0;
  int totalItems = 0;
  int correctItems = 0;
}
