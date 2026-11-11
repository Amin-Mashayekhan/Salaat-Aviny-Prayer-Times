import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_labels.dart';

/// The bar at the bottom of the home screen while an azan (or a preview)
/// plays: what plays, how far, and a Stop button. Nothing when idle.
class NowPlayingBar extends ConsumerWidget {
  /// Creates the bar.
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(azanPlaybackProvider);
    if (!state.playing) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final prayer = state.prayer;
    final title = prayer == null
        ? l10n.homeNowPlayingGeneric
        : l10n.homeNowPlaying(prayer.label(l10n));
    final total = state.duration?.inMicroseconds ?? 0;
    // A determinate bar even when the length is unknown: no looping motion.
    final progress = total <= 0
        ? 0.0
        : (state.position.inMicroseconds / total).clamp(0.0, 1.0);

    return Material(
      key: const Key('now-playing-bar'),
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Gaps.l,
          vertical: Gaps.s,
        ),
        child: Row(
          children: [
            Icon(
              Icons.volume_up_rounded,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: Gaps.m),
            Flexible(
              flex: 2,
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: Gaps.m),
            Expanded(
              flex: 3,
              child: Semantics(
                value: '${(progress * 100).round()}%',
                child: LinearProgressIndicator(
                  value: progress,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(width: Gaps.m),
            FilledButton.tonalIcon(
              key: const Key('now-playing-stop'),
              onPressed: () => ref.read(azanPlaybackProvider.notifier).stop(),
              icon: const Icon(Icons.stop_rounded),
              label: Text(l10n.homeStop),
            ),
          ],
        ),
      ),
    );
  }
}
