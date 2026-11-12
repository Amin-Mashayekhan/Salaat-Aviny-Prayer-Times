import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;

/// Writes log records to `<dir>/salaat.log`, rotating at [maxBytes] and
/// keeping [keep] older files (`salaat.1.log`, `salaat.2.log`, ...).
///
/// It never throws: a log that cannot be written must not break the app, so
/// every failure is swallowed (and the sink stops trying after the first one).
/// Writes are synchronous appends; the app logs a handful of lines a minute,
/// so this stays simple and keeps the order of lines exact.
class FileLogSink {
  /// Creates a sink writing into [directory].
  FileLogSink(this.directory, {this.maxBytes = 1024 * 1024, this.keep = 2});

  /// The log folder.
  final Directory directory;

  /// Size at which the current file is rotated.
  final int maxBytes;

  /// How many rotated files are kept next to the current one.
  final int keep;

  bool _broken = false;
  File? _file;

  /// The file lines are appended to.
  File get currentFile => File(p.join(directory.path, 'salaat.log'));

  /// Formats and appends [record].
  void write(LogRecord record) {
    if (_broken) return;
    try {
      final file = _file ??= _open();
      final buffer = StringBuffer()
        ..write(record.time.toUtc().toIso8601String())
        ..write(' [')
        ..write(record.level.name)
        ..write('] ')
        ..write(record.loggerName)
        ..write(': ')
        ..write(record.message);
      if (record.error != null) buffer.write(' | ${record.error}');
      if (record.stackTrace != null) buffer.write('\n${record.stackTrace}');
      buffer.writeln();
      file.writeAsStringSync(buffer.toString(), mode: FileMode.append);
      if (file.lengthSync() > maxBytes) _rotate();
    } on Object {
      _broken = true;
    }
  }

  File _open() {
    directory.createSync(recursive: true);
    final file = currentFile;
    if (file.existsSync() && file.lengthSync() > maxBytes) _rotate();
    return file;
  }

  void _rotate() {
    _file = null;
    for (var i = keep; i >= 1; i--) {
      final from = i == 1
          ? currentFile
          : File(p.join(directory.path, 'salaat.${i - 1}.log'));
      final to = File(p.join(directory.path, 'salaat.$i.log'));
      if (!from.existsSync()) continue;
      if (to.existsSync()) to.deleteSync();
      from.renameSync(to.path);
    }
  }
}
