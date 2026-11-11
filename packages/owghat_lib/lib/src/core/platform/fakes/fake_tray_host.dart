import 'dart:async';

import 'package:owghat_lib/src/core/platform/tray_host.dart';
import 'package:owghat_lib/src/core/platform/tray_menu.dart';

/// A [TrayHost] that records what it was told.
class FakeTrayHost implements TrayHost {
  /// Creates the fake.
  FakeTrayHost();

  final StreamController<TrayEvent> _events =
      StreamController<TrayEvent>.broadcast();

  /// The icon asset last set.
  String? icon;

  /// The tooltip last set.
  String? tooltip;

  /// The menu last set.
  TrayMenu? menu;

  /// Every tooltip set, in order.
  final List<String> tooltips = [];

  /// Every menu set, in order.
  final List<TrayMenu> menus = [];

  /// Whether `dispose` was called.
  bool disposed = false;

  @override
  Stream<TrayEvent> get events => _events.stream;

  @override
  Future<void> setIcon(String asset) async => icon = asset;

  @override
  Future<void> setTooltip(String text) async {
    tooltip = text;
    tooltips.add(text);
  }

  @override
  Future<void> setMenu(TrayMenu value) async {
    menu = value;
    menus.add(value);
  }

  @override
  Future<void> dispose() async => disposed = true;

  /// Simulates a click on the icon.
  void clickIcon() => _events.add(const TrayEvent(TrayEventKind.iconClicked));

  /// Simulates choosing the menu row [id].
  void choose(String id) =>
      _events.add(TrayEvent(TrayEventKind.menuItem, menuItemId: id));

  /// Closes the event stream.
  Future<void> close() => _events.close();
}
