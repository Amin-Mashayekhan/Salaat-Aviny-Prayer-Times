import 'dart:async';

import 'package:owghat_lib/src/core/platform/audio_output.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';

/// One call of [FakeAudioOutput.play].
class FakePlay {
  /// Creates a record.
  const FakePlay(this.sound, this.volume, this.fadeIn);

  /// The sound requested.
  final SoundRef sound;

  /// The volume requested.
  final double volume;

  /// The fade-in requested.
  final Duration fadeIn;

  @override
  String toString() => 'FakePlay($sound, $volume, fade $fadeIn)';
}

/// An [AudioOutput] that records calls and plays nothing.
class FakeAudioOutput implements AudioOutput {
  /// Creates the fake.
  FakeAudioOutput();

  final StreamController<AudioPlaybackState> _states =
      StreamController<AudioPlaybackState>.broadcast();

  /// Every `play` call, in order.
  final List<FakePlay> plays = [];

  /// Number of `stop` calls.
  int stopCount = 0;

  /// Sounds whose `play` throws.
  final Set<SoundRef> failing = {};

  /// Makes every `play` throw.
  bool failAll = false;

  /// Length reported for every sound.
  @override
  Duration? duration = const Duration(minutes: 3);

  /// What is playing now, or null.
  SoundRef? current;

  @override
  Stream<AudioPlaybackState> get states => _states.stream;

  @override
  Future<void> play(
    SoundRef sound, {
    required double volume,
    Duration fadeIn = Duration.zero,
  }) async {
    plays.add(FakePlay(sound, volume, fadeIn));
    if (failAll || failing.contains(sound)) {
      throw AudioOutputException('cannot play $sound');
    }
    current = sound;
    _states.add(
      AudioPlaybackState(status: AudioStatus.playing, duration: duration),
    );
  }

  @override
  Future<void> stop() async {
    stopCount++;
    if (current != null) {
      current = null;
      _states.add(const AudioPlaybackState(status: AudioStatus.stopped));
    }
  }

  /// Simulates a position update of the current sound.
  void emitPosition(Duration position) => _states.add(
    AudioPlaybackState(
      status: AudioStatus.playing,
      position: position,
      duration: duration,
    ),
  );

  /// Simulates the current sound reaching its end.
  void complete() {
    current = null;
    _states.add(
      AudioPlaybackState(
        status: AudioStatus.completed,
        position: duration ?? Duration.zero,
        duration: duration,
      ),
    );
  }

  /// Simulates an asynchronous playback error of the current sound.
  void failPlayback() {
    current = null;
    _states.add(const AudioPlaybackState(status: AudioStatus.failed));
  }

  /// Closes the state stream.
  Future<void> dispose() => _states.close();
}
