import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/core/time/second_ticker.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/prayer_times/application/prayer_providers.dart';
import 'package:owghat_lib/src/features/window/application/window_visible_provider.dart';

void main() {
  final base = DateTime.utc(2026, 11, 11, 12, 0, 30, 400);

  test('secondTicks aligns to whole seconds', () {
    fakeAsync((async) {
      final seen = <DateTime>[];
      final sub = secondTicks(Clock(() => base.add(async.elapsed)))
          .listen(seen.add);
      async.elapse(const Duration(seconds: 3));
      expect(seen.length, 4);
      expect(seen[1].microsecond, 0);
      expect(seen[1].millisecond, 0);
      expect(seen[1].second, 31);
      unawaited(sub.cancel());
    });
  });

  test('minuteTicks aligns to whole minutes', () {
    fakeAsync((async) {
      final seen = <DateTime>[];
      final sub = minuteTicks(Clock(() => base.add(async.elapsed)))
          .listen(seen.add);
      async.elapse(const Duration(minutes: 3));
      expect(seen.length, 4);
      expect(seen[1].second, 0);
      expect(seen[1].minute, 1);
      unawaited(sub.cancel());
    });
  });

  test('a hidden window ticks once a minute, a visible one every second', () {
    fakeAsync((async) {
      final container = ProviderContainer(
        overrides: [
          systemClockProvider.overrideWithValue(
            Clock(() => base.add(async.elapsed)),
          ),
        ],
      );
      addTearDown(container.dispose);
      var ticks = 0;
      container.listen(
        nowTickProvider,
        (_, _) => ticks++,
        fireImmediately: true,
      );
      async.elapse(const Duration(seconds: 10));
      final visibleTicks = ticks;
      expect(visibleTicks, greaterThanOrEqualTo(10));

      container.read(windowVisibleProvider.notifier).set(visible: false);
      async.flushMicrotasks();
      ticks = 0;
      async.elapse(const Duration(seconds: 59));
      expect(ticks, lessThanOrEqualTo(4));
      async.elapse(const Duration(minutes: 5));
      expect(ticks, lessThanOrEqualTo(12));
    });
  });
}

void unawaited(Future<void> f) {}
