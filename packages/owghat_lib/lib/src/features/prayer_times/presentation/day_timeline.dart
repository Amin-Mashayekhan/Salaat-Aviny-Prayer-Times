import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_view.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/sky_palette.dart';
import 'package:prayer_core/prayer_core.dart';

/// The day line of the hero card: one dot per event positioned in time from
/// the first shown event to midnight, the passed part drawn solid and a
/// marker for "now".
///
/// The line runs from the start edge (right in Persian). Labels are drawn
/// only where they fit: the next event first, then the others in time order.
class DayTimeline extends StatelessWidget {
  /// Creates the timeline.
  const DayTimeline({
    required this.dots,
    required this.nowFraction,
    required this.labelOf,
    super.key,
  });

  /// The events.
  final List<TimelineDot> dots;

  /// Position of now (0 to 1), or null to draw no marker and no solid part.
  final double? nowFraction;

  /// Name of an event.
  final String Function(Prayer prayer) labelOf;

  static const double _inset = 10;
  static const double _trackY = 12;
  static const double _labelTop = 30;
  static const double _labelGap = 8;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = Theme.of(context).textTheme.labelLarge!
        .copyWith(color: SkyStyle.onSky);
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    final l10n = AppLocalizations.of(context);

    return Semantics(
      label: l10n.homeTimelineLabel,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final usable = math.max(0, width - 2 * _inset).toDouble();

            // Measure the labels.
            final widths = <Prayer, double>{};
            var labelHeight = 0.0;
            for (final dot in dots) {
              final painter = TextPainter(
                text: TextSpan(text: labelOf(dot.prayer), style: style),
                textDirection: direction,
                textScaler: scaler,
                maxLines: 1,
              )..layout();
              widths[dot.prayer] = painter.width;
              labelHeight = math.max(labelHeight, painter.height);
              painter.dispose();
            }

            // Pick the labels that fit, the next event first.
            final order = [
              ...dots.where((d) => d.isNext),
              ...dots.where((d) => !d.isNext),
            ];
            final placed = <Prayer, double>{};
            final taken = <(double, double)>[];
            for (final dot in order) {
              final w = widths[dot.prayer]!;
              final x = _clamp(
                _inset + dot.fraction * usable - w / 2,
                w,
                width,
              );
              final overlaps = taken.any(
                (t) => x < t.$2 + _labelGap && x + w + _labelGap > t.$1,
              );
              if (overlaps) continue;
              taken.add((x, x + w));
              placed[dot.prayer] = x;
            }

            final now = nowFraction;
            return SizedBox(
              width: width,
              height: _labelTop + labelHeight + 2,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PositionedDirectional(
                    start: _inset,
                    top: _trackY - 2,
                    width: usable,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: SkyStyle.onSky.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (now != null)
                    PositionedDirectional(
                      start: _inset,
                      top: _trackY - 2,
                      width: now * usable,
                      height: 4,
                      child: const DecoratedBox(
                        decoration: BoxDecoration(
                          color: SkyStyle.onSky,
                          borderRadius: BorderRadius.all(Radius.circular(2)),
                        ),
                      ),
                    ),
                  for (final dot in dots)
                    _dot(dot, _inset + dot.fraction * usable, colors),
                  if (now != null) _nowMarker(_inset + now * usable, colors),
                  for (final entry in placed.entries)
                    PositionedDirectional(
                      key: Key('timeline-label-${entry.key.name}'),
                      start: entry.value,
                      top: _labelTop,
                      child: Text(
                        labelOf(entry.key),
                        style: style,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static double _clamp(double x, double w, double total) =>
      math.max(0, math.min(x, total - w));

  Widget _dot(TimelineDot dot, double x, AppColors colors) {
    final size = dot.isNext ? 16.0 : 10.0;
    return PositionedDirectional(
      key: Key('timeline-dot-${dot.prayer.name}'),
      start: x - size / 2,
      top: _trackY - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: dot.isNext
              ? colors.accentWarm
              : dot.passed
              ? SkyStyle.onSky
              : Colors.transparent,
          border: Border.all(color: SkyStyle.onSky, width: 2),
        ),
      ),
    );
  }

  Widget _nowMarker(double x, AppColors colors) {
    const size = 18.0;
    return PositionedDirectional(
      key: const Key('timeline-now'),
      start: x - size / 2,
      top: _trackY - size / 2,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: SkyStyle.onSky,
          border: Border.all(color: colors.accentWarm, width: 4),
        ),
      ),
    );
  }
}
