import 'package:flutter/material.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';

/// The page widget of [destination].
///
/// Pages are registered here as their features land; until then a
/// placeholder with the destination name is shown.
Widget destinationPage(Destination destination) =>
    _Placeholder(key: ValueKey(destination), destination: destination);

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.destination, super.key});

  final Destination destination;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Text(
        destination.label(l10n),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
    );
  }
}
