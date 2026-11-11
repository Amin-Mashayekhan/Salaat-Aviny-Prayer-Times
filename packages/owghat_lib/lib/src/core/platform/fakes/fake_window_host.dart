import 'dart:async';

import 'package:owghat_lib/src/core/platform/window_host.dart';

/// A [WindowHost] that keeps its state in memory.
class FakeWindowHost implements WindowHost {
  /// Creates the fake.
  FakeWindowHost({this.currentBounds});

  final StreamController<WindowEventKind> _events =
      StreamController<WindowEventKind>.broadcast();

  /// Whether the window is visible.
  bool visible = false;

  /// Whether `quit` was called.
  bool quitCalled = false;

  /// Number of `focus` calls.
  int focusCount = 0;

  /// Whether `initialize` ran.
  bool initialized = false;

  /// Bounds passed to `initialize`.
  WindowBounds? restoredBounds;

  /// Bounds reported by `bounds`.
  WindowBounds? currentBounds;

  @override
  Stream<WindowEventKind> get events => _events.stream;

  @override
  Future<void> initialize({
    required double minWidth,
    required double minHeight,
    required double defaultWidth,
    required double defaultHeight,
    WindowBounds? savedBounds,
  }) async {
    initialized = true;
    restoredBounds = savedBounds;
  }

  @override
  Future<void> show() async => visible = true;

  @override
  Future<void> hide() async => visible = false;

  @override
  Future<void> focus() async => focusCount++;

  @override
  Future<bool> isVisible() async => visible;

  @override
  Future<WindowBounds?> bounds() async => currentBounds;

  @override
  Future<void> quit() async => quitCalled = true;

  /// Simulates the user pressing the close button.
  void requestClose() => _events.add(WindowEventKind.closeRequested);

  /// Simulates a move or resize to [bounds].
  void moveTo(WindowBounds bounds) {
    currentBounds = bounds;
    _events.add(WindowEventKind.boundsChanged);
  }

  /// Closes the event stream.
  Future<void> dispose() => _events.close();
}
