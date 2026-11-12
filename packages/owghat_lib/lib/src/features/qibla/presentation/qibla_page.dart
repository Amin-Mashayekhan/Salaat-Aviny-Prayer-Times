import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/qibla/application/qibla_providers.dart';
import 'package:owghat_lib/src/features/qibla/presentation/compass_painter.dart';
import 'package:owghat_lib/src/features/qibla/presentation/qibla_map_tab.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';

/// The Qibla screen with two tabs:
///
/// * **Map**: the line from the chosen position (the prayer-times city, this
///   device, or any point) to the Kaaba on a map, with the angle and distance.
/// * **Compass and sun**: a compass rose with the qibla line and the sun, the
///   bearing, the distance, today's sun-on-qibla times and the note that a PC
///   has no compass. It works without the internet.
class QiblaPage extends ConsumerStatefulWidget {
  /// Creates the page.
  const QiblaPage({super.key});

  /// Width from which the compass and the facts sit side by side.
  static const double twoColumnWidth = 720;

  @override
  ConsumerState<QiblaPage> createState() => _QiblaPageState();
}

enum _QiblaTab { map, compass }

class _QiblaPageState extends ConsumerState<QiblaPage> {
  _QiblaTab _tab = _QiblaTab.map;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Gaps.l, Gaps.l, Gaps.l, 0),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SegmentedButton<_QiblaTab>(
              key: const Key('qibla-tabs'),
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: _QiblaTab.map,
                  label: Text(l10n.qiblaTabMap),
                  icon: const Icon(Icons.map_outlined),
                ),
                ButtonSegment(
                  value: _QiblaTab.compass,
                  label: Text(l10n.qiblaTabCompass),
                  icon: const Icon(Icons.explore_outlined),
                ),
              ],
              selected: {_tab},
              onSelectionChanged: (selection) =>
                  setState(() => _tab = selection.first),
            ),
          ),
        ),
        Expanded(
          child: switch (_tab) {
            _QiblaTab.map => const QiblaMapTab(),
            _QiblaTab.compass => const _CompassTab(),
          },
        ),
      ],
    );
  }
}

class _CompassTab extends StatelessWidget {
  const _CompassTab();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= QiblaPage.twoColumnWidth;
        const compass = _CompassCard();
        const facts = _Facts();
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Gaps.l),
          child: twoColumns
              ? const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: compass),
                    SizedBox(width: Gaps.l),
                    Expanded(child: facts),
                  ],
                )
              : const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    compass,
                    SizedBox(height: Gaps.l),
                    facts,
                  ],
                ),
        );
      },
    );
  }
}

String _bearingText(AppLocalizations l10n, Formatter fmt, QiblaInfo info) =>
    l10n.qiblaBearingValue(
      fmt.formatNumber(info.bearing, fractionDigits: 1),
      l10n.homeCompass('p${info.compassIndex}'),
    );

class _CompassCard extends ConsumerWidget {
  const _CompassCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final fmt = ref.watch(formatterProvider);
    final info = ref.watch(qiblaInfoProvider);
    final sun = ref.watch(sunNowProvider);
    final sunAzimuth = sun.isUp ? sun.azimuth : null;

    final base = l10n.qiblaCompassSemantics(
      fmt.formatNumber(info.bearing, fractionDigits: 1),
      l10n.homeCompass('p${info.compassIndex}'),
    );
    final semantics = sunAzimuth == null
        ? base
        : l10n.qiblaCompassSemanticsSun(base, fmt.formatNumber(sunAzimuth));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: AspectRatio(
              aspectRatio: 1,
              child: Semantics(
                image: true,
                label: semantics,
                child: ExcludeSemantics(
                  child: CustomPaint(
                    key: const Key('qibla-compass'),
                    painter: QiblaCompassPainter(
                      qiblaBearing: info.bearing,
                      sunAzimuth: sunAzimuth,
                      cardinals: [
                        for (final point in const ['n', 'e', 's', 'w'])
                          l10n.qiblaCardinal(point),
                      ],
                      colors: CompassColors(
                        face: colors.surfaceCard,
                        ring: theme.colorScheme.outline,
                        tick: theme.colorScheme.onSurfaceVariant,
                        label: theme.colorScheme.onSurface,
                        north: colors.danger,
                        qibla: theme.colorScheme.primary,
                        sun: colors.accentWarm,
                      ),
                      textDirection: Directionality.of(context),
                      textScaler: MediaQuery.textScalerOf(context),
                      fontFamily: theme.textTheme.bodyMedium?.fontFamily,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Facts extends ConsumerWidget {
  const _Facts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final fmt = ref.watch(formatterProvider);
    final language = ref.watch(settingsProvider.select((s) => s.language));
    final place = ref.watch(activeLocationProvider).nameIn(language);
    final info = ref.watch(qiblaInfoProvider);
    final sun = ref.watch(sunNowProvider);
    final today = ref.watch(sunOnQiblaTodayProvider);

    String clock(DateTime? instant) => instant == null
        ? l10n.homeNoValue
        // Rounded to the nearest minute, like every other time in the app.
        : fmt.formatInstant(
            instant.add(const Duration(seconds: 30)),
            today.utcOffset,
          );

    Widget fact(String label, String value, Key key) => Padding(
      padding: const EdgeInsets.only(bottom: Gaps.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, key: key, style: theme.textTheme.titleLarge),
        ],
      ),
    );

    Widget sunEvent({
      required String title,
      required String help,
      required DateTime? instant,
      required Key key,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: Gaps.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: Gaps.m,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(title, style: theme.textTheme.bodyLarge),
              Text(
                clock(instant),
                key: key,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: context.appColors.accentWarm,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            instant == null ? l10n.qiblaSunNone : help,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Gaps.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.qiblaForLocation(place),
              key: const Key('qibla-place'),
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: Gaps.m),
            fact(
              l10n.qiblaBearingLabel,
              _bearingText(l10n, fmt, info),
              const Key('qibla-bearing'),
            ),
            fact(
              l10n.qiblaDistanceLabel,
              l10n.qiblaDistanceValue(
                fmt.formatNumber(info.distanceKm.round()),
              ),
              const Key('qibla-distance'),
            ),
            fact(
              l10n.qiblaSunNowLabel,
              sun.isUp
                  ? l10n.qiblaSunNowValue(
                      fmt.formatNumber(sun.azimuth, fractionDigits: 1),
                      fmt.formatNumber(sun.altitude, fractionDigits: 1),
                    )
                  : l10n.qiblaSunBelow,
              const Key('qibla-sun-now'),
            ),
            const Divider(height: Gaps.xl),
            Text(l10n.qiblaSunTimesTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: Gaps.s),
            sunEvent(
              title: l10n.qiblaSunInTitle,
              help: l10n.qiblaSunInHelp,
              instant: today.inDirection,
              key: const Key('qibla-sun-in'),
            ),
            sunEvent(
              title: l10n.qiblaSunOppTitle,
              help: l10n.qiblaSunOppHelp,
              instant: today.opposite,
              key: const Key('qibla-sun-opposite'),
            ),
            const Divider(height: Gaps.xl),
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
                    l10n.qiblaNoCompassNote,
                    key: const Key('qibla-note'),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
