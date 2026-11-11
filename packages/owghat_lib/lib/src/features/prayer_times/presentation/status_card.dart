import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/clock/application/local_offset_provider.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_status.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_labels.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_plan_providers.dart';

/// The status card: azan state with the mute menu, reminder summary, qibla
/// summary and the next wake-up alarm. Each line opens its screen.
class StatusCard extends ConsumerWidget {
  /// Creates the card.
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = ref.watch(formatterProvider);
    final theme = Theme.of(context);
    final azan = ref.watch(settingsProvider.select((s) => s.azan));
    final now = ref.watch(nowProvider);
    final reminders = summarizeReminders(
      ref.watch(settingsProvider.select((s) => s.reminders)),
    );
    final qibla = ref.watch(qiblaSummaryProvider);
    final destinations = ref.read(destinationProvider.notifier);

    final muted = azan.mute.isActiveAt(now);
    final String azanText;
    if (!azan.enabled) {
      azanText = l10n.homeAzanOff;
    } else if (muted && azan.mute.indefinite) {
      azanText = l10n.homeAzanMutedIndefinite;
    } else if (muted) {
      azanText = l10n.homeAzanMutedUntil(
        Formatter.isolate(_clock(ref, fmt, azan.mute.until!)),
      );
    } else {
      azanText = l10n.homeAzanOn;
    }

    final reminderText = reminders.isOff
        ? l10n.homeReminderOff
        : reminders.isUniform
        ? l10n.homeReminderMinutes(fmt.formatNumber(reminders.minMinutes!))
        : l10n.homeReminderRange(
            fmt.formatNumber(reminders.minMinutes!),
            fmt.formatNumber(reminders.maxMinutes!),
          );

    final qiblaText = l10n.homeQiblaSummary(
      fmt.formatNumber(qibla.bearing.round() % 360),
      l10n.homeCompass('p${qibla.compassIndex}'),
    );

    final nextWake = ref.watch(nextWakeOccurrenceProvider);
    final wakeText = nextWake == null
        ? l10n.homeNoValue
        : describeNextShort(
            fmt: fmt,
            names: ref.watch(calendarNamesProvider),
            occurrence: nextWake,
            today: ref.watch(todayProvider),
            utcOffset: ref.watch(localOffsetAtProvider)(nextWake.instantUtc),
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: Gaps.m,
          horizontal: Gaps.s,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gaps.m),
              child: Text(
                l10n.homeStatusTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: Gaps.s),
            _StatusLine(
              key: const Key('status-azan'),
              icon: azan.enabled && !muted
                  ? Icons.volume_up_outlined
                  : Icons.volume_off_outlined,
              text: azanText,
              onTap: () => destinations.select(Destination.settings),
              trailing: const _MuteMenu(),
            ),
            _StatusLine(
              key: const Key('status-reminders'),
              icon: Icons.notifications_outlined,
              text: reminderText,
              onTap: () => destinations.select(Destination.settings),
            ),
            _StatusLine(
              key: const Key('status-qibla'),
              icon: Icons.explore_outlined,
              text: qiblaText,
              onTap: () => destinations.select(Destination.qibla),
            ),
            _StatusLine(
              key: const Key('status-wake'),
              icon: Icons.alarm_outlined,
              text: l10n.homeNextWakeAlarm(wakeText),
              onTap: () => destinations.select(Destination.wakeUp),
            ),
          ],
        ),
      ),
    );
  }

  static String _clock(WidgetRef ref, Formatter fmt, DateTime instant) {
    final location = ref.read(activeLocationProvider);
    final offset = ref
        .read(zoneOffsetResolverProvider)
        .currentOffset(
          rule: location.offset,
          zoneId: location.zoneId,
          instant: instant,
        );
    return fmt.formatInstant(instant, offset);
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.icon,
    required this.text,
    required this.onTap,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: Gaps.m, vertical: Gaps.s),
      child: Row(
        mainAxisSize: trailing == null ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: Gaps.m),
          Flexible(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
    final link = InkWell(
      borderRadius: BorderRadius.circular(Radii.control),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Align(alignment: AlignmentDirectional.centerStart, child: body),
      ),
    );
    if (trailing == null) return link;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [link, trailing!],
    );
  }
}

/// The mute menu: until the next azan, 1 hour, 24 hours, until turned back
/// on, and cancel (only while muted).
class _MuteMenu extends ConsumerWidget {
  const _MuteMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final fmt = ref.watch(formatterProvider);
    final now = ref.watch(nowProvider);
    final muted = ref.watch(
      settingsProvider.select((s) => s.azan.mute.isActiveAt(now)),
    );
    final nextAzan = ref.watch(nextAzanInstantProvider);

    String label(MuteOption option) => switch (option) {
      MuteOption.untilNextPrayer => l10n.homeMuteUntilNext,
      MuteOption.oneHour => l10n.homeMuteForDuration(
        fmt.formatDuration(const Duration(hours: 1)),
      ),
      MuteOption.twentyFourHours => l10n.homeMuteForDuration(
        fmt.formatDuration(const Duration(hours: 24)),
      ),
      MuteOption.indefinite => l10n.homeMuteIndefinite,
      MuteOption.cancel => l10n.homeMuteCancel,
    };

    return PopupMenuButton<MuteOption>(
      key: const Key('mute-menu'),
      tooltip: l10n.homeMute,
      onSelected: (option) {
        final value = muteSettingFor(
          option,
          now: ref.read(nowProvider),
          nextAzan: ref.read(nextAzanInstantProvider),
        );
        if (value != null) ref.read(settingsProvider.notifier).setMute(value);
      },
      itemBuilder: (context) => [
        for (final option in MuteOption.values)
          if (option != MuteOption.cancel || muted)
            PopupMenuItem(
              value: option,
              enabled: option != MuteOption.untilNextPrayer || nextAzan != null,
              child: Text(label(option)),
            ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Gaps.s),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  l10n.homeMute,
                  style: Theme.of(context).textTheme.labelLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
