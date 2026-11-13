import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/core/platform/notice_scheduler.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/notifications/application/notice_texts.dart';
import 'package:owghat_lib/src/features/prayer_times/domain/prayer_day.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

final Logger _log = Logger('NoticePlanner');

/// How many days ahead the operating system gets the azan and reminder
/// notifications. If the app is not opened for longer than this, the
/// notifications stop until it is opened again.
const int plannedNoticeDays = 10;

/// The azan and reminder notifications of the next [days] days, from now on,
/// in the language, digits and clock of the settings. Only reads state.
///
/// The same rules as the in-app dispatcher apply: an azan switched off in the
/// settings gets no notification, a muted azan and a reminder without the
/// chime are silent.
List<PlannedNotice> buildPlannedNotices(
  Ref ref, {
  int days = plannedNoticeDays,
}) {
  final now = ref.read(clockProvider).now().toUtc();
  final settings = ref.read(settingsProvider);
  final location = ref.read(activeLocationProvider);
  final resolver = ref.read(zoneOffsetResolverProvider);
  final texts = NoticeTexts.fromSettings(settings);
  final place = location.nameIn(settings.language);

  final today = resolver.civilDateAt(
    now,
    resolver.currentOffset(
      rule: location.offset,
      zoneId: location.zoneId,
      instant: now,
    ),
  );
  final dates = [for (var i = 0; i < days; i++) today.addDays(i)];
  final offsets = {
    for (final date in dates)
      date: resolver.offsetFor(
        rule: location.offset,
        zoneId: location.zoneId,
        date: date,
      ),
  };
  final events = const ScheduleBuilder().build(
    instantsByDate: {
      for (final date in dates)
        date: computePrayerDay(
          date: date,
          location: location,
          calculation: settings.calculation,
          resolver: resolver,
        ).instants,
    },
    azanEnabled: settings.azan.enabled ? settings.azan.enabledPrayers : {},
    reminderMinutes: settings.reminders.minutesBefore,
  );

  final notices = <PlannedNotice>[];
  for (final event in events) {
    final prayer = event.prayer;
    if (prayer == null || !event.instantUtc.isAfter(now)) continue;
    final offset = offsets[event.date] ?? Duration.zero;
    final muted = settings.azan.mute.isActiveAt(event.instantUtc);
    switch (event.kind) {
      case EventKind.azan:
        notices.add(
          PlannedNotice(
            kind: PlannedNoticeKind.azan,
            instantUtc: event.instantUtc,
            spec: texts.azan(
              prayer: prayer,
              place: place,
              time: texts.clock(event.instantUtc, offset),
              withStop: false,
            ),
            sound: !muted,
          ),
        );
      case EventKind.reminder:
        final azanAt = event.relatedInstantUtc;
        if (azanAt == null) continue;
        notices.add(
          PlannedNotice(
            kind: PlannedNoticeKind.reminder,
            instantUtc: event.instantUtc,
            spec: texts.reminder(
              prayer: prayer,
              minutes: azanAt.difference(event.instantUtc).inMinutes,
              place: place,
              time: texts.clock(azanAt, offset),
            ),
            sound: settings.reminders.chime && !muted,
          ),
        );
      case EventKind.wakeAlarm:
      case EventKind.dayRollover:
        break;
    }
  }
  notices.sort((a, b) => a.instantUtc.compareTo(b.instantUtc));
  return notices;
}

/// Keeps the notifications planned with the operating system in step with
/// the settings. Only active where the platform schedules them
/// (`PlatformCapabilities.osScheduledNotices`); reading the provider starts it.
class NoticePlanner {
  NoticePlanner._(this._ref);

  final Ref _ref;
  bool _disposed = false;

  /// Hands the current plan to the operating system. Never throws.
  Future<void> replan() async {
    if (_disposed) return;
    try {
      final notices = buildPlannedNotices(_ref);
      await _ref.read(noticeSchedulerProvider).replaceAll(notices);
      _log.info('Planned ${notices.length} notifications');
    } on Object catch (error, stack) {
      _log.warning('Planning notifications failed', error, stack);
    }
  }
}

/// The running planner (null where the app sounds the azan itself).
final noticePlannerProvider = Provider<NoticePlanner?>((ref) {
  if (!ref.watch(platformCapabilitiesProvider).osScheduledNotices) return null;
  final planner = NoticePlanner._(ref);
  // Like the schedule engine, a change is read one microtask later, when the
  // derived providers are current.
  void replan() => unawaited(Future<void>.microtask(planner.replan));
  ref
    ..listen(settingsProvider, (_, _) => replan())
    ..listen(effectiveCorrectionProvider, (_, _) => replan())
    ..onDispose(() => planner._disposed = true);
  replan();
  return planner;
});
