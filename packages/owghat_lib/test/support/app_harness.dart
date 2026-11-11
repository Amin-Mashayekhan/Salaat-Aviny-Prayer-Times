import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/app.dart';
import 'package:owghat_lib/src/core/time/system_zone.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// A fake Windows zone that always agrees with the database (Iran, no DST).
class AgreeingZone implements SystemZone {
  const AgreeingZone();

  @override
  Duration localOffsetAt(DateTime instant) =>
      const Duration(hours: 3, minutes: 30);
}

class _TestNow extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.utc(2026, 11, 11, 12);

  // A setter-style helper for tests.
  // ignore: use_setters_to_change_properties
  void set(DateTime value) => state = value;
}

final _testNowProvider = NotifierProvider<_TestNow, DateTime>(_TestNow.new);

/// An azan playback that reports a fixed state and records stop calls.
class FakePlayback extends AzanPlaybackController {
  FakePlayback(this.initial);
  final AzanPlaybackState initial;
  int stops = 0;

  @override
  AzanPlaybackState build() => initial;

  @override
  Future<void> stop() async {
    stops++;
    state = const AzanPlaybackState();
  }
}

/// The whole app in a test: fake time, real providers, a chosen window size,
/// text scale and theme.
class AppHarness {
  AppHarness._(this.container);

  /// The provider container behind the app.
  final ProviderContainer container;

  /// Moves the (fake) clock to [now] (UTC) and pumps one frame.
  Future<void> setNow(WidgetTester tester, DateTime now) async {
    container.read(_testNowProvider.notifier).set(now);
    await tester.pump();
  }

  /// The settings controller.
  SettingsController get settings => container.read(settingsProvider.notifier);

  /// Current settings.
  AppSettings get current => container.read(settingsProvider);

  /// Builds and pumps the app.
  static Future<AppHarness> pump(
    WidgetTester tester, {
    required LocationRepository repository,
    DateTime? now,
    AppSettings? settings,
    Size size = const Size(1200, 800),
    double textScale = 1,
    Brightness brightness = Brightness.light,
    List<Override> overrides = const [],
    bool onboardingDone = true,
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
        locationRepositoryProvider.overrideWithValue(repository),
        initialSettingsProvider.overrideWithValue(
          base.copyWith(onboardingCompleted: onboardingDone),
        ),
        nowProvider.overrideWith((ref) => ref.watch(_testNowProvider)),
        systemZoneProvider.overrideWithValue(const AgreeingZone()),
        themeModeProvider.overrideWithValue(
          brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light,
        ),
        ...overrides,
      ],
    );
    addTearDown(container.dispose);
    if (now != null) {
      container.read(_testNowProvider.notifier).set(now);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const OwghatApp()),
    );
    await tester.pumpAndSettle();
    return AppHarness._(container);
  }
}

/// Settings for a Persian UI (the default).
const AppSettings persianSettings = AppSettings.defaults();

/// Settings for an English UI with Latin digits.
const AppSettings englishSettings = AppSettings(
  language: AppLanguage.en,
  digits: DigitStyle.latin,
);
