import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/azan/domain/next_azan.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// How long after an azan "mute until the next azan" stays on, so the azan
/// itself (even one fired a little late, within the catch-up grace of three
/// minutes) is still skipped.
const Duration muteSlackAfterAzan = Duration(minutes: 4);

/// Whether the quick mute is active right now.
///
/// Derived from `settings.azan.mute` and the clock: when a timed mute runs
/// out this turns false by itself, and nothing is ever written back to the
/// settings.
final muteActiveProvider = Provider<bool>((ref) {
  final mute = ref.watch(settingsProvider.select((s) => s.azan.mute));
  final now = ref.watch(nowProvider);
  return mute.isActiveAt(now);
});

/// The user-facing mute actions (tray menu, home screen, settings). Each one
/// is a user action, so each may write the settings through
/// `SettingsController.setMute`.
class MuteActions {
  /// Creates the actions over [_ref].
  MuteActions(this._ref);

  final Ref _ref;

  /// Mutes until the next azan has been skipped. When no azan is switched on
  /// this falls back to 24 hours.
  void untilNextAzan() {
    final now = _ref.read(clockProvider).now().toUtc();
    final next = nextAzanInstant(
      days: _ref.read(prayerDaysAroundTodayProvider),
      enabled: _ref.read(settingsProvider).azan.enabledPrayers,
      now: now,
    );
    if (next == null) {
      forDuration(const Duration(hours: 24));
      return;
    }
    _ref
        .read(settingsProvider.notifier)
        .setMute(MuteSetting(until: next.add(muteSlackAfterAzan)));
  }

  /// Mutes for [duration] from now.
  void forDuration(Duration duration) {
    final now = _ref.read(clockProvider).now().toUtc();
    _ref
        .read(settingsProvider.notifier)
        .setMute(MuteSetting(until: now.add(duration)));
  }

  /// Mutes until the user turns it off.
  void indefinitely() => _ref
      .read(settingsProvider.notifier)
      .setMute(const MuteSetting(indefinite: true));

  /// Turns the mute off.
  void cancel() =>
      _ref.read(settingsProvider.notifier).setMute(MuteSetting.none);
}

/// The mute actions.
final muteActionsProvider = Provider<MuteActions>(MuteActions.new);
