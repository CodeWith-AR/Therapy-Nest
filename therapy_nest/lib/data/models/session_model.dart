/// Metadata for a single therapy session.
///
/// A session groups multiple [AttemptModel] records and tracks
/// which domains were practiced and how many items were targeted.
class SessionModel {
  const SessionModel({
    required this.id,
    required this.patientId,
    required this.startedAt,
    this.endedAt,
    required this.targetDomains,
    required this.targetItemCount,
    this.deviceInfo = const {},
  });

  /// Unique session identifier (UUID).
  final String id;

  /// The authenticated user / patient ID.
  final String patientId;

  /// When the session was started.
  final DateTime startedAt;

  /// When the session ended (null if still in progress).
  final DateTime? endedAt;

  /// List of domain codes selected for this session.
  final List<String> targetDomains;

  /// Target number of items for the session.
  final int targetItemCount;

  /// Device metadata (platform, OS version, screen size).
  final Map<String, dynamic> deviceInfo;

  /// Whether the session is still in progress.
  bool get isActive => endedAt == null;

  /// Session duration, or elapsed time if still active.
  Duration get duration {
    final end = endedAt ?? DateTime.now();
    return end.difference(startedAt);
  }

  /// Creates a [SessionModel] from a JSON map.
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
      targetDomains: List<String>.from(json['target_domains'] as List),
      targetItemCount: json['target_item_count'] as int,
      deviceInfo: json['device_info'] != null
          ? Map<String, dynamic>.from(json['device_info'] as Map)
          : const {},
    );
  }

  /// Converts to a JSON map for Supabase persistence.
  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'target_domains': targetDomains,
        'target_item_count': targetItemCount,
        'device_info': deviceInfo,
      };
}
