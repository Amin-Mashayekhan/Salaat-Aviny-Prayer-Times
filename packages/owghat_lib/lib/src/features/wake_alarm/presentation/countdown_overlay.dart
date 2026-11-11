import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_countdown_state.dart';

/// The cancellable countdown before the PC is put to sleep or hibernated
/// (5 seconds after "Sleep now" / "Hibernate now", 30 seconds after an
/// alarm). It is drawn in place, never as a modal dialog: a countdown that a
/// background alarm starts must not take over the screen (rule 8 in
/// `CLAUDE.md`). Shows nothing while no countdown runs; `Esc` or the button
/// cancels it.
///
/// The Wake-up page places it itself. Because an alarm can start the
/// countdown while another screen is open, the app shell should show this
/// widget on every screen too.
class WakeCountdownOverlay extends ConsumerWidget {
  /// Creates the overlay.
  const WakeCountdownOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = ref.watch(wakeCountdownProvider);
    if (!countdown.active) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final fmt = ref.watch(formatterProvider);
    final time = fmt.formatDuration(countdown.remaining);
    final action = countdown.isHibernate
        ? l10n.wakeCountdownHibernate(time)
        : l10n.wakeCountdownSleep(time);
    final message = countdown.kind == WakeCountdownKind.afterAlarm
        ? '${l10n.wakeCountdownAfterAlarm} $action'
        : action;
    final progress = countdown.total == Duration.zero
        ? 0.0
        : (countdown.remaining.inMilliseconds / countdown.total.inMilliseconds)
              .clamp(0.0, 1.0);
    void cancel() =>
        ref.read(wakeAlarmControllerProvider.notifier).cancelCountdown();

    return CallbackShortcuts(
      bindings: {const SingleActivator(LogicalKeyboardKey.escape): cancel},
      child: Focus(
        autofocus: true,
        child: Semantics(
          container: true,
          liveRegion: true,
          label: message,
          child: Material(
            key: const Key('wake-countdown'),
            elevation: 6,
            color: theme.colorScheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Radii.card),
              side: BorderSide(color: colors.warning, width: 2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Gaps.l),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        countdown.isHibernate
                            ? Icons.bedtime_outlined
                            : Icons.nightlight_outlined,
                        color: colors.warning,
                      ),
                      const SizedBox(width: Gaps.m),
                      Expanded(
                        child: Text(
                          message,
                          key: const Key('wake-countdown-text'),
                          style: theme.textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Gaps.m),
                  LinearProgressIndicator(
                    key: const Key('wake-countdown-progress'),
                    value: progress,
                    color: colors.warning,
                  ),
                  const SizedBox(height: Gaps.m),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FilledButton(
                      key: const Key('wake-countdown-cancel'),
                      onPressed: cancel,
                      child: Text(l10n.wakeCountdownCancel),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
