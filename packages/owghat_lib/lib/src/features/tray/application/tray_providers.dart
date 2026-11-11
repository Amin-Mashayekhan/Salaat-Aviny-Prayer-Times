import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/platform/tray_menu.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/azan/application/mute_providers.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/notifications/application/notice_texts.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/next_prayer.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/tray/domain/tray_menu_builder.dart';
import 'package:prayer_core/prayer_core.dart';

/// The UTC offset of the active location on the day of [moment].
Duration _offsetOf(Ref ref, PrayerMoment moment) {
  final location = ref.watch(activeLocationProvider);
  return ref
      .watch(zoneOffsetResolverProvider)
      .offsetFor(
        rule: location.offset,
        zoneId: location.zoneId,
        date: moment.date,
      );
}

TrayTime? _trayTime(Ref ref, PrayerMoment? moment) => moment == null
    ? null
    : TrayTime(
        prayer: moment.prayer,
        instant: moment.instant,
        offset: _offsetOf(ref, moment),
      );

/// The tray tooltip `<prayer> <time> · <remaining>`.
///
/// It is recomputed with the clock but only changes (and so only reaches the
/// tray) when the text changes: once a minute.
final trayTooltipProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider);
  final next = ref.watch(nextPrayerProvider);
  return buildTrayTooltip(
    texts: NoticeTexts.fromSettings(settings),
    next: _trayTime(ref, next.next),
    remaining: next.remaining,
  );
});

/// The tray menu model. Changes when the next prayer, the times of today, the
/// playing state, the mute, the locations or the language change.
final trayMenuProvider = Provider<TrayMenu>((ref) {
  final settings = ref.watch(settingsProvider);
  final location = ref.watch(activeLocationProvider);
  final resolver = ref.watch(zoneOffsetResolverProvider);
  final today = ref.watch(prayerDayProvider(ref.watch(todayProvider)));
  final next = ref.watch(nextPrayerProvider).next;
  final playing = ref.watch(azanPlaybackProvider.select((s) => s.playing));
  final muted = ref.watch(muteActiveProvider);
  final saved = ref.watch(savedLocationsProvider);

  final offset = resolver.offsetFor(
    rule: location.offset,
    zoneId: location.zoneId,
    date: today.date,
  );
  return buildTrayMenu(
    texts: NoticeTexts.fromSettings(settings),
    next: _trayTime(ref, next),
    today: [
      for (final prayer in Prayer.values)
        if (settings.display.shows(prayer) && today.instants[prayer] != null)
          TrayTime(
            prayer: prayer,
            instant: today.instants[prayer]!,
            offset: offset,
          ),
    ],
    playing: playing,
    muted: muted,
    locations: [
      for (final entry in saved)
        TrayLocation(id: entry.id, name: entry.nameIn(settings.language)),
    ],
    activeLocationId: location.id,
  );
});
