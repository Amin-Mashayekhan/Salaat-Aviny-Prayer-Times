import 'package:flutter/foundation.dart';

/// What the platform the app runs on can do. The screens hide what does not
/// exist (a phone has no tray and no "start with Windows"), and the
/// scheduling picks who sounds the azan.
@immutable
class PlatformCapabilities {
  /// Creates the description; the defaults are those of the desktop.
  const PlatformCapabilities({
    this.desktopWindow = true,
    this.autostart = true,
    this.wakeTimers = true,
    this.osScheduledNotices = false,
  });

  /// Windows, macOS, Linux: a window, a tray icon, close-to-tray, autostart.
  static const PlatformCapabilities desktop = PlatformCapabilities();

  /// Android and iOS: no window or tray; the operating system shows the azan
  /// and reminder notifications at their time, even when the app is closed.
  static const PlatformCapabilities mobile = PlatformCapabilities(
    desktopWindow: false,
    autostart: false,
    wakeTimers: false,
    osScheduledNotices: true,
  );

  /// A browser tab: nothing runs when the tab is closed.
  static const PlatformCapabilities web = PlatformCapabilities(
    desktopWindow: false,
    autostart: false,
    wakeTimers: false,
  );

  /// A desktop window with a tray icon, close-to-tray and start-minimised.
  final bool desktopWindow;

  /// Starting together with the operating system.
  final bool autostart;

  /// Waking the computer from sleep (the Wake-up screen).
  final bool wakeTimers;

  /// The operating system schedules the azan and reminder notifications (with
  /// their sound) ahead of time, so they come even when the app is not
  /// running. The app then does not sound them itself.
  final bool osScheduledNotices;

  @override
  bool operator ==(Object other) =>
      other is PlatformCapabilities &&
      other.desktopWindow == desktopWindow &&
      other.autostart == autostart &&
      other.wakeTimers == wakeTimers &&
      other.osScheduledNotices == osScheduledNotices;

  @override
  int get hashCode =>
      Object.hash(desktopWindow, autostart, wakeTimers, osScheduledNotices);
}
