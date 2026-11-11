import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/app/shell/destination_pages.dart';

/// Navigation rail plus the page of the selected destination.
class AppShell extends ConsumerWidget {
  /// Creates the shell.
  const AppShell({super.key});

  /// Content is never wider than this, however large the window.
  static const double maxContentWidth = 960;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(destinationProvider);
    final narrow = MediaQuery.sizeOf(context).width < 900;

    final items = [
      for (final d in Destination.values)
        NavigationRailDestination(
          icon: Icon(d.icon),
          selectedIcon: Icon(d.selectedIcon),
          label: Text(d.label(l10n)),
        ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            NavigationRail(
              labelType: narrow
                  ? NavigationRailLabelType.none
                  : NavigationRailLabelType.all,
              selectedIndex: Destination.values.indexOf(current),
              onDestinationSelected: (i) => ref
                  .read(destinationProvider.notifier)
                  .select(Destination.values[i]),
              destinations: items,
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: destinationPage(current),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
