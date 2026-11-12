import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';

/// The destination currently shown in the shell.
class DestinationController extends Notifier<Destination> {
  @override
  Destination build() =>
      destinationFromName(ref.read(launchArgsProvider).page) ??
      Destination.home;

  /// Shows [destination].
  // A method reads better than a setter at call sites such as onTap.
  // ignore: use_setters_to_change_properties
  void select(Destination destination) => state = destination;
}

/// Provider of [DestinationController].
final destinationProvider =
    NotifierProvider<DestinationController, Destination>(
      DestinationController.new,
    );
