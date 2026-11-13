import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';

/// The destination currently shown in the shell.
class DestinationController extends Notifier<Destination> {
  @override
  Destination build() {
    final named = destinationFromName(ref.read(launchArgsProvider).page);
    if (named != null &&
        ref.read(visibleDestinationsProvider).contains(named)) {
      return named;
    }
    return Destination.home;
  }

  /// Shows [destination].
  void select(Destination destination) {
    // A screen this platform does not have (the Wake-up screen on a phone)
    // is never opened.
    if (!ref.read(visibleDestinationsProvider).contains(destination)) return;
    state = destination;
  }
}

/// Provider of [DestinationController].
final destinationProvider =
    NotifierProvider<DestinationController, Destination>(
      DestinationController.new,
    );

/// The destinations this platform shows, in navigation order: the Wake-up
/// screen only where the computer can be woken from sleep.
final visibleDestinationsProvider = Provider<List<Destination>>((ref) {
  final capabilities = ref.watch(platformCapabilitiesProvider);
  return [
    for (final d in Destination.values)
      if (d != Destination.wakeUp || capabilities.wakeTimers) d,
  ];
});
