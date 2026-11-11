import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/core/platform/audio_output.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/azan/domain/azan_volume.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
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

/// How an attempt to play an azan ended.
enum AzanPlayResult {
  /// The requested sound is playing.
  played,

  /// The requested sound could not be played; the bundled default is playing
  /// instead.
  playedFallback,

  /// Nothing could be played.
  failed,
}

/// Controls and reports azan playback.
///
/// CONTRACT used by the UI: watch the state, call `stop()`. The audio-device
/// logic (volume, fade-in, fallback sound) lives here; this class never
/// throws to its callers: a sound that cannot be played falls back to the
/// bundled default azan, and if even that fails the failure is returned as
/// [AzanPlayResult.failed] and logged.
class AzanPlaybackController extends Notifier<AzanPlaybackState> {
  static final Logger _log = Logger('AzanPlayback');

  StreamSubscription<AudioPlaybackState>? _subscription;
  AudioOutput? _subscribedTo;

  /// Bumped by every start and stop, so late results of an older request are
  /// ignored.
  int _session = 0;

  /// Whether the current sound is an azan or a preview (the chime is not
  /// tracked: it is short and does not show in the UI).
  bool _tracking = false;

  /// The sound of the tracked session and how it was requested, so that an
  /// asynchronous playback failure can fall back to the default sound.
  SoundRef? _sound;
  double _volume = 1;
  Duration _fadeIn = Duration.zero;

  @override
  AzanPlaybackState build() {
    ref.onDispose(() {
      unawaited(_subscription?.cancel());
      _subscription = null;
      _subscribedTo = null;
    });
    return const AzanPlaybackState();
  }

  /// Plays the azan of [prayer] with the sound and volume of the settings:
  /// master volume times the prayer volume, with the optional fade-in.
  ///
  /// Mute and the master switch are decided by the caller; this plays.
  Future<AzanPlayResult> playAzan(Prayer prayer) {
    final azan = ref.read(settingsProvider).azan;
    final perPrayer = azan.perPrayer[prayer] ?? const PrayerAzan();
    return _start(
      sound: perPrayer.sound,
      volume: effectiveAzanVolume(
        master: azan.masterVolume,
        perPrayer: perPrayer.volume,
      ),
      fadeIn: fadeInFor(azan),
      prayer: prayer,
    );
  }

  /// Plays [sound] for the settings screen, at the master volume times
  /// [volume] (0 to 1).
  Future<AzanPlayResult> preview(SoundRef sound, {double volume = 1}) {
    final azan = ref.read(settingsProvider).azan;
    return _start(
      sound: sound,
      volume: effectiveAzanVolume(master: azan.masterVolume, perPrayer: volume),
      fadeIn: fadeInFor(azan),
    );
  }

  /// Plays the short reminder chime at the master volume. Skipped while an
  /// azan or preview is playing; never changes [state].
  Future<void> playChime() async {
    if (_tracking) return;
    final azan = ref.read(settingsProvider).azan;
    try {
      await ref
          .read(audioOutputProvider)
          .play(SoundRef.chime, volume: azan.masterVolume.clamp(0, 1));
    } on Object catch (error, stack) {
      _log.warning('The reminder chime could not be played', error, stack);
    }
  }

  /// Stops whatever is playing. A no-op when idle.
  Future<void> stop() async {
    if (!_tracking && !state.playing) return;
    _session++;
    _tracking = false;
    _sound = null;
    state = const AzanPlaybackState();
    try {
      await ref.read(audioOutputProvider).stop();
    } on Object catch (error, stack) {
      _log.warning('Stopping the audio failed', error, stack);
    }
  }

  Future<AzanPlayResult> _start({
    required SoundRef sound,
    required double volume,
    required Duration fadeIn,
    Prayer? prayer,
  }) async {
    final output = ref.read(audioOutputProvider);
    _listenTo(output);
    final session = ++_session;
    _tracking = true;
    _sound = sound;
    _volume = volume;
    _fadeIn = fadeIn;
    state = AzanPlaybackState(playing: true, prayer: prayer);

    var usedFallback = false;
    try {
      await output.play(sound, volume: volume, fadeIn: fadeIn);
    } on Object catch (error, stack) {
      _log.warning('Playing $sound failed', error, stack);
      if (session != _session) return AzanPlayResult.failed;
      if (sound == SoundRef.defaultAzan) return _giveUp(session);
      usedFallback = true;
      _sound = SoundRef.defaultAzan;
      try {
        await output.play(SoundRef.defaultAzan, volume: volume, fadeIn: fadeIn);
      } on Object catch (fallbackError, fallbackStack) {
        _log.severe(
          'The default azan could not be played either',
          fallbackError,
          fallbackStack,
        );
        return _giveUp(session);
      }
    }
    if (session != _session) return AzanPlayResult.played;
    final length = output.duration;
    if (length != null && state.duration == null) {
      state = AzanPlaybackState(
        playing: true,
        prayer: state.prayer,
        position: state.position,
        duration: length,
      );
    }
    return usedFallback ? AzanPlayResult.playedFallback : AzanPlayResult.played;
  }

  AzanPlayResult _giveUp(int session) {
    if (session == _session) {
      _tracking = false;
      _sound = null;
      state = const AzanPlaybackState();
    }
    return AzanPlayResult.failed;
  }

  void _listenTo(AudioOutput output) {
    if (identical(_subscribedTo, output)) return;
    unawaited(_subscription?.cancel());
    _subscribedTo = output;
    _subscription = output.states.listen(_onAudio);
  }

  void _onAudio(AudioPlaybackState audio) {
    if (!_tracking) return;
    switch (audio.status) {
      case AudioStatus.playing:
        state = AzanPlaybackState(
          playing: true,
          prayer: state.prayer,
          // Whole seconds only, so the UI does not rebuild ten times a second.
          position: Duration(seconds: audio.position.inSeconds),
          duration: audio.duration ?? state.duration,
        );
      case AudioStatus.completed:
        _tracking = false;
        _sound = null;
        state = const AzanPlaybackState();
      case AudioStatus.failed:
        unawaited(_recoverFromFailure());
      case AudioStatus.stopped:
        // Our own stop() already reset the state; a "stopped" that arrives
        // while a new sound is starting belongs to the sound it replaced.
        break;
    }
  }

  Future<void> _recoverFromFailure() async {
    final failed = _sound;
    if (failed == null) return;
    final session = _session;
    if (failed == SoundRef.defaultAzan) {
      _giveUp(session);
      return;
    }
    _log.warning('Playback of $failed failed; falling back to the default');
    _sound = SoundRef.defaultAzan;
    try {
      await ref
          .read(audioOutputProvider)
          .play(SoundRef.defaultAzan, volume: _volume, fadeIn: _fadeIn);
    } on Object catch (error, stack) {
      _log.severe('The default azan could not be played either', error, stack);
      _giveUp(session);
    }
  }
}

/// Provider of the azan playback state and controller.
final azanPlaybackProvider =
    NotifierProvider<AzanPlaybackController, AzanPlaybackState>(
      AzanPlaybackController.new,
    );
