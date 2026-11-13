import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_colors.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_banners.dart';
import 'package:owghat_lib/src/features/scheduler/application/notice_permissions.dart';
import 'package:owghat_lib/src/features/settings/application/formatter_provider.dart';

/// The banner above the hero card (one at a time, by priority), with a
/// close button. Renders nothing when no banner applies.
class HomeBannerBar extends ConsumerWidget {
  /// Creates the bar.
  const HomeBannerBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banner = ref.watch(homeBannerProvider);
    if (banner == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final fmt = ref.watch(formatterProvider);
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    final permissions = ref.read(noticePermissionsProvider.notifier);
    // Banners that the person can act on get a button.
    final action = switch (banner) {
      NotificationsOffBanner() => () => unawaited(
        permissions.askNotifications(),
      ),
      ExactTimingBanner() => () => unawaited(permissions.askExactTiming()),
      _ => null,
    };
    final (IconData icon, Color tint, String text) = switch (banner) {
      NotificationsOffBanner() => (
        Icons.notifications_off_outlined,
        colors.danger,
        l10n.homeBannerNotificationsOff,
      ),
      ExactTimingBanner() => (
        Icons.alarm_off_outlined,
        colors.warning,
        l10n.homeBannerExactTiming,
      ),
      MutedBanner(:final until, :final utcOffset) => (
        Icons.volume_off_outlined,
        scheme.primary,
        until == null
            ? l10n.homeBannerMutedIndefinite
            : l10n.homeBannerMutedUntil(
                Formatter.isolate(fmt.formatInstant(until, utcOffset)),
              ),
      ),
      ClockSkewBanner(:final skew) => (
        Icons.schedule,
        colors.warning,
        l10n.homeBannerClockSkew(fmt.formatDuration(skew.abs())),
      ),
      StaleZoneBanner() => (
        Icons.public_off_outlined,
        colors.warning,
        l10n.homeBannerStaleZone,
      ),
      SettingsResetBanner() => (
        Icons.restore,
        colors.danger,
        l10n.homeBannerSettingsReset,
      ),
    };

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        key: Key('banner-${banner.key.split(':').first}'),
        padding: const EdgeInsetsDirectional.only(start: Gaps.m),
        decoration: BoxDecoration(
          color: tint.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Radii.control),
          border: Border.all(color: tint.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: tint),
            const SizedBox(width: Gaps.m),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: Gaps.s),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            if (action != null)
              TextButton(
                key: const Key('banner-action'),
                onPressed: action,
                child: Text(l10n.homeBannerAllow),
              ),
            IconButton(
              key: const Key('banner-dismiss'),
              tooltip: l10n.homeBannerDismiss,
              icon: const Icon(Icons.close),
              onPressed: () => ref
                  .read(dismissedBannersProvider.notifier)
                  .dismiss(banner.key),
            ),
          ],
        ),
      ),
    );
  }
}
