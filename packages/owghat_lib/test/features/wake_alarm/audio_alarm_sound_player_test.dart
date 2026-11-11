import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/platform/audio_output.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_audio_output.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/audio_alarm_sound_player.dart';

void main() {
  late FakeAudioOutput audio;
  late AudioOutputAlarmSoundPlayer player;
  setUp(() {
    audio = FakeAudioOutput();
    player = AudioOutputAlarmSoundPlayer(audio);
  });
  tearDown(() => audio.dispose());

  Future<void> pump() => Future<void>.delayed(Duration.zero);

  test('completes when the sound reaches its end', () async {
    var done = false;
    final future = player
        .play(SoundRef.defaultAzan, volume: 0.5)
        .then((_) => done = true);
    await pump();
    expect(audio.plays.single.volume, 0.5);
    expect(done, isFalse);
    audio.complete();
    await future;
    expect(done, isTrue);
  });

  test('stop ends the pending play', () async {
    final future = player.play(SoundRef.defaultAzan, volume: 1);
    await pump();
    await player.stop();
    await future;
    expect(audio.stopCount, 1);
  });

  test('a start failure is thrown', () async {
    audio.failAll = true;
    await expectLater(
      player.play(SoundRef.defaultAzan, volume: 1),
      throwsA(isA<AudioOutputException>()),
    );
  });

  test('a playback error while playing is thrown', () async {
    final future = player.play(SoundRef.defaultAzan, volume: 1);
    await pump();
    audio.failPlayback();
    await expectLater(future, throwsA(isA<AudioOutputException>()));
  });
}
