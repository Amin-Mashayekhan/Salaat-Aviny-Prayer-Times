import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';

/// Keeps the Windows autostart entry in step with
/// `settings.window.launchAtStartup`.
///
/// The direction is always setting to Windows: this class never changes a
/// setting. A failure is logged and leaves the setting as the user chose it.
class AutostartController {
  /// Creates the controller over [_ref]; call [start] once.
  AutostartController(this._ref);

  static final Logger _log = Logger('AutostartController');

  final Ref _ref;

  /// Aligns Windows with the current setting, then follows later changes.
  Future<void> start() async {
    await apply(enabled: _ref.read(settingsProvider).window.launchAtStartup);
    _ref.listen<bool>(
      settingsProvider.select((s) => s.window.launchAtStartup),
      (previous, next) {
        if (previous != next) unawaited(apply(enabled: next));
      },
    );
  }

  /// Registers or removes the autostart entry so that it matches [enabled].
  Future<void> apply({required bool enabled}) async {
    try {
      final service = _ref.read(autostartServiceProvider);
      final current = await service.isEnabled();
      if (enabled) {
        // Enabling again also refreshes the path after the app was moved.
        await service.enable();
      } else if (current) {
        await service.disable();
      }
    } on Object catch (error, stack) {
      _log.warning('Updating the autostart entry failed', error, stack);
    }
  }
}

/// The autostart controller. `bootstrap` calls `start` on it.
final autostartControllerProvider = Provider<AutostartController>(
  AutostartController.new,
);
