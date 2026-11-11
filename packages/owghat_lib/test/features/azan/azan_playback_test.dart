import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/time/fade_ramp.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/azan/application/mute_providers.dart';
import 'package:owghat_lib/src/features/azan/domain/azan_volume.dart';
import 'package:owghat_lib/src/features/azan/domain/next_azan.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/platform_world.dart';
import '../../support/test_data.dart';

AppSettings _settings({
  double master = 0.5,
  bool fade = true,
  SoundRef sound = SoundRef.defaultAzan,
  double fajrVolume = 0.8,
}) => AppSettings(
  azan: AzanSettings(
    masterVolume: master,
    fadeIn: fade,
    perPrayer: {
      ...AzanSettings.defaultPerPrayer,
      Prayer.fajr: PrayerAzan(enabled: true, sound: sound, volume: fajrVolume),
    },
  ),
);

void main() {
  late LocationRepository repo;
  setUpAll(() async => repo = await loadTestRepository());

  group('volume maths', () {
    test('is the master volume times the prayer volume', () {
      expect(
        effectiveAzanVolume(master: 0.5, perPrayer: 0.8),
        closeTo(0.4, 1e-9),
      );
      expect(effectiveAzanVolume(master: 1, perPrayer: 1), 1);
      expect(effectiveAzanVolume(master: 0, perPrayer: 1), 0);
    });

    test('never leaves the range 0 to 1', () {
      expect(effectiveAzanVolume(master: 2, perPrayer: 2), 1);
      expect(effectiveAzanVolume(master: -1, perPrayer: 1), 0);
    });

    test('fade-in is two seconds when switched on, none otherwise', () {
      expect(fadeInFor(const AzanSettings()), const Duration(seconds: 2));
      expect(fadeInFor(const AzanSettings(fadeIn: false)), Duration.zero);
    });
  });

  group('fade ramp', () {
    test('goes from 0 to 1 in equal steps over the duration', () {
      fakeAsync((async) {
        final values = <double>[];
        fadeRamp(const Duration(seconds: 2), steps: 4).listen(values.add);
        async.flushMicrotasks();
        expect(values, [0]);
        async.elapse(const Duration(seconds: 1));
        expect(values, [0, 0.25, 0.5]);
        async.elapse(const Duration(seconds: 1));
        expect(values, [0, 0.25, 0.5, 0.75, 1]);
      });
    });

    test('a zero duration jumps straight to full volume', () async {
      expect(await fadeRamp(Duration.zero).toList(), [0, 1]);
    });
  });

  group('playing an azan', () {
    test('uses master x prayer volume and the two-second fade-in', () async {
      final w = PlatformWorld(repo, settings: _settings());
      addTearDown(w.dispose);
      final result = await w
          .read(azanPlaybackProvider.notifier)
          .playAzan(Prayer.fajr);
      expect(result, AzanPlayResult.played);
      final play = w.audio.plays.single;
      expect(play.sound, SoundRef.defaultAzan);
      expect(play.volume, closeTo(0.4, 1e-9));
      expect(play.fadeIn, const Duration(seconds: 2));
      expect(w.read(azanPlaybackProvider).playing, isTrue);
      expect(w.read(azanPlaybackProvider).prayer, Prayer.fajr);
    });

    test('no fade-in when the setting is off', () async {
      final w = PlatformWorld(repo, settings: _settings(fade: false));
      addTearDown(w.dispose);
      await w.read(azanPlaybackProvider.notifier).playAzan(Prayer.fajr);
      expect(w.audio.plays.single.fadeIn, Duration.zero);
    });

    test('plays the sound chosen for the prayer', () async {
      const mine = SoundRef.file('C:/sounds/mine.mp3');
      final w = PlatformWorld(repo, settings: _settings(sound: mine));
      addTearDown(w.dispose);
      await w.read(azanPlaybackProvider.notifier).playAzan(Prayer.fajr);
      expect(w.audio.plays.single.sound, mine);
    });

    test('reports position and length while playing', () async {
      final w = PlatformWorld(repo, settings: _settings());
      addTearDown(w.dispose);
      await w.read(azanPlaybackProvider.notifier).playAzan(Prayer.fajr);
      w.audio.emitPosition(const Duration(seconds: 42, milliseconds: 700));
      await settle();
      final state = w.read(azanPlaybackProvider);
      expect(state.position, const Duration(seconds: 42));
      expect(state.duration, const Duration(minutes: 3));
    });

    test('finishes by itself when the sound completes', () async {
      final w = PlatformWorld(repo, settings: _settings());
      addTearDown(w.dispose);
      await w.read(azanPlaybackProvider.notifier).playAzan(Prayer.fajr);
      w.audio.complete();
      await settle();
      expect(w.read(azanPlaybackProvider), const AzanPlaybackState());
    });
  });

  group('fallback to the bundled azan', () {
    const missing = SoundRef.file('C:/gone/azan.mp3');

    test('a missing file plays the default asset instead', () async {
      final w = PlatformWorld(repo, settings: _settings(sound: missing));
      addTearDown(w.dispose);
      w.audio.failing.add(missing);
      final result = await w
          .read(azanPlaybackProvider.notifier)
          .playAzan(Prayer.fajr);
      expect(result, AzanPlayResult.playedFallback);
      expect(w.audio.plays.map((p) => p.sound), [
        missing,
        SoundRef.defaultAzan,
      ]);
      // The fallback keeps the volume and the fade.
      expect(w.audio.plays.last.volume, closeTo(0.4, 1e-9));
      expect(w.audio.plays.last.fadeIn, const Duration(seconds: 2));
      expect(w.read(azanPlaybackProvider).playing, isTrue);
    });

    test('an asynchronous playback error also falls back', () async {
      final w = PlatformWorld(repo, settings: _settings(sound: missing));
      addTearDown(w.dispose);
      await w.read(azanPlaybackProvider.notifier).playAzan(Prayer.fajr);
      w.audio.failPlayback();
      await settle();
      expect(w.audio.plays.map((p) => p.sound), [
        missing,
        SoundRef.defaultAzan,
      ]);
      expect(w.read(azanPlaybackProvider).playing, isTrue);
    });

    test(
      'when even the default fails it reports failure and never throws',
      () async {
        final w = PlatformWorld(repo, settings: _settings(sound: missing));
        addTearDown(w.dispose);
        w.audio.failAll = true;
        final result = await w
            .read(azanPlaybackProvider.notifier)
            .playAzan(Prayer.fajr);
        expect(result, AzanPlayResult.failed);
        expect(w.read(azanPlaybackProvider), const AzanPlaybackState());
      },
    );
  });

  group('stop', () {
    test('stops the output and resets the state', () async {
      final w = PlatformWorld(repo, settings: _settings());
      addTearDown(w.dispose);
      final controller = w.read(azanPlaybackProvider.notifier);
      await controller.playAzan(Prayer.fajr);
      await controller.stop();
      expect(w.audio.stopCount, 1);
      expect(w.read(azanPlaybackProvider), const AzanPlaybackState());
    });

    test('is a no-op when nothing plays', () async {
      final w = PlatformWorld(repo);
      addTearDown(w.dispose);
      await w.read(azanPlaybackProvider.notifier).stop();
      expect(w.audio.stopCount, 0);
    });
  });

  group('preview and chime', () {
    test('preview plays the sound at master x given volume', () async {
      final w = PlatformWorld(repo, settings: _settings());
      addTearDown(w.dispose);
      const sound = SoundRef.file('C:/sounds/x.mp3');
      final result = await w
          .read(azanPlaybackProvider.notifier)
          .preview(sound, volume: 0.5);
      expect(result, AzanPlayResult.played);
      expect(w.audio.plays.single.volume, closeTo(0.25, 1e-9));
      expect(w.read(azanPlaybackProvider).playing, isTrue);
      expect(w.read(azanPlaybackProvider).prayer, isNull);
    });

    test(
      'the chime does not show as playback and never interrupts an azan',
      () async {
        final w = PlatformWorld(repo, settings: _settings());
        addTearDown(w.dispose);
        final controller = w.read(azanPlaybackProvider.notifier);
        await controller.playChime();
        expect(w.audio.plays.single.sound, SoundRef.chime);
        expect(w.read(azanPlaybackProvider).playing, isFalse);
        await controller.playAzan(Prayer.fajr);
        await controller.playChime();
        expect(w.audio.plays.length, 2); // chime, azan; no second chime
      },
    );

    test('a failing chime is swallowed', () async {
      final w = PlatformWorld(repo);
      addTearDown(w.dispose);
      w.audio.failAll = true;
      await w.read(azanPlaybackProvider.notifier).playChime();
    });
  });

  group('mute', () {
    test('expires by itself and is never written back to the settings', () {
      final w = PlatformWorld(repo, now: PlatformWorld.tehran(5, 0));
      addTearDown(w.dispose);
      final start = w.now;
      final until = start.add(const Duration(minutes: 30));
      w.read(settingsProvider.notifier).setMute(MuteSetting(until: until));
      final saved = w.settings.toJson().toString();

      expect(w.settings.azan.mute.isActiveAt(w.now), isTrue);
      w.now = start.add(const Duration(minutes: 29, seconds: 59));
      expect(w.settings.azan.mute.isActiveAt(w.now), isTrue);
      w.now = until;
      expect(w.settings.azan.mute.isActiveAt(w.now), isFalse);
      w.now = until.add(const Duration(hours: 5));
      expect(w.settings.azan.mute.isActiveAt(w.now), isFalse);
      expect(w.settings.toJson().toString(), saved);
    });

    test('muteActiveProvider follows the clock through the second ticker', () {
      fakeAsync((async) {
        final start = PlatformWorld.tehran(5, 0);
        final w = PlatformWorld(repo, now: start);
        addTearDown(w.dispose);
        w.container.listen(muteActiveProvider, (_, _) {});
        w
            .read(settingsProvider.notifier)
            .setMute(MuteSetting(until: start.add(const Duration(seconds: 3))));
        w.container.listen(nowProvider, (_, _) {});
        async.flushMicrotasks();
        expect(w.read(muteActiveProvider), isTrue);
        // Move the clock and let the ticker run.
        w.now = start.add(const Duration(seconds: 5));
        async.elapse(const Duration(seconds: 2));
        expect(w.read(muteActiveProvider), isFalse);
      });
    });

    test('an indefinite mute stays on', () {
      final w = PlatformWorld(repo);
      addTearDown(w.dispose);
      w.read(muteActionsProvider).indefinitely();
      w.now = w.now.add(const Duration(days: 400));
      expect(w.settings.azan.mute.isActiveAt(w.now), isTrue);
      w.read(muteActionsProvider).cancel();
      expect(w.settings.azan.mute, MuteSetting.none);
    });

    test('mute for a duration counts from now', () {
      final w = PlatformWorld(repo);
      addTearDown(w.dispose);
      w.read(muteActionsProvider).forDuration(const Duration(hours: 1));
      expect(w.settings.azan.mute.until, w.now.add(const Duration(hours: 1)));
    });

    test('until the next azan ends just after the next enabled azan', () {
      // 05:00 Tehran: the next enabled azan is Fajr at 05:10.
      final w = PlatformWorld(repo, now: PlatformWorld.tehran(5, 0));
      addTearDown(w.dispose);
      w.read(muteActionsProvider).untilNextAzan();
      final until = w.settings.azan.mute.until!;
      final fajr = PlatformWorld.tehran(5, 10);
      expect(until.isAfter(fajr), isTrue);
      expect(until.difference(fajr), muteSlackAfterAzan);
    });

    test('nextAzanInstant skips prayers whose azan is off', () {
      final w = PlatformWorld(repo, now: PlatformWorld.tehran(12, 0));
      addTearDown(w.dispose);
      final days = w.read(prayerDaysAroundTodayProvider);
      // Asr and Isha are off by default: after Dhuhr the next is Maghrib.
      final next = nextAzanInstant(
        days: days,
        enabled: w.settings.azan.enabledPrayers,
        now: w.now,
      );
      expect(next, isNotNull);
      final maghrib = days[1].instants[Prayer.maghrib]!;
      expect(next, maghrib);
      expect(
        nextAzanInstant(days: days, enabled: const {}, now: w.now),
        isNull,
      );
    });
  });
}
