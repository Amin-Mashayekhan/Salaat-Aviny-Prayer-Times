import 'package:flutter/foundation.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';

/// What the audio device is doing.
enum AudioStatus {
  /// Nothing is playing.
  stopped,

  /// A sound is playing.
  playing,

  /// The sound reached its end.
  completed,

  /// The sound could not be played (file missing, device busy...).
  failed,
}

/// A snapshot of the audio output, emitted on every change.
@immutable
class AudioPlaybackState {
  /// Creates a snapshot.
  const AudioPlaybackState({
    required this.status,
    this.position = Duration.zero,
    this.duration,
  });

  /// What the device is doing.
  final AudioStatus status;

  /// How far into the sound we are.
  final Duration position;

  /// Length of the sound, when known.
  final Duration? duration;

  @override
  bool operator ==(Object other) =>
      other is AudioPlaybackState &&
      other.status == status &&
      other.position == position &&
      other.duration == duration;

  @override
  int get hashCode => Object.hash(status, position, duration);

  @override
  String toString() => 'AudioPlaybackState($status, $position / $duration)';
}

/// Thrown by [AudioOutput.play] when a sound cannot be started.
class AudioOutputException implements Exception {
  /// Creates the exception.
  const AudioOutputException(this.message);

  /// What went wrong, for the log (never shown to the user).
  final String message;

  @override
  String toString() => 'AudioOutputException: $message';
}

/// Plays one sound at a time (the azan, a preview or the reminder chime).
///
/// The Windows implementation lives in the app package (`audioplayers`).
/// Playing a new sound replaces the one that is playing.
abstract interface class AudioOutput {
  /// Starts [sound] at [volume] (0 to 1).
  ///
  /// When [fadeIn] is longer than zero the volume rises from silence to
  /// [volume] over that time. Throws (any exception) if the sound cannot be
  /// started; the caller falls back to the default sound.
  Future<void> play(
    SoundRef sound, {
    required double volume,
    Duration fadeIn = Duration.zero,
  });

  /// Stops whatever is playing. A no-op when idle.
  Future<void> stop();

  /// Every change of the playback state, as a broadcast stream.
  Stream<AudioPlaybackState> get states;

  /// Length of the current sound, if known.
  Duration? get duration;
}
