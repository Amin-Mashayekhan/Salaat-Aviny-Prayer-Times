import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prayer_core/prayer_core.dart';

/// Runs a due wake-up alarm event. The dispatcher forwards every
/// `EventKind.wakeAlarm` event (decision `fire` or `fireLate`) here.
///
/// The default does nothing; the wake-up feature overrides it.
final wakeAlarmHandlerProvider =
    Provider<Future<void> Function(ScheduledEvent event)>(
      (ref) => (event) async {},
    );
