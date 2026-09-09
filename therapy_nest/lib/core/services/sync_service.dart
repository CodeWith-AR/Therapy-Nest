import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/local_db/app_database.dart';
import '../../data/models/exercise_item_model.dart';
import '../../data/repositories/exercise_repository.dart';
import '../utils/logger.dart';

// ═══════════════════════════════════════════════════════════════════════
// CONNECTIVITY STATUS
// ═══════════════════════════════════════════════════════════════════════

enum ConnectivityStatus { online, offline, syncing }

// ═══════════════════════════════════════════════════════════════════════
// SYNC SERVICE
// ═══════════════════════════════════════════════════════════════════════

/// Manages offline → online synchronisation of attempts, sessions, and θ.
///
/// Listens to [connectivity_plus] and triggers batch uploads when the
/// device regains connectivity. Also prefetches exercise items for
/// offline play and clears stale cache (>7 days).
class SyncService extends ChangeNotifier {
  SyncService(this._db, this._exerciseRepo);

  final AppDatabase _db;
  final ExerciseRepository _exerciseRepo;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// Current connectivity status — drives the [ConnectivityBanner].
  ConnectivityStatus _status = ConnectivityStatus.online;
  ConnectivityStatus get status => _status;

  bool _isSyncing = false;

  SupabaseClient get _client => Supabase.instance.client;

  // ── Lifecycle ──────────────────────────────────────────────────────

  /// Begins listening to connectivity changes.
  void startListening() {
    _subscription = Connectivity()
        .onConnectivityChanged
        .listen(_onConnectivityChanged);

    // Check initial state.
    Connectivity().checkConnectivity().then(_onConnectivityChanged);
  }

  /// Stops listening and cancels the subscription.
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  // ── Connectivity Callback ─────────────────────────────────────────

  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    final isOnline = results.any((r) => r != ConnectivityResult.none);

    if (isOnline && _status == ConnectivityStatus.offline) {
      // Just came back online — trigger full sync.
      _setStatus(ConnectivityStatus.syncing);
      await _runFullSync();
      _setStatus(ConnectivityStatus.online);
    } else if (!isOnline) {
      _setStatus(ConnectivityStatus.offline);
    } else {
      // Already online — no change needed.
      if (_status != ConnectivityStatus.syncing) {
        _setStatus(ConnectivityStatus.online);
      }
    }
  }

  void _setStatus(ConnectivityStatus s) {
    if (_status == s) return;
    _status = s;
    notifyListeners();
  }

  // ── Full Sync Pipeline ────────────────────────────────────────────

  Future<void> _runFullSync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      await syncPendingAttempts();
      await syncPendingSessions();
      await syncAbilityEstimates();
      await clearExpiredCache();

      AppLogger.info('Full sync completed', tag: 'SyncService');
    } catch (e) {
      AppLogger.error('Full sync failed', error: e, tag: 'SyncService');
    } finally {
      _isSyncing = false;
    }
  }

  // ── Attempt Sync ──────────────────────────────────────────────────

  /// Uploads up to 50 pending attempts to Supabase, then marks them synced.
  Future<void> syncPendingAttempts() async {
    try {
      final pending = await _db.getPendingSyncAttempts();
      if (pending.isEmpty) return;

      // Build Supabase-compatible JSON rows.
      final rows = pending.map((a) => {
        'id': a.id,
        'session_id': a.sessionId,
        'exercise_item_id': a.exerciseItemId,
        'domain': a.domain,
        'response': jsonDecode(a.responseJson),
        'is_correct': a.isCorrect,
        'partial_score': a.partialScore,
        'response_time_ms': a.responseTimeMs,
        'hint_count': a.hintCount,
        'theta_before': a.thetaBefore,
        'theta_after': a.thetaAfter,
        'created_at': a.createdAt.toIso8601String(),
      }).toList();

      await _client.from('exercise_attempts').upsert(rows);
      await _db.markAttemptsSynced(pending.map((a) => a.id).toList());

      AppLogger.info(
        'Synced ${pending.length} attempts',
        tag: 'SyncService',
      );
    } catch (e) {
      AppLogger.error('Attempt sync failed', error: e, tag: 'SyncService');
    }
  }

  // ── Session Sync ──────────────────────────────────────────────────

  /// Uploads pending sessions to Supabase, then marks them synced.
  Future<void> syncPendingSessions() async {
    try {
      final pending = await _db.getPendingSyncSessions();
      if (pending.isEmpty) return;

      final rows = pending.map((s) => {
        'id': s.id,
        'patient_id': s.patientId,
        'started_at': s.startedAt.toIso8601String(),
        'ended_at': s.endedAt?.toIso8601String(),
        'target_domains': jsonDecode(s.targetDomainsJson),
        'target_item_count': s.targetItemCount,
      }).toList();

      await _client.from('therapy_sessions').upsert(rows);
      await _db.markSessionsSynced(pending.map((s) => s.id).toList());

      AppLogger.info(
        'Synced ${pending.length} sessions',
        tag: 'SyncService',
      );
    } catch (e) {
      AppLogger.error('Session sync failed', error: e, tag: 'SyncService');
    }
  }

  // ── Ability Estimate Sync (θ) ─────────────────────────────────────

  /// Pushes local θ values to Supabase. Conflict resolution: take max(θ)
  /// — the more generous estimate for the patient.
  Future<void> syncAbilityEstimates() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      final localEstimates = await _db.getAllAbilityEstimates();
      if (localEstimates.isEmpty) return;

      // Read current server θ scores.
      final serverData = await _client
          .from('patient_profiles')
          .select('theta_scores')
          .eq('user_id', userId)
          .maybeSingle();

      final serverScores =
          (serverData?['theta_scores'] as Map<String, dynamic>?) ?? {};

      // Merge: take max(local, server) per domain.
      final merged = Map<String, dynamic>.from(serverScores);
      for (final est in localEstimates) {
        final serverTheta =
            ((merged[est.domain] as Map<String, dynamic>?)?['theta'] as num?)
                ?.toDouble() ??
            -3.0;
        final winningTheta =
            est.theta > serverTheta ? est.theta : serverTheta;

        merged[est.domain] = {
          ...((merged[est.domain] as Map<String, dynamic>?) ?? {}),
          'theta': winningTheta,
          'updated_at': est.updatedAt.toIso8601String(),
        };
      }

      await _client
          .from('patient_profiles')
          .update({'theta_scores': merged}).eq('user_id', userId);

      AppLogger.info(
        'Synced θ for ${localEstimates.length} domains',
        tag: 'SyncService',
      );
    } catch (e) {
      AppLogger.error('θ sync failed', error: e, tag: 'SyncService');
    }
  }

  // ── Prefetch Exercises ────────────────────────────────────────────

  /// Downloads up to 50 items per domain from the hardcoded item bank
  /// and caches them locally for offline play.
  Future<void> prefetchExercises(List<String> domains) async {
    try {
      for (final domain in domains) {
        final items = _exerciseRepo.getItemsForDomain(domain, 0.0, 50);
        if (items.isEmpty) continue;

        final companions = items.map((item) => _itemToCompanion(item)).toList();
        await _db.cacheItems(companions);
      }

      AppLogger.info(
        'Prefetched exercises for ${domains.length} domains',
        tag: 'SyncService',
      );
    } catch (e) {
      AppLogger.error('Prefetch failed', error: e, tag: 'SyncService');
    }
  }

  /// Converts an [ExerciseItemModel] to a Drift companion for caching.
  LocalExerciseItemsCompanion _itemToCompanion(ExerciseItemModel item) {
    return LocalExerciseItemsCompanion(
      id: Value(item.id),
      domain: Value(item.domain),
      exerciseTypeCode: Value(item.exerciseTypeCode),
      difficulty: Value(item.difficulty),
      discrimination: Value(item.discrimination),
      locale: Value(item.locale),
      stimulusJson: Value(jsonEncode(item.stimulus)),
      acceptedAnswersJson: Value(jsonEncode(item.acceptedAnswers)),
      mediaUrl: Value(item.mediaUrl),
      cuesJson: Value(jsonEncode(item.cues)),
      isActive: Value(item.isActive),
      cachedAt: Value(DateTime.now()),
    );
  }

  // ── Cache Expiry ──────────────────────────────────────────────────

  /// Removes cached items older than 7 days.
  Future<void> clearExpiredCache() async {
    try {
      final deleted =
          await _db.clearExpiredItems(const Duration(days: 7));
      if (deleted > 0) {
        AppLogger.info(
          'Cleared $deleted expired cached items',
          tag: 'SyncService',
        );
      }
    } catch (e) {
      AppLogger.error('Cache cleanup failed', error: e, tag: 'SyncService');
    }
  }
}
