/// Immutable accessibility settings data model.
/// Persisted via SharedPreferences through [AccessibilityViewModel].
class AccessibilitySettings {
  const AccessibilitySettings({
    this.textScaleFactor = 1.0,
    this.highContrastMode = false,
    this.ttsSpeed = 1.0,
    this.touchTargetScale = 1.0,
    this.reduceMotion = false,
    this.voiceInputMode = false,
    this.researchConsent = false,
  });

  /// Text scale multiplier.
  /// 0.85 = Small, 1.0 = Default, 1.15 = Large, 1.3 = Extra Large, 1.5 = Maximum.
  final double textScaleFactor;

  /// When true, the app swaps to a high-contrast colour palette (7:1 ratios).
  final bool highContrastMode;

  /// Text-to-speech rate (0.5× – 1.5×, default 1.0×).
  final double ttsSpeed;

  /// Touch target scale multiplier.
  /// 1.0 = Default (56dp), 1.15 = Large, 1.35 = Extra Large (≈80dp).
  final double touchTargetScale;

  /// When true, disable flutter_animate, confetti, and heavy motion;
  /// use plain FadeTransition only.
  final bool reduceMotion;

  /// When true, adds a mic button to ALL exercises, not just speech modules.
  final bool voiceInputMode;

  /// When true, user consents to sharing anonymized usage data for research.
  final bool researchConsent;

  /// Named labels for the text scale slider stops.
  static const List<String> textScaleLabels = [
    'Small',
    'Default',
    'Large',
    'Extra Large',
    'Maximum',
  ];

  /// Corresponding scale values for each label.
  static const List<double> textScaleValues = [
    0.85,
    1.0,
    1.15,
    1.3,
    1.5,
  ];

  /// Named labels for touch target size options.
  static const List<String> touchTargetLabels = [
    'Compact',
    'Default',
    'Large',
    'Extra Large',
  ];

  /// Corresponding scale values for each touch target label.
  static const List<double> touchTargetValues = [
    0.85,
    1.0,
    1.15,
    1.35,
  ];

  /// Returns the index of the current text scale value in [textScaleValues].
  int get textScaleIndex {
    final idx = textScaleValues.indexOf(textScaleFactor);
    return idx >= 0 ? idx : 1; // default
  }

  /// Returns the index of the current touch target value in [touchTargetValues].
  int get touchTargetIndex {
    final idx = touchTargetValues.indexOf(touchTargetScale);
    return idx >= 0 ? idx : 1; // default
  }

  AccessibilitySettings copyWith({
    double? textScaleFactor,
    bool? highContrastMode,
    double? ttsSpeed,
    double? touchTargetScale,
    bool? reduceMotion,
    bool? voiceInputMode,
    bool? researchConsent,
  }) {
    return AccessibilitySettings(
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      highContrastMode: highContrastMode ?? this.highContrastMode,
      ttsSpeed: ttsSpeed ?? this.ttsSpeed,
      touchTargetScale: touchTargetScale ?? this.touchTargetScale,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      voiceInputMode: voiceInputMode ?? this.voiceInputMode,
      researchConsent: researchConsent ?? this.researchConsent,
    );
  }
}
