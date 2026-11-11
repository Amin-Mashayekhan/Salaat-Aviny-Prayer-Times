import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_view.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/day_timeline.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/sky_palette.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';

/// The big card of the home screen: what is next, how long is left, and the
/// day timeline, on a sky gradient that follows the time of day.
///
/// The countdown is the largest text on screen and is rebuilt from
/// `nowProvider` only. While another day is browsed the card shows that
/// day's date instead of a countdown.
class HeroCard extends ConsumerWidget {
  /// Creates the card.
  const HeroCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final view = ref.watch(homeViewProvider);
    final fmt = ref.watch(formatterProvider);
    final colors = context.appColors;
    final theme = Theme.of(context);

    final gradient = SkyStyle.gradient(
      colors,
      skyPeriodOf(view.current?.prayer),
    );
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final label = TextStyle(
      color: SkyStyle.onSky,
      fontSize: theme.textTheme.titleLarge?.fontSize,
      height: 28 / 20,
      fontWeight: FontWeight.w500,
    );

    return Semantics(
      container: true,
      child: AnimatedContainer(
        key: const Key('hero-card'),
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(Gaps.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Radii.card),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (view.isLive)
              _LiveHeader(view: view, fmt: fmt, l10n: l10n, labelStyle: label)
            else
              _OtherDayHeader(labelStyle: label, l10n: l10n),
            const SizedBox(height: Gaps.l),
            DayTimeline(
              dots: view.dots,
              nowFraction: view.nowFraction,
              labelOf: (prayer) => prayer.label(l10n),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveHeader extends StatelessWidget {
  const _LiveHeader({
    required this.view,
    required this.fmt,
    required this.l10n,
    required this.labelStyle,
  });

  final HomeView view;
  final Formatter fmt;
  final AppLocalizations l10n;
  final TextStyle labelStyle;

  @override
  Widget build(BuildContext context) {
    final next = view.next;
    final theme = Theme.of(context);
    if (next == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.homeHeroNoNext, style: labelStyle),
          Text(
            l10n.homeNoValue,
            key: const Key('hero-countdown'),
            style: theme.textTheme.displayLarge?.copyWith(
              color: SkyStyle.onSky,
            ),
          ),
        ],
      );
    }

    final name = next.prayer.label(l10n);
    final time = fmt.formatInstant(next.instant, view.utcOffset);
    final countdown = Text(
      fmt.formatCountdown(view.remaining),
      key: const Key('hero-countdown'),
      maxLines: 1,
      softWrap: false,
      style: theme.textTheme.displayLarge?.copyWith(color: SkyStyle.onSky),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeUntilEvent(name),
          key: const Key('hero-label'),
          style: labelStyle,
        ),
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: Gaps.l,
          runSpacing: Gaps.s,
          children: [
            // The countdown changes every second; screen readers hear the
            // phrase below, which changes once a minute.
            Semantics(
              liveRegion: true,
              label: l10n.homeCountdownSemantics(
                name,
                fmt.formatDurationWords(view.remaining),
              ),
              child: ExcludeSemantics(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: countdown,
                ),
              ),
            ),
            Text(
              l10n.homeEventAt(name, Formatter.isolate(time)),
              key: const Key('hero-event'),
              style: labelStyle,
            ),
          ],
        ),
      ],
    );
  }
}

class _OtherDayHeader extends ConsumerWidget {
  const _OtherDayHeader({required this.labelStyle, required this.l10n});

  final TextStyle labelStyle;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final view = ref.watch(homeViewProvider);
    final header = ref.watch(dateHeaderProvider(view.date));
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeViewingDay(header.primary),
          key: const Key('hero-viewing'),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: SkyStyle.onSky,
          ),
        ),
        const SizedBox(height: Gaps.s),
        Text(l10n.homeOtherDayHint, style: labelStyle.copyWith(fontSize: 15)),
      ],
    );
  }
}
