import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_view.dart';
import 'package:owghat_lib/src/features/calendar/domain/date_converter.dart';
import 'package:owghat_lib/src/features/calendar/domain/tri_date.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';

/// The date converter: three linked date fields (Shamsi, lunar, Gregorian).
/// Editing one calendar fills in the other two; an impossible date is
/// explained under the calendar being edited and leaves the others alone.
///
/// It is also the "pick a date in any calendar" control: "Show in
/// calendar" opens the converted day in the month grid.
class DateConverterCard extends ConsumerStatefulWidget {
  /// Creates the card.
  const DateConverterCard({super.key});

  @override
  ConsumerState<DateConverterCard> createState() => _DateConverterCardState();
}

class _DateConverterCardState extends ConsumerState<DateConverterCard> {
  final Map<CalendarKind, List<TextEditingController>> _fields = {
    for (final kind in CalendarKind.values)
      kind: [for (var i = 0; i < 3; i++) TextEditingController()],
  };
  final Map<CalendarKind, ConvertError?> _errors = {};
  final Set<CalendarKind> _unavailable = {};

  /// The calendar the user edited last, and its valid result if any.
  CalendarKind? _source;
  TriDate? _result;

  @override
  void initState() {
    super.initState();
    _fillFrom(ref.read(calendarSelectedProvider), except: null);
  }

  @override
  void dispose() {
    for (final row in _fields.values) {
      for (final controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  int get _adjustment =>
      ref.read(settingsProvider.select((s) => s.hijriAdjustmentDays));

  void _fillFrom(TriDate date, {required CalendarKind? except}) {
    final fmt = ref.read(formatterProvider);
    for (final kind in CalendarKind.values) {
      if (kind == except) continue;
      final value = date.dateIn(kind);
      final row = _fields[kind]!;
      _errors[kind] = null;
      if (value == null) {
        _unavailable.add(kind);
        for (final controller in row) {
          controller.text = '';
        }
      } else {
        _unavailable.remove(kind);
        row[0].text = fmt.formatNumber(value.year);
        row[1].text = fmt.formatNumber(value.month);
        row[2].text = fmt.formatNumber(value.day);
      }
    }
  }

  void _edited(CalendarKind kind) {
    final row = _fields[kind]!;
    final result = convertDate(
      kind,
      row[0].text,
      row[1].text,
      row[2].text,
      hijriAdjustment: _adjustment,
    );
    setState(() {
      _source = kind;
      _unavailable.remove(kind);
      switch (result) {
        case ConvertOk(:final date):
          _errors[kind] = null;
          _result = date;
          _fillFrom(date, except: kind);
        case ConvertError():
          _errors[kind] = result;
          _result = null;
      }
    });
  }

  String _errorText(AppLocalizations l10n, ConvertError error) {
    final fmt = ref.read(formatterProvider);
    return switch (error.problem) {
      ConvertProblem.incomplete => l10n.calendarConvErrIncomplete,
      ConvertProblem.notANumber => l10n.calendarConvErrNumber,
      ConvertProblem.monthOutOfRange => l10n.calendarConvErrMonth,
      ConvertProblem.dayOutOfRange => l10n.calendarConvErrDay(
        fmt.formatNumber(1),
        fmt.formatNumber(error.maxDay ?? 31),
      ),
      ConvertProblem.outOfRange => l10n.calendarConvErrRange,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final names = ref.watch(calendarNamesProvider);
    final scaler = MediaQuery.textScalerOf(context);

    // The selected day of the grid drives the fields; a change of the lunar
    // adjustment re-derives them from what the user typed last.
    ref.listen(calendarSelectedProvider, (previous, next) {
      final sameDay = previous?.gregorian == next.gregorian;
      setState(() {
        if (sameDay && _source != null) {
          final row = _fields[_source!]!;
          final redo = convertDate(
            _source!,
            row[0].text,
            row[1].text,
            row[2].text,
            hijriAdjustment: next.hijriAdjustment,
          );
          if (redo is ConvertOk) {
            _result = redo.date;
            _fillFrom(redo.date, except: null);
          }
        } else {
          _source = null;
          _result = null;
          _fillFrom(next, except: null);
        }
      });
    });

    Widget field(CalendarKind kind, int index, String label, double width) {
      return SizedBox(
        width: scaler.scale(width),
        child: Semantics(
          label: '${names.kind(kind)} $label',
          child: TextField(
            key: Key('conv-${kind.name}-${const ['y', 'm', 'd'][index]}'),
            controller: _fields[kind]![index],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[0-9۰-۹٠-٩]')),
              LengthLimitingTextInputFormatter(index == 0 ? 4 : 2),
            ],
            decoration: InputDecoration(
              labelText: label,
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Radii.control),
              ),
            ),
            onChanged: (_) => _edited(kind),
          ),
        ),
      );
    }

    Widget row(CalendarKind kind) {
      final error = _errors[kind];
      return Padding(
        padding: const EdgeInsets.only(bottom: Gaps.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(names.kind(kind), style: theme.textTheme.labelLarge),
            const SizedBox(height: Gaps.s),
            Wrap(
              spacing: Gaps.s,
              runSpacing: Gaps.s,
              children: [
                field(kind, 0, l10n.calendarFieldYear, 92),
                field(kind, 1, l10n.calendarFieldMonth, 72),
                field(kind, 2, l10n.calendarFieldDay, 72),
              ],
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: Gaps.s),
                child: Text(
                  _errorText(l10n, error),
                  key: Key('conv-error-${kind.name}'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              )
            else if (_unavailable.contains(kind))
              Padding(
                padding: const EdgeInsets.only(top: Gaps.s),
                child: Text(
                  l10n.calendarHijriUnavailable,
                  key: Key('conv-unavailable-${kind.name}'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    final result = _result;
    return Card(
      key: const Key('cal-converter'),
      child: Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.calendarConverterTitle,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: Gaps.s),
            Text(
              l10n.calendarConverterHint,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Gaps.m),
            for (final kind in CalendarKind.values) row(kind),
            if (result != null)
              Padding(
                padding: const EdgeInsets.only(bottom: Gaps.s),
                child: Text(
                  names.weekday(result.weekday),
                  key: const Key('conv-weekday'),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonalIcon(
                key: const Key('conv-show'),
                icon: const Icon(Icons.event_outlined),
                label: Text(l10n.calendarConverterShow),
                onPressed: result == null
                    ? null
                    : () => ref
                          .read(calendarViewProvider.notifier)
                          .select(result.gregorian),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
