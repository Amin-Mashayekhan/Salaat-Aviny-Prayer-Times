import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_audio_output.dart';
import 'package:owghat_lib/src/core/platform/platform_paths.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/core/time/clock_warning.dart';
import 'package:owghat_lib/src/core/time/network_time_source.dart';
import 'package:owghat_lib/src/core/time/system_zone.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/diagnostics/application/app_version.dart';
import 'package:owghat_lib/src/features/diagnostics/application/diagnostics_providers.dart';
import 'package:owghat_lib/src/features/diagnostics/application/diagnostics_report.dart';
import 'package:owghat_lib/src/features/diagnostics/presentation/about_diagnostics_section.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/resolved_location.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/scheduler/domain/event_dispatcher.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_providers.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/fake_wake_services.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/app_harness.dart';
import '../../support/test_data.dart';

// 20 Aban 1405, 15:30 in Tehran.
final _now = DateTime.utc(2026, 11, 11, 12);

class _NoopDispatcher implements ScheduleDispatcher {
  @override
  Future<void> dispatch(ScheduledEvent event, CatchUpDecision decision) async {}
}

class _FakeSource implements NetworkTimeSource {
  Duration offset = const Duration(seconds: 45);

  @override
  Future<Duration> measureOffset(String host) async => offset;
}

class _Zone implements SystemZone {
  const _Zone(this.offset);
  final Duration offset;

  @override
  Duration localOffsetAt(DateTime instant) => offset;
}

/// A user whose settings hold everything that must stay out of a report.
final AppSettings _secretSettings = const AppSettings.defaults().copyWith(
  locations: const [
    SavedLocation.custom(
      id: 'home',
      name: 'Alice Secret Home',
      latitude: 35.689123,
      longitude: 51.389456,
      elevationMeters: 1189.7,
      zoneId: 'Asia/Tehran',
    ),
  ],
  activeLocationId: 'home',
  wakeAlarms: const [
    WakeAlarm(id: 'wake-private-id', label: 'Secret alarm label'),
  ],
  networkTime: const NetworkTimeSettings(host: 'ntp.secret.example'),
);

/// The containers of the running test.
final _containers = <ProviderContainer>[];

/// Like `testWidgets`, but ends by shutting down the controllers that own
/// timers (the wake-up controller's hourly re-check, the schedule engine):
/// Flutter reports them as pending before the harness disposes its container.
void diagTest(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    _containers.clear();
    await body(tester);
    await tester.pumpWidget(const SizedBox());
    for (final container in _containers) {
      container
        ..invalidate(wakeAlarmControllerProvider)
        ..invalidate(scheduleEngineProvider)
        ..invalidate(clockCorrectionProvider);
    }
    _containers.clear();
  });
}

void main() {
  late LocationRepository repo;

  setUpAll(() async {
    repo = await loadTestRepository();
  });

  group('report text', () {
    ResolvedLocation custom({LocationOffset? offset}) => ResolvedLocation(
      id: 'home',
      nameFa: 'Alice Secret Home',
      nameEn: 'Alice Secret Home',
      latitude: 35.689123,
      longitude: 51.389456,
      elevationMeters: 1189.7,
      zoneId: 'Asia/Tehran',
      offset: offset ?? const LocationOffset.automatic(),
      isCustom: true,
    );

    ScheduledEvent azan(Prayer prayer, DateTime at) => ScheduledEvent(
      kind: EventKind.azan,
      instantUtc: at,
      date: CivilDate(2026, 11, 11),
      prayer: prayer,
    );

    String report({
      ClockWarning? warning,
      WakeCapability? capability,
      List<ScheduledEvent>? events,
      String? logDirectory = r'C:\Users\Alice\AppData\Roaming\Owghat\logs',
      ResolvedLocation? location,
    }) => buildDiagnosticsReport(
      version: '1.2.3',
      nowUtc: _now,
      settings: _secretSettings,
      location: location ?? custom(),
      offsetNow: const Duration(hours: 3, minutes: 30),
      clockWarning: warning,
      wakeCapability: capability,
      armedWakeRequests: 2,
      events:
          events ??
          [
            azan(Prayer.maghrib, DateTime.utc(2026, 11, 11, 13, 50)),
            ScheduledEvent(
              kind: EventKind.wakeAlarm,
              instantUtc: DateTime.utc(2026, 11, 12, 0, 30, 15),
              date: CivilDate(2026, 11, 12),
              alarmId: 'wake-private-id',
            ),
          ],
      offsetAt: (_) => const Duration(hours: 3, minutes: 30),
      logDirectory: logDirectory,
    );

    test('rounds coordinates to two decimals and keeps nothing personal', () {
      final text = report();
      expect(text, contains('Latitude: 35.69'));
      expect(text, contains('Longitude: 51.39'));
      expect(text, contains('Elevation: 1190 m'));
      for (final secret in [
        '35.689',
        '51.389',
        '35.6891',
        '1189',
        'Alice',
        'Secret',
        'wake-private-id',
        'ntp.secret',
      ]) {
        expect(text, isNot(contains(secret)), reason: secret);
      }
      // No number anywhere has three or more decimals.
      expect(RegExp(r'\d\.\d{3,}').hasMatch(text), isFalse, reason: text);
      // The user name of the log folder is replaced.
      expect(text, contains(r'C:\Users\<user>\AppData\Roaming\Owghat\logs'));
    });

    test('lists the events with UTC and local instants', () {
      final text = report();
      expect(
        text,
        contains(
          '1. azan maghrib: 2026-11-11 13:50:00 UTC | '
          '2026-11-11 17:20:00 (UTC+03:30)',
        ),
      );
      expect(
        text,
        contains(
          '2. wake-up alarm: 2026-11-12 00:30:15 UTC | '
          '2026-11-12 04:00:15 (UTC+03:30)',
        ),
      );
      expect(text, contains('Next 2 scheduled events (UTC | local)'));
      expect(report(events: const []), contains('(nothing scheduled)'));
    });

    test('says what the clock and the wake-up check found', () {
      expect(report(), contains('Status: no problem found'));
      expect(
        report(warning: const ClockSkewWarning(Duration(seconds: -45))),
        contains('D-1 clock skew of about 45 s'),
      );
      expect(
        report(
          warning: const StaleZoneRulesWarning(
            windowsOffset: Duration(hours: 4, minutes: 30),
            expectedOffset: Duration(hours: 3, minutes: 30),
          ),
        ),
        contains(
          'D-2 Windows uses UTC+04:30 but the time-zone database says '
          'UTC+03:30',
        ),
      );
      expect(report(), contains('Capability: not checked'));
      final withCapability = report(
        capability: const WakeCapability(
          taskCreationOk: true,
          wakeTimersOnAc: WakeTimerPolicy.disabled,
          wakeTimersOnBattery: WakeTimerPolicy.enabled,
          inProcessTimerOk: true,
          modernStandby: false,
          lastError: r'secret path C:\Users\Alice\x',
        ),
      );
      expect(withCapability, contains('plugged-in=disabled'));
      expect(withCapability, contains('Issues: wakeTimersDisabledOnAc'));
      expect(withCapability, contains('2 wake requests registered'));
      // The raw error text never reaches the report.
      expect(withCapability, isNot(contains('secret path')));
    });

    test('a fixed offset and a missing log folder', () {
      final text = report(
        location: custom(offset: const LocationOffset.fixed(210)),
        logDirectory: null,
      );
      expect(text, contains('fixed offset 210 min east of UTC'));
      expect(text, contains('Log folder: not available'));
    });

    test('anonymisePath', () {
      expect(anonymisePath(null), isNull);
      expect(anonymisePath(''), isNull);
      expect(
        anonymisePath(r'C:\Users\Alice Smith\AppData\x'),
        r'C:\Users\<user>\AppData\x',
      );
      expect(anonymisePath('/home/bob/.config/x'), '/home/<user>/.config/x');
      expect(anonymisePath(r'D:\data\logs'), r'D:\data\logs');
    });

    test('the next ten events: future ones only, sorted, no rollovers', () {
      final events = [
        for (var i = 0; i < 14; i++)
          azan(Prayer.fajr, _now.add(Duration(hours: 14 - i))),
        ScheduledEvent(
          kind: EventKind.dayRollover,
          instantUtc: _now.add(const Duration(minutes: 1)),
          date: CivilDate(2026, 11, 11),
        ),
        azan(Prayer.dhuhr, _now.subtract(const Duration(hours: 1))),
        azan(Prayer.asr, _now),
      ];
      final next = nextDiagnosticEvents(events, _now);
      expect(next, hasLength(10));
      expect(next.first.instantUtc, _now.add(const Duration(hours: 1)));
      expect(next.last.instantUtc, _now.add(const Duration(hours: 10)));
      expect(next.any((e) => e.kind == EventKind.dayRollover), isFalse);
      expect(
        next.map((e) => e.instantUtc).toList(),
        [...next.map((e) => e.instantUtc)]..sort(),
      );
    });
  });

  // ---- the widget --------------------------------------------------------

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    AppSettings? settings,
    List<Override> overrides = const [],
    Size size = const Size(1200, 800),
    double textScale = 1,
    Brightness brightness = Brightness.light,
    Widget Function(Widget section)? wrap,
    bool settle = true,
    SystemZone zone = const AgreeingZone(),
    FakeAudioOutput? audio,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final base = settings ?? const AppSettings.defaults();
    final container = ProviderContainer(
      overrides: [
        locationRepositoryProvider.overrideWithValue(repo),
        initialSettingsProvider.overrideWithValue(base),
        nowProvider.overrideWithValue(_now),
        systemClockProvider.overrideWithValue(Clock.fixed(_now)),
        systemZoneProvider.overrideWithValue(zone),
        audioOutputProvider.overrideWithValue(audio ?? FakeAudioOutput()),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    _containers.add(container);
    const section = AboutDiagnosticsSection();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: Locale(base.language.name),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: buildTheme(brightness),
          home: Scaffold(body: wrap == null ? section : wrap(section)),
        ),
      ),
    );
    if (settle) await tester.pumpAndSettle();
    return container;
  }

  String text(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data!;

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  group('about', () {
    diagTest('name, version, notes', (tester) async {
      await pump(tester);
      expect(find.text('Salaat | Avini Prayer Times'), findsOneWidget);
      expect(text(tester, 'about-version'), contains('1.0.0'));
      expect(text(tester, 'about-version'), startsWith('نسخه‌ی'));
      expect(
        text(tester, 'about-font-note'),
        contains('SIL Open Font License'),
      );
      expect(text(tester, 'about-sound-note'), contains('CC0'));
      expect(find.text('درباره'), findsOneWidget);
    });

    diagTest('the version comes from appVersionProvider', (tester) async {
      await pump(
        tester,
        settings: englishSettings,
        overrides: [appVersionProvider.overrideWithValue('2.3.4')],
      );
      expect(text(tester, 'about-version'), contains('2.3.4'));
      expect(text(tester, 'about-version'), startsWith('Version'));
    });

    diagTest('the licences button opens the licence page', (tester) async {
      await pump(tester, settings: englishSettings);
      await tapKey(tester, 'about-licences');
      expect(find.byType(LicensePage), findsOneWidget);
    });

    diagTest('sits inside a scrolling parent as well as a bounded one', (
      tester,
    ) async {
      await pump(
        tester,
        size: const Size(800, 560),
        wrap: (section) => ListView(children: [section]),
      );
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('diag-copy')), findsOneWidget);
      await pump(tester, size: const Size(800, 560));
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const Key('diag-copy')));
      expect(tester.takeException(), isNull);
    });
  });

  group('scheduled events', () {
    diagTest('lists the next events with UTC and local instants', (
      tester,
    ) async {
      await pump(tester, settings: englishSettings);
      // 15:30 in Tehran: the Maghrib reminder (17:10) and azan (17:20) today,
      // then tomorrow's Fajr, Dhuhr and Maghrib with their reminders.
      expect(text(tester, 'diag-event-0'), '1. Reminder: Maghrib');
      expect(
        text(tester, 'diag-event-times-0'),
        'UTC ${Formatter.isolate('2026-11-11 13:40:00 UTC')} | local '
        '${Formatter.isolate('2026-11-11 17:10:00 (UTC+03:30)')}',
      );
      expect(text(tester, 'diag-event-1'), '2. Azan: Maghrib');
      expect(find.byKey(const Key('diag-event-7')), findsOneWidget);
      expect(find.byKey(const Key('diag-event-8')), findsNothing);
      expect(find.byKey(const Key('diag-events-empty')), findsNothing);
    });

    diagTest('Persian digits and wording follow the settings', (tester) async {
      await pump(tester);
      expect(text(tester, 'diag-event-0'), '۱. یادآوری اذان مغرب');
      expect(text(tester, 'diag-event-1'), '۲. اذان مغرب');
      expect(
        text(tester, 'diag-event-times-0'),
        contains('۲۰۲۶-۱۱-۱۱ ۱۳:۴۰:۰۰'),
      );
    });

    diagTest('reads the running engine, and follows alarm changes', (
      tester,
    ) async {
      final container = await pump(
        tester,
        settings: englishSettings,
        overrides: [
          eventDispatcherProvider.overrideWithValue(_NoopDispatcher()),
        ],
      );
      // The engine is the source: what it holds is what is shown.
      final engine = container.read(scheduleEngineProvider);
      expect(engine.events, isNotEmpty);
      expect(text(tester, 'diag-event-0'), '1. Reminder: Maghrib');
      expect(find.text('Wake-up alarm'), findsNothing);

      container
          .read(wakeAlarmControllerProvider.notifier)
          .addAlarm(const WakeAlarm(id: 'wake-test-1', hour: 16));
      await tester.pumpAndSettle();
      expect(text(tester, 'diag-event-0'), '1. Wake-up alarm');
      expect(
        text(tester, 'diag-event-times-0'),
        contains('2026-11-11 16:00:00 (UTC+03:30)'),
      );
      expect(text(tester, 'diag-event-1'), '2. Reminder: Maghrib');
    });

    diagTest('nothing scheduled says so', (tester) async {
      await pump(
        tester,
        settings: englishSettings.copyWith(
          azan: const AzanSettings(enabled: false),
          reminders: const ReminderSettings(minutesBefore: {}),
        ),
      );
      expect(find.byKey(const Key('diag-events-empty')), findsOneWidget);
    });
  });

  group('clock', () {
    diagTest('no network check: says the skew is not measured', (tester) async {
      await pump(tester, settings: englishSettings);
      expect(
        text(tester, 'diag-clock'),
        'No problem seen, but the network time check is off, so clock skew '
        'is not measured.',
      );
    });

    diagTest('D-1: clock skew', (tester) async {
      await pump(
        tester,
        settings: englishSettings.copyWith(
          networkTime: const NetworkTimeSettings(enabled: true),
        ),
        overrides: [networkTimeSourceProvider.overrideWithValue(_FakeSource())],
      );
      expect(text(tester, 'diag-clock'), 'The PC clock is off by about 45 s.');
    });

    diagTest('checked and fine', (tester) async {
      await pump(
        tester,
        settings: englishSettings.copyWith(
          networkTime: const NetworkTimeSettings(enabled: true),
        ),
        overrides: [
          networkTimeSourceProvider.overrideWithValue(
            _FakeSource()..offset = const Duration(seconds: 2),
          ),
        ],
      );
      expect(text(tester, 'diag-clock'), 'No clock problem found.');
    });

    diagTest('D-2: stale Windows zone rules', (tester) async {
      await pump(
        tester,
        settings: englishSettings,
        zone: const _Zone(Duration(hours: 4, minutes: 30)),
      );
      expect(
        text(tester, 'diag-clock'),
        startsWith('Windows shows a different time for this place'),
      );
    });
  });

  group('audio test', () {
    diagTest('plays the chime, can be stopped', (tester) async {
      final audio = FakeAudioOutput();
      await pump(tester, settings: englishSettings, audio: audio);
      await tapKey(tester, 'diag-audio');
      expect(audio.plays, hasLength(1));
      expect(audio.plays.single.sound, SoundRef.chime);
      expect(text(tester, 'diag-audio-result'), 'The test sound played.');
      expect(find.text('Stop'), findsOneWidget);
      await tapKey(tester, 'diag-audio');
      expect(audio.stopCount, greaterThan(0));
      expect(find.text('Play a test sound'), findsOneWidget);
    });

    diagTest('a failure is a plain message', (tester) async {
      final audio = FakeAudioOutput()..failAll = true;
      await pump(tester, settings: englishSettings, audio: audio);
      await tapKey(tester, 'diag-audio');
      expect(
        text(tester, 'diag-audio-result'),
        'The test sound could not be played. Check the speakers and the '
        'Windows volume.',
      );
      expect(find.textContaining('cannot play'), findsNothing);
    });
  });

  group('wake-up check', () {
    diagTest('not checked, then the result of the probe', (tester) async {
      final wake = FakeWakeTimerService(
        capability: const WakeCapability(
          taskCreationOk: true,
          wakeTimersOnAc: WakeTimerPolicy.disabled,
          wakeTimersOnBattery: WakeTimerPolicy.enabled,
          inProcessTimerOk: true,
          modernStandby: false,
        ),
      );
      await pump(
        tester,
        settings: englishSettings,
        overrides: [wakeTimerServiceProvider.overrideWithValue(wake)],
      );
      expect(text(tester, 'diag-wake-none'), 'Not checked yet.');
      expect(wake.probeCalls, 0);
      await tapKey(tester, 'diag-wake-check');
      expect(wake.probeCalls, 1);
      expect(text(tester, 'diag-wake-task'), 'Scheduled task: works');
      expect(text(tester, 'diag-wake-ac'), 'Wake timers, plugged in: off');
      expect(
        text(tester, 'diag-wake-battery'),
        'Wake timers, on battery: allowed',
      );
      expect(
        text(tester, 'diag-wake-inprocess'),
        'Timer inside the app: works',
      );
      expect(text(tester, 'diag-wake-modern'), 'Modern Standby: no');
      expect(
        text(tester, 'diag-wake-issue-wakeTimersDisabledOnAc'),
        'Windows has wake timers turned off while the PC is plugged in.',
      );
    });

    diagTest('Persian values', (tester) async {
      await pump(
        tester,
        overrides: [
          wakeTimerServiceProvider.overrideWithValue(FakeWakeTimerService()),
        ],
      );
      await tapKey(tester, 'diag-wake-check');
      expect(text(tester, 'diag-wake-task'), 'وظیفه‌ی زمان‌بندی‌شده: سالم');
      expect(text(tester, 'diag-wake-modern'), 'آماده‌به‌کار مدرن: نامشخص');
    });
  });

  group('log location', () {
    diagTest('shows the log folder when the paths are bound', (tester) async {
      final dir = Directory(r'C:\Users\Alice\AppData\Roaming\Owghat\Owghat');
      await pump(
        tester,
        settings: englishSettings,
        overrides: [
          platformPathsProvider.overrideWithValue(PlatformPaths(dir)),
        ],
      );
      final shown = tester
          .widget<SelectableText>(find.byKey(const Key('diag-log')))
          .data!;
      expect(shown, endsWith('logs'));
      expect(shown, contains('Owghat'));
    });

    diagTest('says so when there is none', (tester) async {
      await pump(tester, settings: englishSettings);
      expect(text(tester, 'diag-log'), 'Not available.');
    });
  });

  group('copy diagnostics', () {
    diagTest('copies a report without personal data', (tester) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pump(
        tester,
        settings: _secretSettings.copyWith(language: AppLanguage.en),
        overrides: [
          platformPathsProvider.overrideWithValue(
            PlatformPaths(Directory(r'C:\Users\Alice\AppData\Roaming\Owghat')),
          ),
        ],
      );
      await tapKey(tester, 'diag-copy');
      expect(
        text(tester, 'diag-copy-result'),
        'Copied to the clipboard. It has no names and no exact coordinates.',
      );
      final report = copied!;
      expect(report, startsWith('Salaat diagnostics'));
      expect(report, contains('Latitude: 35.69'));
      expect(report, contains('Longitude: 51.39'));
      for (final secret in [
        '35.689',
        '51.389',
        'Alice',
        'Secret',
        'wake-private-id',
        'ntp.secret',
      ]) {
        expect(report, isNot(contains(secret)), reason: secret);
      }
      // No coordinate (or any number) with more than two decimals.
      expect(RegExp(r'\d\.\d{3,}').hasMatch(report), isFalse, reason: report);
      // It holds what the screen shows: the version and the events.
      expect(report, contains('App version: 1.0.0'));
      expect(report, contains('1. reminder maghrib: 2026-11-11 13:40:00 UTC'));
      expect(report, contains('Alarms: 1 saved, 1 on'));
    });

    diagTest('a clipboard that fails is reported plainly', (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            throw PlatformException(code: 'nope', message: 'secret detail');
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await pump(tester, settings: englishSettings);
      await tapKey(tester, 'diag-copy');
      expect(text(tester, 'diag-copy-result'), 'Could not copy.');
      expect(find.textContaining('secret detail'), findsNothing);
    });
  });

  group('settings page', () {
    // The Settings screen does not mount this widget yet (the orchestrator
    // wires aboutSectionBuilderProvider); this keeps the report provider
    // honest on its own.
    test('the report provider holds the same text as the builder', () async {
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(repo),
          initialSettingsProvider.overrideWithValue(_secretSettings),
          nowProvider.overrideWithValue(_now),
          systemClockProvider.overrideWithValue(Clock.fixed(_now)),
          systemZoneProvider.overrideWithValue(const AgreeingZone()),
        ],
      );
      addTearDown(container.dispose);
      await container.read(diagnosticEventsProvider.future);
      final report = container.read(diagnosticsReportProvider);
      expect(report, contains('Latitude: 35.69'));
      expect(report, contains('Next 10 scheduled events'));
      expect(container.read(logDirectoryProvider), isNull);
    });
  });

  group('layout', () {
    for (final locale in ['fa', 'en']) {
      for (final dark in [false, true]) {
        for (final size in [const Size(1200, 800), const Size(800, 560)]) {
          for (final scale in [1.0, 2.0]) {
            diagTest('$locale ${dark ? 'dark' : 'light'} '
                '${size.width.toInt()}x${size.height.toInt()} x$scale '
                'has no overflow', (tester) async {
              await pump(
                tester,
                settings: (locale == 'fa' ? persianSettings : englishSettings)
                    .copyWith(
                      networkTime: const NetworkTimeSettings(enabled: true),
                    ),
                overrides: [
                  networkTimeSourceProvider.overrideWithValue(_FakeSource()),
                  platformPathsProvider.overrideWithValue(
                    PlatformPaths(
                      Directory(
                        r'C:\Users\Someone\AppData\Roaming\Owghat\Owghat',
                      ),
                    ),
                  ),
                  wakeTimerServiceProvider.overrideWithValue(
                    FakeWakeTimerService(
                      capability: const WakeCapability(
                        taskCreationOk: false,
                        wakeTimersOnAc: WakeTimerPolicy.disabled,
                        wakeTimersOnBattery: WakeTimerPolicy.importantOnly,
                        modernStandby: true,
                      ),
                    ),
                  ),
                ],
                size: size,
                textScale: scale,
                brightness: dark ? Brightness.dark : Brightness.light,
              );
              expect(tester.takeException(), isNull);
              await tapKey(tester, 'diag-wake-check');
              await tapKey(tester, 'diag-audio');
              await tapKey(tester, 'diag-copy');
              expect(tester.takeException(), isNull);
              expect(find.byKey(const Key('diag-wake-modern')), findsOneWidget);
            });
          }
        }
      }
    }
  });
}
