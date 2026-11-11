/// Remembers which scheduled events were already handled, so that each one
/// happens exactly once even across restarts.
abstract interface class HandledEventsStore {
  /// Ids of all remembered events.
  Set<String> get ids;

  /// Whether [id] was handled.
  bool isHandled(String id);

  /// Records [id] as handled at [at].
  void markHandled(String id, DateTime at);

  /// Forgets entries handled before [cutoff].
  void prune(DateTime cutoff);
}

/// A [HandledEventsStore] kept in memory only.
class InMemoryHandledEventsStore implements HandledEventsStore {
  /// Creates a store, optionally pre-filled.
  InMemoryHandledEventsStore([Map<String, DateTime>? initial])
    : _handled = {...?initial};

  final Map<String, DateTime> _handled;

  @override
  Set<String> get ids => _handled.keys.toSet();

  @override
  bool isHandled(String id) => _handled.containsKey(id);

  @override
  void markHandled(String id, DateTime at) => _handled[id] = at.toUtc();

  @override
  void prune(DateTime cutoff) =>
      _handled.removeWhere((_, at) => at.isBefore(cutoff));

  /// The remembered entries (for persistence).
  Map<String, DateTime> get entries => Map.unmodifiable(_handled);
}
