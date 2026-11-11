import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/clock/application/clock_warning_provider.dart';
import 'package:owghat_lib/src/features/clock/application/local_offset_provider.dart';
import 'package:owghat_lib/src/features/clock/application/now_minute_provider.dart';
import 'package:owghat_lib/src/features/diagnostics/application/app_version.dart';
import 'package:owghat_lib/src/features/diagnostics/application/diagnostics_report.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_plan_providers.dart';
import 'package:prayer_core/prayer_core.dart';

/// The next scheduled events (azan, reminders, wake-up alarms), at most
/// [diagnosticsEventCount], read from the running schedule engine.
///
/// It is asynchronous on purpose: the engine rebuilds one microtask after a
/// change of settings, and this provider reads it one microtask after its own
/// inputs changed, so it never shows the list of before the change. Where the
/// engine cannot be created (no event dispatcher bound, as in a preview or a
/// test) the same events are built from the settings with
/// `buildScheduleEvents`, the function the engine itself uses.
final diagnosticEventsProvider = FutureProvider<List<ScheduledEvent>>((
  ref,
) async {
  // The same triggers that make the engine rebuild.
  ref
    ..watch(settingsProvider)
    ..watch(effectiveCorrectionProvider)
    ..watch(alarmOccurrencesProvider)
    ..watch(wakeBookkeepingProvider);
  final now = ref.watch(nowMinuteProvider);
  await Future<void>.microtask(() {});
  List<ScheduledEvent> events;
  try {
    events = ref.read(scheduleEngineProvider).events;
  } on Object {
    // Riverpod 3 wraps what a provider throws, so this is not a bare
    // StateError. The engine needs a dispatcher; without one, build the same
    // list.
    events = buildScheduleEvents(ref);
  }
  return nextDiagnosticEvents(events, now);
});

/// Where the log files are, or null when the platform paths are not bound.
final logDirectoryProvider = Provider<String?>((ref) {
  try {
    return ref.watch(platformPathsProvider).logDir.path;
  } on Object {
    // The runner binds the paths (an unbound provider throws, wrapped by
    // Riverpod 3); a preview or test may not.
    return null;
  }
});

/// The plain-text diagnostics report (no personal data; see
/// [buildDiagnosticsReport]).
final diagnosticsReportProvider = Provider<String>((ref) {
  final now = ref.watch(nowMinuteProvider);
  final offsetAt = ref.watch(localOffsetAtProvider);
  return buildDiagnosticsReport(
    version: ref.watch(appVersionProvider),
    nowUtc: now,
    settings: ref.watch(settingsProvider),
    location: ref.watch(activeLocationProvider),
    offsetNow: offsetAt(now),
    clockWarning: ref.watch(clockWarningProvider),
    wakeCapability: ref.watch(wakeCapabilityProvider),
    armedWakeRequests: ref.watch(
      wakeAlarmControllerProvider.select((s) => s.armed.length),
    ),
    events: ref.watch(diagnosticEventsProvider).value ?? const [],
    offsetAt: offsetAt,
    logDirectory: ref.watch(logDirectoryProvider),
  );
});
