import 'dart:async';

import 'package:owghat_lib/src/core/platform/audio_output.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_services.dart';

/// An [AlarmSoundPlayer] over the app [AudioOutput]: `play` completes when the
/// sound reached its end or was stopped, and throws when it cannot be played.
class AudioOutputAlarmSoundPlayer implements AlarmSoundPlayer {
  /// Creates the player over [audio].
  AudioOutputAlarmSoundPlayer(AudioOutput audio) : _audio = audio;

  final AudioOutput _audio;
  Completer<void>? _pending;

  @override
  Future<void> play(SoundRef sound, {required double volume}) async {
    final done = Completer<void>();
    _pending = done;
    var started = false;
    final subscription = _audio.states.listen((state) {
      if (done.isCompleted) return;
      switch (state.status) {
        case AudioStatus.playing:
          started = true;
        case AudioStatus.completed:
          done.complete();
        case AudioStatus.stopped:
          // "stopped" before the sound began is the previous sound ending.
          if (started) done.complete();
        case AudioStatus.failed:
          done.completeError(
            const AudioOutputException('playback failed'),
            StackTrace.current,
          );
      }
    });
    try {
      await _audio.play(sound, volume: volume);
      await done.future;
    } finally {
      await subscription.cancel();
      if (identical(_pending, done)) _pending = null;
    }
  }

  @override
  Future<void> stop() async {
    final pending = _pending;
    await _audio.stop();
    if (pending != null && !pending.isCompleted) pending.complete();
  }
}
