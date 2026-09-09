import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/logger.dart';
import '../local_db/app_database.dart';
import '../models/session_model.dart';

/// Manages therapy session lifecycle — create, end, and list sessions.
///
/// Sessions are persisted offline-first: always saved to the local Drift DB,
/// then synced to Supabase's `therapy_sessions` table when online.
class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;

  SupabaseClient get _client => Supabase.instance.client;

  static const _uuid = Uuid();

  // ── Start Session ─────────────────────────────────────────────────

  /// Creates a new therapy session — offline-first.
  ///
  /// 1. Always saves to local DB.
  /// 2. Attempts Supabase insert; marks `isSynced` accordingly.
  Future<SessionModel> startSession(
    List<String> domains,
    int targetItems,
  ) async {
    final userId = _client.auth.currentUser?.id ?? '';
    final session = SessionModel(
      id: _uuid.v4(),
      patientId: userId,
      startedAt: DateTime.now(),
      targetDomains: domains,
      targetItemCount: targetItems,
    );

    // 1. Save locally.
    await _db.saveLocalSession(LocalSessionsCompanion(
      id: Value(session.id),
      patientId: Value(session.patientId),
      startedAt: Value(session.startedAt),
      targetDomainsJson: Value(jsonEncode(session.targetDomains)),
      targetItemCount: Value(session.targetItemCount),
      isSynced: const Value(false),
    ));

    // 2. Try Supabase insert.
    try {
      await _client.from('therapy_sessions').insert(session.toJson());
      await _db.markSessionsSynced([session.id]);
      AppLogger.info(
        'Session started & synced: ${session.id}',
        tag: 'SessionRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Session saved locally, sync deferred',
        error: e,
        tag: 'SessionRepository',
      );
    }

    return session;
  }

  // ── End Session ───────────────────────────────────────────────────

  /// Marks a session as ended — offline-first.
  Future<void> endSession(String sessionId, DateTime endedAt) async {
    // 1. Update local DB.
    await _db.endLocalSession(sessionId, endedAt);

    // 2. Try Supabase update.
    try {
      await _client.from('therapy_sessions').update({
        'ended_at': endedAt.toIso8601String(),
      }).eq('id', sessionId);

      AppLogger.info(
        'Session ended & synced: $sessionId',
        tag: 'SessionRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Session end saved locally, sync deferred',
        error: e,
        tag: 'SessionRepository',
      );
    }
  }

  // ── Get Sessions ──────────────────────────────────────────────────

  /// Lists past sessions — tries Supabase first, falls back to local DB.
  Future<List<SessionModel>> getSessions({int limit = 20}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return _getLocalSessions(limit: limit);

      final data = await _client
          .from('therapy_sessions')
          .select()
          .eq('patient_id', userId)
          .order('started_at', ascending: false)
          .limit(limit);

      return (data as List)
          .map((json) => SessionModel.fromJson(
                Map<String, dynamic>.from(json as Map),
              ))
          .toList();
    } catch (e) {
      AppLogger.error(
        'Failed to load sessions from server, using local fallback',
        error: e,
        tag: 'SessionRepository',
      );
      return _getLocalSessions(limit: limit);
    }
  }

  /// Fallback: reads sessions from the local Drift DB.
  Future<List<SessionModel>> _getLocalSessions({int limit = 20}) async {
    final localSessions = await _db.getLocalSessions(limit: limit);
    return localSessions
        .map((s) => SessionModel(
              id: s.id,
              patientId: s.patientId,
              startedAt: s.startedAt,
              endedAt: s.endedAt,
              targetDomains: List<String>.from(
                jsonDecode(s.targetDomainsJson) as List,
              ),
              targetItemCount: s.targetItemCount,
            ))
        .toList();
  }
}
