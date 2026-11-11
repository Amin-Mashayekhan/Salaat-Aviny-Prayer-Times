import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/time/clock_warning.dart';
import 'package:owghat_lib/src/core/time/network_time_source.dart';
import 'package:owghat_lib/src/core/time/system_zone.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/clock/application/clock_warning_provider.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

import '../../support/test_data.dart';

class _FakeSource implements NetworkTimeSource {
  Duration offset = Duration.zero;
  Object? error;
  final List<String> hosts = [];

  @override
  Future<Duration> measureOffset(String host) async {
    hosts.add(host);
    final failure = error;
    if (failure is Exception) throw failure;
    return offset;
  }
}

class _FakeZone implements SystemZone {
  _FakeZone(this.offset);
  Duration offset;

  @override
  Duration localOffsetAt(DateTime instant) => offset;
}

void main() {
  const iran = Duration(hours: 3, minutes: 30);

  group('evaluateClockWarning', () {
    ClockWarning? eval({
      Duration? skew,
      Duration windows = iran,
      Duration expected = iran,
      bool automatic = true,
      bool isIran = true,
    }) => evaluateClockWarning(
      measuredSkew: skew,
      windowsOffset: windows,
      expectedOffset: expected,
      automaticZone: automatic,
      isIranZone: isIran,
    );

    test('nothing to say when everything agrees', () {
      expect(eval(), isNull);
      expect(eval(skew: const Duration(seconds: 29)), isNull);
    });

    test('D-1: a skew of 30 seconds or more', () {
      expect(eval(skew: const Duration(seconds: 30)), isA<ClockSkewWarning>());
      expect(eval(skew: const Duration(minutes: -5)), isA<ClockSkewWarning>());
    });

    test('D-2: Windows applies an hour the database does not', () {
      final w = eval(windows: const Duration(hours: 4, minutes: 30));
      expect(w, isA<StaleZoneRulesWarning>());
      final stale = w! as StaleZoneRulesWarning;
      expect(stale.windowsOffset, const Duration(hours: 4, minutes: 30));
      expect(stale.expectedOffset, iran);
    });

    test('D-2 does not apply to a user-typed fixed offset', () {
      expect(
        eval(windows: const Duration(hours: 4, minutes: 30), automatic: false),
        isNull,
      );
    });

    test('an hour of skew in Iran gets the D-2 wording', () {
      expect(
        eval(skew: const Duration(minutes: 60, seconds: 20)),
        isA<StaleZoneRulesWarning>(),
      );
      expect(
        eval(skew: const Duration(minutes: 60), isIran: false),
        isA<ClockSkewWarning>(),
      );
    });
  });

  group('ClockCorrectionController', () {
    late _FakeSource source;

    ProviderContainer makeContainer({
      NetworkTimeSettings network = const NetworkTimeSettings(),
      DateTime? now,
    }) {
      source = _FakeSource();
      final container = ProviderContainer(
        overrides: [
          networkTimeSourceProvider.overrideWithValue(source),
          systemClockProvider.overrideWithValue(
            Clock.fixed(now ?? DateTime.utc(2026, 11, 11, 12)),
          ),
          initialSettingsProvider.overrideWithValue(
            AppSettings(networkTime: network),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    test('does nothing while disabled', () {
      fakeAsync((async) {
        final c = makeContainer();
        c.read(clockCorrectionProvider);
        async.elapse(const Duration(hours: 13));
        expect(source.hosts, isEmpty);
        expect(c.read(effectiveCorrectionProvider), Duration.zero);
      });
    });

    test('checks at once and then every six hours when enabled', () {
      fakeAsync((async) {
        final c = makeContainer(
          network: const NetworkTimeSettings(enabled: true, host: 'h.example'),
        );
        source.offset = const Duration(seconds: 42);
        c.read(clockCorrectionProvider);
        async.flushMicrotasks();
        expect(source.hosts, ['h.example']);
        expect(
          c.read(clockCorrectionProvider).offset,
          const Duration(seconds: 42),
        );
        async.elapse(const Duration(hours: 6, minutes: 1));
        expect(source.hosts.length, 2);
        async.elapse(const Duration(hours: 6));
        expect(source.hosts.length, 3);
      });
    });

    test('the measured offset is not applied unless the user asked', () {
      fakeAsync((async) {
        final c = makeContainer(
          network: const NetworkTimeSettings(enabled: true),
        );
        source.offset = const Duration(seconds: 90);
        c.read(clockCorrectionProvider);
        async.flushMicrotasks();
        expect(c.read(clockCorrectionProvider).offset, isNotNull);
        expect(c.read(effectiveCorrectionProvider), Duration.zero);
        expect(c.read(clockProvider).now(), DateTime.utc(2026, 11, 11, 12));
      });
    });

    test('with correction on, the app clock is shifted', () {
      fakeAsync((async) {
        final c = makeContainer(
          network: const NetworkTimeSettings(
            enabled: true,
            applyCorrection: true,
          ),
        );
        source.offset = const Duration(seconds: 90);
        c.read(clockCorrectionProvider);
        async.flushMicrotasks();
        expect(
          c.read(effectiveCorrectionProvider),
          const Duration(seconds: 90),
        );
        expect(
          c.read(clockProvider).now(),
          DateTime.utc(2026, 11, 11, 12, 1, 30),
        );
      });
    });

    test('a network error is recorded and correction stays zero', () {
      fakeAsync((async) {
        final c = makeContainer(
          network: const NetworkTimeSettings(
            enabled: true,
            applyCorrection: true,
          ),
        );
        source.error = Exception('no network');
        c.read(clockCorrectionProvider);
        async.flushMicrotasks();
        final state = c.read(clockCorrectionProvider);
        expect(state.error, contains('no network'));
        expect(state.checking, isFalse);
        expect(state.offset, isNull);
        expect(c.read(effectiveCorrectionProvider), Duration.zero);
      });
    });

    test('turning the check off stops the timer', () {
      fakeAsync((async) {
        final c = makeContainer(
          network: const NetworkTimeSettings(enabled: true),
        );
        c.read(clockCorrectionProvider);
        async.flushMicrotasks();
        expect(source.hosts.length, 1);
        c
            .read(settingsProvider.notifier)
            .setNetworkTime(const NetworkTimeSettings());
        c.read(clockCorrectionProvider);
        async.elapse(const Duration(hours: 24));
        expect(source.hosts.length, 1);
      });
    });
  });

  group('clockWarningProvider', () {
    test('D-2 appears when Windows is an hour ahead of the database', () async {
      final repo = await loadTestRepository();
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(repo),
          systemClockProvider.overrideWithValue(
            Clock.fixed(DateTime.utc(2026, 7, 1, 12)),
          ),
          systemZoneProvider.overrideWithValue(
            _FakeZone(const Duration(hours: 4, minutes: 30)),
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(
        container.read(clockWarningProvider),
        isA<StaleZoneRulesWarning>(),
      );
    });

    test('no warning when Windows agrees', () async {
      final repo = await loadTestRepository();
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(repo),
          systemClockProvider.overrideWithValue(
            Clock.fixed(DateTime.utc(2026, 7, 1, 12)),
          ),
          systemZoneProvider.overrideWithValue(_FakeZone(iran)),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(clockWarningProvider), isNull);
    });

    test('a fixed-offset location never gets D-2', () async {
      final repo = await loadTestRepository();
      final container = ProviderContainer(
        overrides: [
          locationRepositoryProvider.overrideWithValue(repo),
          systemClockProvider.overrideWithValue(
            Clock.fixed(DateTime.utc(2026, 7, 1, 12)),
          ),
          systemZoneProvider.overrideWithValue(
            _FakeZone(const Duration(hours: 4, minutes: 30)),
          ),
          initialSettingsProvider.overrideWithValue(
            const AppSettings(
              locations: [
                SavedLocation.builtin(
                  id: 'city:1',
                  cityId: 1,
                  offset: LocationOffset.fixed(210),
                ),
              ],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      expect(container.read(clockWarningProvider), isNull);
    });
  });

  test('the real DartSystemZone answers for any instant', () {
    const zone = DartSystemZone();
    final offset = zone.localOffsetAt(DateTime.utc(2026, 7, 1, 12));
    expect(offset.inHours.abs(), lessThan(15));
  });

  test('the real source type exists and is constructible', () {
    expect(const NtpNetworkTimeSource(), isA<NetworkTimeSource>());
  });
}
