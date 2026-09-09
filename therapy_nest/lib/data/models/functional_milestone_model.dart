/// Functional recovery milestone (from functional_landmarks table).
///
/// Each milestone has a θ threshold. When a patient's domain θ
/// exceeds the threshold, the milestone is considered achieved.
class FunctionalMilestoneModel {
  const FunctionalMilestoneModel({
    required this.id,
    required this.domainCode,
    required this.name,
    required this.description,
    required this.thetaThreshold,
    this.isAchieved = false,
    this.achievedAt,
  });

  /// Unique milestone identifier.
  final String id;

  /// Domain this milestone belongs to.
  final String domainCode;

  /// Short name (e.g. "Name Common Objects").
  final String name;

  /// Encouraging description (e.g. "You can reliably name common objects!").
  final String description;

  /// θ value required to unlock this milestone.
  final double thetaThreshold;

  /// Whether the patient has achieved this milestone.
  final bool isAchieved;

  /// When the milestone was first achieved (null if not yet).
  final DateTime? achievedAt;

  /// Returns a copy marked as achieved.
  FunctionalMilestoneModel markAchieved() {
    return FunctionalMilestoneModel(
      id: id,
      domainCode: domainCode,
      name: name,
      description: description,
      thetaThreshold: thetaThreshold,
      isAchieved: true,
      achievedAt: DateTime.now(),
    );
  }

  /// Progress toward this milestone as a 0–1 fraction.
  double progressFraction(double currentTheta) {
    if (isAchieved) return 1.0;
    if (thetaThreshold <= -3.0) return 1.0;
    // Map θ from -3.0 to thetaThreshold as 0→1
    final range = thetaThreshold + 3.0;
    if (range <= 0) return 1.0;
    return ((currentTheta + 3.0) / range).clamp(0.0, 1.0);
  }
}
