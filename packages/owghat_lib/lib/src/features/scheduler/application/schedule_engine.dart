// The engine keeps private fields while the named parameters stay public.
// ignore_for_file: prefer_initializing_formals
import 'dart:async';

import 'package:clock/clock.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/features/scheduler/domain/event_dispatcher.dart';
import 'package:owghat_lib/src/features/scheduler/domain/handled_events_store.dart';
import 'package:prayer_core/prayer_core.dart';

/// Runs the schedule: arms one timer for the next event, handles everything
/// that is due exactly once, and recovers from sleep and clock changes.
///
/// See "Schedule engine" in `docs/04-DOMAIN-SPEC.md`. The engine is plain
/// Dart; Riverpod wiring lives in `scheduler_providers.dart`.
class ScheduleEngine {
  /// Creates an engine.
  ///
  /// - [buildEvents] returns the events for today and tomorrow from the
  ///   current settings; it is called on every rebuild.
  /// - [monotonic] is a clock that is unaffected by clock changes (a running
  ///   `Stopwatch`); comparing it with [clock] reveals clock jumps.
  ScheduleEngine({
    required Clock clock,
    required List<ScheduledEvent> Function() buildEvents,
    required ScheduleDispatcher dispatcher,
    required HandledEventsStore handled,
    CatchUpPolicy policy = const CatchUpPolicy(),
    Duration Function()? monotonic,
    Duration watchdogInterval = const Duration(seconds: 15),
    Duration watchdogTolerance = const Duration(seconds: 5),
    Duration retention = const Duration(days: 3),
  }) : _clock = clock,
       _buildEvents = buildEvents,
       _dispatcher = dispatcher,
       _handled = handled,
       _policy = policy,
       _monotonic = monotonic ?? _defaultMonotonic(),
       _watchdogInterval = watchdogInterval,
       _watchdogTolerance = watchdogTolerance,
       _retention = retention;

  static final Logger _log = Logger('ScheduleEngine');

  static Duration Function() _defaultMonotonic() {
    final stopwatch = Stopwatch()..start();
    return () => stopwatch.elapsed;
  }

  final Clock _clock;
  final List<ScheduledEvent> Function() _buildEvents;
  final ScheduleDispatcher _dispatcher;
  final HandledEventsStore _handled;
  final CatchUpPolicy _policy;
  final Duration Function() _monotonic;
  final Duration _watchdogInterval;
  final Duration _watchdogTolerance;
  final Duration _retention;

  List<ScheduledEvent> _events = const [];
  Timer? _timer;
  Timer? _watchdog;
  DateTime? _lastWall;
  Duration? _lastMono;
  bool _busy = false;
  bool _again = false;
  bool _firstRun = true;
  bool _disposed = false;

  /// The events currently scheduled (sorted).
  List<ScheduledEvent> get events => List.unmodifiable(_events);

  /// Builds the schedule, handles anything already due, and starts the
  /// timer and the clock watchdog.
  Future<void> start() async {
    _noteClocks();
    _watchdog?.cancel();
    _watchdog = Timer.periodic(_watchdogInterval, (_) => _checkClocks());
    await rebuild();
  }

  /// Rebuilds the events from the current settings and re-evaluates them.
  ///
  /// Called on settings changes, system resume, clock changes, the day
  /// rollover and by the watchdog.
  Future<void> rebuild() async {
    if (_disposed) return;
    _events = _buildEvents();
    await _process();
    _arm();
  }

  /// Stops all timers. The engine cannot be restarted.
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _watchdog?.cancel();
  }

  void _noteClocks() {
    _lastWall = _clock.now().toUtc();
    _lastMono = _monotonic();
  }

  void _checkClocks() {
    if (_disposed) return;
    final wall = _clock.now().toUtc();
    final mono = _monotonic();
    final lastWall = _lastWall;
    final lastMono = _lastMono;
    _lastWall = wall;
    _lastMono = mono;
    if (lastWall == null || lastMono == null) return;
    final drift = (wall.difference(lastWall) - (mono - lastMono)).abs();
    if (drift > _watchdogTolerance) {
      _log.info('Clock jump of $drift detected; rebuilding the schedule');
      unawaited(rebuild());
    }
  }

  Future<void> _process() async {
    if (_busy) {
      _again = true;
      return;
    }
    _busy = true;
    try {
      do {
        _again = false;
        await _processOnce();
      } while (_again && !_disposed);
    } finally {
      _busy = false;
    }
  }

  Future<void> _processOnce() async {
    final now = _clock.now().toUtc();
    final decisions = _policy.decideAll(_events, now, _handled.ids);
    var rebuildNeeded = false;
    for (final event in _events) {
      if (_disposed) return;
      var decision = decisions[event.id] ?? CatchUpDecision.notYetDue;
      if (decision == CatchUpDecision.notYetDue ||
          decision == CatchUpDecision.alreadyHandled) {
        continue;
      }
      // At a cold start we do not know whether the PC was on earlier, so
      // old events are dropped quietly instead of announcing "missed".
      if (_firstRun && decision == CatchUpDecision.notifyMissed) {
        decision = CatchUpDecision.drop;
      }
      _handled.markHandled(event.id, now);
      if (decision == CatchUpDecision.drop) continue;
      if (event.kind == EventKind.dayRollover) {
        rebuildNeeded = true;
        continue;
      }
      try {
        await _dispatcher.dispatch(event, decision);
      } on Object catch (error, stack) {
        _log.warning('Dispatching ${event.id} failed', error, stack);
      }
    }
    _firstRun = false;
    _handled.prune(now.subtract(_retention));
    if (rebuildNeeded && !_disposed) {
      _events = _buildEvents();
      _again = true;
    }
  }

  void _arm() {
    _timer?.cancel();
    _timer = null;
    if (_disposed) return;
    final now = _clock.now().toUtc();
    ScheduledEvent? next;
    for (final event in _events) {
      if (_handled.isHandled(event.id)) continue;
      if (event.instantUtc.isAfter(now) &&
          (next == null || event.instantUtc.isBefore(next.instantUtc))) {
        next = event;
      }
    }
    if (next == null) return;
    var delay = next.instantUtc.difference(now);
    const cap = Duration(hours: 1);
    if (delay > cap) delay = cap;
    if (delay < const Duration(milliseconds: 1)) {
      delay = const Duration(milliseconds: 1);
    }
    _timer = Timer(delay, () {
      unawaited(
        _process().then((_) {
          _noteClocks();
          _arm();
        }),
      );
    });
  }
}
