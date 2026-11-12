import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:owghat_lib/owghat_lib.dart';

/// [AudioOutput] on `audioplayers` (first-party Windows backend).
///
/// Bundled sounds are mapped from their `asset:<id>` form to files under
/// `assets/audio/`; user sounds are played from their path. A missing file or
/// an unknown asset throws before anything plays, so the library can fall
/// back to the default azan.
class AudioplayersOutput implements AudioOutput {
  /// Creates the output; [player] is injectable for experiments.
  AudioplayersOutput({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _subscriptions
      ..add(_player.onPlayerStateChanged.listen(_onState))
      ..add(_player.onPositionChanged.listen(_onPosition))
      ..add(_player.onDurationChanged.listen(_onDuration))
      ..add(_player.onPlayerComplete.listen((_) => _onComplete()));
  }

  /// Bundled sound ids and their file below `assets/` (audioplayers adds the
  /// `assets/` prefix itself).
  static const Map<String, String> bundled = {
    'azan_default': 'audio/azan_default.wav',
    'chime': 'audio/chime.wav',
  };

  final AudioPlayer _player;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final StreamController<AudioPlaybackState> _states =
      StreamController<AudioPlaybackState>.broadcast();

  StreamSubscription<double>? _fade;
  Timer? _watchdog;
  AudioStatus _status = AudioStatus.stopped;
  Duration _position = Duration.zero;
  Duration? _duration;

  @override
  Stream<AudioPlaybackState> get states => _states.stream;

  @override
  Duration? get duration => _duration;

  @override
  Future<void> play(
    SoundRef sound, {
    required double volume,
    Duration fadeIn = Duration.zero,
  }) async {
    final source = _sourceFor(sound);
    await _cancelFade();
    _duration = null;
    _position = Duration.zero;
    // A new sound starts from "nothing yet". Without this reset the previous
    // sound's `completed` status was re-sent by the next position or duration
    // event, which made the library think the new sound had already ended.
    _status = AudioStatus.stopped;
    final target = volume.clamp(0.0, 1.0);
    // With a fade-in the sound starts silent and the ramp raises the volume.
    await _player.play(source, volume: fadeIn > Duration.zero ? 0 : target);
    if (fadeIn > Duration.zero) {
      _fade = fadeRamp(
        fadeIn,
      ).listen((fraction) => unawaited(_player.setVolume(target * fraction)));
    }
  }

  @override
  Future<void> stop() async {
    await _cancelFade();
    await _player.stop();
    _position = Duration.zero;
    _emit(AudioStatus.stopped);
  }

  /// Releases the native player.
  Future<void> dispose() async {
    _stopWatchdog();
    await _cancelFade();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _player.dispose();
    await _states.close();
  }

  Source _sourceFor(SoundRef sound) {
    switch (sound.kind) {
      case SoundKind.asset:
        final path = bundled[sound.value];
        if (path == null) {
          throw AudioOutputException('Unknown bundled sound ${sound.value}');
        }
        return AssetSource(path);
      case SoundKind.file:
        if (!File(sound.value).existsSync()) {
          throw AudioOutputException('Sound file not found: ${sound.value}');
        }
        return DeviceFileSource(sound.value);
    }
  }

  Future<void> _cancelFade() async {
    await _fade?.cancel();
    _fade = null;
  }

  void _onState(PlayerState state) {
    switch (state) {
      case PlayerState.playing:
        _emit(AudioStatus.playing);
      case PlayerState.completed:
        _emit(AudioStatus.completed);
      case PlayerState.stopped:
      case PlayerState.paused:
      case PlayerState.disposed:
        // `stop()` reports "stopped" itself; the library ignores these.
        break;
    }
  }

  // Position and duration updates are only forwarded while a sound is really
  // playing; before that they are remembered and ride along with the next
  // `playing` snapshot.
  void _onPosition(Duration position) {
    _position = position;
    if (_status == AudioStatus.playing) _emit(AudioStatus.playing);
  }

  void _onDuration(Duration duration) {
    _duration = duration;
    if (_status == AudioStatus.playing) _emit(AudioStatus.playing);
  }

  void _onComplete() {
    unawaited(_cancelFade());
    if (_status != AudioStatus.completed) _emit(AudioStatus.completed);
  }

  /// While a sound plays, ask the native player once a second whether it is
  /// still playing. The end-of-sound event comes from a native thread (the
  /// engine logs "message sent on a non-platform thread"), so it must not be
  /// the only thing that can end a playback.
  void _startWatchdog() {
    _watchdog ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status != AudioStatus.playing) return;
      final state = _player.state;
      if (state == PlayerState.completed ||
          state == PlayerState.stopped ||
          state == PlayerState.disposed) {
        _onComplete();
      }
    });
  }

  void _stopWatchdog() {
    _watchdog?.cancel();
    _watchdog = null;
  }

  void _emit(AudioStatus status) {
    _status = status;
    if (status == AudioStatus.playing) {
      _startWatchdog();
    } else {
      _stopWatchdog();
    }
    if (_states.isClosed) return;
    _states.add(
      AudioPlaybackState(
        status: status,
        position: _position,
        duration: _duration,
      ),
    );
  }
}
