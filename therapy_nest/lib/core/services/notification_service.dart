import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../core/utils/logger.dart';
import '../../data/storage/local_store.dart';

/// Top-level background handler — must be a top-level function.
///
/// Called by FCM when the app is in the background or terminated.
/// No PHI is included in any notification payload.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.info(
    'Background FCM message: ${message.messageId}',
    tag: 'NotificationService',
  );
}

/// Manages push notifications via Firebase Cloud Messaging (FCM) and
/// local notifications via [flutter_local_notifications].
///
/// Notification types (all PHI-free):
/// 1. Daily Practice Reminder — scheduled at user's preferred time
/// 2. Milestone Achieved — one-shot on achievement unlock
/// 3. Weekly Progress Summary — Sunday 7 PM
/// 4. Inactivity Reminder — after 3+ days without a session
///
/// Permission is requested **after** the first session completes,
/// not at install time.
class NotificationService extends ChangeNotifier {
  NotificationService(this._store);

  final LocalStore _store;

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // ── Notification Channel IDs ────────────────────────────────────────
  static const String _channelDailyId = 'therapy_nest_daily';
  static const String _channelDailyName = 'Daily Reminder';
  static const String _channelMilestoneId = 'therapy_nest_milestone';
  static const String _channelMilestoneName = 'Milestone Achievements';
  static const String _channelWeeklyId = 'therapy_nest_weekly';
  static const String _channelWeeklyName = 'Weekly Summary';
  static const String _channelInactivityId = 'therapy_nest_inactivity';
  static const String _channelInactivityName = 'Inactivity Reminder';

  // ── Local Notification IDs ──────────────────────────────────────────
  static const int _notifIdDaily = 1001;
  static const int _notifIdWeekly = 1002;
  static const int _notifIdInactivity = 1003;
  static const int _notifIdMilestoneBase = 2000;

  // ── SharedPreferences Keys ──────────────────────────────────────────
  static const String _kPermissionRequested = 'notif_permission_requested';
  static const String _kFcmToken = 'notif_fcm_token';

  // ── Initialisation ──────────────────────────────────────────────────

  /// Initialises FCM, local notifications, and foreground handlers.
  ///
  /// Called once from [appProviders] during app startup.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialise timezone database
      tz.initializeTimeZones();

      // Initialise local notifications plugin
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );
      await _localNotif.initialize(initSettings);

      // Create Android notification channels
      if (Platform.isAndroid) {
        final androidPlugin =
            _localNotif.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelDailyId,
              _channelDailyName,
              importance: Importance.defaultImportance,
            ),
          );
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelMilestoneId,
              _channelMilestoneName,
              importance: Importance.high,
            ),
          );
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelWeeklyId,
              _channelWeeklyName,
              importance: Importance.defaultImportance,
            ),
          );
          await androidPlugin.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelInactivityId,
              _channelInactivityName,
              importance: Importance.defaultImportance,
            ),
          );
        }
      }

      // FCM foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // FCM token management
      final token = await _fcm.getToken();
      if (token != null) {
        await _store.setString(_kFcmToken, token);
        AppLogger.info('FCM token acquired', tag: 'NotificationService');
      }
      _fcm.onTokenRefresh.listen((newToken) {
        _store.setString(_kFcmToken, newToken);
        AppLogger.info(
          'FCM token refreshed',
          tag: 'NotificationService',
        );
      });

      _isInitialized = true;
      notifyListeners();
      AppLogger.info('NotificationService initialised', tag: 'NotificationService');
    } catch (e) {
      AppLogger.error(
        'NotificationService init failed',
        error: e,
        tag: 'NotificationService',
      );
    }
  }

  // ── Permission Request ──────────────────────────────────────────────

  /// Requests notification permission from the user.
  ///
  /// Called **after the first completed session** — never at install time.
  /// Stores a flag so it is not re-requested on every session.
  Future<void> requestPermission() async {
    final alreadyRequested = await _store.getBool(_kPermissionRequested);
    if (alreadyRequested == true) return;

    try {
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      AppLogger.info(
        'Notification permission: ${settings.authorizationStatus}',
        tag: 'NotificationService',
      );

      await _store.setBool(_kPermissionRequested, true);
    } catch (e) {
      AppLogger.error(
        'Permission request failed',
        error: e,
        tag: 'NotificationService',
      );
    }
  }

  /// Whether permission has already been requested.
  Future<bool> get hasRequestedPermission async =>
      (await _store.getBool(_kPermissionRequested)) ?? false;

  // ── Daily Reminder ──────────────────────────────────────────────────

  /// Schedules a daily local notification at the user's preferred time.
  ///
  /// Payload text: generic, no PHI.
  Future<void> scheduleDailyReminder(int hour, int minute) async {
    await cancelDailyReminder();

    // Calculate the next occurrence of the target time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _localNotif.zonedSchedule(
      _notifIdDaily,
      'Therapy Nest',
      "Time for your daily therapy practice! 🧠 Just 15 minutes makes a difference.",
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelDailyId,
          _channelDailyName,
          icon: '@mipmap/ic_launcher',
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    AppLogger.info(
      'Daily reminder scheduled at $hour:${minute.toString().padLeft(2, '0')}',
      tag: 'NotificationService',
    );
  }

  /// Cancels the daily reminder notification.
  Future<void> cancelDailyReminder() async {
    await _localNotif.cancel(_notifIdDaily);
  }

  // ── Weekly Summary ──────────────────────────────────────────────────

  /// Schedules a weekly local notification for Sunday at 7 PM.
  ///
  /// Payload text: generic encouragement, no PHI.
  Future<void> scheduleWeeklySummary() async {
    await cancelWeeklySummary();

    // Find next Sunday at 19:00
    final now = tz.TZDateTime.now(tz.local);
    var nextSunday = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      19,
      0,
    );
    while (nextSunday.weekday != DateTime.sunday) {
      nextSunday = nextSunday.add(const Duration(days: 1));
    }
    if (nextSunday.isBefore(now)) {
      nextSunday = nextSunday.add(const Duration(days: 7));
    }

    await _localNotif.zonedSchedule(
      _notifIdWeekly,
      'Therapy Nest — Weekly Summary',
      '📈 Your weekly progress summary is ready! Check your progress.',
      nextSunday,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelWeeklyId,
          _channelWeeklyName,
          icon: '@mipmap/ic_launcher',
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    AppLogger.info(
      'Weekly summary scheduled for Sunday 7 PM',
      tag: 'NotificationService',
    );
  }

  /// Cancels the weekly summary notification.
  Future<void> cancelWeeklySummary() async {
    await _localNotif.cancel(_notifIdWeekly);
  }

  // ── Milestone Notification ──────────────────────────────────────────

  /// Fires a one-shot local notification for a milestone / achievement unlock.
  ///
  /// No PHI — uses the achievement name only (e.g. "One Week Strong").
  Future<void> showMilestoneNotification(String milestoneName) async {
    final notifId = _notifIdMilestoneBase +
        milestoneName.hashCode.abs() % 1000;

    await _localNotif.show(
      notifId,
      'Therapy Nest — Achievement Unlocked! 🏆',
      '🎉 New milestone: $milestoneName',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelMilestoneId,
          _channelMilestoneName,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );

    AppLogger.info(
      'Milestone notification shown: $milestoneName',
      tag: 'NotificationService',
    );
  }

  // ── Inactivity Reminder ─────────────────────────────────────────────

  /// Schedules an inactivity reminder 3 days from now.
  ///
  /// Should be called after every session ends to reset the timer.
  /// Payload: generic "we miss you" text, no PHI.
  Future<void> scheduleInactivityReminder() async {
    await cancelInactivityReminder();

    final triggerDate = tz.TZDateTime.now(tz.local).add(
      const Duration(days: 3),
    );

    await _localNotif.zonedSchedule(
      _notifIdInactivity,
      'Therapy Nest',
      "Missing you! Your practice is ready when you are.",
      triggerDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelInactivityId,
          _channelInactivityName,
          icon: '@mipmap/ic_launcher',
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    AppLogger.info(
      'Inactivity reminder scheduled for ${triggerDate.toIso8601String()}',
      tag: 'NotificationService',
    );
  }

  /// Cancels the inactivity reminder.
  Future<void> cancelInactivityReminder() async {
    await _localNotif.cancel(_notifIdInactivity);
  }

  // ── FCM Foreground Handler ──────────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    AppLogger.info(
      'Foreground FCM message: ${message.notification?.title}',
      tag: 'NotificationService',
    );

    // Show as local notification so the user sees it while in-app
    final notification = message.notification;
    if (notification != null) {
      _localNotif.show(
        notification.hashCode,
        notification.title ?? 'Therapy Nest',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelMilestoneId,
            _channelMilestoneName,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    }
  }
}
