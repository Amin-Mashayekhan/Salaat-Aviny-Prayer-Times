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
import 'package:owghat_lib/src/features/calendar/domain/tri_date.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/timetable_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/viewed_date_provider.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:prayer_core/prayer_core.dart';

/// Text put before today's day number so colour is not the only signal.
const String todayMarker = '▶ ';

/// The monthly timetable (`docs/05-UI-UX-SPEC.md` §4.2): one row per day,
/// one column per shown time, in the Shamsi (default), lunar or Gregorian
/// calendar. Today is highlighted, Fridays are tinted, the header stays in
/// place while the days scroll, and a click opens that day on Home.
class TimetablePage extends ConsumerWidget {
  /// Creates the page.
  const TimetablePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selection = ref.watch(timetableSelectionProvider);
    final controller = ref.read(timetableSelectionProvider.notifier);
    final names = ref.watch(calendarNamesProvider);
    final fmt = ref.watch(formatterProvider);
    final rows = ref.watch(timetableMonthProvider(selection));

    final title = l10n.calendarMonthYear(
      names.month(selection.kind, selection.month),
      fmt.formatNumber(selection.year),
    );

    return Padding(
      padding: const EdgeInsets.all(Gaps.l),
      child: Column(
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
                    key: const Key('tt-previous'),
                    tooltip: l10n.timetablePreviousMonth,
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
                          key: const Key('tt-title'),
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('tt-next'),
                    tooltip: l10n.timetableNextMonth,
                    icon: const Icon(Icons.navigate_next),
                    onPressed: controller.canMove(1) ? controller.next : null,
                  ),
                ],
              ),
              Semantics(
                label: l10n.timetableCalendarSwitch,
                container: true,
                child: Wrap(
                  spacing: Gaps.s,
                  children: [
                    for (final kind in CalendarKind.values)
                      ChoiceChip(
                        key: Key('tt-kind-${kind.name}'),
                        label: Text(names.kind(kind)),
                        selected: kind == selection.kind,
                        onSelected: (_) => controller.setKind(kind),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Gaps.m),
          Expanded(
            child: rows == null
                ? Center(child: Text(l10n.timetableMonthUnavailable))
                : _MonthTable(selection: selection, rows: rows),
          ),
        ],
      ),
    );
  }
}

class _MonthTable extends ConsumerWidget {
  const _MonthTable({required this.selection, required this.rows});

  final TimetableSelection selection;
  final List<TimetableRow> rows;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final fmt = ref.watch(formatterProvider);
    final names = ref.watch(calendarNamesProvider);
    final today = ref.watch(todayProvider);
    final display = ref.watch(settingsProvider.select((s) => s.display));
    final prayers = [
      for (final p in Prayer.values)
        if (display.shows(p)) p,
    ];

    final headStyle = theme.textTheme.labelLarge!.copyWith(
      fontWeight: FontWeight.w700,
    );
    final cellStyle = theme.textTheme.bodyMedium!;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);

    double measure(String text, TextStyle style) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final width = painter.width;
      painter.dispose();
      return width;
    }

    // Column 0: day, 1: weekday, then the times.
    final headers = [
      l10n.timetableColDay,
      l10n.timetableColWeekday,
      for (final p in prayers) p.label(l10n),
    ];
    final widestTime = measure(
      fmt.formatTime(const Duration(hours: 12, minutes: 58)),
      cellStyle.copyWith(fontWeight: FontWeight.w700),
    );
    final widestWeekday = [
      for (var d = 1; d <= 7; d++)
        measure(
          names.weekday(d),
          cellStyle.copyWith(fontWeight: FontWeight.w700),
        ),
    ].reduce(math.max);
    // Today carries a marker in front of its day number, besides the colour.
    final widestDay = measure(
      '$todayMarker${fmt.formatNumber(30)}',
      cellStyle.copyWith(fontWeight: FontWeight.w700),
    );
    const pad = 2 * Gaps.m;
    final natural = <double>[
      math.max(measure(headers[0], headStyle), widestDay) + pad,
      math.max(measure(headers[1], headStyle), widestWeekday) + pad,
      for (var i = 0; i < prayers.length; i++)
        math.max(measure(headers[i + 2], headStyle), widestTime) + pad,
    ];
    final naturalTotal = natural.fold<double>(0, (a, b) => a + b);

    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final grow = naturalTotal >= available ? 1.0 : available / naturalTotal;
        final widths = [for (final w in natural) w * grow];
        final tableWidth = math.max(available, naturalTotal);

        Widget cell(int column, Widget child) => SizedBox(
          width: widths[column],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Gaps.m),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: child,
            ),
          ),
        );

        final header = Container(
          key: const Key('tt-header'),
          constraints: const BoxConstraints(minHeight: 44),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Radii.control),
            ),
          ),
          child: Row(
            children: [
              for (var i = 0; i < headers.length; i++)
                cell(
                  i,
                  Text(
                    headers[i],
                    style: headStyle,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
            ],
          ),
        );

        final body = SingleChildScrollView(
          child: Column(
            children: [
              for (final row in rows)
                _DayRow(
                  row: row,
                  isToday: row.date == today,
                  widths: widths,
                  prayers: prayers,
                  fmt: fmt,
                  names: names,
                  cellStyle: cellStyle,
                  colors: colors,
                  onOpen: () {
                    ref.read(viewedDateProvider.notifier).show(row.date);
                    ref
                        .read(destinationProvider.notifier)
                        .select(Destination.home);
                  },
                ),
            ],
          ),
        );

        // The header is outside the vertical scroll view, so it stays put;
        // both share one horizontal scroll view for narrow windows.
        return Card(
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: tableWidth,
              height: constraints.maxHeight,
              child: Column(
                children: [
                  header,
                  Expanded(child: body),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _DayRow extends ConsumerWidget {
  const _DayRow({
    required this.row,
    required this.isToday,
    required this.widths,
    required this.prayers,
    required this.fmt,
    required this.names,
    required this.cellStyle,
    required this.colors,
    required this.onOpen,
  });

  final TimetableRow row;
  final bool isToday;
  final List<double> widths;
  final List<Prayer> prayers;
  final Formatter fmt;
  final CalendarNames names;
  final TextStyle cellStyle;
  final AppColors colors;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final header = ref.watch(dateHeaderProvider(row.date));

    final style = cellStyle.copyWith(
      fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
      color: isToday ? colors.accentWarm : null,
    );
    final tint = isToday
        ? colors.accentWarm.withValues(alpha: 0.14)
        : row.isFriday
        ? colors.success.withValues(alpha: 0.10)
        : null;

    Widget cell(int column, String text, {Key? key}) => SizedBox(
      width: widths[column],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gaps.m),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            text,
            key: key,
            style: style,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: l10n.timetableOpenDay(header.primary),
      onTap: onOpen,
      child: InkWell(
        key: Key('tt-row-${row.date.iso}'),
        onTap: onOpen,
        child: Container(
          constraints: const BoxConstraints(minHeight: 40),
          decoration: BoxDecoration(
            color: tint,
            border: Border(
              bottom: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            children: [
              cell(
                0,
                '${isToday ? todayMarker : ''}${fmt.formatNumber(row.dayOfMonth)}',
                key: Key('tt-day-${row.date.iso}'),
              ),
              cell(1, names.weekday(row.tri.weekday)),
              for (var i = 0; i < prayers.length; i++)
                cell(
                  i + 2,
                  row.day.times[prayers[i]] == null
                      ? l10n.homeNoValue
                      : fmt.formatTime(row.day.times[prayers[i]]!),
                  key: Key('tt-${row.date.iso}-${prayers[i].name}'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
