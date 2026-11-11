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

  void _onPosition(Duration position) {
    _position = position;
    _emit(_status);
  }

  void _onDuration(Duration duration) {
    _duration = duration;
    _emit(_status);
  }

  void _onComplete() {
    unawaited(_cancelFade());
    _emit(AudioStatus.completed);
  }

  void _emit(AudioStatus status) {
    _status = status;
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
