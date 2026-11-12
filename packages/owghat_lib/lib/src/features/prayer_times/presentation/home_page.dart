import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_banners.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/hero_card.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/home_banner_bar.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/home_header.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/now_playing_bar.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/status_card.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/today_list.dart';

/// The home screen: the next prayer and its
/// countdown first, today's times and the status below, a now-playing bar
/// at the bottom while audio plays.
class HomePage extends ConsumerWidget {
  /// Creates the page.
  const HomePage({super.key});

  /// Width from which the list and the status card sit side by side.
  static const double twoColumnWidth = 720;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing = ref.watch(azanPlaybackProvider.select((s) => s.playing));
    final hasBanner = ref.watch(homeBannerProvider) != null;

    final scroll = LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= twoColumnWidth;
        const list = TodayList();
        const status = StatusCard();
        // Everything is built at once (the page is short), so layout problems
        // never hide below the fold.
        return SingleChildScrollView(
          padding: const EdgeInsets.all(Gaps.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeBannerBar(),
              if (hasBanner) const SizedBox(height: Gaps.m),
              const HomeHeader(),
              const SizedBox(height: Gaps.m),
              const HeroCard(),
              const SizedBox(height: Gaps.l),
              if (twoColumns)
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: list),
                    SizedBox(width: Gaps.l),
                    Expanded(flex: 2, child: status),
                  ],
                )
              else
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    list,
                    SizedBox(height: Gaps.l),
                    status,
                  ],
                ),
            ],
          ),
        );
      },
    );

    final page = Column(
      children: [
        Expanded(child: scroll),
        const NowPlayingBar(),
      ],
    );
    if (!playing) return page;
    // Esc stops the audio while it plays.
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            ref.read(azanPlaybackProvider.notifier).stop(),
      },
      child: Focus(autofocus: true, child: page),
    );
  }
}
