import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/core/platform/app_notifier.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/azan/application/azan_playback.dart';
import 'package:owghat_lib/src/features/window/application/window_controller.dart';

/// Carries out the buttons of notifications: Stop silences the azan, and
/// clicking a toast opens the window. Reading the provider starts it.
final notificationActionRouterProvider = Provider<void>((ref) {
  final subscription = ref.read(appNotifierProvider).actions.listen((action) {
    switch (action.kind) {
      case NotificationActionKind.stop:
        unawaited(ref.read(azanPlaybackProvider.notifier).stop());
      case NotificationActionKind.open:
        unawaited(ref.read(windowControllerProvider).show());
    }
  });
  ref.onDispose(() => unawaited(subscription.cancel()));
});
