import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ═══════════════════════════════════════════════════════════════════════
// TABLE 1 — Cached exercise items for offline play
// ═══════════════════════════════════════════════════════════════════════

class LocalExerciseItems extends Table {
  TextColumn get id => text()();
  TextColumn get domain => text()();
  TextColumn get exerciseTypeCode => text()();
  RealColumn get difficulty => real()();
  RealColumn get discrimination => real().withDefault(const Constant(1.0))();
  TextColumn get locale => text().withDefault(const Constant('en'))();
  TextColumn get stimulusJson => text()();
  TextColumn get acceptedAnswersJson => text()();
  TextColumn get mediaUrl => text().nullable()();
  TextColumn get cuesJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════════
// TABLE 2 — Pending sync attempts (append-only queue)
// ═══════════════════════════════════════════════════════════════════════

class LocalAttempts extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get exerciseItemId => text()();
  TextColumn get domain => text()();
  TextColumn get responseJson => text()();
  BoolColumn get isCorrect => boolean()();
  RealColumn get partialScore => real()();
  IntColumn get responseTimeMs => integer()();
  IntColumn get hintCount => integer()();
  RealColumn get thetaBefore => real()();
  RealColumn get thetaAfter => real()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════════
// TABLE 3 — Authoritative offline θ per domain
// ═══════════════════════════════════════════════════════════════════════

class LocalAbilityEstimates extends Table {
  TextColumn get domain => text()();
  RealColumn get theta => real()();
  RealColumn get standardError => real().withDefault(const Constant(1.0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {domain};
}

// ═══════════════════════════════════════════════════════════════════════
// TABLE 4 — Sessions created offline
// ═══════════════════════════════════════════════════════════════════════

class LocalSessions extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  TextColumn get targetDomainsJson => text()();
  IntColumn get targetItemCount => integer()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════════
// TABLE 5 — Cached achievement state
// ═══════════════════════════════════════════════════════════════════════

class LocalAchievements extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text()();
  IntColumn get iconCodePoint => integer()();
  TextColumn get category => text()();
  BoolColumn get isUnlocked => boolean().withDefault(const Constant(false))();
  DateTimeColumn get unlockedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ═══════════════════════════════════════════════════════════════════════
// DATABASE CLASS
// ═══════════════════════════════════════════════════════════════════════

@DriftDatabase(tables: [
  LocalExerciseItems,
  LocalAttempts,
  LocalAbilityEstimates,
  LocalSessions,
  LocalAchievements,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Allow injecting a custom [QueryExecutor] for testing.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  // ── Exercise Item Queries ─────────────────────────────────────────

  /// Fetches cached exercise items for [domain], ordered by difficulty.
  Future<List<LocalExerciseItem>> getItemsForDomain(
    String domain, {
    int limit = 50,
  }) {
    return (select(localExerciseItems)
          ..where((t) => t.domain.equals(domain))
          ..orderBy([(t) => OrderingTerm.asc(t.difficulty)])
          ..limit(limit))
        .get();
  }

  /// Bulk-inserts exercise items, replacing duplicates by primary key.
  Future<void> cacheItems(List<LocalExerciseItemsCompanion> items) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(localExerciseItems, items);
    });
  }

  /// Deletes cached items older than [maxAge].
  Future<int> clearExpiredItems(Duration maxAge) {
    final cutoff = DateTime.now().subtract(maxAge);
    return (delete(localExerciseItems)
          ..where((t) => t.cachedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  // ── Attempt Queries ───────────────────────────────────────────────

  /// Saves an attempt locally with [isSynced] = false.
  Future<void> saveAttempt(LocalAttemptsCompanion attempt) {
    return into(localAttempts).insertOnConflictUpdate(attempt);
  }

  /// Returns up to 50 attempts that have not been synced.
  Future<List<LocalAttempt>> getPendingSyncAttempts() {
    return (select(localAttempts)
          ..where((t) => t.isSynced.equals(false))
          ..limit(50))
        .get();
  }

  /// Marks the given attempt [ids] as synced.
  Future<void> markAttemptsSynced(List<String> ids) {
    return (update(localAttempts)..where((t) => t.id.isIn(ids)))
        .write(const LocalAttemptsCompanion(isSynced: Value(true)));
  }

  /// Returns all attempts for a given session ID.
  Future<List<LocalAttempt>> getAttemptsForSession(String sessionId) {
    return (select(localAttempts)
          ..where((t) => t.sessionId.equals(sessionId)))
        .get();
  }

  /// Returns all attempts for a given domain ordered chronologically.
  Future<List<LocalAttempt>> getAttemptsForDomain(String domain) {
    final lowerDomain = domain.toLowerCase();
    return (select(localAttempts)
          ..where((t) => t.domain.lower().equals(lowerDomain))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  /// Returns attempts for a domain where hintCount >= [minHints] (default 2).
  Future<List<LocalAttempt>> getReviewItemsForDomain(
    String domain, {
    int minHints = 2,
    int limit = 30,
  }) {
    return (select(localAttempts)
          ..where((t) =>
              t.domain.equals(domain) &
              t.hintCount.isBiggerOrEqualValue(minHints))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  // ── Ability Estimate Queries ──────────────────────────────────────

  /// Upserts the θ estimate for [domain].
  Future<void> updateAbilityEstimate(
    String domain,
    double theta,
    double se,
  ) {
    return into(localAbilityEstimates).insertOnConflictUpdate(
      LocalAbilityEstimatesCompanion(
        domain: Value(domain),
        theta: Value(theta),
        standardError: Value(se),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Reads the local θ for [domain], or null if not cached.
  Future<LocalAbilityEstimate?> getAbilityEstimate(String domain) {
    return (select(localAbilityEstimates)
          ..where((t) => t.domain.equals(domain)))
        .getSingleOrNull();
  }

  /// Returns all locally stored ability estimates.
  Future<List<LocalAbilityEstimate>> getAllAbilityEstimates() {
    return select(localAbilityEstimates).get();
  }

  // ── Session Queries ───────────────────────────────────────────────

  /// Saves a session locally.
  Future<void> saveLocalSession(LocalSessionsCompanion session) {
    return into(localSessions).insertOnConflictUpdate(session);
  }

  /// Returns sessions that have not been synced.
  Future<List<LocalSession>> getPendingSyncSessions() {
    return (select(localSessions)
          ..where((t) => t.isSynced.equals(false))
          ..limit(50))
        .get();
  }

  /// Marks the given session [ids] as synced.
  Future<void> markSessionsSynced(List<String> ids) {
    return (update(localSessions)..where((t) => t.id.isIn(ids)))
        .write(const LocalSessionsCompanion(isSynced: Value(true)));
  }

  /// Updates the end time of a local session.
  Future<void> endLocalSession(String sessionId, DateTime endedAt) {
    return (update(localSessions)..where((t) => t.id.equals(sessionId)))
        .write(LocalSessionsCompanion(endedAt: Value(endedAt)));
  }

  /// Loads local sessions ordered by most recent first.
  Future<List<LocalSession>> getLocalSessions({int limit = 20}) {
    return (select(localSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit))
        .get();
  }

  /// Loads completed local sessions (endedAt != null) ordered by most recent first.
  Future<List<LocalSession>> getCompletedSessions({
    int limit = 20,
    int offset = 0,
    String? patientId,
  }) {
    final query = select(localSessions)..where((t) => t.endedAt.isNotNull());
    if (patientId != null && patientId.isNotEmpty) {
      query.where((t) => t.patientId.equals(patientId));
    }
    return (query
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  // ── Achievement Queries ───────────────────────────────────────────

  /// Saves or updates an achievement.
  Future<void> saveAchievement(LocalAchievementsCompanion achievement) {
    return into(localAchievements).insertOnConflictUpdate(achievement);
  }

  /// Returns all cached achievements.
  Future<List<LocalAchievement>> getAllAchievements() {
    return select(localAchievements).get();
  }

  // ── Multi-User Cleanup ────────────────────────────────────────────

  /// Clears all user-specific local data (attempts, sessions, ability estimates, achievements).
  ///
  /// Called on logout or when switching accounts so each patient has an isolated, fresh state.
  Future<void> clearUserData() async {
    await batch((b) {
      b.deleteWhere(localAttempts, (t) => const Constant(true));
      b.deleteWhere(localAbilityEstimates, (t) => const Constant(true));
      b.deleteWhere(localSessions, (t) => const Constant(true));
      b.deleteWhere(localAchievements, (t) => const Constant(true));
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════
// DATABASE CONNECTION
// ═══════════════════════════════════════════════════════════════════════

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbDir.path, 'therapy_nest.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
