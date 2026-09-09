import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/utils/logger.dart';
import '../local_db/app_database.dart';
import '../models/assessment_item_model.dart';
import '../models/assessment_result_model.dart';

/// Provides baseline assessment items and persists results to Supabase and Drift local DB.
///
/// The item bank is hardcoded for v1 — no API call needed.
/// Results are saved locally to Drift SQLite `localAbilityEstimates`,
/// upserted to `patient_profiles.theta_scores` (JSON map),
/// and inserted to `baseline_results` table for analytics if available.
class AssessmentRepository {
  AssessmentRepository(this._db);

  final AppDatabase _db;
  SupabaseClient get _client => Supabase.instance.client;

  // ── Domain constants ───────────────────────────────────────────────

  static const String domainLanguage       = 'language';
  static const String domainReadingWriting  = 'reading_writing';
  static const String domainMemory         = 'memory';
  static const String domainAttention      = 'attention';
  static const String domainSpeech         = 'speech';
  static const String domainMath           = 'math';

  /// Ordered list of domains for the assessment flow.
  static const List<String> domainOrder = [
    domainLanguage,
    domainReadingWriting,
    domainMemory,
    domainAttention,
    domainSpeech,
    domainMath,
  ];

  // ── Item Bank ──────────────────────────────────────────────────────

  /// Returns all assessment items for the given [domain].
  List<AssessmentItemModel> getAssessmentItems(String domain) {
    switch (domain) {
      case domainLanguage:
        return _languageItems;
      case domainReadingWriting:
        return _readingWritingItems;
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

  // ── Persistence ────────────────────────────────────────────────────

  /// Saves assessment results to local SQLite and Supabase.
  ///
  /// 1. Upserts initial θ to local SQLite `local_ability_estimates` (authoritative offline).
  /// 2. Upserts θ scores map to `patient_profiles.theta_scores`.
  /// 3. Best-effort insert into `baseline_results` table for analytics.
  Future<void> saveResults(List<AssessmentResultModel> results) async {
    // 1. Authoritative local Drift DB write
    for (final result in results) {
      try {
        await _db.updateAbilityEstimate(
          result.domain,
          result.thetaInitial,
          0.5,
        );
      } catch (e) {
        AppLogger.error(
          'Failed to update local ability estimate for ${result.domain}',
          error: e,
          tag: 'AssessmentRepository',
        );
      }
    }

    // 2. Remote Supabase sync
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      // Build theta scores map
      final thetaScores = <String, dynamic>{};
      for (final result in results) {
        thetaScores[result.domain] = {
          'theta': result.thetaInitial,
          'correct': result.correctCount,
          'total': result.totalItems,
          'skipped': result.skipped,
        };
      }

      // Update patient_profiles with theta scores
      try {
        await _client.from('patient_profiles').update({
          'theta_scores': thetaScores,
          'baseline_completed_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId);
      } catch (e) {
        AppLogger.warn(
          'Failed to update patient_profiles theta_scores: $e',
          tag: 'AssessmentRepository',
        );
      }

      // Insert raw results for analytics (optional table)
      try {
        final rows = results.map((r) => r.toJson()).toList();
        await _client.from('baseline_results').insert(rows);
      } catch (e) {
        AppLogger.warn(
          'baseline_results table insert skipped/failed: $e',
          tag: 'AssessmentRepository',
        );
      }

      AppLogger.info(
        'Baseline results saved for $userId',
        tag: 'AssessmentRepository',
      );
    } catch (e) {
      AppLogger.error(
        'Failed to save baseline results to Supabase',
        error: e,
        tag: 'AssessmentRepository',
      );
    }
  }

  /// Checks whether the user has already completed a baseline assessment.
  /// Hydrates local Drift DB with remote scores if available.
  Future<bool> hasCompletedBaseline() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final data = await _client
          .from('patient_profiles')
          .select('theta_scores, baseline_completed_at')
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        final scores = data['theta_scores'];
        final baselineAt = data['baseline_completed_at'];
        final hasScores = scores != null && scores is Map && scores.isNotEmpty;
        final isComplete = hasScores || baselineAt != null;

        if (hasScores) {
          try {
            for (final entry in scores.entries) {
              final val = entry.value;
              if (val is Map && val['theta'] != null) {
                final theta = (val['theta'] as num).toDouble();
                await _db.updateAbilityEstimate(entry.key.toString(), theta, 0.5);
              }
            }
          } catch (_) {}
        }
        return isComplete;
      }

      // Fallback: check local Drift DB
      final localEstimates = await _db.getAllAbilityEstimates();
      return localEstimates.isNotEmpty;
    } catch (e) {
      AppLogger.error(
        'Failed to check baseline status remotely, checking local DB',
        error: e,
        tag: 'AssessmentRepository',
      );
      try {
        final localEstimates = await _db.getAllAbilityEstimates();
        return localEstimates.isNotEmpty;
      } catch (_) {
        return false;
      }
    }
  }

  // ═════════════════════════════════════════════════════════════════════
  // ITEM BANKS — Hardcoded for v1
  // ═════════════════════════════════════════════════════════════════════

  // ── Domain 1: Language / Naming (10 items) ─────────────────────────
  // Show icon, user selects correct word from 4 options.
  // Difficulty: items 1-3 b=-1.5, items 4-7 b=0, items 8-10 b=1.5

  static final List<AssessmentItemModel> _languageItems = [
    AssessmentItemModel(
      id: 'lang_01',
      domain: domainLanguage,
      taskType: AssessmentTaskType.multipleChoice,
      difficulty: -1.5,
      stimulus: {'icon': Icons.apple.codePoint, 'fontFamily': 'MaterialIcons', 'label': 'What is this?'},
      options: const ['Apple', 'Ball', 'Cat', 'Dog'],
      correctAnswer: 'Apple',
    ),
    AssessmentItemModel(
      id: 'lang_02',
      domain: domainLanguage,
      taskType: AssessmentTaskType.multipleChoice,
      difficulty: -1.5,
      stimulus: {'icon': Icons.directions_car.codePoint, 'fontFamily': 'MaterialIcons', 'label': 'What is this?'},
      options: const ['Bike', 'Car', 'Bus', 'Train'],
      correctAnswer: 'Car',
    ),
    AssessmentItemModel(
      id: 'lang_03',
      domain: domainLanguage,
      taskType: AssessmentTaskType.multipleChoice,
      difficulty: -1.5,
      stimulus: {'icon': Icons.chair.codePoint, 'fontFamily': 'MaterialIcons', 'label': 'What is this?'},
      options: const ['Table', 'Bed', 'Chair', 'Desk'],
      correctAnswer: 'Chair',
    ),
    AssessmentItemModel(
      id: 'lang_04',
      domain: domainLanguage,
      taskType: AssessmentTaskType.multipleChoice,
      difficulty: 0.0,
      stimulus: {'icon': Icons.door_front_door.codePoint, 'fontFamily': 'MaterialIcons', 'label': 'What is this?'},
      options: const ['Window', 'Door', 'Wall', 'Gate'],
      correctAnswer: 'Door',
    ),
    AssessmentItemModel(
      id: 'lang_05',
      domain: domainLanguage,
      taskType: AssessmentTaskType.multipleChoice,
      difficulty: 0.0,
      stimulus: {'icon': Icons.edit.codePoint, 'fontFamily': 'MaterialIcons', 'label': 'What is this?'},
      options: const ['Pen', 'Brush', 'Ruler', 'Eraser'],
      correctAnswer: 'Pen',
    ),
    AssessmentItemModel(
      id: 'lang_06',
      domain: domainLanguage,
      taskType: AssessmentTaskType.multipleChoice,
      difficulty: 0.0,
      stimulus: {'icon': Icons.local_cafe.codePoint, 'fontFamily': 'MaterialIcons', 'label': 'What is this?'},
      options: const ['Bowl', 'Cup', 'Plate', 'Glass'],
      correctAnswer: 'Cup',
    ),
    AssessmentItemModel(
      id: 'lang_07',
      domain: domainLanguage,
      taskType: AssessmentTaskType.multipleChoice,
      difficulty: 0.0,
      stimulus: {'icon': Icons.access_time.codePoint, 'fontFamily': 'MaterialIcons', 'label': 'What is this?'},
      options: const ['Timer', 'Clock', 'Watch', 'Bell'],
      correctAnswer: 'Clock',
    ),
    AssessmentItemModel(
      id: 'lang_08',
      domain: domainLanguage,
      taskType: AssessmentTaskType.multipleChoice,
      difficulty: 1.5,
      stimulus: {'icon': Icons.ice_skating.codePoint, 'fontFamily': 'MaterialIcons', 'label': 'What is this?'},
      options: const ['Shoe', 'Boot', 'Sandal', 'Skate'],
      correctAnswer: 'Skate',
    ),
    AssessmentItemModel(
      id: 'lang_09',
      domain: domainLanguage,
      taskType: AssessmentTaskType.multipleChoice,
      difficulty: 1.5,
      stimulus: {'icon': Icons.park.codePoint, 'fontFamily': 'MaterialIcons', 'label': 'What is this?'},
      options: const ['Flower', 'Bush', 'Tree', 'Grass'],
      correctAnswer: 'Tree',
    ),
    AssessmentItemModel(
      id: 'lang_10',
      domain: domainLanguage,
      taskType: AssessmentTaskType.multipleChoice,
      difficulty: 1.5,
      stimulus: {'icon': Icons.phone_android.codePoint, 'fontFamily': 'MaterialIcons', 'label': 'What is this?'},
      options: const ['Radio', 'Camera', 'Phone', 'Remote'],
      correctAnswer: 'Phone',
    ),
  ];

  // ── Domain 2: Auditory Comprehension (8 items) ─────────────────────
  // TTS reads a word/phrase, user selects matching icon from 4 options.
  // Stimulus contains the TTS text; options are icon-label pairs.

  static final List<AssessmentItemModel> _readingWritingItems = [
    AssessmentItemModel(
      id: 'comp_01',
      domain: domainReadingWriting,
      taskType: AssessmentTaskType.auditoryChoice,
      difficulty: -1.5,
      stimulus: {'ttsText': 'Show me the book', 'label': 'Listen and choose'},
      options: const ['Book', 'Key', 'Lamp', 'Hat'],
      correctAnswer: 'Book',
    ),
    AssessmentItemModel(
      id: 'comp_02',
      domain: domainReadingWriting,
      taskType: AssessmentTaskType.auditoryChoice,
      difficulty: -1.5,
      stimulus: {'ttsText': 'Point to the star', 'label': 'Listen and choose'},
      options: const ['Moon', 'Star', 'Sun', 'Cloud'],
      correctAnswer: 'Star',
    ),
    AssessmentItemModel(
      id: 'comp_03',
      domain: domainReadingWriting,
      taskType: AssessmentTaskType.auditoryChoice,
      difficulty: -0.5,
      stimulus: {'ttsText': 'Find the one you drink from', 'label': 'Listen and choose'},
      options: const ['Plate', 'Fork', 'Cup', 'Knife'],
      correctAnswer: 'Cup',
    ),
    AssessmentItemModel(
      id: 'comp_04',
      domain: domainReadingWriting,
      taskType: AssessmentTaskType.auditoryChoice,
      difficulty: -0.5,
      stimulus: {'ttsText': 'Which one tells time?', 'label': 'Listen and choose'},
      options: const ['Phone', 'Clock', 'Radio', 'Lamp'],
      correctAnswer: 'Clock',
    ),
    AssessmentItemModel(
      id: 'comp_05',
      domain: domainReadingWriting,
      taskType: AssessmentTaskType.auditoryChoice,
      difficulty: 0.5,
      stimulus: {'ttsText': 'Touch the thing with four legs that you sit on', 'label': 'Listen and choose'},
      options: const ['Table', 'Chair', 'Bed', 'Shelf'],
      correctAnswer: 'Chair',
    ),
    AssessmentItemModel(
      id: 'comp_06',
      domain: domainReadingWriting,
      taskType: AssessmentTaskType.auditoryChoice,
      difficulty: 0.5,
      stimulus: {'ttsText': 'Point to something that grows outside', 'label': 'Listen and choose'},
      options: const ['Lamp', 'Tree', 'Chair', 'Book'],
      correctAnswer: 'Tree',
    ),
    AssessmentItemModel(
      id: 'comp_07',
      domain: domainReadingWriting,
      taskType: AssessmentTaskType.auditoryChoice,
      difficulty: 1.5,
      stimulus: {'ttsText': 'First touch the star, then point to the book', 'label': 'Listen carefully'},
      options: const ['Star', 'Book', 'Key', 'Hat'],
      correctAnswer: 'Star',
      acceptedAnswers: const ['Book'],
    ),
    AssessmentItemModel(
      id: 'comp_08',
      domain: domainReadingWriting,
      taskType: AssessmentTaskType.auditoryChoice,
      difficulty: 1.5,
      stimulus: {'ttsText': 'Point to something you use to write, not to cut', 'label': 'Listen carefully'},
      options: const ['Scissors', 'Pen', 'Knife', 'Brush'],
      correctAnswer: 'Pen',
    ),
  ];

  // ── Domain 3: Memory (8 items) ─────────────────────────────────────
  // Show sequence of colored shapes for 3 seconds, then recall.
  // Difficulty scales by sequence length (3→5).

  static const List<AssessmentItemModel> _memoryItems = [
    AssessmentItemModel(
      id: 'mem_01',
      domain: domainMemory,
      taskType: AssessmentTaskType.sequenceRecall,
      difficulty: -1.5,
      stimulus: {
        'sequence': ['red_circle', 'blue_square'],
        'displayMs': 3000,
      },
      options: ['red_circle, blue_square', 'blue_square, red_circle', 'red_circle, red_circle'],
      correctAnswer: 'red_circle, blue_square',
    ),
    AssessmentItemModel(
      id: 'mem_02',
      domain: domainMemory,
      taskType: AssessmentTaskType.sequenceRecall,
      difficulty: -1.5,
      stimulus: {
        'sequence': ['green_triangle', 'red_circle'],
        'displayMs': 3000,
      },
      options: ['green_triangle, red_circle', 'red_circle, green_triangle', 'green_triangle, green_triangle'],
      correctAnswer: 'green_triangle, red_circle',
    ),
    AssessmentItemModel(
      id: 'mem_03',
      domain: domainMemory,
      taskType: AssessmentTaskType.sequenceRecall,
      difficulty: -0.5,
      stimulus: {
        'sequence': ['blue_square', 'red_circle', 'green_triangle'],
        'displayMs': 3000,
      },
      options: ['blue_square, red_circle, green_triangle', 'red_circle, blue_square, green_triangle', 'green_triangle, red_circle, blue_square'],
      correctAnswer: 'blue_square, red_circle, green_triangle',
    ),
    AssessmentItemModel(
      id: 'mem_04',
      domain: domainMemory,
      taskType: AssessmentTaskType.sequenceRecall,
      difficulty: -0.5,
      stimulus: {
        'sequence': ['yellow_star', 'blue_square', 'red_circle'],
        'displayMs': 3000,
      },
      options: ['yellow_star, blue_square, red_circle', 'blue_square, yellow_star, red_circle', 'red_circle, blue_square, yellow_star'],
      correctAnswer: 'yellow_star, blue_square, red_circle',
    ),
    AssessmentItemModel(
      id: 'mem_05',
      domain: domainMemory,
      taskType: AssessmentTaskType.sequenceRecall,
      difficulty: 0.5,
      stimulus: {
        'sequence': ['red_circle', 'green_triangle', 'blue_square', 'yellow_star'],
        'displayMs': 3000,
      },
      options: ['red_circle, green_triangle, blue_square, yellow_star', 'green_triangle, red_circle, yellow_star, blue_square', 'blue_square, red_circle, green_triangle, yellow_star'],
      correctAnswer: 'red_circle, green_triangle, blue_square, yellow_star',
    ),
    AssessmentItemModel(
      id: 'mem_06',
      domain: domainMemory,
      taskType: AssessmentTaskType.sequenceRecall,
      difficulty: 0.5,
      stimulus: {
        'sequence': ['blue_square', 'yellow_star', 'red_circle', 'green_triangle'],
        'displayMs': 3000,
      },
      options: ['blue_square, yellow_star, red_circle, green_triangle', 'yellow_star, blue_square, green_triangle, red_circle', 'red_circle, green_triangle, blue_square, yellow_star'],
      correctAnswer: 'blue_square, yellow_star, red_circle, green_triangle',
    ),
    AssessmentItemModel(
      id: 'mem_07',
      domain: domainMemory,
      taskType: AssessmentTaskType.sequenceRecall,
      difficulty: 1.5,
      stimulus: {
        'sequence': ['green_triangle', 'red_circle', 'yellow_star', 'blue_square', 'red_circle'],
        'displayMs': 3000,
      },
      options: ['green_triangle, red_circle, yellow_star, blue_square, red_circle', 'red_circle, green_triangle, yellow_star, blue_square, red_circle', 'green_triangle, yellow_star, red_circle, blue_square, red_circle'],
      correctAnswer: 'green_triangle, red_circle, yellow_star, blue_square, red_circle',
    ),
    AssessmentItemModel(
      id: 'mem_08',
      domain: domainMemory,
      taskType: AssessmentTaskType.sequenceRecall,
      difficulty: 1.5,
      stimulus: {
        'sequence': ['yellow_star', 'blue_square', 'green_triangle', 'red_circle', 'yellow_star'],
        'displayMs': 3000,
      },
      options: ['yellow_star, blue_square, green_triangle, red_circle, yellow_star', 'blue_square, yellow_star, red_circle, green_triangle, yellow_star', 'yellow_star, green_triangle, blue_square, red_circle, yellow_star'],
      correctAnswer: 'yellow_star, blue_square, green_triangle, red_circle, yellow_star',
    ),
  ];

  // ── Domain 4: Attention (6 items) ──────────────────────────────────
  // Show grid of symbols, user finds and taps specific target.
  // Response time is captured by the ViewModel.

  static const List<AssessmentItemModel> _attentionItems = [
    AssessmentItemModel(
      id: 'att_01',
      domain: domainAttention,
      taskType: AssessmentTaskType.symbolSearch,
      difficulty: -1.5,
      stimulus: {
        'target': '★',
        'grid': ['●', '★', '▲', '●', '▲', '●', '★', '▲', '●'],
        'targetCount': 2,
        'gridCols': 3,
      },
      options: [],
      correctAnswer: '★',
    ),
    AssessmentItemModel(
      id: 'att_02',
      domain: domainAttention,
      taskType: AssessmentTaskType.symbolSearch,
      difficulty: -1.0,
      stimulus: {
        'target': '▲',
        'grid': ['●', '■', '▲', '■', '●', '▲', '●', '■', '▲', '■', '●', '■'],
        'targetCount': 3,
        'gridCols': 4,
      },
      options: [],
      correctAnswer: '▲',
    ),
    AssessmentItemModel(
      id: 'att_03',
      domain: domainAttention,
      taskType: AssessmentTaskType.symbolSearch,
      difficulty: 0.0,
      stimulus: {
        'target': '♦',
        'grid': ['●', '■', '▲', '♦', '●', '▲', '■', '♦', '●', '▲', '■', '●', '♦', '■', '▲', '●'],
        'targetCount': 3,
        'gridCols': 4,
      },
      options: [],
      correctAnswer: '♦',
    ),
    AssessmentItemModel(
      id: 'att_04',
      domain: domainAttention,
      taskType: AssessmentTaskType.symbolSearch,
      difficulty: 0.5,
      stimulus: {
        'target': '●',
        'grid': ['▲', '■', '●', '♦', '▲', '●', '■', '♦', '●', '▲', '■', '♦', '●', '▲', '■', '♦'],
        'targetCount': 4,
        'gridCols': 4,
      },
      options: [],
      correctAnswer: '●',
    ),
    AssessmentItemModel(
      id: 'att_05',
      domain: domainAttention,
      taskType: AssessmentTaskType.symbolSearch,
      difficulty: 1.0,
      stimulus: {
        'target': '■',
        'grid': ['●', '▲', '♦', '■', '●', '▲', '■', '♦', '●', '▲', '♦', '■', '●', '▲', '♦', '●', '■', '▲', '♦', '●', '▲', '♦', '●', '■'],
        'targetCount': 5,
        'gridCols': 6,
      },
      options: [],
      correctAnswer: '■',
    ),
    AssessmentItemModel(
      id: 'att_06',
      domain: domainAttention,
      taskType: AssessmentTaskType.symbolSearch,
      difficulty: 1.5,
      stimulus: {
        'target': '★',
        'grid': ['●', '▲', '♦', '■', '★', '●', '▲', '♦', '■', '●', '★', '▲', '♦', '■', '●', '▲', '♦', '★', '■', '●', '▲', '♦', '●', '■', '★', '▲', '♦', '●', '■', '▲'],
        'targetCount': 4,
        'gridCols': 6,
      },
      options: [],
      correctAnswer: '★',
    ),
  ];

  // ── Domain 5: Speech / Repetition (6 items — placeholder) ──────────
  // Speech requires Vosk ASR (Module 7). For now, these are skippable.

  static const List<AssessmentItemModel> _speechItems = [
    AssessmentItemModel(
      id: 'spe_01',
      domain: domainSpeech,
      taskType: AssessmentTaskType.speechRepetition,
      difficulty: -1.5,
      stimulus: {'ttsText': 'Cat', 'label': 'Repeat this word'},
      options: [],
      correctAnswer: 'cat',
      acceptedAnswers: ['kat', 'ket'],
    ),
    AssessmentItemModel(
      id: 'spe_02',
      domain: domainSpeech,
      taskType: AssessmentTaskType.speechRepetition,
      difficulty: -1.0,
      stimulus: {'ttsText': 'Water', 'label': 'Repeat this word'},
      options: [],
      correctAnswer: 'water',
      acceptedAnswers: ['wader', 'wata'],
    ),
    AssessmentItemModel(
      id: 'spe_03',
      domain: domainSpeech,
      taskType: AssessmentTaskType.speechRepetition,
      difficulty: 0.0,
      stimulus: {'ttsText': 'Banana', 'label': 'Repeat this word'},
      options: [],
      correctAnswer: 'banana',
      acceptedAnswers: ['bananna', 'banan'],
    ),
    AssessmentItemModel(
      id: 'spe_04',
      domain: domainSpeech,
      taskType: AssessmentTaskType.speechRepetition,
      difficulty: 0.5,
      stimulus: {'ttsText': 'Hospital', 'label': 'Repeat this word'},
      options: [],
      correctAnswer: 'hospital',
      acceptedAnswers: ['hospical', 'hospitol'],
    ),
    AssessmentItemModel(
      id: 'spe_05',
      domain: domainSpeech,
      taskType: AssessmentTaskType.speechRepetition,
      difficulty: 1.0,
      stimulus: {'ttsText': 'Electricity', 'label': 'Repeat this word'},
      options: [],
      correctAnswer: 'electricity',
      acceptedAnswers: ['electricty', 'elektricity'],
    ),
    AssessmentItemModel(
      id: 'spe_06',
      domain: domainSpeech,
      taskType: AssessmentTaskType.speechRepetition,
      difficulty: 1.5,
      stimulus: {'ttsText': 'The cat sat on the mat', 'label': 'Repeat this phrase'},
      options: [],
      correctAnswer: 'the cat sat on the mat',
      acceptedAnswers: ['the cat sat on mat', 'cat sat on the mat'],
    ),
  ];

  // ── Domain 6: Math / Numeracy (6 items) ────────────────────────────
  // Simple number recognition → clock reading.

  static const List<AssessmentItemModel> _mathItems = [
    AssessmentItemModel(
      id: 'math_01',
      domain: domainMath,
      taskType: AssessmentTaskType.numberRecognition,
      difficulty: -1.5,
      stimulus: {'display': '7', 'label': 'What number is this?'},
      options: ['5', '7', '9', '3'],
      correctAnswer: '7',
    ),
    AssessmentItemModel(
      id: 'math_02',
      domain: domainMath,
      taskType: AssessmentTaskType.numberRecognition,
      difficulty: -1.0,
      stimulus: {'display': '15', 'label': 'What number is this?'},
      options: ['13', '51', '15', '50'],
      correctAnswer: '15',
    ),
    AssessmentItemModel(
      id: 'math_03',
      domain: domainMath,
      taskType: AssessmentTaskType.numberRecognition,
      difficulty: 0.0,
      stimulus: {'display': '3 + 4 = ?', 'label': 'Solve this'},
      options: ['5', '6', '7', '8'],
      correctAnswer: '7',
    ),
    AssessmentItemModel(
      id: 'math_04',
      domain: domainMath,
      taskType: AssessmentTaskType.numberRecognition,
      difficulty: 0.5,
      stimulus: {'display': '12 - 5 = ?', 'label': 'Solve this'},
      options: ['6', '7', '8', '5'],
      correctAnswer: '7',
    ),
    AssessmentItemModel(
      id: 'math_05',
      domain: domainMath,
      taskType: AssessmentTaskType.numberRecognition,
      difficulty: 1.0,
      stimulus: {'display': '🕒', 'label': 'What time does this clock show?'},
      options: ['2:00', '3:00', '6:00', '9:00'],
      correctAnswer: '3:00',
    ),
    AssessmentItemModel(
      id: 'math_06',
      domain: domainMath,
      taskType: AssessmentTaskType.numberRecognition,
      difficulty: 1.5,
      stimulus: {'display': '🕤', 'label': 'What time does this clock show?'},
      options: ['9:00', '9:30', '3:30', '6:30'],
      correctAnswer: '9:30',
    ),
  ];
}
