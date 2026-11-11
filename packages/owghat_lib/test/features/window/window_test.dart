import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/platform/app_notifier.dart';
import 'package:owghat_lib/src/core/platform/launch_args.dart';
import 'package:owghat_lib/src/core/platform/window_host.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/notifications/application/notification_actions.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/tray/application/tray_controller.dart';
import 'package:owghat_lib/src/features/window/application/autostart_controller.dart';
import 'package:owghat_lib/src/features/window/application/window_controller.dart';
import 'package:owghat_lib/src/features/window/domain/window_policy.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/platform_world.dart';
import '../../support/test_data.dart';

void main() {
  late LocationRepository repo;
  setUpAll(() async => repo = await loadTestRepository());

  group('window policy', () {
    test('closing hides only with close-to-tray AND a tray icon', () {
      expect(
        decideClose(closeToTray: true, trayReady: true),
        CloseDecision.hideToTray,
      );
      expect(
        decideClose(closeToTray: false, trayReady: true),
        CloseDecision.quit,
      );
      expect(
        decideClose(closeToTray: true, trayReady: false),
        CloseDecision.quit,
      );
      expect(
        decideClose(closeToTray: false, trayReady: false),
        CloseDecision.quit,
      );
    });

    test('starts hidden only for --minimized with start-minimised on', () {
      expect(
        startsHidden(minimizedArgument: true, startMinimizedSetting: true),
        isTrue,
      );
      expect(
        startsHidden(minimizedArgument: true, startMinimizedSetting: false),
        isFalse,
      );
      expect(
        startsHidden(minimizedArgument: false, startMinimizedSetting: true),
        isFalse,
      );
    });

    test('the tray hint is due until it has been shown once', () {
      expect(shouldShowTrayHint(alreadyShown: false), isTrue);
      expect(shouldShowTrayHint(alreadyShown: true), isFalse);
    });

    test('bounds are usable only at full size and on a sane position', () {
      const ok = WindowBounds(x: 100, y: 80, width: 1040, height: 680);
      const tiny = WindowBounds(x: 100, y: 80, width: 300, height: 200);
      const minimised = WindowBounds(
        x: -32000,
        y: -32000,
        width: 1040,
        height: 680,
      );
      expect(ok.isUsable(minWidth: 800, minHeight: 560), isTrue);
      expect(tiny.isUsable(minWidth: 800, minHeight: 560), isFalse);
      expect(minimised.isUsable(minWidth: 800, minHeight: 560), isFalse);
      expect(WindowBounds.fromJson(ok.toJson()), ok);
      expect(WindowBounds.fromJson({'x': 'a'}), isNull);
    });
  });

  group('launch arguments', () {
    test('--minimized and --wake are parsed, unknown ones ignored', () {
      expect(LaunchArgs.parse(const []), const LaunchArgs());
      expect(
        LaunchArgs.parse(const ['--minimized', '--wake', 'a1', '--x']),
        const LaunchArgs(minimized: true, wakeAlarmId: 'a1'),
      );
      expect(LaunchArgs.parse(const ['--wake=b2']).wakeAlarmId, 'b2');
      expect(LaunchArgs.parse(const ['--wake']).wakeAlarmId, isNull);
    });
  });

  group('window controller', () {
    PlatformWorld world({AppSettings? settings}) {
      final w = PlatformWorld(repo, settings: settings);
      addTearDown(w.dispose);
      return w;
    }

    test('starts visible and focused by default', () async {
      final w = world();
      await w.read(windowControllerProvider).start(startHidden: false);
      expect(w.window.initialized, isTrue);
      expect(w.window.visible, isTrue);
      expect(w.window.focusCount, 1);
    });

    test('starts hidden for --minimized', () async {
      final w = world();
      await w.read(windowControllerProvider).start(startHidden: true);
      expect(w.window.initialized, isTrue);
      expect(w.window.visible, isFalse);
    });

    test('restores remembered bounds, ignoring unusable ones', () async {
      final w = world();
      w.stateFile.set(WindowController.stateKey, {
        'bounds': const WindowBounds(
          x: 50,
          y: 60,
          width: 900,
          height: 700,
        ).toJson(),
      });
      await w.read(windowControllerProvider).start(startHidden: true);
      expect(
        w.window.restoredBounds,
        const WindowBounds(x: 50, y: 60, width: 900, height: 700),
      );

      final w2 = world();
      w2.stateFile.set(WindowController.stateKey, {
        'bounds': const WindowBounds(
          x: -32000,
          y: -32000,
          width: 900,
          height: 700,
        ).toJson(),
      });
      await w2.read(windowControllerProvider).start(startHidden: true);
      expect(w2.window.restoredBounds, isNull);
    });

    test('moving the window remembers its bounds in state.json', () async {
      final w = world();
      await w.read(windowControllerProvider).start(startHidden: false);
      const moved = WindowBounds(x: 10, y: 20, width: 1100, height: 700);
      w.window.moveTo(moved);
      await settle();
      final saved =
          w.stateFile[WindowController.stateKey]! as Map<String, Object?>;
      expect(WindowBounds.fromJson(saved['bounds']), moved);

      // A minimised window reports a far-off position: not remembered.
      w.window.moveTo(
        const WindowBounds(x: -32000, y: -32000, width: 1100, height: 700),
      );
      await settle();
      final again =
          w.stateFile[WindowController.stateKey]! as Map<String, Object?>;
      expect(WindowBounds.fromJson(again['bounds']), moved);
    });

    test(
      'close-to-tray hides the window and shows the hint only once',
      () async {
        final w = world();
        await w.read(trayControllerProvider).start();
        await w.read(windowControllerProvider).start(startHidden: false);

        w.window.requestClose();
        await settle();
        expect(w.window.visible, isFalse);
        expect(w.window.quitCalled, isFalse);
        expect(
          w.notifier.shown.single.body,
          'برنامه در کنار ساعت ویندوز فعال می‌ماند.',
        );
        expect(
          (w.stateFile[WindowController.stateKey]!
              as Map<String, Object?>)['trayHintShown'],
          isTrue,
        );

        await w.read(windowControllerProvider).show();
        w.window.requestClose();
        await settle();
        expect(w.window.visible, isFalse);
        expect(w.notifier.shown, hasLength(1));
      },
    );

    test('with close-to-tray off, closing quits', () async {
      final w = world(
        settings: const AppSettings(window: WindowSettings(closeToTray: false)),
      );
      await w.read(trayControllerProvider).start();
      await w.read(windowControllerProvider).start(startHidden: false);
      w.window.requestClose();
      await waitUntil(() => w.window.quitCalled);
      expect(w.window.quitCalled, isTrue);
      expect(w.notifier.shown, isEmpty);
    });

    test('without a tray icon, closing quits instead of hiding', () async {
      final w = world();
      await w.read(windowControllerProvider).start(startHidden: false);
      w.window.requestClose();
      await waitUntil(() => w.window.quitCalled);
      expect(w.window.quitCalled, isTrue);
    });

    test('quit writes the pending state to disk before closing', () async {
      final w = world();
      await w.read(windowControllerProvider).start(startHidden: false);
      w.stateFile.set('probe', 1);
      await w.read(windowControllerProvider).quit();
      expect(w.window.quitCalled, isTrue);
      final text = await File(
        '${w.tempDir.path}${Platform.pathSeparator}state.json',
      ).readAsString();
      expect(jsonDecode(text), containsPair('probe', 1));
    });

    test('a second launch brings the window forward', () async {
      final w = world();
      await w.read(windowControllerProvider).start(startHidden: true);
      expect(w.window.visible, isFalse);
      w.singleInstance.secondLaunch(const ['--something']);
      await settle();
      expect(w.window.visible, isTrue);
      expect(w.window.focusCount, 1);
    });
  });

  group('autostart', () {
    test(
      'enables at start when the setting is on, and follows changes',
      () async {
        final w = PlatformWorld(
          repo,
          settings: const AppSettings(
            window: WindowSettings(launchAtStartup: true),
          ),
        );
        addTearDown(w.dispose);
        await w.read(autostartControllerProvider).start();
        expect(w.autostart.enabled, isTrue);

        w.read(settingsProvider.notifier).setLaunchAtStartup(enabled: false);
        await settle();
        expect(w.autostart.enabled, isFalse);

        w.read(settingsProvider.notifier).setLaunchAtStartup(enabled: true);
        await settle();
        expect(w.autostart.enabled, isTrue);
      },
    );

    test('with the setting off nothing is registered', () async {
      final w = PlatformWorld(repo);
      addTearDown(w.dispose);
      await w.read(autostartControllerProvider).start();
      expect(w.autostart.enableCalls, 0);
      expect(w.autostart.disableCalls, 0);
    });

    test('an entry left behind is removed when the setting is off', () async {
      final w = PlatformWorld(repo);
      addTearDown(w.dispose);
      w.autostart.enabled = true;
      await w.read(autostartControllerProvider).start();
      expect(w.autostart.enabled, isFalse);
    });

    test(
      'a failing registry never throws and never changes the setting',
      () async {
        final w = PlatformWorld(repo);
        addTearDown(w.dispose);
        w.autostart.failing = true;
        await w.read(autostartControllerProvider).start();
        w.read(settingsProvider.notifier).setLaunchAtStartup(enabled: true);
        await settle();
        expect(w.settings.window.launchAtStartup, isTrue);
      },
    );
  });

  group('notification buttons', () {
    test('Stop silences the azan; a click opens the window', () async {
      final w = PlatformWorld(repo);
      addTearDown(w.dispose);
      w.read(notificationActionRouterProvider);
      await w.read(azanPlaybackProvider.notifier).playAzan(Prayer.fajr);
      w.notifier.press(NotificationActionKind.stop, tag: 'azan');
      await settle();
      expect(w.read(azanPlaybackProvider).playing, isFalse);

      w.notifier.press(NotificationActionKind.open);
      await settle();
      expect(w.window.visible, isTrue);
    });
  });
}
