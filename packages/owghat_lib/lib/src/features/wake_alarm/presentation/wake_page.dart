import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/clock/application/local_offset_provider.dart';
import 'package:owghat_lib/src/features/clock/application/now_minute_provider.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_labels.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_plan_providers.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_alarm.dart';
import 'package:owghat_lib/src/features/wake_alarm/presentation/alarm_editor_dialog.dart';
import 'package:owghat_lib/src/features/wake_alarm/presentation/capability_panel.dart';

/// The Wake-up screen (`docs/05-UI-UX-SPEC.md` 4.5): the capability panel,
/// the alarm cards with an add button, the "test in 2 minutes" action, the
/// "sleep now" / "hibernate now" buttons with their cancellable countdown,
/// and the plain-language notices for anything that went wrong.
class WakeUpPage extends ConsumerStatefulWidget {
  /// Creates the page.
  const WakeUpPage({super.key});

  @override
  ConsumerState<WakeUpPage> createState() => _WakeUpPageState();
}

class _WakeUpPageState extends ConsumerState<WakeUpPage> {
  /// A problem the user closed; it stays hidden until a different one comes.
  WakeProblem? _dismissedProblem;
  bool _syncDismissed = false;

  @override
  void initState() {
    super.initState();
    // Find out what this PC allows every time the page opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(wakeAlarmControllerProvider.notifier).probe());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final controller = ref.read(wakeAlarmControllerProvider.notifier);
    final ringing = ref.watch(
      wakeAlarmControllerProvider.select((s) => s.ringingAlarmId),
    );
    final problem = ref.watch(
      wakeAlarmControllerProvider.select((s) => s.problem),
    );
    final syncError = ref.watch(
      wakeAlarmControllerProvider.select((s) => s.syncError != null),
    );
    final alarms = ref.watch(settingsProvider.select((s) => s.wakeAlarms));
    final fmt = ref.watch(formatterProvider);
    final test = ref.watch(wakeBookkeepingProvider.select((b) => b.test));
    final localOffset = ref.watch(localOffsetAtProvider);

    // A dismissed notice comes back if the problem went away and returned.
    if (problem == null) _dismissedProblem = null;
    if (!syncError) _syncDismissed = false;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(Gaps.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.wakeTitle, style: theme.textTheme.headlineMedium),
              const SizedBox(height: Gaps.m),
              if (ringing != null) ...[
                _Notice(
                  key: const Key('wake-ringing'),
                  textKey: const Key('wake-ringing-text'),
                  icon: Icons.alarm_on,
                  color: colors.accentWarm,
                  text: l10n.wakeRinging,
                  action: FilledButton(
                    key: const Key('wake-stop'),
                    onPressed: () => unawaited(controller.stopRinging()),
                    child: Text(l10n.wakeStop),
                  ),
                ),
                const SizedBox(height: Gaps.m),
              ],
              const WakeCapabilityPanel(),
              const SizedBox(height: Gaps.m),
              if (problem != null && problem != _dismissedProblem) ...[
                _Notice(
                  key: const Key('wake-problem'),
                  textKey: const Key('wake-problem-text'),
                  icon: Icons.error_outline,
                  color: colors.danger,
                  text: problem.text(l10n),
                  action: TextButton(
                    key: const Key('wake-problem-dismiss'),
                    onPressed: () =>
                        setState(() => _dismissedProblem = problem),
                    child: Text(l10n.wakeDismiss),
                  ),
                ),
                const SizedBox(height: Gaps.m),
              ],
              if (syncError && !_syncDismissed) ...[
                _Notice(
                  key: const Key('wake-sync-error'),
                  textKey: const Key('wake-sync-error-text'),
                  icon: Icons.sync_problem,
                  color: colors.warning,
                  text: l10n.wakeSyncError,
                  action: TextButton(
                    key: const Key('wake-sync-dismiss'),
                    onPressed: () => setState(() => _syncDismissed = true),
                    child: Text(l10n.wakeDismiss),
                  ),
                ),
                const SizedBox(height: Gaps.m),
              ],
              Wrap(
                spacing: Gaps.m,
                runSpacing: Gaps.s,
                children: [
                  FilledButton.icon(
                    key: const Key('wake-add'),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.wakeAdd),
                    onPressed: () => unawaited(showAlarmEditor(context)),
                  ),
                  OutlinedButton.icon(
                    key: const Key('wake-test'),
                    icon: const Icon(Icons.science_outlined),
                    label: Text(l10n.wakeTest),
                    onPressed: test == null
                        ? controller.testInTwoMinutes
                        : null,
                  ),
                  OutlinedButton.icon(
                    key: const Key('wake-sleep-now'),
                    icon: const Icon(Icons.nightlight_outlined),
                    label: Text(l10n.wakeSleepNow),
                    onPressed: () => unawaited(controller.sleepNow()),
                  ),
                  OutlinedButton.icon(
                    key: const Key('wake-hibernate-now'),
                    icon: const Icon(Icons.bedtime_outlined),
                    label: Text(l10n.wakeHibernateNow),
                    onPressed: () => unawaited(controller.hibernateNow()),
                  ),
                ],
              ),
              const SizedBox(height: Gaps.s),
              Text(
                l10n.wakeSleepHint,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (test != null) ...[
                const SizedBox(height: Gaps.m),
                _Notice(
                  key: const Key('wake-test-pending'),
                  textKey: const Key('wake-test-pending-text'),
                  icon: Icons.science_outlined,
                  color: colors.success,
                  text: l10n.wakeTestPending(
                    Formatter.isolate(
                      fmt.formatInstant(
                        test.occurrence.instantUtc,
                        localOffset(test.occurrence.instantUtc),
                      ),
                    ),
                  ),
                  action: TextButton(
                    key: const Key('wake-test-cancel'),
                    onPressed: controller.cancelTest,
                    child: Text(l10n.wakeTestCancel),
                  ),
                ),
              ],
              const SizedBox(height: Gaps.l),
              if (alarms.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(Gaps.l),
                    child: Text(
                      l10n.wakeEmpty,
                      key: const Key('wake-empty'),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                )
              else
                for (final alarm in alarms) ...[
                  AlarmCard(alarm: alarm, ringing: alarm.id == ringing),
                  const SizedBox(height: Gaps.m),
                ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A coloured one-line notice with an action; the icon repeats the meaning
/// of the colour.
class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.color,
    required this.text,
    required this.action,
    required this.textKey,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String text;
  final Widget action;
  final Key textKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: color.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(color: color),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Gaps.m),
        child: Wrap(
          spacing: Gaps.m,
          runSpacing: Gaps.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color),
                const SizedBox(width: Gaps.s),
                // Flexible text inside a min-size row needs a width limit.
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    text,
                    key: textKey,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            action,
          ],
        ),
      ),
    );
  }
}

/// One alarm: name, when it rings, repeat, what happens afterwards, when it
/// rings next, and the switch / edit / delete controls.
class AlarmCard extends ConsumerWidget {
  /// Creates the card.
  const AlarmCard({required this.alarm, this.ringing = false, super.key});

  /// The alarm.
  final WakeAlarm alarm;

  /// Whether this alarm is ringing right now.
  final bool ringing;

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.wakeDeleteTitle),
        content: Text(l10n.wakeDeleteBody),
        actions: [
          TextButton(
            key: const Key('wake-delete-cancel'),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.wakeCancel),
          ),
          FilledButton(
            key: const Key('wake-delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.wakeDeleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      ref.read(wakeAlarmControllerProvider.notifier).deleteAlarm(alarm.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final fmt = ref.watch(formatterProvider);
    final names = ref.watch(calendarNamesProvider);
    final now = ref.watch(nowMinuteProvider);
    final today = ref.watch(todayProvider);
    final localOffset = ref.watch(localOffsetAtProvider);
    final next = ref.watch(
      wakeAlarmPlanProvider.select((p) => p.upcoming[alarm.id]),
    );

    final trigger = describeTrigger(l10n, fmt, alarm);
    final title = alarm.label.isEmpty ? trigger : alarm.label;
    final after = switch (alarm.afterSound) {
      AfterSound.nothing => null,
      AfterSound.sleep => l10n.wakeAfterSleep,
      AfterSound.hibernate => l10n.wakeAfterHibernate,
    };
    final nextText = !alarm.enabled
        ? l10n.wakeOff
        : next == null
        ? l10n.wakeNextNone
        : describeNext(
            l10n: l10n,
            fmt: fmt,
            names: names,
            occurrence: next,
            now: now,
            today: today,
            utcOffset: localOffset(next.instantUtc),
          );

    Widget line(String text, Key key, {bool strong = false}) => Text(
      text,
      key: key,
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: strong ? FontWeight.w700 : null,
        color: strong ? null : theme.colorScheme.onSurfaceVariant,
      ),
    );

    return Card(
      key: Key('wake-card-${alarm.id}'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(
          color: ringing ? colors.accentWarm : theme.colorScheme.outlineVariant,
          width: ringing ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.card),
        onTap: () => unawaited(showAlarmEditor(context, alarm: alarm)),
        child: Padding(
          padding: const EdgeInsets.all(Gaps.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      key: Key('wake-title-${alarm.id}'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  Semantics(
                    label: '${l10n.wakeEnabledSwitch}: $title',
                    child: Switch(
                      key: Key('wake-switch-${alarm.id}'),
                      value: alarm.enabled,
                      onChanged: (value) => ref
                          .read(wakeAlarmControllerProvider.notifier)
                          .setEnabled(alarm.id, enabled: value),
                    ),
                  ),
                ],
              ),
              if (alarm.label.isNotEmpty)
                line(trigger, Key('wake-trigger-${alarm.id}')),
              line(
                describeRepeat(l10n, names, alarm),
                Key('wake-repeat-${alarm.id}'),
              ),
              if (after != null) line(after, Key('wake-after-${alarm.id}')),
              const SizedBox(height: Gaps.s),
              line(nextText, Key('wake-next-${alarm.id}'), strong: true),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Wrap(
                  children: [
                    IconButton(
                      key: Key('wake-edit-${alarm.id}'),
                      tooltip: l10n.wakeEdit,
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () =>
                          unawaited(showAlarmEditor(context, alarm: alarm)),
                    ),
                    IconButton(
                      key: Key('wake-delete-${alarm.id}'),
                      tooltip: l10n.wakeDelete,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => unawaited(_confirmDelete(context, ref)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
