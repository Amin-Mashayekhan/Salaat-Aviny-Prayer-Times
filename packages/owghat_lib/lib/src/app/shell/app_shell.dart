import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/app/shell/destination_pages.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/onboarding/presentation/onboarding_page.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/application/wake_alarm_controller.dart';
import 'package:owghat_lib/src/features/wake_alarm/presentation/countdown_overlay.dart';

/// Navigation plus the page of the selected destination; the first-run flow
/// instead while `settings.onboardingCompleted` is false.
///
/// A window at least [compactWidth] wide has a navigation rail at the side;
/// a narrower one (a phone) a navigation bar at the bottom.
class AppShell extends ConsumerWidget {
  /// Creates the shell.
  const AppShell({super.key});

  /// Content is never wider than this, however large the window.
  static const double maxContentWidth = 960;

  /// Below this width the navigation moves to a bar at the bottom.
  static const double compactWidth = 600;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarded = ref.watch(
      settingsProvider.select((s) => s.onboardingCompleted),
    );
    if (!onboarded) return const OnboardingPage();

    final l10n = AppLocalizations.of(context);
    final current = ref.watch(destinationProvider);
    final visible = ref.watch(visibleDestinationsProvider);
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < compactWidth;
    final narrow = width < 900;
    final selected = visible.indexOf(current).clamp(0, visible.length - 1);
    void select(int i) =>
        ref.read(destinationProvider.notifier).select(visible[i]);

    final shortcuts = <ShortcutActivator, VoidCallback>{
      // Ctrl+1..6 jump to the destinations in rail order, Ctrl+, opens
      // Settings, Esc stops a playing azan from any screen.
      for (var i = 0; i < visible.length; i++)
        SingleActivator(_digitKeys[i], control: true): () => select(i),
      const SingleActivator(LogicalKeyboardKey.comma, control: true): () =>
          ref.read(destinationProvider.notifier).select(Destination.settings),
      const SingleActivator(LogicalKeyboardKey.escape): () {
        if (ref.read(wakeCountdownProvider).active) {
          ref.read(wakeAlarmControllerProvider.notifier).cancelCountdown();
          return;
        }
        if (ref.read(azanPlaybackProvider).playing) {
          unawaited(ref.read(azanPlaybackProvider.notifier).stop());
        }
      },
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        autofocus: true,
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Row(
                  children: [
                    if (!compact) ...[
                      NavigationRail(
                        labelType: narrow
                            ? NavigationRailLabelType.none
                            : NavigationRailLabelType.all,
                        selectedIndex: selected,
                        onDestinationSelected: select,
                        destinations: [
                          for (final d in visible)
                            NavigationRailDestination(
                              icon: Icon(d.icon),
                              selectedIcon: Icon(d.selectedIcon),
                              label: Text(d.label(l10n)),
                            ),
                        ],
                      ),
                      const VerticalDivider(width: 1),
                    ],
                    Expanded(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: maxContentWidth,
                          ),
                          child: destinationPage(current),
                        ),
                      ),
                    ),
                  ],
                ),
                // The sleep countdown after an alarm must be visible and
                // cancellable on every screen (it is not a modal dialog).
                const Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    heightFactor: 1,
                    child: SizedBox(width: 520, child: WakeCountdownOverlay()),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: compact
              ? NavigationBar(
                  key: const Key('shell-bottom-nav'),
                  selectedIndex: selected,
                  onDestinationSelected: select,
                  labelBehavior:
                      NavigationDestinationLabelBehavior.onlyShowSelected,
                  destinations: [
                    for (final d in visible)
                      NavigationDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: d.label(l10n),
                      ),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  static const List<LogicalKeyboardKey> _digitKeys = [
    LogicalKeyboardKey.digit1,
    LogicalKeyboardKey.digit2,
    LogicalKeyboardKey.digit3,
    LogicalKeyboardKey.digit4,
    LogicalKeyboardKey.digit5,
    LogicalKeyboardKey.digit6,
  ];
}
