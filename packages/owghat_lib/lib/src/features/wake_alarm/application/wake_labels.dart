import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/next_occurrence.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';
import 'package:prayer_core/prayer_core.dart';

/// Weekdays in the order of the Persian week (Saturday first), as ISO
/// weekday numbers.
const List<int> persianWeekOrder = [6, 7, 1, 2, 3, 4, 5];

/// Plain, localised text for each reason a wake-up may not work. Nothing
/// here shows raw exception text.
extension WakeIssueText on WakeIssue {
  /// The sentence for this issue.
  String text(AppLocalizations l10n) => switch (this) {
    WakeIssue.taskCreationFailed => l10n.wakeIssueTaskCreationFailed,
    WakeIssue.wakeTimersDisabledOnAc => l10n.wakeIssueTimersOffAc,
    WakeIssue.wakeTimersDisabledOnBattery => l10n.wakeIssueTimersOffBattery,
    WakeIssue.wakeTimersImportantOnly => l10n.wakeIssueImportantOnly,
    WakeIssue.powerSettingUnknown => l10n.wakeIssueUnknown,
    WakeIssue.inProcessTimerUnavailable => l10n.wakeIssueInProcessTimer,
    WakeIssue.modernStandby => l10n.wakeIssueModernStandby,
  };
}

/// Plain, localised text for a background wake-up problem.
extension WakeProblemText on WakeProblem {
  /// The sentence for this problem.
  String text(AppLocalizations l10n) => switch (this) {
    WakeProblem.soundFailed => l10n.wakeProblemSoundFailed,
    WakeProblem.suspendRefused => l10n.wakeProblemSuspendRefused,
    WakeProblem.hibernateUnavailable => l10n.wakeProblemHibernateUnavailable,
    WakeProblem.probeFailed => l10n.wakeProblemProbeFailed,
  };
}

/// "At 04:00" or "40 min before Fajr".
String describeTrigger(AppLocalizations l10n, Formatter fmt, WakeAlarm alarm) {
  switch (alarm.trigger) {
    case AlarmTriggerKind.fixedTime:
      return l10n.wakeTriggerFixed(
        Formatter.isolate(
          fmt.formatTime(Duration(hours: alarm.hour, minutes: alarm.minute)),
        ),
      );
    case AlarmTriggerKind.relativeToPrayer:
      if (alarm.minutesBefore == 0) {
        return l10n.wakeTriggerAtPrayer(alarm.prayer.label(l10n));
      }
      return l10n.wakeTriggerRelative(
        fmt.formatDuration(Duration(minutes: alarm.minutesBefore)),
        alarm.prayer.label(l10n),
      );
  }
}

/// "Once", "Every day" or "On Saturday, Sunday".
String describeRepeat(
  AppLocalizations l10n,
  CalendarNames names,
  WakeAlarm alarm,
) {
  switch (alarm.repeat) {
    case AlarmRepeat.once:
      return l10n.wakeRepeatOnce;
    case AlarmRepeat.daily:
      return l10n.wakeRepeatDaily;
    case AlarmRepeat.weekdays:
      final days = [
        for (final iso in persianWeekOrder)
          if (alarm.weekdays.contains(iso)) names.weekday(iso),
      ];
      if (days.length == 7) return l10n.wakeRepeatDaily;
      return l10n.wakeRepeatWeekdays(days.join(l10n.wakeListSeparator));
  }
}

/// "Next: 3 h 20 min from now (04:00)", with the weekday when the alarm
/// rings on another day than [today].
String describeNext({
  required AppLocalizations l10n,
  required Formatter fmt,
  required CalendarNames names,
  required WakeOccurrence occurrence,
  required DateTime now,
  required CivilDate today,
  required Duration utcOffset,
}) {
  final remaining = fmt.formatDurationWords(
    occurrence.instantUtc.difference(now),
  );
  final time = Formatter.isolate(
    fmt.formatInstant(occurrence.instantUtc, utcOffset),
  );
  if (occurrence.date == today) return l10n.wakeNext(remaining, time);
  return l10n.wakeNextOtherDay(
    remaining,
    names.weekday(occurrence.date.weekday),
    time,
  );
}

/// The short form for the Home status card: "04:00", or "Thursday 04:00"
/// when it rings on another day than [today].
String describeNextShort({
  required Formatter fmt,
  required CalendarNames names,
  required WakeOccurrence occurrence,
  required CivilDate today,
  required Duration utcOffset,
}) {
  final time = Formatter.isolate(
    fmt.formatInstant(occurrence.instantUtc, utcOffset),
  );
  if (occurrence.date == today) return time;
  return '${names.weekday(occurrence.date.weekday)} $time';
}
