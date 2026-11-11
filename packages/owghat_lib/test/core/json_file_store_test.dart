import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/storage/json_file_store.dart';
import 'package:owghat_lib/src/core/time/debouncer.dart';

void main() {
  late Directory dir;
  late File file;
  late JsonFileStore store;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('owghat_store_');
    file = File('${dir.path}/data.json');
    store = JsonFileStore(file, now: () => DateTime.utc(2026, 11, 11, 12));
    addTearDown(() => dir.deleteSync(recursive: true));
  });

  test('a missing file reads as not existing', () async {
    final result = await store.read();
    expect(result.existed, isFalse);
    expect(result.json, isNull);
    expect(result.quarantined, isFalse);
  });

  test('write then read round-trips and leaves no temp file', () async {
    await store.write({
      'a': 1,
      'b': ['x', null],
    });
    final result = await store.read();
    expect(result.existed, isTrue);
    expect(result.json, {
      'a': 1,
      'b': ['x', null],
    });
    expect(File('${file.path}.tmp').existsSync(), isFalse);
  });

  test(
    'writing creates missing folders and replaces the old content',
    () async {
      final nested = JsonFileStore(File('${dir.path}/a/b/c.json'));
      await nested.write({'v': 1});
      await nested.write({'v': 2});
      expect((await nested.read()).json, {'v': 2});
    },
  );

  test(
    'a leftover temp file from a crash never replaces the real one',
    () async {
      await store.write({'v': 'good'});
      File('${file.path}.tmp').writeAsStringSync('{half written');
      expect((await store.read()).json, {'v': 'good'});
      await store.write({'v': 'newer'});
      expect((await store.read()).json, {'v': 'newer'});
    },
  );

  test('an unreadable file is renamed aside, not deleted', () async {
    file.writeAsStringSync('{truncated');
    final result = await store.read();
    expect(result.quarantined, isTrue);
    expect(result.existed, isTrue);
    expect(file.existsSync(), isFalse);
    final aside = dir.listSync().whereType<File>().single;
    expect(
      aside.uri.pathSegments.last,
      'data.corrupt-20261111T120000000Z.json',
    );
    expect(aside.readAsStringSync(), '{truncated');
  });

  group('Debouncer', () {
    test('runs once after calls stop', () async {
      final debouncer = Debouncer(const Duration(milliseconds: 20));
      var runs = 0;
      debouncer
        ..run(() => runs++)
        ..run(() => runs++)
        ..run(() => runs++);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(runs, 1);
    });

    test('flush runs now and dispose cancels', () async {
      final debouncer = Debouncer(const Duration(milliseconds: 20));
      var runs = 0;
      debouncer.run(() => runs++);
      debouncer.flush(() => runs += 10);
      expect(runs, 10);
      debouncer.run(() => runs++);
      debouncer.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(runs, 10);
    });
  });
}
