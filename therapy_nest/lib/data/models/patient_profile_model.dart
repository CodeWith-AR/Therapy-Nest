/// Represents a patient's onboarding profile from the `patient_profiles` table.
class PatientProfileModel {
  final String userId;
  final List<String> conditions;
  final Map<String, int> severityMap;
  final List<String> goals;
  final int sessionsPerWeek;
  final int minutesPerSession;
  final String dominantLanguage;
  final bool consentResearch;
  final bool consentDataSharing;
  final DateTime? onboardingCompletedAt;

  const PatientProfileModel({
    required this.userId,
    this.conditions = const [],
    this.severityMap = const {},
    this.goals = const [],
    this.sessionsPerWeek = 3,
    this.minutesPerSession = 20,
    this.dominantLanguage = 'en-US',
    this.consentResearch = false,
    this.consentDataSharing = false,
    this.onboardingCompletedAt,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      userId: json['user_id'] as String,
      conditions: (json['conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      severityMap: (json['severity_map'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {},
      goals: (json['goals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sessionsPerWeek: (json['sessions_per_week'] as num?)?.toInt() ?? 3,
      minutesPerSession: (json['minutes_per_session'] as num?)?.toInt() ?? 20,
      dominantLanguage: json['dominant_language'] as String? ?? 'en-US',
      consentResearch: json['consent_research'] as bool? ?? false,
      consentDataSharing: json['consent_data_sharing'] as bool? ?? false,
      onboardingCompletedAt: json['onboarding_completed_at'] != null
          ? DateTime.parse(json['onboarding_completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'conditions': conditions,
      'severity_map': severityMap,
      'goals': goals,
      'sessions_per_week': sessionsPerWeek,
      'minutes_per_session': minutesPerSession,
      'dominant_language': dominantLanguage,
      'consent_research': consentResearch,
      'consent_data_sharing': consentDataSharing,
      'onboarding_completed_at': onboardingCompletedAt?.toIso8601String(),
    };
  }

  PatientProfileModel copyWith({
    String? userId,
    List<String>? conditions,
    Map<String, int>? severityMap,
    List<String>? goals,
    int? sessionsPerWeek,
    int? minutesPerSession,
    String? dominantLanguage,
    bool? consentResearch,
    bool? consentDataSharing,
    DateTime? onboardingCompletedAt,
  }) {
    return PatientProfileModel(
      userId: userId ?? this.userId,
      conditions: conditions ?? this.conditions,
      severityMap: severityMap ?? this.severityMap,
      goals: goals ?? this.goals,
      sessionsPerWeek: sessionsPerWeek ?? this.sessionsPerWeek,
      minutesPerSession: minutesPerSession ?? this.minutesPerSession,
      dominantLanguage: dominantLanguage ?? this.dominantLanguage,
      consentResearch: consentResearch ?? this.consentResearch,
      consentDataSharing: consentDataSharing ?? this.consentDataSharing,
      onboardingCompletedAt:
          onboardingCompletedAt ?? this.onboardingCompletedAt,
    );
  }
}
