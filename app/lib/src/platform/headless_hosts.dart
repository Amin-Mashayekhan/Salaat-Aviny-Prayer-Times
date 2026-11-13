import 'package:owghat_lib/owghat_lib.dart';

/// The window of a platform where the app does not manage one (a phone, a
/// browser tab): the system shows the app; nothing here does anything.
class SystemManagedWindow implements WindowHost {
  /// Creates it.
  const SystemManagedWindow();

  @override
  Future<void> initialize({
    required double minWidth,
    required double minHeight,
    required double defaultWidth,
    required double defaultHeight,
    WindowBounds? savedBounds,
  }) async {}

  @override
  Future<void> show() async {}

  @override
  Future<void> hide() async {}

  @override
  Future<void> focus() async {}

  @override
  Future<bool> isVisible() async => true;

  @override
  Future<WindowBounds?> bounds() async => null;

  @override
  Future<void> quit() async {}

  @override
  Stream<WindowEventKind> get events => const Stream.empty();
}

/// A platform without a tray icon.
class NoTray implements TrayHost {
  /// Creates it.
  const NoTray();

  @override
  Future<void> setIcon(String asset) async {}

  @override
  Future<void> setTooltip(String text) async {}

  @override
  Future<void> setMenu(TrayMenu menu) async {}

  @override
  Future<void> dispose() async {}

  @override
  Stream<TrayEvent> get events => const Stream.empty();
}

/// A platform where the app does not start with the system.
class NoAutostart implements AutostartService {
  /// Creates it.
  const NoAutostart();

  @override
  Future<bool> isEnabled() async => false;

  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

/// A platform that itself keeps the app to one copy.
class SystemSingleInstance implements SingleInstance {
  /// Creates it.
  const SystemSingleInstance();

  @override
  Future<bool> ensure(List<String> args) async => true;

  @override
  Stream<List<String>> get forwardedArgs => const Stream.empty();
}
