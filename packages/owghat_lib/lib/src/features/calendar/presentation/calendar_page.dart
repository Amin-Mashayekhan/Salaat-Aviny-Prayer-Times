import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_view.dart';
import 'package:owghat_lib/src/features/calendar/domain/tri_date.dart';
import 'package:owghat_lib/src/features/calendar/presentation/date_converter_card.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/viewed_date_provider.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

/// Weekday order of the Persian week, as ISO weekdays: Saturday first.
const List<int> _weekOrder = [6, 7, 1, 2, 3, 4, 5];

/// The Calendar screen: a Shamsi month grid
/// with the lunar and Gregorian day numbers in every cell, a side panel for
/// the selected day, the lunar-date adjustment and the date converter.
class CalendarPage extends ConsumerWidget {
  /// Creates the page.
  const CalendarPage({super.key});

  /// Width from which the grid and the side column sit side by side.
  static const double twoColumnWidth = 760;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= twoColumnWidth;
        const grid = _GridColumn();
        const side = _SideColumn();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Gaps.l),
          child: twoColumns
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: grid),
                    SizedBox(width: Gaps.l),
                    Expanded(flex: 2, child: side),
                  ],
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    grid,
                    SizedBox(height: Gaps.l),
                    side,
                  ],
                ),
        );
      },
    );
  }
}

class _GridColumn extends ConsumerWidget {
  const _GridColumn();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final view = ref.watch(calendarViewProvider);
    final controller = ref.read(calendarViewProvider.notifier);
    final names = ref.watch(calendarNamesProvider);
    final fmt = ref.watch(formatterProvider);
    final month = ref.watch(calendarMonthProvider);
    final title = l10n.calendarMonthYear(
      names.jalaliMonth(view.month),
      fmt.formatNumber(view.year),
    );
    final span = month == null
        ? ''
        : _otherCalendars(l10n, names, fmt, month.days.first, month.days.last);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: Gaps.m,
          runSpacing: Gaps.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  key: const Key('cal-previous'),
                  tooltip: l10n.calendarPreviousMonth,
                  icon: const Icon(Icons.navigate_before),
                  onPressed: controller.canMove(-1)
                      ? controller.previous
                      : null,
                ),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 120),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        key: const Key('cal-title'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  key: const Key('cal-next'),
                  tooltip: l10n.calendarNextMonth,
                  icon: const Icon(Icons.navigate_next),
                  onPressed: controller.canMove(1) ? controller.next : null,
                ),
              ],
            ),
            OutlinedButton(
              key: const Key('cal-today'),
              onPressed: controller.goToToday,
              child: Text(l10n.calendarToday),
            ),
          ],
        ),
        if (span.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.s),
            child: Text(
              span,
              key: const Key('cal-span'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: Gaps.m),
        if (month != null) _MonthGrid(month: month, selected: view.selected),
      ],
    );
  }

  /// "Jumada al-Thani 1448 · November 2026" (two months when the Shamsi
  /// month straddles two of them).
  static String _otherCalendars(
    AppLocalizations l10n,
    CalendarNames names,
    Formatter fmt,
    TriDate first,
    TriDate last,
  ) {
    String range(CalendarKind kind, CalendarDate? a, CalendarDate? b) {
      if (a == null || b == null) return '';
      String one(CalendarDate d) => l10n.calendarMonthYear(
        names.month(kind, d.month),
        fmt.formatNumber(d.year),
      );
      if (a.year == b.year && a.month == b.month) return one(a);
      if (a.year == b.year) {
        return l10n.calendarMonthYear(
          '${names.month(kind, a.month)} – ${names.month(kind, b.month)}',
          fmt.formatNumber(a.year),
        );
      }
      return '${one(a)} – ${one(b)}';
    }

    final gregorian = range(
      CalendarKind.gregorian,
      first.dateIn(CalendarKind.gregorian),
      last.dateIn(CalendarKind.gregorian),
    );
    final hijri = range(CalendarKind.hijri, first.hijri, last.hijri);
    return [hijri, gregorian].where((s) => s.isNotEmpty).join(' · ');
  }
}

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({required this.month, required this.selected});

  final CalendarMonth month;
  final CivilDate selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final names = ref.watch(calendarNamesProvider);
    final today = ref.watch(todayProvider);
    final scaler = MediaQuery.textScalerOf(context);
    // Two lines of text plus padding; grows with the text size so nothing
    // is ever clipped at 200 %.
    final cellHeight = math.max<double>(60, scaler.scale(24 + 16) + 16);

    final cells = <TriDate?>[
      for (var i = 0; i < month.leadingBlanks; i++) null,
      ...month.days,
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Semantics(
      container: true,
      label: l10n.calendarGridLabel,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(Gaps.s),
          child: Column(
            children: [
              Row(
                children: [
                  for (final iso in _weekOrder)
                    Expanded(
                      child: Semantics(
                        label: names.weekday(iso),
                        excludeSemantics: true,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 32),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              l10n.calendarWeekdayShort('d$iso'),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: iso == DateTime.friday
                                    ? context.appColors.danger
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              for (var row = 0; row < cells.length ~/ 7; row++)
                Row(
                  children: [
                    for (var col = 0; col < 7; col++)
                      Expanded(
                        child: SizedBox(
                          height: cellHeight,
                          child: cells[row * 7 + col] == null
                              ? null
                              : _DayCell(
                                  date: cells[row * 7 + col]!,
                                  isToday:
                                      cells[row * 7 + col]!.gregorian == today,
                                  isSelected:
                                      cells[row * 7 + col]!.gregorian ==
                                      selected,
                                ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({
    required this.date,
    required this.isToday,
    required this.isSelected,
  });

  final TriDate date;
  final bool isToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final fmt = ref.watch(formatterProvider);
    final header = ref.watch(dateHeaderProvider(date.gregorian));
    final l10n = AppLocalizations.of(context);

    final foreground = isSelected
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;
    final dayStyle = theme.textTheme.bodyLarge!.copyWith(
      fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
      color: date.isFriday && !isSelected ? colors.danger : foreground,
    );
    final smallStyle = theme.textTheme.labelSmall!.copyWith(
      color: isSelected
          ? theme.colorScheme.onPrimaryContainer
          : theme.colorScheme.onSurfaceVariant,
    );
    final hijriDay = date.hijri?.day;
    final label = [
      header.weekday,
      header.jalali,
      ?header.hijri,
      header.gregorian,
    ].join(l10n.calendarSeparator);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        onTap: () =>
            ref.read(calendarViewProvider.notifier).select(date.gregorian),
        excludeSemantics: true,
        child: Material(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : date.isFriday
              ? colors.success.withValues(alpha: 0.10)
              : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.control),
            // The border (not the colour) marks today, so it works in
            // greyscale too.
            side: isToday
                ? BorderSide(color: colors.accentWarm, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            key: Key('cal-cell-${date.gregorian.iso}'),
            borderRadius: BorderRadius.circular(Radii.control),
            onTap: () =>
                ref.read(calendarViewProvider.notifier).select(date.gregorian),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Gaps.s / 2,
                vertical: Gaps.s / 2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      fmt.formatNumber(date.jalali.day),
                      key: Key('cal-day-${date.gregorian.iso}'),
                      style: dayStyle,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hijriDay == null ? '' : fmt.formatNumber(hijriDay),
                          key: Key('cal-hijri-${date.gregorian.iso}'),
                          style: smallStyle,
                        ),
                        const SizedBox(width: Gaps.s),
                        Text(
                          fmt.formatNumber(date.gregorian.day),
                          key: Key('cal-greg-${date.gregorian.iso}'),
                          style: smallStyle,
                        ),
                      ],
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

class _SideColumn extends StatelessWidget {
  const _SideColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DayPanel(),
        SizedBox(height: Gaps.l),
        _AdjustmentCard(),
        SizedBox(height: Gaps.l),
        DateConverterCard(),
      ],
    );
  }
}

class _DayPanel extends ConsumerWidget {
  const _DayPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final names = ref.watch(calendarNamesProvider);
    final fmt = ref.watch(formatterProvider);
    final tri = ref.watch(calendarSelectedProvider);
    final header = ref.watch(dateHeaderProvider(tri.gregorian));
    final day = ref.watch(prayerDayProvider(tri.gregorian));
    final display = ref.watch(settingsProvider.select((s) => s.display));
    final prayers = [
      for (final p in Prayer.values)
        if (display.shows(p)) p,
    ];

    Widget dateLine(CalendarKind kind, String? text, Key key) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Wrap(
        spacing: Gaps.s,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            names.kind(kind),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            text ?? l10n.calendarHijriUnavailable,
            key: key,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );

    return Card(
      key: const Key('cal-panel'),
      child: Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              names.weekday(tri.weekday),
              key: const Key('cal-panel-weekday'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: Gaps.s),
            dateLine(
              CalendarKind.jalali,
              header.jalali,
              const Key('cal-panel-jalali'),
            ),
            dateLine(
              CalendarKind.hijri,
              header.hijri,
              const Key('cal-panel-hijri'),
            ),
            dateLine(
              CalendarKind.gregorian,
              header.gregorian,
              const Key('cal-panel-gregorian'),
            ),
            if (tri.hijri != null && header.hijriApproximate)
              Padding(
                padding: const EdgeInsets.only(top: Gaps.s),
                child: Text(
                  l10n.calendarHijriApproxHint,
                  key: const Key('cal-panel-approx'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const Divider(height: Gaps.xl),
            Text(l10n.calendarPanelTimes, style: theme.textTheme.titleLarge),
            const SizedBox(height: Gaps.s),
            for (final prayer in prayers)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        prayer.label(l10n),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      day.times[prayer] == null
                          ? l10n.homeNoValue
                          : fmt.formatTime(day.times[prayer]!),
                      key: Key('cal-time-${prayer.name}'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: Gaps.m),
            FilledButton.tonalIcon(
              key: const Key('cal-open-home'),
              icon: const Icon(Icons.home_outlined),
              label: Text(l10n.calendarOpenOnHome),
              onPressed: () {
                ref.read(viewedDateProvider.notifier).show(tri.gregorian);
                ref.read(destinationProvider.notifier).select(Destination.home);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustmentCard extends ConsumerWidget {
  const _AdjustmentCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = ref.watch(formatterProvider);
    final value = ref.watch(
      settingsProvider.select((s) => s.hijriAdjustmentDays),
    );
    final controller = ref.read(settingsProvider.notifier);
    const limit = AppSettings.maxHijriAdjustment;
    final sign = value > 0 ? '+' : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.calendarHijriAdjust, style: theme.textTheme.titleLarge),
            const SizedBox(height: Gaps.s),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                IconButton.filledTonal(
                  key: const Key('cal-adjust-earlier'),
                  tooltip: l10n.calendarAdjustEarlier,
                  icon: const Icon(Icons.remove),
                  onPressed: value > -limit
                      ? () => controller.setHijriAdjustment(value - 1)
                      : null,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Gaps.m),
                  child: Semantics(
                    liveRegion: true,
                    child: Text(
                      l10n.calendarAdjustValue(
                        Formatter.isolate('$sign${fmt.formatNumber(value)}'),
                      ),
                      key: const Key('cal-adjust-value'),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  key: const Key('cal-adjust-later'),
                  tooltip: l10n.calendarAdjustLater,
                  icon: const Icon(Icons.add),
                  onPressed: value < limit
                      ? () => controller.setHijriAdjustment(value + 1)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: Gaps.s),
            Text(
              l10n.calendarMoonNote,
              key: const Key('cal-moon-note'),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
