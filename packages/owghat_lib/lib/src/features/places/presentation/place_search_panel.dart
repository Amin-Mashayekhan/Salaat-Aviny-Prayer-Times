import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/platform/place_search.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/places/application/place_search_model.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';

/// Search a place by name on the internet and choose one of the results.
///
/// It says plainly, before anything is sent, that the typed text goes to an
/// online search service and that this is needed only once. The text is sent
/// only when the person presses Search (or Enter), never while typing.
///
/// [onPicked] gets the chosen place (with its time zone and height when
/// [resolveDetails] is set). A failure to fetch them keeps the results on
/// screen so another place can be chosen.
class PlaceSearchPanel extends ConsumerStatefulWidget {
  /// Creates the panel.
  const PlaceSearchPanel({
    required this.onPicked,
    this.keyPrefix = 'place',
    this.settlementsOnly = false,
    this.resolveDetails = false,
    this.showTitle = true,
    super.key,
  });

  /// Prefix of the widget keys (two panels can exist in one tree).
  final String keyPrefix;

  /// Restrict the answer to cities, towns and villages.
  final bool settlementsOnly;

  /// Whether choosing a place also fetches its time zone and height.
  final bool resolveDetails;

  /// Whether the panel shows its own title.
  final bool showTitle;

  /// Called with the chosen place.
  final FutureOr<void> Function(PickedPlace picked) onPicked;

  @override
  ConsumerState<PlaceSearchPanel> createState() => _PlaceSearchPanelState();
}

class _PlaceSearchPanelState extends ConsumerState<PlaceSearchPanel> {
  final TextEditingController _text = TextEditingController();
  late final PlaceSearchModel _model = PlaceSearchModel(
    service: ref.read(placeSearchProvider),
    language: () => ref.read(settingsProvider).language.name,
    settlementsOnly: widget.settlementsOnly,
    resolveDetails: widget.resolveDetails,
  );

  String _key(String name) => '${widget.keyPrefix}-$name';

  @override
  void dispose() {
    _text.dispose();
    _model.dispose();
    super.dispose();
  }

  Future<void> _pick(FoundPlace place) async {
    final picked = await _model.pick(place);
    if (picked == null || !mounted) return;
    await widget.onPicked(picked);
  }

  String _failureText(AppLocalizations l10n) {
    if (_model.detailsFailed) return l10n.placeSearchFailDetails;
    return switch (_model.failure) {
      PlaceSearchFailure.offline => l10n.placeSearchFailOffline,
      PlaceSearchFailure.timeout => l10n.placeSearchFailTimeout,
      PlaceSearchFailure.busy => l10n.placeSearchFailBusy,
      _ => l10n.placeSearchFailGeneric,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = context.appColors;
    final muted = theme.textTheme.labelLarge?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) {
        final status = _model.status;
        final busy = _model.busy;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.showTitle) ...[
              Semantics(
                header: true,
                child: Text(
                  l10n.placeSearchTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: Gaps.s),
            ],
            DecoratedBox(
              key: Key(_key('notice')),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.6,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(Gaps.s),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.public,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: Gaps.s),
                    Expanded(
                      child: Text(
                        widget.resolveDetails
                            ? '${l10n.placeSearchNotice} '
                                  '${l10n.placeSearchNoticeDetails}'
                            : l10n.placeSearchNotice,
                        key: Key(_key('notice-text')),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Gaps.s),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: Key(_key('field')),
                    controller: _text,
                    enabled: !busy,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.placeSearchHint,
                    ),
                    onSubmitted: (value) => unawaited(_model.search(value)),
                  ),
                ),
                const SizedBox(width: Gaps.s),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: FilledButton(
                    key: Key(_key('button')),
                    onPressed: busy
                        ? null
                        : () => unawaited(_model.search(_text.text)),
                    child: Text(l10n.placeSearchButton),
                  ),
                ),
              ],
            ),
            if (status == PlaceSearchStatus.searching ||
                status == PlaceSearchStatus.resolving) ...[
              const SizedBox(height: Gaps.s),
              const LinearProgressIndicator(),
              const SizedBox(height: 4),
              Text(
                status == PlaceSearchStatus.searching
                    ? l10n.placeSearching
                    : l10n.placeSearchResolving(_model.resolving?.name ?? ''),
                key: Key(_key('progress')),
                style: muted,
              ),
            ],
            if (status == PlaceSearchStatus.tooShort)
              _Message(
                key: Key(_key('message')),
                icon: Icons.info_outline,
                color: colors.warning,
                text: l10n.placeSearchTooShort,
              ),
            if (status == PlaceSearchStatus.empty)
              _Message(
                key: Key(_key('message')),
                icon: Icons.search_off,
                color: colors.warning,
                text: l10n.placeSearchNone(_model.query),
              ),
            if (status == PlaceSearchStatus.failed)
              _Message(
                key: Key(_key('message')),
                icon: _model.failure == PlaceSearchFailure.offline
                    ? Icons.wifi_off
                    : Icons.error_outline,
                color: colors.danger,
                text: _failureText(l10n),
              ),
            if (_model.results.isNotEmpty &&
                status != PlaceSearchStatus.searching) ...[
              const SizedBox(height: Gaps.s),
              Text(l10n.placeSearchResultsTitle, style: muted),
              const SizedBox(height: 4),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  key: Key(_key('results')),
                  children: [
                    for (var i = 0; i < _model.results.length; i++) ...[
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        key: Key(_key('result-$i')),
                        enabled: !busy,
                        leading: const Icon(Icons.place_outlined),
                        title: Text(_model.results[i].name),
                        subtitle: _model.results[i].region.isEmpty
                            ? null
                            : Text(_model.results[i].region),
                        onTap: () => unawaited(_pick(_model.results[i])),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: Gaps.s),
            Text(
              l10n.placeSearchAttribution,
              key: Key(_key('attribution')),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.color,
    required this.text,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Gaps.s),
    child: Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: Gaps.s),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    ),
  );
}
