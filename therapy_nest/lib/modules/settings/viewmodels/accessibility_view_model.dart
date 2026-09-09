import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/accessibility_settings.dart';
import '../../../data/models/notification_settings.dart';
import '../../../data/storage/local_store.dart';

/// App-wide accessibility & notification state.
///
/// Persists all values through [LocalStore] (SharedPreferences).
/// Provided at the root level via [ChangeNotifierProvider].
class AccessibilityViewModel extends ChangeNotifier {
  AccessibilityViewModel(this._store);

  final LocalStore _store;
  final FlutterTts _tts = FlutterTts();

  AccessibilitySettings _accessibility = const AccessibilitySettings();
  NotificationSettings _notifications = const NotificationSettings();

  // ── Getters ──────────────────────────────────────────────────────────

  AccessibilitySettings get accessibility => _accessibility;
  NotificationSettings get notifications => _notifications;

  // ── Dark Mode ──────────────────────────────────────────────────────
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  // Convenience accessors used by app.dart / theme.dart
  double get textScaleFactor => _accessibility.textScaleFactor;
  bool get highContrastMode => _accessibility.highContrastMode;
  double get ttsSpeed => _accessibility.ttsSpeed;
  double get touchTargetScale => _accessibility.touchTargetScale;
  bool get reduceMotion => _accessibility.reduceMotion;
  bool get voiceInputMode => _accessibility.voiceInputMode;
  bool get researchConsent => _accessibility.researchConsent;

  // ── Load from disk ───────────────────────────────────────────────────

  /// Call once on creation (via `..loadSettings()` in the provider).
  Future<void> loadSettings() async {
    try {
      final textScale =
          await _store.getString(_kTextScale);
      final highContrast = await _store.getBool(_kHighContrast);
      final speed = await _store.getString(_kTtsSpeed);
      final touchScale = await _store.getString(_kTouchTarget);
      final motion = await _store.getBool(_kReduceMotion);
      final voice = await _store.getBool(_kVoiceInput);
      final research = await _store.getBool(_kResearchConsent);

      _isDarkMode = await _store.getBool(_kDarkMode) ?? false;

      _accessibility = AccessibilitySettings(
        textScaleFactor:
            textScale != null ? double.tryParse(textScale) ?? 1.0 : 1.0,
        highContrastMode: highContrast ?? false,
        ttsSpeed: speed != null ? double.tryParse(speed) ?? 1.0 : 1.0,
        touchTargetScale:
            touchScale != null ? double.tryParse(touchScale) ?? 1.0 : 1.0,
        reduceMotion: motion ?? false,
        voiceInputMode: voice ?? false,
        researchConsent: research ?? false,
      );

      // Notifications
      final dailyReminder = await _store.getBool(_kDailyReminder);
      final reminderHour = await _store.getInt(_kReminderHour);
      final reminderMinute = await _store.getInt(_kReminderMinute);
      final milestone = await _store.getBool(_kMilestone);
      final weekly = await _store.getBool(_kWeeklySummary);
      final inactivity = await _store.getBool(_kInactivity);

      _notifications = NotificationSettings(
        dailyReminder: dailyReminder ?? true,
        dailyReminderTime: TimeOfDay(
          hour: reminderHour ?? 9,
          minute: reminderMinute ?? 0,
        ),
        milestoneNotifications: milestone ?? true,
        weeklySummary: weekly ?? true,
        inactivityReminder: inactivity ?? true,
      );

      AppColors.isHighContrast = _accessibility.highContrastMode;
      AppColors.isDarkMode = _isDarkMode;
      AppDimens.touchScale = _accessibility.touchTargetScale;

      notifyListeners();
      AppLogger.info('Accessibility settings loaded', tag: 'AccessibilityVM');
    } catch (e) {
      AppLogger.error('Failed to load accessibility settings: $e',
          tag: 'AccessibilityVM');
    }
  }

  // ── Dark Mode Setter ────────────────────────────────────────────────

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    AppColors.isDarkMode = value;
    await _store.setBool(_kDarkMode, value);
    notifyListeners();
  }

  /// Toggle dark mode on/off.
  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }

  // ── Accessibility Setters ────────────────────────────────────────────

  Future<void> setTextScaleFactor(double value) async {
    _accessibility = _accessibility.copyWith(textScaleFactor: value);
    await _store.setString(_kTextScale, value.toString());
    notifyListeners();
  }

  Future<void> setHighContrastMode(bool value) async {
    _accessibility = _accessibility.copyWith(highContrastMode: value);
    AppColors.isHighContrast = value;
    await _store.setBool(_kHighContrast, value);
    notifyListeners();
  }

  Future<void> setTtsSpeed(double value) async {
    _accessibility = _accessibility.copyWith(ttsSpeed: value);
    await _store.setString(_kTtsSpeed, value.toString());
    notifyListeners();
  }

  Future<void> setTouchTargetScale(double value) async {
    _accessibility = _accessibility.copyWith(touchTargetScale: value);
    AppDimens.touchScale = value;
    await _store.setString(_kTouchTarget, value.toString());
    notifyListeners();
  }

  Future<void> setReduceMotion(bool value) async {
    _accessibility = _accessibility.copyWith(reduceMotion: value);
    await _store.setBool(_kReduceMotion, value);
    notifyListeners();
  }

  Future<void> setVoiceInputMode(bool value) async {
    _accessibility = _accessibility.copyWith(voiceInputMode: value);
    await _store.setBool(_kVoiceInput, value);
    notifyListeners();
  }

  Future<void> setResearchConsent(bool value) async {
    _accessibility = _accessibility.copyWith(researchConsent: value);
    await _store.setBool(_kResearchConsent, value);
    notifyListeners();
  }

  /// Returns the calibrated speech rate for FlutterTts (Android standard baseline = 0.5).
  double get effectiveSpeechRate => (ttsSpeed * 0.5).clamp(0.1, 1.0);

  /// Scales an exercise's base speech rate by the user's TTS speed multiplier.
  double rateFor(double baseRate) => (baseRate * ttsSpeed).clamp(0.1, 1.0);

  /// Speak a sample sentence at the current TTS speed.
  Future<void> testTts() async {
    await _tts.setSpeechRate(effectiveSpeechRate);
    await _tts.speak(
        'This is how your text-to-speech will sound at this speed.');
  }

  // ── Notification Setters ─────────────────────────────────────────────

  Future<void> setDailyReminder(bool value) async {
    _notifications = _notifications.copyWith(dailyReminder: value);
    await _store.setBool(_kDailyReminder, value);
    notifyListeners();
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    _notifications = _notifications.copyWith(dailyReminderTime: time);
    await _store.setInt(_kReminderHour, time.hour);
    await _store.setInt(_kReminderMinute, time.minute);
    notifyListeners();
  }

  Future<void> setMilestoneNotifications(bool value) async {
    _notifications = _notifications.copyWith(milestoneNotifications: value);
    await _store.setBool(_kMilestone, value);
    notifyListeners();
  }

  Future<void> setWeeklySummary(bool value) async {
    _notifications = _notifications.copyWith(weeklySummary: value);
    await _store.setBool(_kWeeklySummary, value);
    notifyListeners();
  }

  Future<void> setInactivityReminder(bool value) async {
    _notifications = _notifications.copyWith(inactivityReminder: value);
    await _store.setBool(_kInactivity, value);
    notifyListeners();
  }

  // ── SharedPreferences Keys ───────────────────────────────────────────

  static const String _kTextScale = 'a11y_text_scale';
  static const String _kHighContrast = 'a11y_high_contrast';
  static const String _kTtsSpeed = 'a11y_tts_speed';
  static const String _kTouchTarget = 'a11y_touch_target';
  static const String _kReduceMotion = 'a11y_reduce_motion';
  static const String _kVoiceInput = 'a11y_voice_input';
  static const String _kResearchConsent = 'a11y_research_consent';
  static const String _kDailyReminder = 'notif_daily_reminder';
  static const String _kReminderHour = 'notif_reminder_hour';
  static const String _kReminderMinute = 'notif_reminder_minute';
  static const String _kMilestone = 'notif_milestone';
  static const String _kWeeklySummary = 'notif_weekly_summary';
  static const String _kInactivity = 'notif_inactivity';
  static const String _kDarkMode = 'a11y_dark_mode';

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}
