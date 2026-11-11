import 'package:owghat_lib/src/core/storage/json_file_store.dart';
import 'package:owghat_lib/src/core/time/debouncer.dart';
import 'package:owghat_lib/src/core/utils/json_value.dart';

/// The small `state.json` file: facts the app remembers that are not user
/// settings (handled events, window bounds...). It may be deleted at any
/// time without losing a single user choice.
class StateFile {
  /// Creates a state file over a store, already holding `data`.
  StateFile(
    this._store,
    Map<String, Object?> data, {
    Duration debounce = const Duration(milliseconds: 500),
  }) : _data = {...data},
       _debouncer = Debouncer(debounce);

  /// Loads the file; a missing or broken file gives an empty state.
  static Future<StateFile> load(
    JsonFileStore store, {
    Duration debounce = const Duration(milliseconds: 500),
  }) async {
    final result = await store.read();
    return StateFile(store, Json.map(result.json), debounce: debounce);
  }

  final JsonFileStore _store;
  final Debouncer _debouncer;
  final Map<String, Object?> _data;

  /// The value stored under [key].
  Object? operator [](String key) => _data[key];

  /// Stores [value] under [key] and schedules a write.
  void set(String key, Object? value) {
    _data[key] = value;
    _debouncer.run(_write);
  }

  /// Writes immediately.
  Future<void> flush() async {
    _debouncer.dispose();
    await _write();
  }

  Future<void> _write() => _store.write(_data);
}
