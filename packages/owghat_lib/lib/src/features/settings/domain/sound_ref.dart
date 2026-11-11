import 'package:flutter/foundation.dart';

/// Reference to a sound: a bundled asset or a file chosen by the user.
@immutable
class SoundRef {
  /// A bundled sound, by id (for example `azan_default`).
  const SoundRef.asset(String id) : kind = SoundKind.asset, value = id;

  /// A file on disk, by absolute path.
  const SoundRef.file(String path) : kind = SoundKind.file, value = path;

  /// Parses `asset:<id>` or `file:<path>`; anything else is the default azan.
  factory SoundRef.parse(String? text) {
    if (text != null) {
      if (text.startsWith('asset:') && text.length > 6) {
        return SoundRef.asset(text.substring(6));
      }
      if (text.startsWith('file:') && text.length > 5) {
        return SoundRef.file(text.substring(5));
      }
    }
    return defaultAzan;
  }

  /// The bundled placeholder azan.
  static const defaultAzan = SoundRef.asset('azan_default');

  /// The bundled reminder chime.
  static const chime = SoundRef.asset('chime');

  /// Where the sound comes from.
  final SoundKind kind;

  /// Asset id or file path.
  final String value;

  /// The text form stored in settings.
  String get encoded => '${kind.name}:$value';

  @override
  bool operator ==(Object other) =>
      other is SoundRef && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);

  @override
  String toString() => encoded;
}

/// Origin of a [SoundRef].
enum SoundKind {
  /// Bundled with the app.
  asset,

  /// A user file.
  file,
}
