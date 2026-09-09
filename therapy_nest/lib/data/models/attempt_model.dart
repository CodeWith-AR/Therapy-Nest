/// Records a single attempt (response) to an exercise item.
///
/// Each attempt captures the user's response, correctness, partial score
/// (accounting for cueing), response time, and the θ (ability estimate)
/// before and after this attempt for the relevant domain.
class AttemptModel {
  const AttemptModel({
    required this.id,
    required this.sessionId,
    required this.exerciseItemId,
    required this.domain,
    required this.response,
    required this.isCorrect,
    required this.partialScore,
    required this.responseTimeMs,
    required this.hintCount,
    required this.thetaBefore,
    required this.thetaAfter,
    required this.createdAt,
    this.isSynced = true,
  });

  /// Unique attempt identifier (UUID).
  final String id;

  /// The session this attempt belongs to.
  final String sessionId;

  /// The exercise item that was attempted.
  final String exerciseItemId;

  /// The domain this item belongs to.
  final String domain;

  /// The user's raw response payload.
  ///
  /// Schema varies by task type:
  /// - Multiple choice: `{ 'selected': 'Apple' }`
  /// - Sequence recall: `{ 'sequence': ['red_circle', 'blue_square'] }`
  /// - Speech: `{ 'transcription': 'cat' }`
  final Map<String, dynamic> response;

  /// Whether the response was correct (before cueing adjustments).
  final bool isCorrect;

  /// Partial score accounting for cueing level (0.0 – 1.0).
  ///
  /// - Correct at level 0: 1.0
  /// - Correct at level 1-2: 0.7
  /// - Correct at level 3-4: 0.3
  /// - No response after level 4: 0.0
  final double partialScore;

  /// Response time in milliseconds.
  final int responseTimeMs;

  /// Number of hints/cues used before answering (0–4).
  final int hintCount;

  /// Ability estimate (θ) before this attempt.
  final double thetaBefore;

  /// Ability estimate (θ) after this attempt.
  final double thetaAfter;

  /// When this attempt was recorded.
  final DateTime createdAt;

  /// Whether this attempt has been synced to the server.
  /// `false` means it's in the offline queue.
  final bool isSynced;

  /// Creates an [AttemptModel] from a JSON map.
  factory AttemptModel.fromJson(Map<String, dynamic> json) {
    return AttemptModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      exerciseItemId: json['exercise_item_id'] as String,
      domain: json['domain'] as String,
      response: Map<String, dynamic>.from(json['response'] as Map),
      isCorrect: json['is_correct'] as bool,
      partialScore: (json['partial_score'] as num).toDouble(),
      responseTimeMs: json['response_time_ms'] as int,
      hintCount: json['hint_count'] as int,
      thetaBefore: (json['theta_before'] as num).toDouble(),
      thetaAfter: (json['theta_after'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
      isSynced: json['is_synced'] as bool? ?? true,
    );
  }

  /// Converts to a JSON map for Supabase persistence.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'exercise_item_id': null,
      'domain': domain,
      'response': {
        ...response,
        'exercise_item_id': exerciseItemId,
      },
      'is_correct': isCorrect,
      'partial_score': partialScore,
      'response_time_ms': responseTimeMs,
      'hint_count': hintCount,
      'theta_before': thetaBefore,
      'theta_after': thetaAfter,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Explicit alias for Supabase persistence.
  Map<String, dynamic> toSupabaseJson() => toJson();
}
