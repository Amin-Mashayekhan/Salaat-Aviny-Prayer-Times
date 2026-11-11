import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/core/utils/json_value.dart';

/// Position and size of the main window in logical pixels.
@immutable
class WindowBounds {
  /// Creates bounds.
  const WindowBounds({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  /// Reads the JSON form; null if it is not valid bounds.
  static WindowBounds? fromJson(Object? raw) {
    final map = Json.map(raw);
    final x = map['x'];
    final y = map['y'];
    final width = map['width'];
    final height = map['height'];
    if (x is! num || y is! num || width is! num || height is! num) return null;
    return WindowBounds(
      x: x.toDouble(),
      y: y.toDouble(),
      width: width.toDouble(),
      height: height.toDouble(),
    );
  }

  /// Left edge.
  final double x;

  /// Top edge.
  final double y;

  /// Width.
  final double width;

  /// Height.
  final double height;

  /// Whether these bounds are worth remembering and restoring: at least the
  /// minimum size, and not the far-off-screen position Windows reports for a
  /// minimised window.
  bool isUsable({required double minWidth, required double minHeight}) =>
      width >= minWidth &&
      height >= minHeight &&
      x > -10000 &&
      y > -10000 &&
      x < 100000 &&
      y < 100000;

  /// The JSON form.
  Map<String, Object?> toJson() => {
    'x': x,
    'y': y,
    'width': width,
    'height': height,
  };

  @override
  bool operator ==(Object other) =>
      other is WindowBounds &&
      other.x == x &&
      other.y == y &&
      other.width == width &&
      other.height == height;

  @override
  int get hashCode => Object.hash(x, y, width, height);

  @override
  String toString() => 'WindowBounds($x, $y, $width x $height)';
}

/// What happened to the window.
enum WindowEventKind {
  /// The user asked to close the window (title bar, Alt+F4). The window has
  /// NOT closed: the app decides whether to hide it or quit.
  closeRequested,

  /// The window was moved or resized.
  boundsChanged,
}

/// Controls the one top-level window.
///
/// The Windows implementation lives in the app package (`window_manager`).
abstract interface class WindowHost {
  /// Prepares the window: minimum size, initial bounds, and the interception
  /// of the close button (a close request is reported as
  /// [WindowEventKind.closeRequested] instead of closing the window).
  Future<void> initialize({
    required double minWidth,
    required double minHeight,
    required double defaultWidth,
    required double defaultHeight,
    WindowBounds? savedBounds,
  });

  /// Shows the window and brings it to the front.
  Future<void> show();

  /// Hides the window (the app keeps running in the tray).
  Future<void> hide();

  /// Gives the window keyboard focus.
  Future<void> focus();

  /// Whether the window is currently visible.
  Future<bool> isVisible();

  /// The current bounds, or null if they cannot be read.
  Future<WindowBounds?> bounds();

  /// Really closes the window, which ends the app.
  Future<void> quit();

  /// Close requests and bounds changes.
  Stream<WindowEventKind> get events;
}
