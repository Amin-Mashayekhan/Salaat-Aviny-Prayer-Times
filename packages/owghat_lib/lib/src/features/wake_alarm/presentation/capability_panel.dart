import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_labels.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';

/// The result of the wake-timer probe: green when this PC can wake itself,
/// amber with plain reasons and a button to Windows Power Options when it
/// may not. The app never changes a power setting itself.
class WakeCapabilityPanel extends ConsumerStatefulWidget {
  /// Creates the panel.
  const WakeCapabilityPanel({super.key});

  @override
  ConsumerState<WakeCapabilityPanel> createState() =>
      _WakeCapabilityPanelState();
}

class _WakeCapabilityPanelState extends ConsumerState<WakeCapabilityPanel> {
  bool _openFailed = false;

  Future<void> _openPowerOptions() async {
    final opened = await ref
        .read(wakeAlarmControllerProvider.notifier)
        .openPowerOptions();
    if (mounted) setState(() => _openFailed = !opened);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final capability = ref.watch(wakeCapabilityProvider);
    final probing = ref.watch(
      wakeAlarmControllerProvider.select((s) => s.probing),
    );

    final issues = capability?.issues ?? const <WakeIssue>[];
    final ok = capability != null && capability.canWake && issues.isEmpty;
    final accent = capability == null
        ? theme.colorScheme.outline
        : ok
        ? colors.success
        : colors.warning;

    final String title;
    if (capability == null) {
      title = probing
          ? l10n.wakeCapabilityChecking
          : l10n.wakeCapabilityUnknown;
    } else if (ok) {
      title = l10n.wakeCapabilityOkTitle;
    } else {
      title = l10n.wakeCapabilityWarnTitle;
    }

    return Card(
      key: Key(
        capability == null
            ? 'wake-capability-unknown'
            : ok
            ? 'wake-capability-ok'
            : 'wake-capability-warn',
      ),
      color: accent.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Radii.card),
        side: BorderSide(color: accent, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The icon repeats what the colour says.
                Icon(
                  capability == null
                      ? Icons.help_outline
                      : ok
                      ? Icons.check_circle_outline
                      : Icons.warning_amber_rounded,
                  color: accent,
                ),
                const SizedBox(width: Gaps.m),
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      title,
                      key: const Key('wake-capability-title'),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
                if (probing)
                  const Padding(
                    padding: EdgeInsets.all(Gaps.s),
                    child: SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    key: const Key('wake-refresh'),
                    tooltip: l10n.wakeCapabilityRefresh,
                    icon: const Icon(Icons.refresh),
                    onPressed: () => unawaited(
                      ref.read(wakeAlarmControllerProvider.notifier).probe(),
                    ),
                  ),
              ],
            ),
            if (ok) ...[
              const SizedBox(height: Gaps.s),
              Text(
                l10n.wakeCapabilityOkBody,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (capability != null && !ok) ...[
              const SizedBox(height: Gaps.s),
              for (final issue in issues)
                Padding(
                  padding: const EdgeInsets.only(bottom: Gaps.s),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2, right: Gaps.s),
                        child: Icon(Icons.circle, size: 8, color: accent),
                      ),
                      Expanded(
                        child: Text(
                          issue.text(l10n),
                          key: Key('wake-issue-${issue.name}'),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              Text(
                l10n.wakePowerHint,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Gaps.m),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.tonalIcon(
                  key: const Key('wake-open-power'),
                  icon: const Icon(Icons.power_settings_new),
                  label: Text(l10n.wakeOpenPowerOptions),
                  onPressed: _openPowerOptions,
                ),
              ),
              if (_openFailed)
                Padding(
                  padding: const EdgeInsets.only(top: Gaps.s),
                  child: Text(
                    l10n.wakeOpenPowerFailed,
                    key: const Key('wake-open-power-failed'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
