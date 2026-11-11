import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/features/calendar/application/calendar_names.dart';
import 'package:owghat_lib/src/features/locations/application/location_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/viewed_date_provider.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';

/// The top of the home screen: the location (with the switcher of saved
/// locations), the three dates and the day navigation.
class HomeHeader extends ConsumerWidget {
  /// Creates the header.
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 640;
        const location = _LocationSwitcher();
        const dates = _DateBlock();
        if (wide) {
          return const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: location),
              SizedBox(width: Gaps.l),
              Expanded(child: dates),
            ],
          );
        }
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            location,
            SizedBox(height: Gaps.s),
            dates,
          ],
        );
      },
    );
  }
}

class _LocationSwitcher extends ConsumerWidget {
  const _LocationSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = ref.watch(settingsProvider.select((s) => s.language));
    final active = ref.watch(activeLocationProvider);
    final saved = ref.watch(savedLocationsProvider);

    return PopupMenuButton<String>(
      key: const Key('home-location-switcher'),
      tooltip: l10n.homeSwitchLocation,
      onSelected: (id) =>
          ref.read(settingsProvider.notifier).setActiveLocation(id),
      itemBuilder: (context) => [
        for (final location in saved)
          CheckedPopupMenuItem<String>(
            value: location.id,
            checked: location.id == active.id,
            child: Text(location.nameIn(language)),
          ),
      ],
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.place_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: Gaps.s),
            Flexible(
              child: Text(
                active.nameIn(language),
                key: const Key('home-location-name'),
                style: theme.textTheme.headlineMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class _DateBlock extends ConsumerWidget {
  const _DateBlock();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final viewed = ref.watch(viewedDateProvider);
    final today = ref.watch(todayProvider);
    final shown = viewed ?? today;
    final header = ref.watch(dateHeaderProvider(shown));
    final controller = ref.read(viewedDateProvider.notifier);

    final hijri = header.hijri;
    final secondary = Wrap(
      alignment: WrapAlignment.end,
      children: [
        if (hijri != null)
          Tooltip(
            message: header.hijriApproximate
                ? l10n.calendarHijriApproxHint
                : '',
            child: Text(
              '$hijri · ',
              key: const Key('date-hijri'),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        Text(
          header.gregorian,
          key: const Key('date-gregorian'),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          header.primary,
          key: const Key('date-primary'),
          style: theme.textTheme.titleLarge,
          textAlign: TextAlign.end,
        ),
        secondary,
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              key: const Key('day-previous'),
              tooltip: l10n.homePreviousDay,
              icon: const Icon(Icons.navigate_before),
              onPressed: () => controller.shiftDays(-1),
            ),
            if (viewed != null)
              ActionChip(
                key: const Key('day-today-chip'),
                label: Text(l10n.homeToday),
                tooltip: l10n.homeBackToToday,
                onPressed: controller.reset,
              ),
            IconButton(
              key: const Key('day-next'),
              tooltip: l10n.homeNextDay,
              icon: const Icon(Icons.navigate_next),
              onPressed: () => controller.shiftDays(1),
            ),
          ],
        ),
      ],
    );
  }
}
