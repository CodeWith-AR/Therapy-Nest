import 'dart:convert';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../local_db/app_database.dart';
import '../models/ability_estimate_model.dart';
import '../models/attempt_model.dart';
import '../models/exercise_item_model.dart';
import 'attention_exercise_seed_data.dart';
import 'language_exercise_seed_data.dart';
import 'memory_exercise_seed_data.dart';
import 'reading_writing_exercise_seed_data.dart';
import 'speech_exercise_seed_data.dart';
import 'math_exercise_seed_data.dart';

/// Provides therapy exercise items and persists attempt data to Supabase.
///
/// The item bank is hardcoded for v1 (same offline-first approach as
/// [AssessmentRepository]). Items are selected adaptively based on the
/// user's current θ (ability estimate) for each domain.
///
/// With Module 12, the repository is offline-first: attempts and θ are
/// always written to the local Drift DB first, then synced to Supabase.
class ExerciseRepository {
  ExerciseRepository(this._db);

  final AppDatabase _db;

  SupabaseClient get _client => Supabase.instance.client;

  // ── Domain constants (shared with AssessmentRepository) ─────────────

  static const String domainLanguage      = 'language';
  static const String domainReadingWriting = 'reading_writing';
  static const String domainMemory        = 'memory';
  static const String domainAttention     = 'attention';
  static const String domainSpeech        = 'speech';
  static const String domainMath          = 'math';

  /// All available therapy domains.
  static const List<String> allDomains = [
    domainLanguage,
    domainReadingWriting,
    domainMemory,
    domainAttention,
    domainSpeech,
    domainMath,
  ];

  // ── Item Selection ─────────────────────────────────────────────────

  /// Returns exercise items for [domain] selected adaptively near [theta].
  ///
  /// Items are sorted by proximity to the target difficulty
  /// (expected_success ≈ 0.75) and the top [count] are returned,
  /// shuffled for variety.
  List<ExerciseItemModel> getItemsForDomain(
    String domain,
    double theta,
    int count,
  ) {
    final allItems = _getItemBank(domain);
    if (allItems.isEmpty) return [];

    // Target difficulty for ~75% expected success
    // From Elo formula: expected = 1 / (1 + 10^((b - θ) / 400))
    // We want expected ≈ 0.75, so b ≈ θ - 400 * log10(1/0.75 - 1)
    // ≈ θ - 400 * log10(0.333) ≈ θ + 191
    // But since our difficulty scale is [-3, 3] not Elo [0, 3000],
    // we use a simpler proximity sort.

    // Sort by how close each item's difficulty is to theta
    // (prefer items slightly below theta for ~75% success rate)
    final targetDifficulty = theta - 0.3; // slight offset for 75% success
    final sorted = List<ExerciseItemModel>.from(allItems)
      ..sort((a, b) {
        final distA = (a.difficulty - targetDifficulty).abs();
        final distB = (b.difficulty - targetDifficulty).abs();
        return distA.compareTo(distB);
      });

    final selected = sorted.take(count).toList()..shuffle(Random());
    return selected;
  }

  /// Returns all items for a domain from the hardcoded bank.
  List<ExerciseItemModel> _getItemBank(String domain) {
    switch (domain) {
      case domainLanguage:
        return _languageItems;
      case domainReadingWriting:
        return [..._readingWritingItems, ...readingWritingExerciseSeedData];
      case domainMemory:
        return _memoryItems;
      case domainAttention:
        return _attentionItems;
      case domainSpeech:
        return _speechItems;
      case domainMath:
        return _mathItems;
      default:
        return [];
    }
  }

  /// Returns a specific exercise item by ID from any domain bank.
  ExerciseItemModel? getItemById(String id) {
    for (final domain in allDomains) {
      final items = _getItemBank(domain);
      final match = items.where((item) => item.id == id).firstOrNull;
      if (match != null) return match;
    }
    return null;
  }

  // ── Persistence ────────────────────────────────────────────────────

  /// Saves an attempt record — offline-first.
  ///
  /// 1. Always writes to the local Drift DB with `isSynced = false`.
  /// 2. Attempts to persist to Supabase.
  /// 3. If Supabase succeeds, marks the local row as synced.
  /// 4. If Supabase fails, the [SyncService] will retry later.
  Future<void> saveAttempt(AttemptModel attempt) async {
    // 1. Write to local DB first (authoritative).
    await _db.saveAttempt(LocalAttemptsCompanion(
      id: Value(attempt.id),
      sessionId: Value(attempt.sessionId),
      exerciseItemId: Value(attempt.exerciseItemId),
      domain: Value(attempt.domain),
      responseJson: Value(jsonEncode(attempt.response)),
      isCorrect: Value(attempt.isCorrect),
      partialScore: Value(attempt.partialScore),
      responseTimeMs: Value(attempt.responseTimeMs),
      hintCount: Value(attempt.hintCount),
      thetaBefore: Value(attempt.thetaBefore),
      thetaAfter: Value(attempt.thetaAfter),
      createdAt: Value(attempt.createdAt),
      isSynced: const Value(false),
    ));

    // 2. Try Supabase insert.
    try {
      await _client.from('exercise_attempts').insert(attempt.toJson());
      // 3. Mark synced on success.
      await _db.markAttemptsSynced([attempt.id]);
      AppLogger.info(
        'Attempt saved & synced: ${attempt.id}',
        tag: 'ExerciseRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Attempt saved locally, sync deferred',
        error: e,
        tag: 'ExerciseRepository',
      );
      // 4. Stays in local queue — SyncService will retry.
    }
  }

  /// Updates the ability estimate for a domain — offline-first.
  ///
  /// 1. Always writes to the local Drift DB first (authoritative).
  /// 2. Attempts to update Supabase.
  /// 3. On failure, [SyncService] will push with max(θ) conflict resolution.
  Future<void> updateAbilityEstimate(AbilityEstimateModel estimate) async {
    // 1. Write to local DB first (authoritative).
    await _db.updateAbilityEstimate(
      estimate.domainCode,
      estimate.theta,
      estimate.standardError,
    );

    // 2. Try Supabase update.
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      // Read current theta_scores
      final data = await _client
          .from('patient_profiles')
          .select('theta_scores')
          .eq('user_id', userId)
          .maybeSingle();

      final existing = data?['theta_scores'] as Map<String, dynamic>? ?? {};

      // Merge in updated domain theta
      existing[estimate.domainCode] = {
        ...((existing[estimate.domainCode] as Map<String, dynamic>?) ?? {}),
        'theta': estimate.theta,
        'updated_at': estimate.updatedAt.toIso8601String(),
      };

      await _client.from('patient_profiles').update({
        'theta_scores': existing,
      }).eq('user_id', userId);

      AppLogger.info(
        'θ updated & synced for ${estimate.domainCode}: ${estimate.theta.toStringAsFixed(2)}',
        tag: 'ExerciseRepository',
      );
    } catch (e) {
      AppLogger.error(
        'θ saved locally, sync deferred for ${estimate.domainCode}',
        error: e,
        tag: 'ExerciseRepository',
      );
      // SyncService will push with max(θ) conflict resolution.
    }
  }

  /// Loads ability estimates from local SQLite (authoritative) and patient_profiles.theta_scores.
  Future<Map<String, double>> getAbilityEstimates() async {
    final result = <String, double>{};

    // 1. Read authoritative local SQLite first
    try {
      final localEstimates = await _db.getAllAbilityEstimates();
      for (final est in localEstimates) {
        result[est.domain] = est.theta;
      }
    } catch (e) {
      AppLogger.error(
        'Failed to load local ability estimates',
        error: e,
        tag: 'ExerciseRepository',
      );
    }

    if (result.isNotEmpty) {
      return result;
    }

    // 2. Fall back to Supabase remote profile if local DB has no records yet
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return {};

      final data = await _client
          .from('patient_profiles')
          .select('theta_scores')
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null || data['theta_scores'] == null) return {};

      final scores = Map<String, dynamic>.from(data['theta_scores'] as Map);

      for (final entry in scores.entries) {
        if (entry.value is Map) {
          final domainData = Map<String, dynamic>.from(entry.value as Map);
          final th = (domainData['theta'] as num?)?.toDouble() ?? 0.0;
          result[entry.key] = th;
          // Cache into local SQLite for offline access
          await _db.updateAbilityEstimate(entry.key, th, 0.5);
        }
      }

      return result;
    } catch (e) {
      AppLogger.error(
        'Failed to load remote ability estimates',
        error: e,
        tag: 'ExerciseRepository',
      );
      return result;
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // EXERCISE ITEM BANKS — Hardcoded for v1
  // ═════════════════════════════════════════════════════════════════════

  // ── Language (52 items across 6 exercise types) ────────────────────
  // Imported from language_exercise_seed_data.dart for maintainability.

  static const List<ExerciseItemModel> _languageItems = languageExerciseSeedData;

  // ── Reading & Writing (8 items — existing + new seed data) ─────────

  static const List<ExerciseItemModel> _readingWritingItems = [
    ExerciseItemModel(
      id: 'comp_ex_01',
      exerciseTypeCode: 'sentence_completion',
      taskType: ExerciseTaskType.sentenceCompletion,
      domain: domainReadingWriting,
      difficulty: -2.0,
      stimulus: {
        'sentenceWithBlank': 'The sky is ___.',
        'options': ['blue', 'heavy', 'loud', 'sharp'],
      },
      acceptedAnswers: ['blue'],
      cues: [
        {'level': '1', 'type': 'semantic', 'text': 'Think about the color you see when you look up'},
        {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "B"'},
        {'level': '3', 'type': 'visual', 'text': 'B _ _ _'},
        {'level': '4', 'type': 'model', 'text': 'The answer is blue'},
      ],
    ),
    ExerciseItemModel(
      id: 'comp_ex_02',
      exerciseTypeCode: 'sentence_completion',
      taskType: ExerciseTaskType.sentenceCompletion,
      domain: domainReadingWriting,
      difficulty: -1.5,
      stimulus: {
        'sentenceWithBlank': 'I drink ___ when I am thirsty.',
        'options': ['water', 'sand', 'paper', 'stones'],
      },
      acceptedAnswers: ['water'],
      cues: [
        {'level': '1', 'type': 'semantic', 'text': 'It\'s a liquid you can drink'},
        {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "W"'},
        {'level': '3', 'type': 'visual', 'text': 'W _ _ _ _'},
        {'level': '4', 'type': 'model', 'text': 'The answer is water'},
      ],
    ),
    ExerciseItemModel(
      id: 'comp_ex_03',
      exerciseTypeCode: 'sentence_completion',
      taskType: ExerciseTaskType.sentenceCompletion,
      domain: domainReadingWriting,
      difficulty: -0.5,
      stimulus: {
        'sentenceWithBlank': 'We sleep in a ___.',
        'options': ['car', 'bed', 'tree', 'desk'],
      },
      acceptedAnswers: ['bed'],
      cues: [
        {'level': '1', 'type': 'semantic', 'text': 'It\'s a piece of furniture in the bedroom'},
        {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "B"'},
        {'level': '3', 'type': 'visual', 'text': 'B _ _'},
        {'level': '4', 'type': 'model', 'text': 'The answer is bed'},
      ],
    ),
    ExerciseItemModel(
      id: 'comp_ex_04',
      exerciseTypeCode: 'sentence_completion',
      taskType: ExerciseTaskType.sentenceCompletion,
      domain: domainReadingWriting,
      difficulty: 0.0,
      stimulus: {
        'sentenceWithBlank': 'The doctor works at the ___.',
        'options': ['school', 'hospital', 'farm', 'beach'],
      },
      acceptedAnswers: ['hospital'],
      cues: [
        {'level': '1', 'type': 'semantic', 'text': 'It\'s a place where sick people go'},
        {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "H"'},
        {'level': '3', 'type': 'visual', 'text': 'H _ _ _ _ _ _ _'},
        {'level': '4', 'type': 'model', 'text': 'The answer is hospital'},
      ],
    ),
    ExerciseItemModel(
      id: 'comp_ex_05',
      exerciseTypeCode: 'sentence_completion',
      taskType: ExerciseTaskType.sentenceCompletion,
      domain: domainReadingWriting,
      difficulty: 0.5,
      stimulus: {
        'sentenceWithBlank': 'She ___ the book before going to sleep.',
        'options': ['ate', 'read', 'threw', 'planted'],
      },
      acceptedAnswers: ['read'],
      cues: [
        {'level': '1', 'type': 'semantic', 'text': 'What do you do with a book?'},
        {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "R"'},
        {'level': '3', 'type': 'visual', 'text': 'R _ _ _'},
        {'level': '4', 'type': 'model', 'text': 'The answer is read'},
      ],
    ),
    ExerciseItemModel(
      id: 'comp_ex_06',
      exerciseTypeCode: 'sentence_completion',
      taskType: ExerciseTaskType.sentenceCompletion,
      domain: domainReadingWriting,
      difficulty: 1.0,
      stimulus: {
        'sentenceWithBlank': 'The opposite of hot is ___.',
        'options': ['warm', 'cold', 'fast', 'tall'],
      },
      acceptedAnswers: ['cold'],
      cues: [
        {'level': '1', 'type': 'semantic', 'text': 'Think about the opposite temperature'},
        {'level': '2', 'type': 'phonemic', 'text': 'It starts with the letter "C"'},
        {'level': '3', 'type': 'visual', 'text': 'C _ _ _'},
        {'level': '4', 'type': 'model', 'text': 'The answer is cold'},
      ],
    ),
    ExerciseItemModel(
      id: 'comp_ex_07',
      exerciseTypeCode: 'sentence_completion',
      taskType: ExerciseTaskType.sentenceCompletion,
      domain: domainReadingWriting,
      difficulty: 1.5,
      stimulus: {
        'sentenceWithBlank': 'Although it was raining, she ___ forgot her umbrella.',
        'options': ['never', 'always', 'still', 'quietly'],
      },
      acceptedAnswers: ['still'],
      cues: [
        {'level': '1', 'type': 'semantic', 'text': 'Despite the rain, she did it anyway'},
        {'level': '2', 'type': 'phonemic', 'text': 'It starts with "St"'},
        {'level': '3', 'type': 'visual', 'text': 'St _ _ _'},
        {'level': '4', 'type': 'model', 'text': 'The answer is still'},
      ],
    ),
    ExerciseItemModel(
      id: 'comp_ex_08',
      exerciseTypeCode: 'sentence_completion',
      taskType: ExerciseTaskType.sentenceCompletion,
      domain: domainReadingWriting,
      difficulty: 2.0,
      stimulus: {
        'sentenceWithBlank': 'The scientist\'s ___ led to a major breakthrough.',
        'options': ['breakfast', 'experiment', 'vacation', 'nap'],
      },
      acceptedAnswers: ['experiment'],
      cues: [
        {'level': '1', 'type': 'semantic', 'text': 'Scientists do this to test ideas'},
        {'level': '2', 'type': 'phonemic', 'text': 'It starts with "Ex"'},
        {'level': '3', 'type': 'visual', 'text': 'Ex _ _ _ _ _ _ _ _'},
        {'level': '4', 'type': 'model', 'text': 'The answer is experiment'},
      ],
    ),
  ];

  // ── Memory (50 items across 5 exercise types) ─────────────────────
  // Imported from memory_exercise_seed_data.dart for maintainability.

  static const List<ExerciseItemModel> _memoryItems = memoryExerciseSeedData;

  // ── Attention (50 items across 4 exercise types) ───────────────────
  // Imported from attention_exercise_seed_data.dart for maintainability.

  static const List<ExerciseItemModel> _attentionItems = attentionExerciseSeedData;

  // ── Speech (50 items across 4 exercise types) ──────────────────────
  // Imported from speech_exercise_seed_data.dart for maintainability.

  static const List<ExerciseItemModel> _speechItems = speechExerciseSeedData;

  // ── Math (54 items across 6 exercise types) ───────────────────────
  // Imported from math_exercise_seed_data.dart for maintainability.

  static const List<ExerciseItemModel> _mathItems = mathExerciseSeedData;
}
