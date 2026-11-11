import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the main window is on screen. While it is hidden in the tray the
/// app has nothing to animate, so the clock ticks once a minute instead of
/// once a second (idle CPU about zero).
class WindowVisible extends Notifier<bool> {
  @override
  bool build() => true;

  /// Records the visibility reported by the window controller.
  // A method matches how the controller reports changes.
  // ignore: use_setters_to_change_properties
  void set({required bool visible}) => state = visible;
}

/// Provider of [WindowVisible].
final windowVisibleProvider = NotifierProvider<WindowVisible, bool>(
  WindowVisible.new,
);
