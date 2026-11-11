import 'dart:async';
import 'dart:ui' show PlatformDispatcher, Rect, Size;

import 'package:flutter/services.dart' show SystemNavigator;
import 'package:owghat_lib/owghat_lib.dart';
import 'package:window_manager/window_manager.dart';

/// [WindowHost] on `window_manager` (the native `Window` API).
///
/// Every close request is cancelled and reported as
/// [WindowEventKind.closeRequested]: the app decides whether to hide to the
/// tray or quit, and [quit] is the only call that really closes the window.
class WindowManagerHost implements WindowHost {
  /// Creates the host.
  WindowManagerHost();

  final StreamController<WindowEventKind> _events =
      StreamController<WindowEventKind>.broadcast();

  Window? _window;
  bool _quitting = false;

  @override
  Stream<WindowEventKind> get events => _events.stream;

  Window? get _target => _window ??= WindowManager.instance.getCurrent();

  @override
  Future<void> initialize({
    required double minWidth,
    required double minHeight,
    required double defaultWidth,
    required double defaultHeight,
    WindowBounds? savedBounds,
  }) async {
    final window = _target;
    if (window == null) {
      throw StateError('There is no native window to manage');
    }
    window.minimumSize = Size(minWidth, minHeight).toNative();
    if (savedBounds != null && _isOnScreen(savedBounds)) {
      window.bounds = Rect.fromLTWH(
        savedBounds.x,
        savedBounds.y,
        savedBounds.width,
        savedBounds.height,
      ).toNative();
    } else {
      window
        ..setSize(Size(defaultWidth, defaultHeight).toNative(), false)
        ..center();
    }
    window.addListener(_onEvent);
  }

  @override
  Future<void> show() async {
    _target
      ?..show()
      ..focus();
  }

  @override
  Future<void> hide() async => _target?.hide();

  @override
  Future<void> focus() async => _target?.focus();

  @override
  Future<bool> isVisible() async => _target?.isVisible ?? false;

  @override
  Future<WindowBounds?> bounds() async {
    final window = _target;
    if (window == null) return null;
    final rect = window.bounds.toRect();
    return WindowBounds(
      x: rect.left,
      y: rect.top,
      width: rect.width,
      height: rect.height,
    );
  }

  @override
  Future<void> quit() async {
    _quitting = true;
    final window = _target;
    if (window == null || !window.close()) {
      // The window could not be closed natively: leave through the app.
      await SystemNavigator.pop();
    }
  }

  void _onEvent(WindowEvent event) {
    switch (event) {
      case WindowCloseRequestedEvent(:final request):
        if (_quitting) return; // Let the close go through.
        request.cancel();
        _events.add(WindowEventKind.closeRequested);
      case WindowMovedEvent():
      case WindowResizedEvent():
        _events.add(WindowEventKind.boundsChanged);
      default:
        break;
    }
  }

  /// A restored window must not land outside every monitor (for example after
  /// a monitor was unplugged). Without a display list here, the position has
  /// to fall within a generous box around the primary display size.
  bool _isOnScreen(WindowBounds bounds) {
    final displays = PlatformDispatcher.instance.displays;
    if (displays.isEmpty) return false;
    var width = 0.0;
    var height = 0.0;
    for (final display in displays) {
      width += display.size.width / display.devicePixelRatio;
      height = height < display.size.height / display.devicePixelRatio
          ? display.size.height / display.devicePixelRatio
          : height;
    }
    return bounds.x > -width &&
        bounds.x + bounds.width > 100 &&
        bounds.x < width - 100 &&
        bounds.y > -height &&
        bounds.y < height - 100;
  }
}
