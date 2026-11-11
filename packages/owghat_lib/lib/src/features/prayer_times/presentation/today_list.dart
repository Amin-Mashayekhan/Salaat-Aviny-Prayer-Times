import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_view.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/prayer_icons.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';

/// The list of the times of the shown day: icon, name, time and, for the
/// five prayers, the bell that switches the azan on or off.
///
/// Passed rows are dimmed; the next row has an accent colour, a leading
/// marker and a bold weight (colour is never the only signal). Times that do
/// not occur show a dash and the card explains why.
class TodayList extends ConsumerWidget {
  /// Creates the list.
  const TodayList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(homeViewProvider);
    final fmt = ref.watch(formatterProvider);
    final theme = Theme.of(context);

    final title = switch (view.kind) {
      HomeDayKind.today => l10n.homeTodayTimes,
      HomeDayKind.tomorrow => l10n.homeTomorrowTimes,
      HomeDayKind.other || HomeDayKind.earlier => l10n.homeDayTimes(
        ref.watch(dateHeaderProvider(view.date)).primary,
      ),
    };

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
                title,
                key: const Key('list-title'),
                style: theme.textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: Gaps.s),
            for (final row in view.rows)
              _TimeRow(row: row, fmt: fmt, l10n: l10n),
            if (view.hasMissingTimes) const _NoTimesInfo(),
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends ConsumerWidget {
  const _TimeRow({required this.row, required this.fmt, required this.l10n});

  final HomeRow row;
  final Formatter fmt;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final name = row.prayer.label(l10n);
    final time = row.time == null
        ? l10n.homeNoValue
        : fmt.formatTime(row.time!);

    final base = theme.textTheme.bodyLarge!;
    final color = row.isNext
        ? colors.accentWarm
        : theme.colorScheme.onSurface.withValues(alpha: row.passed ? 0.55 : 1);
    final style = base.copyWith(
      color: color,
      fontWeight: row.isNext ? FontWeight.w700 : FontWeight.w400,
    );

    final azan = row.prayer.hasAzan
        ? ref.watch(
            settingsProvider.select((s) => s.azan.perPrayer[row.prayer]),
          )
        : null;

    return Container(
      key: Key('row-${row.prayer.name}'),
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsetsDirectional.only(start: Gaps.s),
      decoration: BoxDecoration(
        color: row.isNext ? colors.accentWarm.withValues(alpha: 0.1) : null,
        borderRadius: BorderRadius.circular(Radii.control),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              container: true,
              excludeSemantics: true,
              label:
                  '$name $time${row.isNext ? ', ${l10n.homeNextMarker}' : ''}',
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: row.isNext
                        ? Icon(
                            Icons.play_arrow_rounded,
                            key: Key('next-marker-${row.prayer.name}'),
                            size: 20,
                            color: colors.accentWarm,
                          )
                        : null,
                  ),
                  Icon(prayerIcon(row.prayer), size: 20, color: color),
                  const SizedBox(width: Gaps.m),
                  Expanded(
                    child: Text(
                      name,
                      style: style,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Gaps.s),
                  Text(
                    time,
                    key: Key('time-${row.prayer.name}'),
                    style: style,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 48,
            height: 44,
            child: azan == null
                ? null
                : IconButton(
                    key: Key('bell-${row.prayer.name}'),
                    tooltip: azan.enabled
                        ? l10n.homeAzanToggleOff(name)
                        : l10n.homeAzanToggleOn(name),
                    isSelected: azan.enabled,
                    icon: const Icon(Icons.notifications_off_outlined),
                    selectedIcon: const Icon(
                      Icons.notifications_active_outlined,
                    ),
                    onPressed: () => ref
                        .read(settingsProvider.notifier)
                        .setPrayerAzan(
                          row.prayer,
                          azan.copyWith(enabled: !azan.enabled),
                        ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _NoTimesInfo extends ConsumerWidget {
  const _NoTimesInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gaps.m, Gaps.m, Gaps.m, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: Gaps.s),
              Expanded(
                child: Text(
                  l10n.homeNoTimesInfo,
                  key: const Key('no-times-info'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () => ref
                .read(destinationProvider.notifier)
                .select(Destination.settings),
            child: Text(l10n.homeNoTimesAction),
          ),
        ],
      ),
    );
  }
}
