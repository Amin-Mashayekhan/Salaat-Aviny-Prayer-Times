/// Something that happened to the machine power or clock state.
enum PowerEvent {
  /// The PC is about to sleep or hibernate.
  suspending,

  /// The PC woke up.
  resumed,

  /// The system clock or time zone was changed.
  timeChanged,
}

/// Source of [PowerEvent]s (Windows: `WM_POWERBROADCAST`, `WM_TIMECHANGE`).
abstract interface class PowerEvents {
  /// The events, as a broadcast stream.
  Stream<PowerEvent> get events;
}

/// A [PowerEvents] that never emits (tests and unsupported platforms).
class NoPowerEvents implements PowerEvents {
  /// Creates the silent source.
  const NoPowerEvents();

  @override
  Stream<PowerEvent> get events => const Stream.empty();
}
