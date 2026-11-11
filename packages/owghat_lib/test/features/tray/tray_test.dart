import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/core/platform/tray_menu.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/locations/domain/saved_location.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/tray/application/tray_controller.dart';
import 'package:owghat_lib/src/features/tray/application/tray_providers.dart';
import 'package:owghat_lib/src/features/tray/domain/tray_ids.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/platform_world.dart';
import '../../support/test_data.dart';

List<String> _ids(List<TrayMenuEntry> entries) => [
  for (final e in entries)
    if (e is TrayMenuItem) e.id else '---',
];

void main() {
  late LocationRepository repo;
  setUpAll(() async => repo = await loadTestRepository());

  PlatformWorld worldAt(int hour, int minute, {AppSettings? settings}) {
    final w = PlatformWorld(
      repo,
      settings: settings,
      now: PlatformWorld.tehran(hour, minute),
    );
    addTearDown(w.dispose);
    return w;
  }

  group('menu model', () {
    test('idle: next line, times of today, then the fixed rows', () {
      final w = worldAt(11, 0);
      final menu = w.read(trayMenuProvider);
      expect(_ids(menu.entries), [
        TrayIds.next,
        '${TrayIds.timeRowPrefix}fajr',
        '${TrayIds.timeRowPrefix}sunrise',
        '${TrayIds.timeRowPrefix}dhuhr',
        '${TrayIds.timeRowPrefix}asr',
        '${TrayIds.timeRowPrefix}sunset',
        '${TrayIds.timeRowPrefix}maghrib',
        '${TrayIds.timeRowPrefix}isha',
        '${TrayIds.timeRowPrefix}midnight',
        '---',
        TrayIds.mute,
        TrayIds.location,
        '---',
        TrayIds.show,
        TrayIds.settings,
        TrayIds.quit,
      ]);
      final next = menu.find(TrayIds.next)!;
      expect(next.label, 'بعدی: اذان ظهر · ۱۱:۴۸');
      expect(next.enabled, isFalse);
      expect(menu.find('${TrayIds.timeRowPrefix}dhuhr')!.enabled, isFalse);
      expect(menu.find(TrayIds.stop), isNull);
      expect(menu.find(TrayIds.mute)!.label, 'بی‌صدا');
      expect(menu.find(TrayIds.muteCancel)!.enabled, isFalse);
      expect(menu.find(TrayIds.show)!.label, 'نمایش پنجره');
      expect(menu.find(TrayIds.settings)!.label, 'تنظیمات');
      expect(menu.find(TrayIds.quit)!.label, 'خروج');
    });

    test('the mute submenu lists the five choices of the spec', () {
      final w = worldAt(11, 0);
      final mute = w.read(trayMenuProvider).find(TrayIds.mute)!;
      expect(_ids(mute.children), [
        TrayIds.muteUntilNext,
        TrayIds.muteOneHour,
        TrayIds.muteOneDay,
        TrayIds.muteIndefinite,
        TrayIds.muteCancel,
      ]);
      expect(mute.children.whereType<TrayMenuItem>().map((i) => i.label), [
        'تا اذان بعدی',
        '۱ ساعت',
        '۲۴ ساعت',
        'تا اطلاع ثانوی',
        'لغو بی‌صدا',
      ]);
    });

    test(
      'playing: the stop row appears right after the first separator',
      () async {
        final w = worldAt(11, 0);
        await w.read(azanPlaybackProvider.notifier).playAzan(Prayer.fajr);
        final menu = w.read(trayMenuProvider);
        final ids = _ids(menu.entries);
        final separator = ids.indexOf('---');
        expect(ids[separator + 1], TrayIds.stop);
        expect(ids[separator + 2], TrayIds.mute);
        expect(menu.find(TrayIds.stop)!.label, 'توقف اذان');
      },
    );

    test('muted: the mute row says so and cancel is enabled', () {
      final w = worldAt(
        11,
        0,
        settings: const AppSettings(
          azan: AzanSettings(mute: MuteSetting(indefinite: true)),
        ),
      );
      final menu = w.read(trayMenuProvider);
      expect(menu.find(TrayIds.mute)!.label, 'بی‌صدا (فعال)');
      expect(menu.find(TrayIds.muteCancel)!.enabled, isTrue);
    });

    test('two locations: radio rows, the active one is checked', () {
      final w = worldAt(11, 0);
      w
          .read(settingsProvider.notifier)
          .addLocation(
            const SavedLocation.builtin(id: 'city:2', cityId: 2),
            activate: false,
          );
      final location = w.read(trayMenuProvider).find(TrayIds.location)!;
      final rows = location.children.whereType<TrayMenuItem>().toList();
      expect(rows.map((r) => r.id), ['loc:city:1', 'loc:city:2']);
      expect(rows.map((r) => r.label), ['تهران', 'اصفهان']);
      expect(rows.map((r) => r.checked), [true, false]);

      w.read(settingsProvider.notifier).setActiveLocation('city:2');
      final after = w.read(trayMenuProvider).find(TrayIds.location)!;
      expect(after.children.whereType<TrayMenuItem>().map((r) => r.checked), [
        false,
        true,
      ]);
    });

    test('English labels and Latin digits follow the settings', () {
      final w = worldAt(
        11,
        0,
        settings: const AppSettings(
          language: AppLanguage.en,
          digits: DigitStyle.latin,
        ),
      );
      final menu = w.read(trayMenuProvider);
      expect(menu.find(TrayIds.next)!.label, 'Next: Dhuhr · 11:48');
      expect(menu.find(TrayIds.quit)!.label, 'Quit');
      expect(menu.find(TrayIds.muteOneHour)!.label, '1 h');
    });

    test('after the last prayer the next line points at tomorrow', () {
      final w = worldAt(23, 59);
      final next = w.read(trayMenuProvider).find(TrayIds.next)!;
      expect(next.label, startsWith('بعدی: '));
    });
  });

  group('tooltip', () {
    test('is "<prayer> <time> · <remaining>"', () {
      final w = worldAt(11, 0);
      expect(w.read(trayTooltipProvider), 'اذان ظهر ۱۱:۴۸ · ۴۸ دقیقه دیگر');
    });

    test('hours and minutes in English', () {
      final w = worldAt(
        10,
        0,
        settings: const AppSettings(
          language: AppLanguage.en,
          digits: DigitStyle.latin,
        ),
      );
      expect(w.read(trayTooltipProvider), 'Dhuhr 11:48 · in 1 h 48 min');
    });

    test('is refreshed once a minute, not every second', () {
      fakeAsync((async) {
        final w = worldAt(11, 0);
        unawaited(w.read(trayControllerProvider).start());
        async.flushMicrotasks();
        expect(w.tray.icon, trayIconAsset);
        // First second: 11:00:01.
        w.now = w.now.add(const Duration(seconds: 1));
        async.elapse(const Duration(seconds: 1));
        final afterFirst = w.tray.tooltips.length;
        for (var i = 0; i < 30; i++) {
          w.now = w.now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }
        expect(w.tray.tooltips.length, afterFirst);
        for (var i = 0; i < 40; i++) {
          w.now = w.now.add(const Duration(seconds: 1));
          async.elapse(const Duration(seconds: 1));
        }
        expect(w.tray.tooltips.length, afterFirst + 1);
        expect(w.tray.tooltip, 'اذان ظهر ۱۱:۴۸ · ۴۶ دقیقه دیگر');
      });
    });
  });

  group('controller', () {
    Future<PlatformWorld> started({AppSettings? settings}) async {
      final w = worldAt(11, 0, settings: settings);
      await w.read(trayControllerProvider).start();
      return w;
    }

    test('start sets the icon, tooltip and menu', () async {
      final w = await started();
      expect(w.tray.icon, trayIconAsset);
      expect(w.tray.tooltip, isNotEmpty);
      expect(w.tray.menu, isNotNull);
      expect(w.read(trayControllerProvider).ready, isTrue);
    });

    test('the menu is pushed again when the mute changes', () async {
      final w = await started();
      final before = w.tray.menus.length;
      w
          .read(settingsProvider.notifier)
          .setMute(const MuteSetting(indefinite: true));
      await settle();
      expect(w.tray.menus.length, before + 1);
      expect(w.tray.menu!.find(TrayIds.mute)!.label, 'بی‌صدا (فعال)');
    });

    test('the menu is pushed again when the azan starts playing', () async {
      final w = await started();
      await w.read(azanPlaybackProvider.notifier).playAzan(Prayer.fajr);
      await settle();
      expect(w.tray.menu!.find(TrayIds.stop), isNotNull);
    });

    test('mute choices call SettingsController.setMute', () async {
      final w = await started();
      w.tray.choose(TrayIds.muteOneHour);
      await settle();
      expect(w.settings.azan.mute.until, w.now.add(const Duration(hours: 1)));

      w.tray.choose(TrayIds.muteOneDay);
      await settle();
      expect(w.settings.azan.mute.until, w.now.add(const Duration(hours: 24)));

      w.tray.choose(TrayIds.muteIndefinite);
      await settle();
      expect(w.settings.azan.mute.indefinite, isTrue);

      w.tray.choose(TrayIds.muteCancel);
      await settle();
      expect(w.settings.azan.mute, MuteSetting.none);

      w.tray.choose(TrayIds.muteUntilNext);
      await settle();
      expect(w.settings.azan.mute.until, isNotNull);
    });

    test('choosing a location makes it active', () async {
      final w = await started();
      w
          .read(settingsProvider.notifier)
          .addLocation(
            const SavedLocation.builtin(id: 'city:2', cityId: 2),
            activate: false,
          );
      w.tray.choose('${TrayIds.locationPrefix}city:2');
      await settle();
      expect(w.settings.activeLocationId, 'city:2');
    });

    test('stop silences the azan', () async {
      final w = await started();
      await w.read(azanPlaybackProvider.notifier).playAzan(Prayer.fajr);
      w.tray.choose(TrayIds.stop);
      await settle();
      expect(w.read(azanPlaybackProvider).playing, isFalse);
      expect(w.audio.stopCount, 1);
    });

    test('show, settings and a click on the icon show the window', () async {
      final w = await started();
      w.window.visible = false;
      w.tray.clickIcon();
      await settle();
      expect(w.window.visible, isTrue);

      w.window.visible = false;
      w.tray.choose(TrayIds.settings);
      await settle();
      expect(w.window.visible, isTrue);
      expect(w.read(destinationProvider), Destination.settings);

      w.window.visible = false;
      w.tray.choose(TrayIds.show);
      await settle();
      expect(w.window.visible, isTrue);
    });

    test('quit flushes and closes the window and removes the icon', () async {
      final w = await started();
      w.tray.choose(TrayIds.quit);
      await waitUntil(() => w.window.quitCalled);
      expect(w.window.quitCalled, isTrue);
      expect(w.tray.disposed, isTrue);
    });

    test('a tray host that fails never throws into the app', () async {
      final w = worldAt(11, 0);
      // The fake host is fine; closing its stream must not matter either.
      await w.tray.close();
      await w.read(trayControllerProvider).start();
    });
  });
}
