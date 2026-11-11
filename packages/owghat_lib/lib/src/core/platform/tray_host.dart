import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/core/platform/tray_menu.dart';

/// What the user did with the tray icon.
enum TrayEventKind {
  /// Left click on the icon.
  iconClicked,

  /// Double click on the icon.
  iconDoubleClicked,

  /// A menu row was chosen; see [TrayEvent.menuItemId].
  menuItem,
}

/// A tray interaction.
@immutable
class TrayEvent {
  /// Creates an event.
  const TrayEvent(this.kind, {this.menuItemId});

  /// What happened.
  final TrayEventKind kind;

  /// The `TrayMenuItem.id` for [TrayEventKind.menuItem].
  final String? menuItemId;

  @override
  bool operator ==(Object other) =>
      other is TrayEvent &&
      other.kind == kind &&
      other.menuItemId == menuItemId;

  @override
  int get hashCode => Object.hash(kind, menuItemId);
}

/// The notification-area icon with its tooltip and menu.
///
/// The Windows implementation lives in the app package (`tray_manager`).
abstract interface class TrayHost {
  /// Shows the icon. [asset] is a bundled asset name such as
  /// `assets/icons/tray.png`.
  Future<void> setIcon(String asset);

  /// Sets the hover text.
  Future<void> setTooltip(String text);

  /// Replaces the context menu.
  Future<void> setMenu(TrayMenu menu);

  /// Removes the icon.
  Future<void> dispose();

  /// Clicks on the icon and on menu rows.
  Stream<TrayEvent> get events;
}
