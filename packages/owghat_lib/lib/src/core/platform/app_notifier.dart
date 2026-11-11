import 'package:flutter/foundation.dart';

/// A button a notification can offer.
enum NotificationActionKind {
  /// Stop the azan that is playing.
  stop,

  /// Show the app window.
  open,
}

/// A button on a notification, with its localised label.
@immutable
class NotificationButton {
  /// Creates a button.
  const NotificationButton({required this.kind, required this.label});

  /// What pressing the button does.
  final NotificationActionKind kind;

  /// The text on the button.
  final String label;

  @override
  bool operator ==(Object other) =>
      other is NotificationButton && other.kind == kind && other.label == label;

  @override
  int get hashCode => Object.hash(kind, label);
}

/// What a notification says.
@immutable
class NotificationSpec {
  /// Creates a notification.
  const NotificationSpec({
    required this.tag,
    required this.title,
    required this.body,
    this.buttons = const [],
    this.silent = true,
  });

  /// Groups notifications of one sort; a new one replaces the previous one
  /// with the same tag where the platform allows it.
  final String tag;

  /// First line.
  final String title;

  /// Second line.
  final String body;

  /// Optional buttons (at most two are used).
  final List<NotificationButton> buttons;

  /// No sound from the toast itself (the app plays its own sounds).
  final bool silent;

  @override
  bool operator ==(Object other) =>
      other is NotificationSpec &&
      other.tag == tag &&
      other.title == title &&
      other.body == body &&
      other.silent == silent &&
      listEquals(other.buttons, buttons);

  @override
  int get hashCode => Object.hash(tag, title, body, silent, buttons.length);

  @override
  String toString() => 'NotificationSpec($tag: $title | $body)';
}

/// The user pressed a button on a notification (or clicked its body, which
/// is reported as [NotificationActionKind.open]).
@immutable
class NotificationAction {
  /// Creates the event.
  const NotificationAction({required this.kind, this.tag});

  /// What was pressed.
  final NotificationActionKind kind;

  /// The tag of the notification, if known.
  final String? tag;
}

/// Shows desktop notifications (Windows toasts).
///
/// Only immediate notifications exist: on an unpackaged Windows app
/// scheduling and cancelling are unreliable, so the schedule engine does the
/// timing. [show] never throws for ordinary failures.
abstract interface class AppNotifier {
  /// Shows [spec] now.
  Future<void> show(NotificationSpec spec);

  /// Button presses and clicks on notifications shown by [show].
  Stream<NotificationAction> get actions;
}
