import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/core/platform/tray_host.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/azan/application/mute_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/tray/application/tray_providers.dart';
import 'package:owghat_lib/src/features/tray/domain/tray_ids.dart';
import 'package:owghat_lib/src/features/window/application/window_controller.dart';

/// Asset name of the tray icon (bundled by the app package).
const String trayIconAsset = 'assets/icons/tray.png';

/// Keeps the tray icon, its tooltip and its menu in step with the app state
/// and carries out what the user chooses there.
///
/// Mute and location choices are user actions, so they go through
/// `SettingsController` like any other change.
class TrayController {
  /// Creates the controller over [_ref]; call [start] once.
  TrayController(this._ref);

  static final Logger _log = Logger('TrayController');

  final Ref _ref;
  StreamSubscription<TrayEvent>? _events;
  bool _ready = false;

  /// Whether the icon is in the tray, so that hiding the window is safe.
  bool get ready => _ready;

  /// Puts the icon in the tray and starts following the state.
  Future<void> start() async {
    final host = _ref.read(trayHostProvider);
    try {
      await host.setIcon(trayIconAsset);
      _ready = true;
    } on Object catch (error, stack) {
      _log.warning('The tray icon could not be created', error, stack);
      return;
    }
    _events = host.events.listen(_onEvent);
    _ref
      ..listen<String>(
        trayTooltipProvider,
        (_, tooltip) => unawaited(_guard(() => host.setTooltip(tooltip))),
        fireImmediately: true,
      )
      ..listen(
        trayMenuProvider,
        (_, menu) => unawaited(_guard(() => host.setMenu(menu))),
        fireImmediately: true,
      );
  }

  /// Removes the icon.
  Future<void> dispose() async {
    await _events?.cancel();
    _events = null;
    _ready = false;
    await _guard(() => _ref.read(trayHostProvider).dispose());
  }

  Future<void> _guard(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (error, stack) {
      _log.warning('A tray call failed', error, stack);
    }
  }

  void _onEvent(TrayEvent event) {
    switch (event.kind) {
      case TrayEventKind.iconClicked:
      case TrayEventKind.iconDoubleClicked:
        unawaited(_ref.read(windowControllerProvider).show());
      case TrayEventKind.menuItem:
        final id = event.menuItemId;
        if (id != null) unawaited(_guard(() => _run(id)));
    }
  }

  Future<void> _run(String id) async {
    final mute = _ref.read(muteActionsProvider);
    final window = _ref.read(windowControllerProvider);
    switch (id) {
      case TrayIds.stop:
        await _ref.read(azanPlaybackProvider.notifier).stop();
      case TrayIds.muteUntilNext:
        mute.untilNextAzan();
      case TrayIds.muteOneHour:
        mute.forDuration(const Duration(hours: 1));
      case TrayIds.muteOneDay:
        mute.forDuration(const Duration(hours: 24));
      case TrayIds.muteIndefinite:
        mute.indefinitely();
      case TrayIds.muteCancel:
        mute.cancel();
      case TrayIds.show:
        await window.show();
      case TrayIds.settings:
        _ref.read(destinationProvider.notifier).select(Destination.settings);
        await window.show();
      case TrayIds.quit:
        await window.quit();
      default:
        if (id.startsWith(TrayIds.locationPrefix)) {
          _ref
              .read(settingsProvider.notifier)
              .setActiveLocation(id.substring(TrayIds.locationPrefix.length));
        }
    }
  }
}

/// The tray controller. `bootstrap` calls `start` on it.
final trayControllerProvider = Provider<TrayController>((ref) {
  final controller = TrayController(ref);
  ref.onDispose(() => unawaited(controller._events?.cancel()));
  return controller;
});
