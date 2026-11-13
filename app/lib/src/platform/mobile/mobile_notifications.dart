import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:owghat_lib/owghat_lib.dart';
import 'package:timezone/timezone.dart' as tz;

/// Notifications on Android with `flutter_local_notifications`: shown now
/// ([AppNotifier]) and planned ahead with the system ([NoticeScheduler]), so
/// the azan and the reminders come at their time even when the app is closed
/// and after the phone restarts.
///
/// The azan sound is a raw resource (`res/raw/azan`), because a notification
/// channel's sound is fixed when the channel is created. Each kind has a
/// silent twin for a muted azan or a reminder without the chime.
class MobileNotifications implements AppNotifier, NoticeScheduler {
  /// Creates the notifications.
  MobileNotifications({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<NotificationAction> _actions =
      StreamController<NotificationAction>.broadcast();
  Future<bool>? _ready;

  /// First id of planned notifications; immediate ones use ids below it.
  static const int _plannedBase = 1000;

  static const _azan = AndroidNotificationChannel(
    'azan',
    'Azan',
    description: 'The azan at prayer time',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('azan'),
  );
  static const _azanSilent = AndroidNotificationChannel(
    'azan_silent',
    'Azan (silent)',
    description: 'Prayer time while the azan is muted',
    importance: Importance.high,
    playSound: false,
  );
  static const _reminder = AndroidNotificationChannel(
    'reminder',
    'Reminders',
    description: 'Some minutes before the azan',
    sound: RawResourceAndroidNotificationSound('chime'),
  );
  static const _reminderSilent = AndroidNotificationChannel(
    'reminder_silent',
    'Reminders (silent)',
    description: 'Reminders without the chime',
    playSound: false,
  );
  static const _general = AndroidNotificationChannel(
    'general',
    'Messages',
    description: 'Other messages of the app',
    playSound: false,
  );

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<bool> _initialize() async {
    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
        onDidReceiveNotificationResponse: (_) => _actions.add(
          const NotificationAction(kind: NotificationActionKind.open),
        ),
      );
      final android = _android;
      for (final channel in [
        _azan,
        _azanSilent,
        _reminder,
        _reminderSilent,
        _general,
      ]) {
        await android?.createNotificationChannel(channel);
      }
      return true;
    } on Object catch (error, stack) {
      debugPrint('Notifications could not start: $error\n$stack');
      return false;
    }
  }

  Future<bool> get _started => _ready ??= _initialize();

  NotificationDetails _details(AndroidNotificationChannel channel) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: channel.importance,
          priority: channel.importance == Importance.high
              ? Priority.high
              : Priority.defaultPriority,
          playSound: channel.playSound,
          sound: channel.sound,
          category: channel == _azan || channel == _azanSilent
              ? AndroidNotificationCategory.reminder
              : null,
        ),
      );

  @override
  Stream<NotificationAction> get actions => _actions.stream;

  @override
  Future<void> show(NotificationSpec spec) async {
    try {
      if (!await _started) return;
      await _plugin.show(
        id: spec.tag.hashCode.abs() % _plannedBase,
        title: spec.title,
        body: spec.body,
        notificationDetails: _details(_general),
      );
    } on Object catch (error, stack) {
      debugPrint('Showing a notification failed: $error\n$stack');
    }
  }

  @override
  Future<void> replaceAll(List<PlannedNotice> notices) async {
    if (!await _started) return;
    final exact = await exactTimingAllowed();
    // Everything planned before goes; the new list is complete.
    await _plugin.cancelAll();
    for (var i = 0; i < notices.length; i++) {
      final notice = notices[i];
      final channel = switch (notice.kind) {
        PlannedNoticeKind.azan => notice.sound ? _azan : _azanSilent,
        PlannedNoticeKind.reminder =>
          notice.sound ? _reminder : _reminderSilent,
      };
      try {
        await _plugin.zonedSchedule(
          id: _plannedBase + i,
          scheduledDate: tz.TZDateTime.from(notice.instantUtc, tz.UTC),
          notificationDetails: _details(channel),
          androidScheduleMode: exact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
          title: notice.spec.title,
          body: notice.spec.body,
        );
      } on Object catch (error, stack) {
        debugPrint('Planning a notification failed: $error\n$stack');
      }
    }
  }

  @override
  Future<bool> requestPermissions() async {
    if (!await _started) return false;
    try {
      return await _android?.requestNotificationsPermission() ?? true;
    } on Object {
      return false;
    }
  }

  @override
  Future<bool> exactTimingAllowed() async {
    try {
      return await _android?.canScheduleExactNotifications() ?? true;
    } on Object {
      return false;
    }
  }

  @override
  Future<void> requestExactTiming() async {
    try {
      await _android?.requestExactAlarmsPermission();
    } on Object catch (error) {
      debugPrint('Asking for exact alarms failed: $error');
    }
  }
}
