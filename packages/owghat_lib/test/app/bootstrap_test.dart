import 'dart:convert';
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/app.dart';
import 'package:owghat_lib/src/app/bootstrap.dart';
import 'package:owghat_lib/src/app/startup_info.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_audio_output.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_simple_services.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_tray_host.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_window_host.dart';
import 'package:owghat_lib/src/core/platform/launch_args.dart';
import 'package:owghat_lib/src/core/platform/platform_services.dart';
import 'package:owghat_lib/src/core/platform/window_host.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/settings_reset_notice.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/tray/application/tray_controller.dart';
import 'package:prayer_core/prayer_core.dart';

/// Reads the bundled assets from disk (tests run in the package folder).
Future<String> _diskAssets(String path) =>
    File(path.replaceFirst('packages/owghat_lib/', '')).readAsString();

/// A window host that records what had already happened when it was set up.
class _OrderWindow extends FakeWindowHost {
  _OrderWindow(this.audio);

  final FakeAudioOutput audio;
  int playsWhenInitialized = -1;

  @override
  Future<void> initialize({
    required double minWidth,
    required double minHeight,
    required double defaultWidth,
    required double defaultHeight,
    WindowBounds? savedBounds,
  }) {
    playsWhenInitialized = audio.plays.length;
    return super.initialize(
      minWidth: minWidth,
      minHeight: minHeight,
      defaultWidth: defaultWidth,
      defaultHeight: defaultHeight,
      savedBounds: savedBounds,
    );
  }
}

void main() {
  late Directory dir;
  late FakeAudioOutput audio;
  late FakeWindowHost window;
  late FakeTrayHost tray;
  late FakeAutostartService autostart;
  late PlatformServices services;
  AppRuntime? runtime;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('owghat_boot');
    audio = FakeAudioOutput();
    window = FakeWindowHost();
    tray = FakeTrayHost();
    autostart = FakeAutostartService();
    services = PlatformServices.fake(
      supportDir: dir,
      assetLoader: _diskAssets,
      audio: audio,
      window: window,
      tray: tray,
      autostart: autostart,
    );
  });

  tearDown(() async {
    runtime?.container.dispose();
    runtime = null;
    await audio.dispose();
    try {
      dir.deleteSync(recursive: true);
    } on Object {
      // Best effort on Windows.
    }
  });

  Future<AppRuntime> prepare({
    List<String> args = const [],
    PlatformServices? override,
    DateTime? at,
  }) async {
    final started = await prepareApp(
      args: LaunchArgs.parse(args),
      services: override ?? services,
      extraOverrides: [
        if (at != null) systemClockProvider.overrideWithValue(Clock.fixed(at)),
      ],
    );
    return runtime = started;
  }

  void writeSettings(AppSettings settings) =>
      File('${dir.path}/settings.json')
          .writeAsStringSync(jsonEncode(settings.toJson()));

  test('first run: defaults, engine running, tray and window up', () async {
    final started = await prepare();
    final container = started.container;
    expect(started.info.firstRun, isTrue);
    expect(started.info.settingsWereReset, isFalse);
    expect(container.read(startupInfoProvider).firstRun, isTrue);
    expect(container.read(settingsProvider), const AppSettings.defaults());

    // The schedule engine is running: events for today and tomorrow exist.
    expect(container.read(scheduleEngineProvider).events, isNotEmpty);

    expect(tray.icon, trayIconAsset);
    expect(tray.menu, isNotNull);
    expect(window.initialized, isTrue);
    expect(window.visible, isTrue);
    expect(autostart.enableCalls, 0);
  });

  test('--minimized keeps the window hidden', () async {
    await prepare(args: const ['--minimized']);
    expect(window.initialized, isTrue);
    expect(window.visible, isFalse);
    expect(tray.icon, trayIconAsset);
  });

  test('--minimized is overruled by "start minimised" being off', () async {
    writeSettings(
      const AppSettings(window: WindowSettings(startMinimized: false)),
    );
    await prepare(args: const ['--minimized']);
    expect(window.visible, isTrue);
  });

  test('settings from disk drive the language and the theme', () async {
    writeSettings(
      const AppSettings(
        language: AppLanguage.en,
        theme: ThemeSetting.dark,
        onboardingCompleted: true,
      ),
    );
    final started = await prepare();
    final container = started.container;
    expect(started.info.firstRun, isFalse);
    expect(container.read(localeProvider), const Locale('en'));
    expect(container.read(themeModeProvider), ThemeMode.dark);

    // The UI follows later changes made through SettingsController.
    container.read(settingsProvider.notifier).setLanguage(AppLanguage.fa);
    container.read(settingsProvider.notifier).setTheme(ThemeSetting.light);
    expect(container.read(localeProvider), const Locale('fa'));
    expect(container.read(themeModeProvider), ThemeMode.light);
  });

  test('a broken settings file is set aside and defaults are used', () async {
    File('${dir.path}/settings.json').writeAsStringSync('{ not json');
    final started = await prepare();
    expect(started.info.settingsWereReset, isTrue);
    expect(started.container.read(settingsWasResetProvider), isTrue);
    expect(
      started.container.read(settingsProvider),
      const AppSettings.defaults(),
    );
    final leftovers = dir.listSync().map((f) => f.uri.pathSegments.last);
    expect(
      leftovers.any((name) => name.startsWith('settings.corrupt-')),
      isTrue,
    );
  });

  test('the engine starts before the window is set up', () async {
    final ordered = _OrderWindow(audio);
    // 11:48:01 in Tehran: the Dhuhr azan is due right now.
    final at = DateTime.utc(2026, 11, 11, 8, 18, 1);
    await prepare(
      at: at,
      override: PlatformServices.fake(
        supportDir: dir,
        assetLoader: _diskAssets,
        audio: audio,
        window: ordered,
        tray: tray,
        autostart: autostart,
      ),
    );
    expect(audio.plays, isNotEmpty, reason: 'the azan played at start');
    expect(ordered.playsWhenInitialized, greaterThan(0));
  });

  test('autostart is registered at start when the setting is on', () async {
    writeSettings(
      const AppSettings(window: WindowSettings(launchAtStartup: true)),
    );
    await prepare();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(autostart.enabled, isTrue);
  });

  test(
    'a second copy hands over and exits without starting anything',
    () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final onError = FlutterError.onError;
      addTearDown(() => FlutterError.onError = onError);
      final second = PlatformServices.fake(
        supportDir: dir,
        assetLoader: _diskAssets,
        audio: audio,
        window: window,
        tray: tray,
        singleInstance: FakeSingleInstance(primary: false),
      );
      await bootstrap(const ['--minimized'], second);
      expect(window.initialized, isFalse);
      expect(tray.icon, isNull);
      expect(File('${dir.path}/state.json').existsSync(), isFalse);
    },
  );

  test('a missing prayer asset loader is reported, not swallowed', () async {
    final broken = PlatformServices.fake(supportDir: dir);
    expect(
      () => prepareApp(args: const LaunchArgs(), services: broken),
      throwsA(isA<StateError>()),
    );
  });

  test('the schedule contains the five daily prayers of Tehran', () async {
    final started = await prepare();
    final azans = started.container
        .read(scheduleEngineProvider)
        .events
        .where((e) => e.kind == EventKind.azan)
        .map((e) => e.prayer)
        .toSet();
    expect(azans, containsAll({Prayer.fajr, Prayer.dhuhr, Prayer.maghrib}));
  });
}
