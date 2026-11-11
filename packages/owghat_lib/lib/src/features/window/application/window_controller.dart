import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/core/platform/window_host.dart';
import 'package:owghat_lib/src/core/utils/json_value.dart';
import 'package:owghat_lib/src/features/notifications/application/notice_texts.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/tray/application/tray_controller.dart';
import 'package:owghat_lib/src/features/window/domain/window_policy.dart';

/// Runs the main window: close-to-tray, remembered bounds, start hidden,
/// and bringing the window forward when a second copy is launched.
///
/// Everything it remembers goes to `state.json` under the key `window`
/// (never to the user settings).
class WindowController {
  /// Creates the controller over [_ref]; call [start] once.
  WindowController(this._ref);

  static final Logger _log = Logger('WindowController');

  /// `state.json` key holding bounds and the tray-hint flag.
  static const String stateKey = 'window';

  /// Smallest window width.
  static const double minWidth = 800;

  /// Smallest window height.
  static const double minHeight = 560;

  /// Width of a first-run window.
  static const double defaultWidth = 1040;

  /// Height of a first-run window.
  static const double defaultHeight = 680;

  final Ref _ref;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _visible = false;
  bool _quitting = false;

  /// Whether the window is currently shown.
  bool get visible => _visible;

  /// Prepares the window and starts listening. The window is shown unless
  /// [startHidden].
  Future<void> start({required bool startHidden}) async {
    final host = _ref.read(windowHostProvider);
    try {
      await host.initialize(
        minWidth: minWidth,
        minHeight: minHeight,
        defaultWidth: defaultWidth,
        defaultHeight: defaultHeight,
        savedBounds: _savedBounds(),
      );
    } on Object catch (error, stack) {
      _log.warning('Preparing the window failed', error, stack);
    }
    _subscriptions
      ..add(host.events.listen(_onWindowEvent))
      ..add(
        _ref.read(singleInstanceProvider).forwardedArgs.listen((_) {
          unawaited(show());
        }),
      );
    if (!startHidden) await show();
  }

  /// Shows the window and brings it to the front.
  Future<void> show() async {
    final host = _ref.read(windowHostProvider);
    try {
      await host.show();
      await host.focus();
      _visible = true;
    } on Object catch (error, stack) {
      _log.warning('Showing the window failed', error, stack);
    }
  }

  /// Hides the window to the tray.
  Future<void> hide() async {
    try {
      await _ref.read(windowHostProvider).hide();
      _visible = false;
    } on Object catch (error, stack) {
      _log.warning('Hiding the window failed', error, stack);
    }
  }

  /// Saves everything pending and closes the app.
  Future<void> quit() async {
    if (_quitting) return;
    _quitting = true;
    try {
      await _rememberBounds();
      await _ref.read(settingsRepositoryProvider)?.flush();
      await _ref.read(stateFileProvider).flush();
    } on Object catch (error, stack) {
      _log.warning('Saving before quit failed', error, stack);
    }
    try {
      await _ref.read(trayControllerProvider).dispose();
      await _ref.read(windowHostProvider).quit();
    } on Object catch (error, stack) {
      _log.warning('Quitting failed', error, stack);
    }
  }

  /// Cancels the subscriptions.
  void dispose() {
    for (final subscription in _subscriptions) {
      unawaited(subscription.cancel());
    }
    _subscriptions.clear();
  }

  void _onWindowEvent(WindowEventKind kind) {
    switch (kind) {
      case WindowEventKind.closeRequested:
        unawaited(_onCloseRequested());
      case WindowEventKind.boundsChanged:
        unawaited(_rememberBounds());
    }
  }

  Future<void> _onCloseRequested() async {
    final decision = decideClose(
      closeToTray: _ref.read(settingsProvider).window.closeToTray,
      trayReady: _ref.read(trayControllerProvider).ready,
    );
    switch (decision) {
      case CloseDecision.quit:
        await quit();
      case CloseDecision.hideToTray:
        await _rememberBounds();
        await hide();
        await _showTrayHintOnce();
    }
  }

  Future<void> _showTrayHintOnce() async {
    final state = _ref.read(stateFileProvider);
    final current = Json.map(state[stateKey]);
    if (!shouldShowTrayHint(
      alreadyShown: Json.boolean(current['trayHintShown'], fallback: false),
    )) {
      return;
    }
    state.set(stateKey, {...current, 'trayHintShown': true});
    try {
      await _ref
          .read(appNotifierProvider)
          .show(
            NoticeTexts.fromSettings(_ref.read(settingsProvider)).trayHint(),
          );
    } on Object catch (error, stack) {
      _log.warning('Showing the tray hint failed', error, stack);
    }
  }

  WindowBounds? _savedBounds() {
    final bounds = WindowBounds.fromJson(
      Json.map(_ref.read(stateFileProvider)[stateKey])['bounds'],
    );
    if (bounds == null ||
        !bounds.isUsable(minWidth: minWidth, minHeight: minHeight)) {
      return null;
    }
    return bounds;
  }

  Future<void> _rememberBounds() async {
    try {
      final host = _ref.read(windowHostProvider);
      if (!await host.isVisible()) return;
      final bounds = await host.bounds();
      if (bounds == null ||
          !bounds.isUsable(minWidth: minWidth, minHeight: minHeight)) {
        return;
      }
      final state = _ref.read(stateFileProvider);
      final current = Json.map(state[stateKey]);
      if (WindowBounds.fromJson(current['bounds']) == bounds) return;
      state.set(stateKey, {...current, 'bounds': bounds.toJson()});
    } on Object catch (error, stack) {
      _log.warning('Remembering the window bounds failed', error, stack);
    }
  }
}

/// The window controller. `bootstrap` calls `start` on it.
final windowControllerProvider = Provider<WindowController>((ref) {
  final controller = WindowController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});
