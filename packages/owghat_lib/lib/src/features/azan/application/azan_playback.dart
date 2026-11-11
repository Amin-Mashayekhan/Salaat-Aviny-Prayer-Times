import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_core/prayer_core.dart';

/// What the azan player is doing right now.
@immutable
class AzanPlaybackState {
  /// Creates a state.
  const AzanPlaybackState({
    this.playing = false,
    this.prayer,
    this.position = Duration.zero,
    this.duration,
  });

  /// Whether an azan (or preview) is playing.
  final bool playing;

  /// The prayer being played, or null for a preview or when idle.
  final Prayer? prayer;

  /// How far into the sound we are.
  final Duration position;

  /// Length of the sound if known.
  final Duration? duration;

  @override
  bool operator ==(Object other) =>
      other is AzanPlaybackState &&
      other.playing == playing &&
      other.prayer == prayer &&
      other.position == position &&
      other.duration == duration;

  @override
  int get hashCode => Object.hash(playing, prayer, position, duration);
}

/// Controls and reports azan playback.
///
/// CONTRACT used by the UI: watch the state, call `stop()`. The real
/// implementation (audio output, fade-in, fallback sound) replaces the body
/// of this class; the public surface must stay as it is.
class AzanPlaybackController extends Notifier<AzanPlaybackState> {
  @override
  AzanPlaybackState build() => const AzanPlaybackState();

  /// Stops whatever is playing. A no-op when idle.
  Future<void> stop() async {
    state = const AzanPlaybackState();
  }
}

/// Provider of the azan playback state and controller.
final azanPlaybackProvider =
    NotifierProvider<AzanPlaybackController, AzanPlaybackState>(
      AzanPlaybackController.new,
    );
