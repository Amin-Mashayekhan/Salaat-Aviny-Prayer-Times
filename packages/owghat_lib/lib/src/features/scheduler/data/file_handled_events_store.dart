import 'package:owghat_lib/src/core/storage/state_file.dart';
import 'package:owghat_lib/src/core/utils/json_value.dart';
import 'package:owghat_lib/src/features/scheduler/domain/handled_events_store.dart';

/// A [HandledEventsStore] persisted in the `handledEvents` section of
/// `state.json`.
class FileHandledEventsStore implements HandledEventsStore {
  /// Creates the store and reads the remembered entries from the file.
  FileHandledEventsStore(this._file) {
    for (final entry in Json.map(_file[_key]).entries) {
      final at = Json.utcDate(entry.value);
      if (at != null) _memory.markHandled(entry.key, at);
    }
  }

  static const String _key = 'handledEvents';

  final StateFile _file;
  final InMemoryHandledEventsStore _memory = InMemoryHandledEventsStore();

  @override
  Set<String> get ids => _memory.ids;

  @override
  bool isHandled(String id) => _memory.isHandled(id);

  @override
  void markHandled(String id, DateTime at) {
    _memory.markHandled(id, at);
    _save();
  }

  @override
  void prune(DateTime cutoff) {
    final before = _memory.entries.length;
    _memory.prune(cutoff);
    if (_memory.entries.length != before) _save();
  }

  void _save() {
    _file.set(_key, {
      for (final entry in _memory.entries.entries)
        entry.key: entry.value.toIso8601String(),
    });
  }
}
