import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:owghat_lib/owghat_lib.dart';
import 'package:path/path.dart' as p;

/// [AppNotifier] on `flutter_local_notifications` for the desktop: Windows
/// toasts, Linux desktop notifications (libnotify) and macOS notifications.
///
/// Only immediate toasts are used: on an unpackaged Windows app scheduling
/// and cancelling are unreliable, so the schedule engine does the timing.
/// The plugin is initialised lazily on the first toast, so a second copy of
/// the app that exits at once never touches the toast registration.
class FlutterLocalNotifier implements AppNotifier {
  /// Creates the notifier.
  FlutterLocalNotifier({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  /// Display name of the app in the toast header.
  static const String appName = 'Salaat';

  /// The app user model id (company.product), used to attribute toasts.
  static const String appUserModelId = 'app.salaat.Salaat';

  /// GUID of the toast activation callback (fixed for this app).
  static const String activationGuid = '6b1f2c0e-7d5a-4f36-9a3b-2c1e8d4f7a90';

  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<NotificationAction> _actions =
      StreamController<NotificationAction>.broadcast();
  final Map<String, int> _ids = {};
  Future<bool>? _ready;

  @override
  Stream<NotificationAction> get actions => _actions.stream;

  @override
  Future<void> show(NotificationSpec spec) async {
    try {
      if (!await (_ready ??= _initialize())) return;
      final id = _ids.putIfAbsent(spec.tag, () => _ids.length + 1);
      await _plugin.show(
        id: id,
        title: spec.title,
        body: spec.body,
        // A click on the toast body reports "open" through the payload.
        payload: _encode(NotificationActionKind.open, spec.tag),
        notificationDetails: NotificationDetails(
          windows: WindowsNotificationDetails(
            audio: spec.silent ? WindowsNotificationAudio.silent() : null,
            actions: [
              for (final button in spec.buttons.take(2))
                WindowsAction(
                  content: button.label,
                  arguments: _encode(button.kind, spec.tag),
                ),
            ],
          ),
          linux: LinuxNotificationDetails(
            suppressSound: spec.silent,
            actions: [
              for (final button in spec.buttons.take(2))
                LinuxNotificationAction(
                  key: _encode(button.kind, spec.tag),
                  label: button.label,
                ),
            ],
          ),
          macOS: DarwinNotificationDetails(presentSound: !spec.silent),
        ),
      );
    } on Object catch (error, stack) {
      // A toast that cannot be shown must never disturb the schedule.
      debugPrint('Showing a notification failed: $error\n$stack');
    }
  }

  Future<bool> _initialize() async {
    try {
      final result = await _plugin.initialize(
        settings: InitializationSettings(
          linux: const LinuxInitializationSettings(defaultActionName: 'Open'),
          macOS: const DarwinInitializationSettings(),
          windows: WindowsInitializationSettings(
            appName: appName,
            appUserModelId: appUserModelId,
            guid: activationGuid,
            iconPath: _iconPath(),
          ),
        ),
        onDidReceiveNotificationResponse: _onResponse,
      );
      return result ?? false;
    } on Object catch (error, stack) {
      debugPrint('Initialising notifications failed: $error\n$stack');
      return false;
    }
  }

  /// The tray icon doubles as the toast icon.
  String? _iconPath() {
    final path = p.join(
      p.dirname(Platform.resolvedExecutable),
      'data',
      'flutter_assets',
      'assets',
      'icons',
      'tray.png',
    );
    return File(path).existsSync() ? path : null;
  }

  static String _encode(NotificationActionKind kind, String tag) =>
      '${kind.name}:$tag';

  void _onResponse(NotificationResponse response) {
    final text = response.actionId ?? response.payload;
    if (text == null || text.isEmpty) return;
    final separator = text.indexOf(':');
    final kindName = separator < 0 ? text : text.substring(0, separator);
    final tag = separator < 0 ? null : text.substring(separator + 1);
    for (final kind in NotificationActionKind.values) {
      if (kind.name == kindName) {
        _actions.add(NotificationAction(kind: kind, tag: tag));
        return;
      }
    }
  }
}
