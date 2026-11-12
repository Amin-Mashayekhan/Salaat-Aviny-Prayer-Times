import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:owghat_lib/src/core/platform/power_events.dart';
import 'package:owghat_lib/src/core/time/countdown.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_providers.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_plan_providers.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/wake_task_xml.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/next_occurrence.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_countdown_state.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_plan.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_services.dart';
import 'package:prayer_core/prayer_core.dart';

/// Lengths of the wake-up timings. Constants, not settings.
abstract final class WakeTimings {
  /// Cancellable countdown after "Sleep now" / "Hibernate now".
  static const Duration manualCountdown = Duration(seconds: 5);

  /// Cancellable on-screen countdown before an alarm's `afterSound` action.
  /// The PC is never suspended without it.
  static const Duration afterAlarmCountdown = Duration(seconds: 30);

  /// How long the PC is kept awake after an alarm that does not suspend the
  /// PC afterwards, or after the user cancelled the countdown. Windows
  /// would otherwise go back to sleep about two minutes after a timer wake.
  static const Duration stayAwakeAfter = Duration(minutes: 10);

  /// Longest an alarm sound may play before it is stopped.
  static const Duration maxRing = Duration(minutes: 15);

  /// The OS is asked to wake this long BEFORE the alarm instant, so the PC
  /// and the app are fully up when the alarm is due.
  static const Duration wakeLead = Duration(seconds: 30);

  /// If the wake time is closer than this, the PC is awake anyway and no OS
  /// request is made.
  static const Duration minimumLead = Duration(seconds: 10);

  /// Distance of the "test in two minutes" alarm.
  static const Duration testDelay = Duration(minutes: 2);

  /// How often the plan is recomputed and the OS requests re-checked even if
  /// nothing told us to.
  static const Duration recheckEvery = Duration(hours: 1);

  /// Hold taken when the app is started by a wake task, until the alarm
  /// itself takes over.
  static const Duration launchGuard = Duration(minutes: 3);
}

/// What went wrong in the background. The UI maps each to a localised
/// non-modal notice; [WakeAlarmState.problemDetail] is for diagnostics only.
enum WakeProblem {
  /// The sound could not be played (even the fallback).
  soundFailed,

  /// Windows refused to sleep or hibernate.
  suspendRefused,

  /// Hibernation is not available on this PC.
  hibernateUnavailable,

  /// The capability check itself failed.
  probeFailed,
}

/// State of the wake-up feature.
@immutable
class WakeAlarmState {
  /// Creates a state.
  const WakeAlarmState({
    this.capability,
    this.probing = false,
    this.countdown = WakeCountdownState.idle,
    this.ringingAlarmId,
    this.armed = const {},
    this.syncError,
    this.problem,
    this.problemDetail,
  });

  /// The latest probe result; null until [WakeAlarmController.probe] ran.
  final WakeCapability? capability;

  /// A probe is running.
  final bool probing;

  /// The on-screen suspend countdown (idle when none). Also exposed as
  /// [wakeCountdownProvider].
  final WakeCountdownState countdown;

  /// The id of the alarm that is ringing or just woke the PC; null when no
  /// alarm flow is running.
  final String? ringingAlarmId;

  /// Alarm id to the instant the OS was last asked to wake the PC at
  /// (already includes [WakeTimings.wakeLead]).
  final Map<String, DateTime> armed;

  /// Text of the last failure to arm or cancel an OS wake request, or null.
  final String? syncError;

  /// The latest background problem, or null.
  final WakeProblem? problem;

  /// Diagnostic text for [problem].
  final String? problemDetail;

  /// Copy with changes; the `clear` flags reset nullable fields.
  WakeAlarmState copyWith({
    WakeCapability? capability,
    bool? probing,
    WakeCountdownState? countdown,
    String? ringingAlarmId,
    bool clearRinging = false,
    Map<String, DateTime>? armed,
    String? syncError,
    bool clearSyncError = false,
    WakeProblem? problem,
    String? problemDetail,
    bool clearProblem = false,
  }) => WakeAlarmState(
    capability: capability ?? this.capability,
    probing: probing ?? this.probing,
    countdown: countdown ?? this.countdown,
    ringingAlarmId: clearRinging
        ? null
        : (ringingAlarmId ?? this.ringingAlarmId),
    armed: armed ?? this.armed,
    syncError: clearSyncError ? null : (syncError ?? this.syncError),
    problem: clearProblem ? null : (problem ?? this.problem),
    problemDetail: clearProblem ? null : (problemDetail ?? this.problemDetail),
  );
}

final RegExp _alarmIdPattern = RegExp(r'^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$');

/// Owns the wake-up alarms at run time: edits them (through
/// `SettingsController`, the only settings writer), keeps the OS wake
/// requests in step with them, and runs an alarm when the schedule engine
/// reports it.
///
/// CONTRACT used by the UI (Wake-up screen): watch the state (and
/// [wakeCountdownProvider]), call the named actions. CONTRACT used by the
/// bootstrap: override `wakeTimerServiceProvider`, `powerControlProvider` and
/// `alarmSoundPlayerProvider`, read `wakeAlarmControllerProvider` once at
/// start-up (so the OS wake requests are synced), bind the dispatcher's
/// wake-alarm handler to `wakeAlarmEventHandlerProvider`, and call
/// [noteWakeLaunch] for a `--wake <id>` argument.
class WakeAlarmController extends Notifier<WakeAlarmState> {
  static final Logger _log = Logger('WakeAlarmController');

  int _flowToken = 0;
  Countdown? _countdown;
  Completer<bool>? _countdownDone;
  Countdown? _hold;
  Countdown? _ringCap;

  final Map<String, DateTime?> _armed = {};
  Map<String, DateTime> _wanted = {};
  bool _listed = false;
  bool _syncing = false;
  bool _resyncQueued = false;
  Countdown? _hourly;
  bool _syncDirty = false;
  bool _disposed = false;

  late WakeTimerService _service;
  late AlarmSoundPlayer _player;

  @override
  WakeAlarmState build() {
    _disposed = false;
    _service = ref.read(wakeTimerServiceProvider);
    _player = ref.read(alarmSoundPlayerProvider);
    // Why these triggers and not a listener on the plan provider: Riverpod
    // refreshes a derived provider lazily and a derived provider read inside a
    // listener callback is still stale. So the root sources (settings, the
    // bookkeeping, power events, an hourly check) only ask for a re-sync,
    // which reads the plan one microtask later, when it is current.
    ref
      ..onDispose(_dispose)
      ..listen(settingsProvider, (_, _) => _resyncSoon())
      ..listen(wakeBookkeepingProvider, (_, _) => _resyncSoon());
    final subscription = ref.read(powerEventsProvider).events.listen((event) {
      // After sleep or a clock change "next occurrence" must be recomputed.
      if (event != PowerEvent.suspending) {
        ref.read(wakeBookkeepingProvider.notifier).bump();
      }
    });
    ref.onDispose(() => unawaited(subscription.cancel()));
    _updateHourlyCheck();
    // The first sync runs after build, never inside it.
    _resyncSoon();
    return const WakeAlarmState();
  }

  void _dispose() {
    _disposed = true;
    _countdown?.cancel();
    _ringCap?.cancel();
    _hold?.cancel();
    _hourly?.cancel();
    final done = _countdownDone;
    if (done != null && !done.isCompleted) done.complete(false);
    unawaited(_player.stop());
    unawaited(_service.releaseAwake());
  }

  void _set(WakeAlarmState Function(WakeAlarmState s) change) {
    if (_disposed) return;
    state = change(state);
  }

  // ---- alarms (user actions) ---------------------------------------------

  /// A fresh alarm id (unique among the saved alarms, safe for task names).
  String newAlarmId() {
    final base =
        'wake-${ref.read(clockProvider).now().toUtc().microsecondsSinceEpoch}';
    final taken = ref
        .read(settingsProvider)
        .wakeAlarms
        .map((a) => a.id)
        .toSet();
    var id = base;
    var n = 1;
    while (taken.contains(id)) {
      id = '$base-${n++}';
    }
    return id;
  }

  SettingsFailure? _validate(WakeAlarm alarm) {
    if (!_alarmIdPattern.hasMatch(alarm.id)) return SettingsFailure.invalid;
    if (alarm.hour < 0 || alarm.hour > 23) return SettingsFailure.outOfRange;
    if (alarm.minute < 0 || alarm.minute > 59) {
      return SettingsFailure.outOfRange;
    }
    if (alarm.minutesBefore < 0 || alarm.minutesBefore > 720) {
      return SettingsFailure.outOfRange;
    }
    if (alarm.volume < 0 || alarm.volume > 1) return SettingsFailure.outOfRange;
    if (alarm.repeat == AlarmRepeat.weekdays &&
        (alarm.weekdays.isEmpty ||
            alarm.weekdays.any(
              (d) => d < DateTime.monday || d > DateTime.sunday,
            ))) {
      return SettingsFailure.invalid;
    }
    return null;
  }

  void _touched(String id) => ref
      .read(wakeBookkeepingProvider.notifier)
      .touched(id, ref.read(clockProvider).now().toUtc());

  /// Adds a new alarm. Returns why it was refused, or null.
  SettingsFailure? addAlarm(WakeAlarm alarm) {
    final failure = _validate(alarm);
    if (failure != null) return failure;
    if (ref.read(settingsProvider).wakeAlarms.any((a) => a.id == alarm.id)) {
      return SettingsFailure.duplicate;
    }
    ref.read(settingsProvider.notifier).upsertWakeAlarm(alarm);
    _touched(alarm.id);
    return null;
  }

  /// Replaces the alarm with the same id.
  SettingsFailure? updateAlarm(WakeAlarm alarm) {
    final failure = _validate(alarm);
    if (failure != null) return failure;
    if (ref.read(settingsProvider).wakeAlarms.every((a) => a.id != alarm.id)) {
      return SettingsFailure.notFound;
    }
    ref.read(settingsProvider.notifier).upsertWakeAlarm(alarm);
    _touched(alarm.id);
    return null;
  }

  /// Switches an alarm on or off.
  SettingsFailure? setEnabled(String id, {required bool enabled}) {
    final alarm = _savedAlarm(id);
    if (alarm == null) return SettingsFailure.notFound;
    ref
        .read(settingsProvider.notifier)
        .upsertWakeAlarm(alarm.copyWith(enabled: enabled));
    _touched(id);
    return null;
  }

  /// Deletes an alarm (and its OS wake request, on the next sync).
  SettingsFailure? deleteAlarm(String id) {
    final failure = ref.read(settingsProvider.notifier).removeWakeAlarm(id);
    if (failure != null) return failure;
    ref.read(wakeBookkeepingProvider.notifier).forgotten(id);
    if (state.ringingAlarmId == id) unawaited(stopRinging());
    return null;
  }

  WakeAlarm? _savedAlarm(String id) {
    for (final alarm in ref.read(settingsProvider).wakeAlarms) {
      if (alarm.id == id) return alarm;
    }
    return null;
  }

  // ---- capability ---------------------------------------------------------

  /// Runs the self-test: what this PC allows. The result is kept in the state.
  Future<WakeCapability> probe() async {
    _set((s) => s.copyWith(probing: true));
    try {
      final capability = await _service.probe();
      _set(
        (s) => s.copyWith(
          capability: capability,
          probing: false,
          clearProblem: s.problem == WakeProblem.probeFailed,
        ),
      );
      return capability;
    } on Object catch (error, stack) {
      _log.warning('Probe failed', error, stack);
      final capability = WakeCapability(
        taskCreationOk: false,
        lastError: error.toString(),
      );
      _set(
        (s) => s.copyWith(
          capability: capability,
          probing: false,
          problem: WakeProblem.probeFailed,
          problemDetail: error.toString(),
        ),
      );
      return capability;
    }
  }

  /// Opens the Windows power options so the user can allow wake timers. The
  /// app itself never changes a power setting.
  Future<bool> openPowerOptions() => _service.openPowerOptions();

  // ---- sleep / hibernate now ---------------------------------------------

  /// Starts the 5-second cancellable countdown, then puts the PC to sleep.
  Future<void> sleepNow() =>
      _manualSuspend(WakeCountdownKind.sleepNow, AfterSound.sleep);

  /// Starts the 5-second cancellable countdown, then hibernates the PC.
  Future<void> hibernateNow() =>
      _manualSuspend(WakeCountdownKind.hibernateNow, AfterSound.hibernate);

  Future<void> _manualSuspend(WakeCountdownKind kind, AfterSound action) async {
    final token = _abortFlow();
    final elapsed = await _runCountdown(
      kind,
      action,
      WakeTimings.manualCountdown,
      token: token,
    );
    if (!elapsed || !_alive(token)) return;
    await _suspend(action);
  }

  /// Cancels the running suspend countdown. After an alarm the PC then stays
  /// awake ([WakeTimings.stayAwakeAfter]); nothing is suspended.
  void cancelCountdown() {
    final done = _countdownDone;
    if (done == null || done.isCompleted) return;
    _countdown?.cancel();
    _set((s) => s.copyWith(countdown: WakeCountdownState.idle));
    done.complete(false);
  }

  Future<bool> _runCountdown(
    WakeCountdownKind kind,
    AfterSound action,
    Duration total, {
    required int token,
    String? alarmId,
  }) {
    _countdown?.cancel();
    final previous = _countdownDone;
    if (previous != null && !previous.isCompleted) previous.complete(false);
    final done = Completer<bool>();
    _countdownDone = done;
    final initial = WakeCountdownState(
      kind: kind,
      action: action,
      total: total,
      remaining: total,
      alarmId: alarmId,
    );
    _set((s) => s.copyWith(countdown: initial));
    _countdown = Countdown.start(
      total: total,
      onTick: (remaining) {
        if (!done.isCompleted && remaining > Duration.zero) {
          _set((s) => s.copyWith(countdown: initial.withRemaining(remaining)));
        }
      },
      onDone: () {
        if (done.isCompleted) return;
        _set((s) => s.copyWith(countdown: WakeCountdownState.idle));
        done.complete(true);
      },
    );
    return done.future;
  }

  Future<void> _suspend(AfterSound action) async {
    await _release();
    final control = ref.read(powerControlProvider);
    final result = action == AfterSound.hibernate
        ? await control.hibernate()
        : await control.sleep();
    switch (result) {
      case PowerResult.ok:
        _set((s) => s.copyWith(clearProblem: true));
      case PowerResult.refused:
        _log.warning('Windows refused to ${action.name}');
        _set(
          (s) => s.copyWith(
            problem: WakeProblem.suspendRefused,
            problemDetail: action.name,
          ),
        );
      case PowerResult.unavailable:
        _log.warning('${action.name} is not available');
        _set(
          (s) => s.copyWith(
            problem: WakeProblem.hibernateUnavailable,
            problemDetail: action.name,
          ),
        );
    }
  }

  // ---- the alarm itself -----------------------------------------------------

  /// Entry point for a `wakeAlarm` event from the schedule engine (bound to
  /// the dispatcher through `wakeAlarmEventHandlerProvider`).
  ///
  /// Returns as soon as the flow has started: the sound and the countdown
  /// run in the background, so the engine is never blocked for minutes and
  /// the azan keeps its schedule. Never throws.
  Future<void> handleWakeEvent(ScheduledEvent event) async {
    try {
      if (_disposed) return;
      final id = event.alarmId;
      if (id == null) return;
      final book = ref.read(wakeBookkeepingProvider);
      final test = book.test;
      final isTest = test != null && test.alarm.id == id;
      final alarm = isTest ? test.alarm : _savedAlarm(id);
      if (alarm == null || !alarm.enabled) {
        _log.info('Wake event $id ignored: alarm is gone or disabled');
        return;
      }
      final bookkeeping = ref.read(wakeBookkeepingProvider.notifier);
      if (isTest) {
        bookkeeping.setTest(null);
      } else if (alarm.repeat == AlarmRepeat.once) {
        // A one-time alarm switches itself off after it fired. This is the
        // one background write to the settings and it is allowed: the user
        // chose "once" for this alarm, so disabling it is carrying out their
        // own setting (the app never changes a setting the user did not ask
        // to change). Only `enabled` changes.
        bookkeeping.fired(id);
        ref
            .read(settingsProvider.notifier)
            .upsertWakeAlarm(alarm.copyWith(enabled: false));
      }
      // Recompute: a repeating alarm's next occurrence, and the OS wake
      // request for it, must now point at the following day.
      bookkeeping.bump();
      final token = _abortFlow();
      unawaited(_runFlow(alarm, token));
    } on Object catch (error, stack) {
      _log.severe('Handling the wake event failed', error, stack);
    }
  }

  /// Call when the app was started by a wake task (`--wake <id>`): holds the
  /// PC awake for a short time so it cannot fall asleep again before the
  /// alarm runs. The alarm itself is found by the schedule engine's catch-up.
  Future<void> noteWakeLaunch(String alarmId) async {
    _log.info('Started by the wake task of $alarmId');
    if (state.ringingAlarmId != null || state.countdown.active) return;
    await _stayAwake(WakeTimings.launchGuard);
    ref.read(wakeBookkeepingProvider.notifier).bump();
  }

  bool _alive(int token) => !_disposed && token == _flowToken;

  /// Ends whatever alarm flow or countdown is running and returns the token
  /// of the next one.
  int _abortFlow() {
    final token = ++_flowToken;
    final wasRinging = state.ringingAlarmId != null;
    _ringCap?.cancel();
    final done = _countdownDone;
    if (done != null && !done.isCompleted) {
      _countdown?.cancel();
      done.complete(false);
    }
    _set(
      (s) => s.copyWith(countdown: WakeCountdownState.idle, clearRinging: true),
    );
    if (wasRinging) unawaited(_player.stop());
    return token;
  }

  Future<void> _runFlow(WakeAlarm alarm, int token) async {
    try {
      _set((s) => s.copyWith(ringingAlarmId: alarm.id));
      _hold?.cancel();
      _hold = null;
      await _keepAwake(null);
      var soundOk = true;
      if (alarm.playSound) soundOk = await _playSound(alarm, token);
      if (!_alive(token)) return;
      _set((s) => s.copyWith(clearRinging: true));

      if (alarm.afterSound == AfterSound.nothing || !soundOk) {
        // Nothing to do afterwards, or the alarm could not be heard: do not
        // put the PC back to sleep behind the user's back.
        await _stayAwake(WakeTimings.stayAwakeAfter);
        return;
      }
      final elapsed = await _runCountdown(
        WakeCountdownKind.afterAlarm,
        alarm.afterSound,
        WakeTimings.afterAlarmCountdown,
        token: token,
        alarmId: alarm.id,
      );
      if (!_alive(token)) return;
      if (!elapsed) {
        // Cancelled: the PC stays awake for a while so the user can use it.
        await _stayAwake(WakeTimings.stayAwakeAfter);
        return;
      }
      await _suspend(alarm.afterSound);
    } on Object catch (error, stack) {
      _log.severe('Alarm ${alarm.id} failed', error, stack);
      if (_alive(token)) {
        _set((s) => s.copyWith(clearRinging: true));
        await _stayAwake(WakeTimings.stayAwakeAfter);
      }
    }
  }

  /// Plays the alarm sound, falling back to the bundled default once.
  /// Returns false if nothing could be played.
  Future<bool> _playSound(WakeAlarm alarm, int token) async {
    _ringCap?.cancel();
    _ringCap = Countdown.start(
      total: WakeTimings.maxRing,
      tick: WakeTimings.maxRing,
      onTick: (_) {},
      onDone: () => unawaited(_player.stop()),
    );
    try {
      for (final sound in {alarm.sound, SoundRef.defaultAzan}) {
        if (!_alive(token)) return true;
        try {
          await _player.play(sound, volume: alarm.volume);
          return true;
        } on Object catch (error, stack) {
          _log.warning('Playing $sound failed', error, stack);
          _set(
            (s) => s.copyWith(
              problem: WakeProblem.soundFailed,
              problemDetail: error.toString(),
            ),
          );
        }
      }
      return false;
    } finally {
      _ringCap?.cancel();
    }
  }

  /// Stops the alarm sound (the "Stop" button). The flow continues: an
  /// `afterSound` action still waits behind its cancellable countdown.
  Future<void> stopRinging() => _player.stop();

  // ---- keeping the PC awake ----------------------------------------------

  Future<void> _keepAwake(Duration? maxDuration) async {
    try {
      await _service.keepAwake(maxDuration);
    } on Object catch (error, stack) {
      _log.warning('keepAwake failed', error, stack);
    }
  }

  Future<void> _release() async {
    _hold?.cancel();
    _hold = null;
    try {
      await _service.releaseAwake();
    } on Object catch (error, stack) {
      _log.warning('releaseAwake failed', error, stack);
    }
  }

  /// Holds the PC awake for [duration], then releases it.
  Future<void> _stayAwake(Duration duration) async {
    _hold?.cancel();
    await _keepAwake(duration);
    if (_disposed) return;
    _hold = Countdown.start(
      total: duration,
      tick: duration,
      onTick: (_) {},
      onDone: () {
        _hold = null;
        unawaited(_release());
      },
    );
  }

  // ---- test alarm ---------------------------------------------------------

  /// Schedules a one-off alarm two minutes from now (not saved in the
  /// settings) so the user can put the PC to sleep and see whether it wakes.
  /// Returns the instant it will ring at.
  DateTime testInTwoMinutes() {
    final clock = ref.read(clockProvider);
    final raw = clock.now().toUtc().add(WakeTimings.testDelay);
    final at = DateTime.fromMillisecondsSinceEpoch(
      raw.millisecondsSinceEpoch ~/ 1000 * 1000,
      isUtc: true,
    );
    final location = ref.read(activeLocationProvider);
    final resolver = ref.read(zoneOffsetResolverProvider);
    final date = resolver.civilDateAt(
      at,
      resolver.currentOffset(
        rule: location.offset,
        zoneId: location.zoneId,
        instant: at,
      ),
    );
    final id = 'wake-test-${at.millisecondsSinceEpoch ~/ 1000}';
    ref
        .read(wakeBookkeepingProvider.notifier)
        .setTest(
          WakeTestAlarm(
            alarm: WakeAlarm(id: id, repeat: AlarmRepeat.once),
            occurrence: WakeOccurrence(alarmId: id, instantUtc: at, date: date),
          ),
        );
    return at;
  }

  /// Cancels the pending test alarm.
  void cancelTest() => ref.read(wakeBookkeepingProvider.notifier).setTest(null);

  // ---- keeping the OS wake requests in step -------------------------------

  /// Re-checks the OS requests against the current plan one microtask later
  /// (see [build]). Several requests in a row become one check.
  void _resyncSoon() {
    if (_resyncQueued || _disposed) return;
    _resyncQueued = true;
    unawaited(
      Future<void>.microtask(() {
        _resyncQueued = false;
        if (_disposed) return;
        _updateHourlyCheck();
        _requestSync(ref.read(wakeAlarmPlanProvider));
      }),
    );
  }

  /// A safety net: once an hour the plan is recomputed and the OS requests
  /// are checked again, which covers a date or offset change nobody told us
  /// about and retries a request that failed earlier.
  ///
  /// It only runs while at least one alarm is enabled, so an app without
  /// alarms keeps no timer at all.
  void _updateHourlyCheck() {
    final needed = ref.read(settingsProvider).wakeAlarms.any((a) => a.enabled);
    if (!needed) {
      _hourly?.cancel();
      _hourly = null;
    } else if (_hourly == null) {
      _startHourlyCheck();
    }
  }

  void _startHourlyCheck() {
    _hourly?.cancel();
    _hourly = Countdown.start(
      total: WakeTimings.recheckEvery,
      tick: WakeTimings.recheckEvery,
      onTick: (_) {},
      onDone: () {
        if (_disposed) return;
        ref.read(wakeBookkeepingProvider.notifier).bump();
        _hourly = null;
        _updateHourlyCheck();
      },
    );
  }

  void _requestSync(WakeAlarmPlan plan) {
    final now = ref.read(clockProvider).now().toUtc();
    final wanted = <String, DateTime>{};
    for (final entry in plan.upcoming.entries) {
      if (!isSafeWakeId(entry.key)) {
        _log.warning('Alarm ${entry.key} has an id unusable for a wake task');
        continue;
      }
      final wake = entry.value.instantUtc.subtract(WakeTimings.wakeLead);
      // Too close: the PC is awake, a wake request would be pointless (and a
      // past trigger could start the task at once).
      if (wake.isAfter(now.add(WakeTimings.minimumLead))) {
        wanted[entry.key] = wake;
      }
    }
    _wanted = wanted;
    if (_syncing) {
      _syncDirty = true;
      return;
    }
    unawaited(_syncLoop());
  }

  Future<void> _syncLoop() async {
    _syncing = true;
    try {
      do {
        _syncDirty = false;
        await _syncOnce();
      } while (_syncDirty && !_disposed);
    } on Object catch (error, stack) {
      _log.severe('Syncing the OS wake requests failed', error, stack);
    } finally {
      _syncing = false;
    }
  }

  Future<void> _syncOnce() async {
    final wanted = Map<String, DateTime>.of(_wanted);
    final errors = <String>[];

    if (!_listed) {
      try {
        for (final id in await _service.pendingIds()) {
          _armed.putIfAbsent(id, () => null);
        }
        _listed = true;
      } on Object catch (error) {
        errors.add('list: $error');
      }
    }

    for (final entry in wanted.entries) {
      if (_disposed) return;
      if (_armed.containsKey(entry.key) && _armed[entry.key] == entry.value) {
        continue;
      }
      try {
        await _service.scheduleWake(entry.value, entry.key);
        _armed[entry.key] = entry.value;
      } on Object catch (error) {
        errors.add('${entry.key}: $error');
      }
    }

    for (final id in _armed.keys.toList()) {
      if (_disposed) return;
      if (wanted.containsKey(id)) continue;
      try {
        await _service.cancel(id);
        _armed.remove(id);
      } on Object catch (error) {
        errors.add('cancel $id: $error');
      }
    }

    _set(
      (s) => s.copyWith(
        armed: {
          for (final entry in _armed.entries)
            if (entry.value != null) entry.key: entry.value!,
        },
        syncError: errors.isEmpty ? null : errors.join('; '),
        clearSyncError: errors.isEmpty,
      ),
    );
  }
}

/// Provider of the wake-up controller and its state.
final wakeAlarmControllerProvider =
    NotifierProvider<WakeAlarmController, WakeAlarmState>(
      WakeAlarmController.new,
    );

/// The cancellable suspend countdown for the UI to show (idle when none).
final wakeCountdownProvider = Provider<WakeCountdownState>(
  (ref) => ref.watch(wakeAlarmControllerProvider.select((s) => s.countdown)),
);

/// The latest capability probe (null until probed).
final wakeCapabilityProvider = Provider<WakeCapability?>(
  (ref) => ref.watch(wakeAlarmControllerProvider.select((s) => s.capability)),
);

/// The function that carries out a `wakeAlarm` event. The dispatcher's
/// `wakeAlarmHandlerProvider` is overridden with this one.
final wakeAlarmEventHandlerProvider =
    Provider<Future<void> Function(ScheduledEvent event)>(
      (ref) => ref.watch(wakeAlarmControllerProvider.notifier).handleWakeEvent,
    );
