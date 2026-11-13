import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/storage/json_file_store.dart';
import 'package:owghat_lib/src/core/storage/state_file.dart';

/// A store whose writes take a while and record when they start and end.
class _SlowStore implements JsonStore {
  final List<String> log = [];
  int running = 0;
  int mostAtOnce = 0;
  bool failNext = false;
  Object? saved;

  @override
  Future<StoreReadResult> read() async =>
      (json: saved, existed: saved != null, quarantined: false);

  @override
  Future<void> write(Object? json) async {
    running++;
    if (running > mostAtOnce) mostAtOnce = running;
    log.add('start');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    running--;
    log.add('end');
    if (failNext) {
      failNext = false;
      throw StateError('disk full');
    }
    saved = json;
  }
}

void main() {
  test(
    'a flush during a write waits for it: never two writes at once',
    () async {
      final store = _SlowStore();
      final state = StateFile(
        store,
        {},
        debounce: const Duration(milliseconds: 1),
      )..set('a', 1);
      // Let the debounced write start, then flush while it is still running.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      state.set('b', 2);
      await state.flush();
      expect(store.mostAtOnce, 1);
      expect(store.saved, {'a': 1, 'b': 2});
    },
  );

  test('a failed write does not stop the next one', () async {
    final store = _SlowStore()..failNext = true;
    final state = StateFile(store, {
      'a': 1,
    }, debounce: const Duration(hours: 1));
    await expectLater(state.flush(), throwsStateError);
    await state.flush();
    expect(store.saved, {'a': 1});
  });

  test('dispose drops a write that is still waiting', () async {
    final store = _SlowStore();
    StateFile(store, {}, debounce: const Duration(milliseconds: 5))
      ..set('a', 1)
      ..dispose();
    await Future<void>.delayed(const Duration(milliseconds: 60));
    expect(store.log, isEmpty);
  });
}
