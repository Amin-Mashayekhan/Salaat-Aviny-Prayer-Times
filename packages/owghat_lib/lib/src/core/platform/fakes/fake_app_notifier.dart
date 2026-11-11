import 'dart:async';

import 'package:owghat_lib/src/core/platform/app_notifier.dart';

/// An [AppNotifier] that records the notifications it was asked to show.
class FakeAppNotifier implements AppNotifier {
  /// Creates the fake.
  FakeAppNotifier();

  final StreamController<NotificationAction> _actions =
      StreamController<NotificationAction>.broadcast();

  /// Every notification shown, in order.
  final List<NotificationSpec> shown = [];

  /// Makes every `show` throw (to test that failures are absorbed).
  bool failAll = false;

  @override
  Stream<NotificationAction> get actions => _actions.stream;

  @override
  Future<void> show(NotificationSpec spec) async {
    if (failAll) throw StateError('toast failed');
    shown.add(spec);
  }

  /// Simulates the user pressing a button.
  void press(NotificationActionKind kind, {String? tag}) =>
      _actions.add(NotificationAction(kind: kind, tag: tag));

  /// Closes the action stream.
  Future<void> dispose() => _actions.close();
}
