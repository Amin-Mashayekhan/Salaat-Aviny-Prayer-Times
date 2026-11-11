import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/core/platform/app_notifier.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/notifications/application/notice_texts.dart';
import 'package:owghat_lib/src/features/scheduler/application/wake_alarm_hook.dart';
import 'package:owghat_lib/src/features/scheduler/domain/event_dispatcher.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

/// Carries out scheduled events for the real app: plays the azan, shows the
/// toasts and the reminder chime, and hands wake-up alarms to the wake-up
/// feature.
///
/// Nothing escapes [dispatch]: every step is guarded, a failing audio device
/// still leaves the toast, and a failing toast never blocks the sound.
class AppScheduleDispatcher implements ScheduleDispatcher {
  /// Creates the dispatcher over [_ref].
  AppScheduleDispatcher(this._ref);

  static final Logger _log = Logger('AppScheduleDispatcher');

  final Ref _ref;

  @override
  Future<void> dispatch(ScheduledEvent event, CatchUpDecision decision) async {
    // The engine starts inside the build of its provider and may dispatch an
    // overdue event right away; changing other providers (the playback
    // state) is not allowed while a provider is building, so step out of
    // that call stack first.
    await Future<void>.microtask(() {});
    try {
      switch (event.kind) {
        case EventKind.azan:
          await _azan(event, decision);
        case EventKind.reminder:
          await _reminder(event, decision);
        case EventKind.wakeAlarm:
          await _wakeAlarm(event, decision);
        case EventKind.dayRollover:
          break; // The engine rebuilds the schedule itself.
      }
    } on Object catch (error, stack) {
      _log.severe('Handling ${event.id} failed', error, stack);
    }
  }

  bool _plays(CatchUpDecision decision) =>
      decision == CatchUpDecision.fire || decision == CatchUpDecision.fireLate;

  Future<void> _azan(ScheduledEvent event, CatchUpDecision decision) async {
    final prayer = event.prayer;
    if (prayer == null) return;
    final settings = _ref.read(settingsProvider);
    final texts = NoticeTexts.fromSettings(settings);
    final time = _clock(texts, event, event.instantUtc);

    if (decision == CatchUpDecision.notifyMissed) {
      await _show(texts.missed(prayer: prayer, time: time));
      return;
    }
    if (!_plays(decision)) return;
    final azan = settings.azan;
    if (!azan.enabled || !(azan.perPrayer[prayer]?.enabled ?? false)) return;

    final now = _ref.read(clockProvider).now().toUtc();
    final muted = azan.mute.isActiveAt(now);
    var result = AzanPlayResult.failed;
    if (!muted) {
      try {
        result = await _ref
            .read(azanPlaybackProvider.notifier)
            .playAzan(prayer);
      } on Object catch (error, stack) {
        _log.severe('The azan of ${prayer.name} could not start', error, stack);
      }
    }

    final place = _ref.read(activeLocationProvider).nameIn(settings.language);
    await _show(
      texts.azan(
        prayer: prayer,
        place: place,
        time: time,
        withStop: !muted && result != AzanPlayResult.failed,
      ),
    );
    if (!muted) {
      if (result == AzanPlayResult.playedFallback) {
        await _show(texts.soundFallback());
      } else if (result == AzanPlayResult.failed) {
        await _show(texts.azanFailed());
      }
    }
  }

  Future<void> _reminder(ScheduledEvent event, CatchUpDecision decision) async {
    final prayer = event.prayer;
    final azanAt = event.relatedInstantUtc;
    if (prayer == null || azanAt == null || !_plays(decision)) return;
    final settings = _ref.read(settingsProvider);
    final now = _ref.read(clockProvider).now().toUtc();
    final left = azanAt.difference(now);
    if (left <= Duration.zero) return; // The azan itself is due.

    // The true time left, which is less than the configured lead time when
    // the reminder fires late (after sleep or a clock change).
    final minutes = ((left.inSeconds + 59) ~/ 60).clamp(1, 24 * 60);
    final texts = NoticeTexts.fromSettings(settings);
    final place = _ref.read(activeLocationProvider).nameIn(settings.language);
    await _show(
      texts.reminder(
        prayer: prayer,
        minutes: minutes,
        place: place,
        time: _clock(texts, event, azanAt),
      ),
    );
    if (settings.reminders.chime && !settings.azan.mute.isActiveAt(now)) {
      await _ref.read(azanPlaybackProvider.notifier).playChime();
    }
  }

  Future<void> _wakeAlarm(
    ScheduledEvent event,
    CatchUpDecision decision,
  ) async {
    if (!_plays(decision)) return;
    await _ref.read(wakeAlarmHandlerProvider)(event);
  }

  /// The wall-clock text of [instant] in the location of [event].
  String _clock(NoticeTexts texts, ScheduledEvent event, DateTime instant) {
    final location = _ref.read(activeLocationProvider);
    final offset = _ref
        .read(zoneOffsetResolverProvider)
        .offsetFor(
          rule: location.offset,
          zoneId: location.zoneId,
          date: event.date,
        );
    return texts.clock(instant, offset);
  }

  Future<void> _show(NotificationSpec spec) async {
    try {
      await _ref.read(appNotifierProvider).show(spec);
    } on Object catch (error, stack) {
      _log.warning('Showing "${spec.title}" failed', error, stack);
    }
  }
}
