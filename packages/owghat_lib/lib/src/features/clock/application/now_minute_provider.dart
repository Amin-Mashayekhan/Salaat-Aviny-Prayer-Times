import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';

/// The current time (UTC) cut to the whole minute. It only notifies once a
/// minute, so screens that need no seconds (the compass, the diagnostics)
/// do not rebuild every second.
final nowMinuteProvider = Provider<DateTime>(
  (ref) => ref.watch(
    nowProvider.select(
      (now) => DateTime.fromMillisecondsSinceEpoch(
        now.millisecondsSinceEpoch ~/
            Duration.millisecondsPerMinute *
            Duration.millisecondsPerMinute,
        isUtc: true,
      ),
    ),
  ),
);
