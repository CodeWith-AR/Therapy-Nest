/// Per-domain ability snapshot for dashboard display.
///
/// Combines current θ, initial θ (from baseline assessment),
/// session count, and last practice date.
class DomainAbilityModel {
  const DomainAbilityModel({
    required this.domainCode,
    required this.domainLabel,
    required this.theta,
    required this.initialTheta,
    required this.sessionCount,
    this.lastPracticed,
  });

  /// Domain code (e.g. 'language', 'memory').
  final String domainCode;

  /// Human-readable label (e.g. 'Language', 'Memory').
  final String domainLabel;

  /// Current ability estimate θ, clamped to [-3.0, 3.0].
  final double theta;

  /// Initial ability estimate θ from baseline assessment.
  final double initialTheta;

  /// Number of sessions that included this domain.
  final int sessionCount;

  /// When this domain was last practiced (null if never).
  final DateTime? lastPracticed;

  /// Maps θ [-3.0, 3.0] to a 0–100 percentage for ability bars.
  double get abilityPercent => ((theta + 3.0) / 6.0 * 100).clamp(0.0, 100.0);

  /// Maps initial θ to a 0–100 percentage.
  double get initialAbilityPercent =>
      ((initialTheta + 3.0) / 6.0 * 100).clamp(0.0, 100.0);

  /// Positive-framed change text. Never shows negative framing.
  String get changeText {
    final delta = theta - initialTheta;
    if (delta > 0.05) return '↑ Nice progress';
    if (delta < -0.05) return 'Building skills';
    return 'Steady';
  }
}
