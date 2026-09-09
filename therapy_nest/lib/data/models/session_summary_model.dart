/// Computed summary of a completed therapy session.
///
/// Used by [SessionResultPage] to display statistics and
/// per-domain ability changes.
class SessionSummaryModel {
  const SessionSummaryModel({
    required this.totalItems,
    required this.correctCount,
    required this.accuracyPercent,
    required this.totalTimeMs,
    required this.domains,
    required this.thetaChanges,
    required this.longestStreak,
  });

  /// Total number of items attempted.
  final int totalItems;

  /// Number of items answered correctly (at any cue level).
  final int correctCount;

  /// Accuracy as a percentage (0–100).
  final double accuracyPercent;

  /// Total session time in milliseconds.
  final int totalTimeMs;

  /// List of domain codes practiced in this session.
  final List<String> domains;

  /// Per-domain θ change: `{ 'language': { 'before': 0.5, 'after': 0.8 } }`.
  final Map<String, Map<String, double>> thetaChanges;

  /// Longest streak of consecutive correct answers.
  final int longestStreak;

  /// Formatted session duration (e.g. "5:32").
  String get formattedDuration {
    final minutes = totalTimeMs ~/ 60000;
    final seconds = (totalTimeMs % 60000) ~/ 1000;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
