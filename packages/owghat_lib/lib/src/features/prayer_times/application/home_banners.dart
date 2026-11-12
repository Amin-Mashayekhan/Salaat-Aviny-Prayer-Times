import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/time/clock_warning.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/clock/application/clock_warning_provider.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/settings_reset_notice.dart';

/// A notice above the hero card of the home screen.
@immutable
sealed class HomeBanner {
  const HomeBanner();

  /// Identifies the banner for dismissal; a changed key is a new banner.
  String get key;
}

/// The azan is muted.
final class MutedBanner extends HomeBanner {
  /// Creates the banner. [until] is null for "until I turn it back on";
  /// [utcOffset] is the offset of the active location at [until].
  const MutedBanner({required this.until, required this.utcOffset});

  /// When the mute ends (UTC), or null if it lasts until turned off.
  final DateTime? until;

  /// UTC offset of the active location at [until].
  final Duration utcOffset;

  @override
  String get key => 'muted:${until?.toIso8601String() ?? 'indefinite'}';
}

/// The PC clock is off by [skew].
final class ClockSkewBanner extends HomeBanner {
  /// Creates the banner.
  const ClockSkewBanner(this.skew);

  /// Network time minus PC time.
  final Duration skew;

  @override
  String get key => 'skew';
}

/// Windows applies other offset rules than the bundled database.
final class StaleZoneBanner extends HomeBanner {
  /// Creates the banner.
  const StaleZoneBanner();

  @override
  String get key => 'stale-zone';
}

/// The settings file was unreadable and has been reset.
final class SettingsResetBanner extends HomeBanner {
  /// Creates the banner.
  const SettingsResetBanner();

  @override
  String get key => 'settings-reset';
}

/// Banners the user closed during this run (not persisted).
class DismissedBanners extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  /// Hides the banner with [key] until the app restarts.
  void dismiss(String key) => state = {...state, key};
}

/// Provider of the dismissed banner keys.
final dismissedBannersProvider =
    NotifierProvider<DismissedBanners, Set<String>>(DismissedBanners.new);

/// All banners that currently apply, highest priority first: azan muted,
/// clock skew, stale Windows zone rules, settings reset.
final activeBannersProvider = Provider<List<HomeBanner>>((ref) {
  final now = ref.watch(nowProvider);
  final mute = ref.watch(settingsProvider.select((s) => s.azan.mute));
  final warning = ref.watch(clockWarningProvider);
  final wasReset = ref.watch(settingsWasResetProvider);
  final location = ref.watch(activeLocationProvider);
  final resolver = ref.watch(zoneOffsetResolverProvider);
  return [
    if (mute.isActiveAt(now))
      MutedBanner(
        until: mute.indefinite ? null : mute.until,
        utcOffset: mute.indefinite || mute.until == null
            ? Duration.zero
            : resolver.currentOffset(
                rule: location.offset,
                zoneId: location.zoneId,
                instant: mute.until!,
              ),
      ),
    if (warning is ClockSkewWarning) ClockSkewBanner(warning.skew),
    if (warning is StaleZoneRulesWarning) const StaleZoneBanner(),
    if (wasReset) const SettingsResetBanner(),
  ];
});

/// The one banner to show: the first that is not dismissed.
final homeBannerProvider = Provider<HomeBanner?>((ref) {
  final dismissed = ref.watch(dismissedBannersProvider);
  for (final banner in ref.watch(activeBannersProvider)) {
    if (!dismissed.contains(banner.key)) return banner;
  }
  return null;
});
