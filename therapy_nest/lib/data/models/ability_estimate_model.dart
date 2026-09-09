/// Per-domain ability estimate (θ) for a patient.
///
/// Updated after each exercise attempt using the Elo-style IRT formula.
/// θ is clamped to the range [-3.0, 3.0].
class AbilityEstimateModel {
  const AbilityEstimateModel({
    required this.patientId,
    required this.domainCode,
    required this.theta,
    this.standardError = 1.0,
    required this.updatedAt,
  });

  /// The patient this estimate belongs to.
  final String patientId;

  /// Clinical domain code (e.g. "language", "memory").
  final String domainCode;

  /// Current ability estimate, clamped to [-3.0, 3.0].
  final double theta;

  /// Standard error of the estimate (decreases with more attempts).
  final double standardError;

  /// When this estimate was last updated.
  final DateTime updatedAt;

  /// Creates a copy with updated theta.
  AbilityEstimateModel copyWithTheta(double newTheta) {
    return AbilityEstimateModel(
      patientId: patientId,
      domainCode: domainCode,
      theta: newTheta.clamp(-3.0, 3.0),
      standardError: standardError,
      updatedAt: DateTime.now(),
    );
  }

  /// Creates an [AbilityEstimateModel] from a JSON map.
  factory AbilityEstimateModel.fromJson(Map<String, dynamic> json) {
    return AbilityEstimateModel(
      patientId: json['patient_id'] as String,
      domainCode: json['domain_code'] as String,
      theta: (json['theta'] as num).toDouble(),
      standardError: (json['standard_error'] as num?)?.toDouble() ?? 1.0,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts to a JSON map for persistence.
  Map<String, dynamic> toJson() => {
        'patient_id': patientId,
        'domain_code': domainCode,
        'theta': theta,
        'standard_error': standardError,
        'updated_at': updatedAt.toIso8601String(),
      };
}
