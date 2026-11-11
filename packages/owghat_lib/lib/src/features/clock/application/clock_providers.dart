import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/time/network_time_source.dart';
import 'package:owghat_lib/src/core/time/system_clock.dart';
import 'package:owghat_lib/src/core/time/system_zone.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';

/// The uncorrected system clock. Tests override it.
final systemClockProvider = Provider<Clock>((ref) => systemClock);

/// The network time source. Tests override it.
final networkTimeSourceProvider = Provider<NetworkTimeSource>(
  (ref) => const NtpNetworkTimeSource(),
);

/// The Windows time zone view. Tests override it.
final systemZoneProvider = Provider<SystemZone>(
  (ref) => const DartSystemZone(),
);

/// The zone resolver (the only decider of UTC offsets).
final zoneOffsetResolverProvider = Provider<ZoneOffsetResolver>(
  (ref) => ZoneOffsetResolver(),
);

/// How often the network clock is checked while enabled.
const Duration networkTimeCheckInterval = Duration(hours: 6);

/// Result of the latest network time check.
class ClockCorrectionState {
  /// Creates a state.
  const ClockCorrectionState({
    this.offset,
    this.checkedAt,
    this.error,
    this.checking = false,
  });

  /// Network time minus PC time at [checkedAt], or null if never measured.
  final Duration? offset;

  /// When the measurement was taken (PC clock).
  final DateTime? checkedAt;

  /// Text of the last failure, if the last check failed.
  final String? error;

  /// A check is running.
  final bool checking;

  /// Copy with changes; [error] and [offset] can be cleared explicitly.
  ClockCorrectionState copyWith({
    Duration? offset,
    DateTime? checkedAt,
    String? error,
    bool? checking,
    bool clearError = false,
  }) => ClockCorrectionState(
    offset: offset ?? this.offset,
    checkedAt: checkedAt ?? this.checkedAt,
    error: clearError ? null : (error ?? this.error),
    checking: checking ?? this.checking,
  );
}

/// Measures the PC clock against network time when the user enabled it.
///
/// It never touches the Windows clock. The measured offset is only applied
/// inside the app, and only when `applyCorrection` is on.
class ClockCorrectionController extends Notifier<ClockCorrectionState> {
  Timer? _timer;

  @override
  ClockCorrectionState build() {
    final enabled = ref.watch(
      settingsProvider.select((s) => s.networkTime.enabled),
    );
    ref.watch(settingsProvider.select((s) => s.networkTime.host));
    ref.onDispose(() => _timer?.cancel());
    _timer?.cancel();
    _timer = null;
    if (enabled) {
      unawaited(Future<void>.microtask(check));
      _timer = Timer.periodic(networkTimeCheckInterval, (_) => check());
    }
    return const ClockCorrectionState();
  }

  /// Runs one check now.
  Future<void> check() async {
    final settings = ref.read(settingsProvider).networkTime;
    if (!settings.enabled) return;
    state = state.copyWith(checking: true);
    try {
      final offset = await ref
          .read(networkTimeSourceProvider)
          .measureOffset(settings.host);
      state = ClockCorrectionState(
        offset: offset,
        checkedAt: ref.read(systemClockProvider).now(),
      );
    } on Object catch (error) {
      state = state.copyWith(checking: false, error: error.toString());
    }
  }
}

/// Provider of the network time check state.
final clockCorrectionProvider =
    NotifierProvider<ClockCorrectionController, ClockCorrectionState>(
      ClockCorrectionController.new,
    );

/// The correction applied inside the app: zero unless the user turned the
/// check and the correction on and a measurement exists.
final effectiveCorrectionProvider = Provider<Duration>((ref) {
  final settings = ref.watch(settingsProvider.select((s) => s.networkTime));
  if (!settings.enabled || !settings.applyCorrection) return Duration.zero;
  return ref.watch(clockCorrectionProvider.select((s) => s.offset)) ??
      Duration.zero;
});

/// The clock everything in the app asks for the current time.
final clockProvider = Provider<Clock>((ref) {
  final base = ref.watch(systemClockProvider);
  final correction = ref.watch(effectiveCorrectionProvider);
  if (correction == Duration.zero) return base;
  return Clock(() => base.now().add(correction));
});
