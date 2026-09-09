/// Per-domain result after baseline assessment completion.
///
/// Stores the raw score and computed initial θ (theta) estimate
/// that seeds the adaptive exercise engine.
class AssessmentResultModel {
  const AssessmentResultModel({
    required this.userId,
    required this.domain,
    required this.correctCount,
    required this.totalItems,
    required this.thetaInitial,
    required this.totalTimeMs,
    required this.completedAt,
    this.skipped = false,
  });

  /// The authenticated user's ID.
  final String userId;

  /// Clinical domain: language, comprehension, memory, attention, speech, math.
  final String domain;

  /// Number of items answered correctly.
  final int correctCount;

  /// Total number of items in this domain.
  final int totalItems;

  /// Initial ability estimate.
  /// Formula: `(correctCount / totalItems × 4.0) - 2.0`
  /// Maps: 0% → -2.0, 50% → 0.0, 100% → +2.0
  final double thetaInitial;

  /// Total time spent on this domain in milliseconds.
  final int totalTimeMs;

  /// When this domain was completed.
  final DateTime completedAt;

  /// Whether the user skipped this domain (e.g. Speech without mic).
  final bool skipped;

  /// Fraction of correct answers (0.0 to 1.0).
  double get scoreFraction =>
      totalItems > 0 ? correctCount / totalItems : 0.0;

  /// Converts to a JSON map for Supabase persistence.
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'domain': domain,
        'correct_count': correctCount,
        'total_items': totalItems,
        'theta_initial': thetaInitial,
        'total_time_ms': totalTimeMs,
        'completed_at': completedAt.toIso8601String(),
        'skipped': skipped,
      };

  /// Computes θ from a raw score fraction.
  /// Static helper so it can be called before constructing the model.
  static double computeTheta(int correct, int total) {
    if (total == 0) return 0.0;
    return (correct / total * 4.0) - 2.0;
  }
}
