import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/core/logging/file_log_sink.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('salaat_log_test_');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  LogRecord record(String message, {Object? error}) =>
      LogRecord(Level.INFO, message, 'test', error);

  test('creates the folder and appends one line per record', () {
    final logs = Directory(p.join(dir.path, 'nested', 'logs'));
    final sink = FileLogSink(logs)
      ..write(record('first'))
      ..write(record('second', error: 'boom'));
    final lines = sink.currentFile.readAsLinesSync();
    expect(lines.length, 2);
    expect(lines[0], contains('[INFO] test: first'));
    expect(lines[1], contains('second | boom'));
  });

  test('rotates at the size limit and keeps a fixed number of files', () {
    final sink = FileLogSink(dir, maxBytes: 200);
    for (var i = 0; i < 40; i++) {
      sink.write(record('line number $i with some padding to grow the file'));
    }
    final names = dir.listSync().map((e) => p.basename(e.path)).toSet();
    expect(
      names,
      containsAll(<String>['salaat.log', 'salaat.1.log', 'salaat.2.log']),
    );
    expect(names.contains('salaat.3.log'), isFalse);
    // The newest line is in the current file, never lost by a rotation.
    final newest = [
      for (final name in names) File(p.join(dir.path, name)).readAsStringSync(),
    ].any((text) => text.contains('line number 39'));
    expect(newest, isTrue);
  });

  test('never throws when the folder cannot be created', () {
    final blocker = File(p.join(dir.path, 'file'))..writeAsStringSync('x');
    // A path below a regular file can never become a directory.
    final sink = FileLogSink(Directory(p.join(blocker.path, 'logs')));
    expect(() => sink.write(record('ignored')), returnsNormally);
    expect(() => sink.write(record('still ignored')), returnsNormally);
  });
}
