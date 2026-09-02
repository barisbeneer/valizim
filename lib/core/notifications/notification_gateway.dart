import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// What the OS currently allows.
enum NotificationPermission {
  /// Never asked. On iOS this is indistinguishable from "asked and denied"
  /// through the plugin alone, so the app tracks its own "have we asked" flag
  /// in settings and only reports [notRequested] before the first request.
  notRequested,
  granted,
  denied,
}

/// Thin seam over `flutter_local_notifications`.
///
/// Exists so scheduling logic can be unit-tested without a platform channel:
/// tests provide a fake, production provides [LocalNotificationGateway].
abstract interface class NotificationGateway {
  Future<void> initialize();

  /// Prompts the user. Only ever called straight after they switch a reminder
  /// on, never at launch (spec section 6).
  Future<bool> requestPermission();

  Future<NotificationPermission> permissionStatus();

  /// Opens the OS notification settings for this app, so a user who denied the
  /// prompt has a way back.
  Future<void> openSystemSettings();

  Future<void> schedule({
    required int id,
    required DateTime localDateTime,
    required String title,
    required String body,
    String? payload,
  });

  Future<void> cancel(int id);

  Future<void> cancelAll();

  Future<Set<int>> pendingIds();
}

/// Production implementation.
class LocalNotificationGateway implements NotificationGateway {
  LocalNotificationGateway([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } on Object catch (error, stack) {
      // An unknown zone id must not stop the app from starting. UTC is a poor
      // default for reminders, so this is reported rather than swallowed
      // silently, and scheduling still works - just anchored to UTC.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'valizim/notifications',
          context: ErrorDescription('resolving the local time zone'),
        ),
      );
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        // All three are false on purpose: permission is requested in context.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios == null) return false;
    final granted = await ios.requestPermissions(alert: true, sound: true);
    return granted ?? false;
  }

  @override
  Future<NotificationPermission> permissionStatus() async {
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios == null) return NotificationPermission.denied;
    final options = await ios.checkPermissions();
    if (options == null) return NotificationPermission.notRequested;
    return options.isEnabled
        ? NotificationPermission.granted
        : NotificationPermission.denied;
  }

  @override
  Future<void> openSystemSettings() async {
    if (!Platform.isIOS) return;
    await _plugin.openAppNotificationSettings();
  }

  @override
  Future<void> schedule({
    required int id,
    required DateTime localDateTime,
    required String title,
    required String body,
    String? payload,
  }) async {
    final scheduled = tz.TZDateTime.from(localDateTime, tz.local);
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      payload: payload,
      scheduledDate: scheduled,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> cancelAll() => _plugin.cancelAll();

  @override
  Future<Set<int>> pendingIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((PendingNotificationRequest r) => r.id).toSet();
  }
}
