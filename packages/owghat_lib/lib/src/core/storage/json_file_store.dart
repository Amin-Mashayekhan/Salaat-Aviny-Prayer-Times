import 'dart:convert';
import 'dart:io';

/// Result of reading a JSON file.
typedef StoreReadResult = ({
  /// Decoded JSON, or null if the file is missing or was unreadable.
  Object? json,

  /// Whether a file existed at all.
  bool existed,

  /// Whether the file was unreadable and has been renamed aside.
  bool quarantined,
});

/// Reads and writes one JSON file safely.
///
/// Writes are atomic (temporary file, flush, rename), so a crash never
/// leaves a half-written file. An unreadable file is renamed to
/// `<name>.corrupt-<timestamp>` instead of being overwritten or deleted.
class JsonFileStore {
  /// Creates a store for [file]. [now] names quarantined files and is
  /// injectable for tests.
  JsonFileStore(this.file, {DateTime Function()? now})
    : _now = now ?? _systemNow;

  /// The file on disk.
  final File file;

  final DateTime Function() _now;

  // The one place outside the clock layer allowed to read the system time:
  // it only names quarantined files.
  static DateTime _systemNow() => DateTime.now(); // allow-now

  /// Reads the file.
  Future<StoreReadResult> read() async {
    if (!file.existsSync()) {
      return (json: null, existed: false, quarantined: false);
    }
    try {
      final text = await file.readAsString();
      return (json: jsonDecode(text), existed: true, quarantined: false);
    } on Object {
      await _quarantine();
      return (json: null, existed: true, quarantined: true);
    }
  }

  /// Writes [json] atomically.
  Future<void> write(Object? json) async {
    await file.parent.create(recursive: true);
    final temp = File('${file.path}.tmp');
    final handle = await temp.open(mode: FileMode.write);
    try {
      await handle.writeString(
        const JsonEncoder.withIndent('  ').convert(json),
      );
      await handle.flush();
    } finally {
      await handle.close();
    }
    await temp.rename(file.path);
  }

  Future<void> _quarantine() async {
    final stamp = _now().toUtc().toIso8601String().replaceAll(
      RegExp('[^0-9A-Za-z]'),
      '',
    );
    final name = file.uri.pathSegments.last;
    final dot = name.lastIndexOf('.');
    final base = dot > 0 ? name.substring(0, dot) : name;
    final ext = dot > 0 ? name.substring(dot) : '';
    final target =
        '${file.parent.path}${Platform.pathSeparator}'
        '$base.corrupt-$stamp$ext';
    try {
      await file.rename(target);
    } on Object {
      // If even renaming fails, leave the file alone; the caller starts from
      // defaults and the next successful write will replace it.
    }
  }
}
