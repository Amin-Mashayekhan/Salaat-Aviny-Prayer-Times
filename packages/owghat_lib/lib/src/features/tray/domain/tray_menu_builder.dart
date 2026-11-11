import 'package:owghat_lib/src/core/platform/tray_menu.dart';
import 'package:owghat_lib/src/features/notifications/application/notice_texts.dart';
import 'package:owghat_lib/src/features/tray/domain/tray_ids.dart';
import 'package:prayer_core/prayer_core.dart';

/// One prayer time with the UTC offset of its day, for the tray.
class TrayTime {
  /// Creates a time.
  const TrayTime({
    required this.prayer,
    required this.instant,
    required this.offset,
  });

  /// Which prayer.
  final Prayer prayer;

  /// When (UTC).
  final DateTime instant;

  /// UTC offset of the location on that day, to show the local clock time.
  final Duration offset;
}

/// A saved location as the tray lists it.
class TrayLocation {
  /// Creates an entry.
  const TrayLocation({required this.id, required this.name});

  /// The saved-location id.
  final String id;

  /// The name in the UI language.
  final String name;
}

/// The tooltip `<prayer> <time> · <remaining>`, or just the app name when no
/// next time is known.
String buildTrayTooltip({
  required NoticeTexts texts,
  required TrayTime? next,
  required Duration remaining,
}) {
  if (next == null) return texts.l10n.appName;
  return texts.l10n.trayTooltip(
    texts.prayerName(next.prayer),
    texts.clock(next.instant, next.offset),
    texts.remaining(remaining),
  );
}

/// The tray menu for the given state, top to bottom as in
/// `docs/05-UI-UX-SPEC.md` section 5.
TrayMenu buildTrayMenu({
  required NoticeTexts texts,
  required TrayTime? next,
  required List<TrayTime> today,
  required bool playing,
  required bool muted,
  required List<TrayLocation> locations,
  required String? activeLocationId,
}) {
  final l10n = texts.l10n;
  return TrayMenu([
    if (next != null)
      TrayMenuItem(
        id: TrayIds.next,
        label: l10n.trayNextLine(
          texts.prayerName(next.prayer),
          texts.clock(next.instant, next.offset),
        ),
        enabled: false,
      ),
    for (final row in today)
      TrayMenuItem(
        id: '${TrayIds.timeRowPrefix}${row.prayer.name}',
        label: l10n.trayTimeRow(
          texts.prayerName(row.prayer),
          texts.clock(row.instant, row.offset),
        ),
        enabled: false,
      ),
    const TrayMenuSeparator(),
    if (playing) TrayMenuItem(id: TrayIds.stop, label: l10n.trayMenuStopAzan),
    TrayMenuItem(
      id: TrayIds.mute,
      label: muted ? l10n.trayMenuMuted : l10n.trayMenuMute,
      children: [
        TrayMenuItem(id: TrayIds.muteUntilNext, label: l10n.trayMuteUntilNext),
        TrayMenuItem(
          id: TrayIds.muteOneHour,
          label: l10n.trayMuteHours(texts.number(1)),
        ),
        TrayMenuItem(
          id: TrayIds.muteOneDay,
          label: l10n.trayMuteHours(texts.number(24)),
        ),
        TrayMenuItem(
          id: TrayIds.muteIndefinite,
          label: l10n.trayMuteIndefinite,
        ),
        TrayMenuItem(
          id: TrayIds.muteCancel,
          label: l10n.trayMuteCancel,
          enabled: muted,
        ),
      ],
    ),
    TrayMenuItem(
      id: TrayIds.location,
      label: l10n.trayMenuLocation,
      children: [
        for (final location in locations)
          TrayMenuItem(
            id: '${TrayIds.locationPrefix}${location.id}',
            label: location.name,
            checked: location.id == activeLocationId,
          ),
      ],
    ),
    const TrayMenuSeparator(),
    TrayMenuItem(id: TrayIds.show, label: l10n.trayMenuShow),
    TrayMenuItem(id: TrayIds.settings, label: l10n.trayMenuSettings),
    TrayMenuItem(id: TrayIds.quit, label: l10n.trayMenuQuit),
  ]);
}
