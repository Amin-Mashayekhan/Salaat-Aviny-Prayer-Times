import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_notice_scheduler.dart';
import 'package:owghat_lib/src/core/platform/launch_args.dart';
import 'package:owghat_lib/src/core/platform/notice_scheduler.dart';
import 'package:owghat_lib/src/core/platform/platform_capabilities.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/prayer_times/application/home_banners.dart';
import 'package:owghat_lib/src/features/scheduler/application/notice_permissions.dart';
import 'package:owghat_lib/src/features/scheduler/application/notice_planner.dart';
import 'package:owghat_lib/src/features/scheduler/application/scheduler_providers.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:prayer_core/prayer_core.dart';

import '../support/app_harness.dart';
import '../support/platform_world.dart';
import '../support/test_data.dart';

void main() {
  late LocationRepository repo;
  setUpAll(() async => repo = await loadTestRepository());

  group('capabilities', () {
    test('desktop, phone and browser differ only where they must', () {
      const d = PlatformCapabilities.desktop;
      expect(d.desktopWindow && d.autostart && d.wakeTimers, isTrue);
      expect(d.osScheduledNotices, isFalse);
      const m = PlatformCapabilities.mobile;
      expect(m.desktopWindow || m.autostart || m.wakeTimers, isFalse);
      expect(m.osScheduledNotices, isTrue);
      const w = PlatformCapabilities.web;
      expect(w.osScheduledNotices || w.wakeTimers, isFalse);
      // ignore: use_named_constants, checks the equality of a new object
      expect(d == const PlatformCapabilities(), isTrue);
      // ignore: use_named_constants, as above
      expect(d.hashCode, const PlatformCapabilities().hashCode);
      expect(d == m, isFalse);
    });

    test('the default scheduler does nothing and allows everything', () async {
      const s = NoNoticeScheduler();
      await s.replaceAll(const []);
      expect(await s.requestPermissions(), isTrue);
      expect(await s.exactTimingAllowed(), isTrue);
      await s.requestExactTiming();
    });
  });

  group('planned notices (phone)', () {
    late FakeNoticeScheduler scheduler;

    PlatformWorld world({AppSettings? settings}) {
      scheduler = FakeNoticeScheduler();
      final w = PlatformWorld(
        repo,
        settings: settings,
        now: PlatformWorld.tehran(12, 0),
        extra: [
          platformCapabilitiesProvider.overrideWithValue(
            PlatformCapabilities.mobile,
          ),
          noticeSchedulerProvider.overrideWithValue(scheduler),
        ],
      );
      addTearDown(w.dispose);
      // As bootstrap does: the planner runs from the start.
      w.read(noticePlannerProvider);
      return w;
    }

    Future<void> settle() => Future<void>.delayed(Duration.zero);

    test('ten days of azans and reminders, from now on, in order', () async {
      final w = world();
      final notices = w.read(_plan);
      expect(notices, isNotEmpty);
      final now = w.now;
      expect(notices.every((n) => n.instantUtc.isAfter(now)), isTrue);
      for (var i = 1; i < notices.length; i++) {
        expect(
          notices[i].instantUtc.isBefore(notices[i - 1].instantUtc),
          isFalse,
        );
      }
      expect(
        notices.last.instantUtc.difference(now),
        lessThan(const Duration(days: plannedNoticeDays)),
      );
      expect(
        notices.last.instantUtc.difference(now),
        greaterThan(const Duration(days: plannedNoticeDays - 2)),
      );
      final azans = notices.where((n) => n.kind == PlannedNoticeKind.azan);
      final reminders = notices.where(
        (n) => n.kind == PlannedNoticeKind.reminder,
      );
      expect(azans, isNotEmpty);
      expect(reminders, isNotEmpty);
      expect(azans.every((n) => n.sound), isTrue);
      // The texts are the same as the in-app notifications (Persian here).
      expect(azans.first.spec.title, startsWith('اذان'));
      expect(azans.first.spec.buttons, isEmpty, reason: 'nothing to stop');
    });

    test('a prayer whose azan is off gets no notification', () async {
      const defaults = AppSettings.defaults();
      final w = world(
        settings: defaults.copyWith(
          azan: defaults.azan.copyWith(
            perPrayer: {
              ...defaults.azan.perPrayer,
              Prayer.maghrib: const PrayerAzan(),
            },
          ),
        ),
      );
      final notices = w.read(_plan);
      expect(
        notices.where(
          (n) =>
              n.kind == PlannedNoticeKind.azan && n.spec.title.contains('مغرب'),
        ),
        isEmpty,
      );
    });

    test('muted: the azan is still shown, silently', () async {
      const defaults = AppSettings.defaults();
      final w = world(
        settings: defaults.copyWith(
          azan: defaults.azan.copyWith(
            mute: const MuteSetting(indefinite: true),
          ),
        ),
      );
      final notices = w.read(_plan);
      expect(notices, isNotEmpty);
      expect(notices.every((n) => !n.sound), isTrue);
    });

    test('a reminder without the chime is silent', () async {
      const defaults = AppSettings.defaults();
      final w = world(
        settings: defaults.copyWith(
          reminders: defaults.reminders.copyWith(chime: false),
        ),
      );
      final reminders = w
          .read(_plan)
          .where((n) => n.kind == PlannedNoticeKind.reminder);
      expect(reminders, isNotEmpty);
      expect(reminders.every((n) => !n.sound), isTrue);
    });

    test(
      'the planner hands the plan over at start and after a change',
      () async {
        final w = world();
        expect(w.read(noticePlannerProvider), isNotNull);
        await settle();
        expect(scheduler.replaceCalls, 1);
        expect(scheduler.planned, isNotEmpty);
        w.read(settingsProvider.notifier).setReminderChime(enabled: false);
        await settle();
        expect(scheduler.replaceCalls, 2);
      },
    );

    test('on the desktop there is no planner', () {
      final w = PlatformWorld(repo, now: PlatformWorld.tehran(12, 0));
      addTearDown(w.dispose);
      expect(w.read(noticePlannerProvider), isNull);
    });

    test('the app does not sound the azan itself where the system does, and '
        'a new day moves the plan on', () async {
      final w = world();
      await w
          .read(eventDispatcherProvider)
          .dispatch(
            w.azanEvent(Prayer.maghrib, hour: 17, minute: 19),
            CatchUpDecision.fire,
          );
      await w
          .read(eventDispatcherProvider)
          .dispatch(
            w.reminderEvent(Prayer.maghrib, hour: 17, minute: 19),
            CatchUpDecision.fire,
          );
      expect(w.audio.plays, isEmpty);
      expect(w.notifier.shown, isEmpty);
      await settle();
      final before = scheduler.replaceCalls;
      await w
          .read(eventDispatcherProvider)
          .dispatch(
            ScheduledEvent(
              kind: EventKind.dayRollover,
              instantUtc: w.now,
              date: CivilDate(2026, 11, 12),
            ),
            CatchUpDecision.fire,
          );
      expect(scheduler.replaceCalls, before + 1);
    });

    test('permissions: asked at start, banners follow the answers, and '
        'exact timing granted later plans again', () async {
      final w = world();
      await settle();
      scheduler
        ..permitted = false
        ..exact = false;
      final controller = w.read(noticePermissionsProvider.notifier);
      await controller.requestAtStart();
      expect(scheduler.permissionRequests, 1);
      expect(
        w.read(activeBannersProvider).first,
        isA<NotificationsOffBanner>(),
      );
      scheduler.permitted = true;
      await controller.askNotifications();
      expect(w.read(activeBannersProvider).first, isA<ExactTimingBanner>());
      final before = scheduler.replaceCalls;
      scheduler.exact = true;
      await controller.askExactTiming();
      expect(scheduler.exactRequests, 1);
      await settle();
      expect(
        w.read(activeBannersProvider).whereType<ExactTimingBanner>(),
        isEmpty,
      );
      expect(scheduler.replaceCalls, before + 1);
    });

    test('nothing is asked on the desktop', () async {
      final desktopScheduler = FakeNoticeScheduler();
      final w = PlatformWorld(
        repo,
        extra: [noticeSchedulerProvider.overrideWithValue(desktopScheduler)],
      );
      addTearDown(w.dispose);
      await w.read(noticePermissionsProvider.notifier).requestAtStart();
      await w.read(noticePermissionsProvider.notifier).refresh();
      expect(desktopScheduler.permissionRequests, 0);
      expect(w.read(noticePermissionsProvider), const NoticePermissions());
    });
  });

  group('phone screens', () {
    Future<AppHarness> openPhone(
      WidgetTester tester, {
      AppSettings settings = englishSettings,
      LaunchArgs args = const LaunchArgs(),
      bool onboardingDone = true,
    }) => AppHarness.pump(
      tester,
      repository: repo,
      size: const Size(390, 844),
      settings: settings,
      onboardingDone: onboardingDone,
      overrides: [
        platformCapabilitiesProvider.overrideWithValue(
          PlatformCapabilities.mobile,
        ),
        noticeSchedulerProvider.overrideWithValue(FakeNoticeScheduler()),
        launchArgsProvider.overrideWithValue(args),
      ],
    );

    testWidgets('a bottom bar with five screens and no Wake-up', (
      tester,
    ) async {
      final h = await openPhone(tester);
      expect(find.byKey(const Key('shell-bottom-nav')), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
      expect(h.container.read(visibleDestinationsProvider), [
        Destination.home,
        Destination.timetable,
        Destination.calendar,
        Destination.qibla,
        Destination.settings,
      ]);
      // A tap on the bar opens the screen.
      await tester.tap(
        find.descendant(
          of: find.byKey(const Key('shell-bottom-nav')),
          matching: find.byIcon(Destination.qibla.icon),
        ),
      );
      await tester.pumpAndSettle();
      expect(h.container.read(destinationProvider), Destination.qibla);
    });

    testWidgets('the Wake-up screen cannot be opened, not even by --page', (
      tester,
    ) async {
      final h = await openPhone(tester, args: const LaunchArgs(page: 'wakeup'));
      expect(h.container.read(destinationProvider), Destination.home);
      h.container.read(destinationProvider.notifier).select(Destination.wakeUp);
      expect(h.container.read(destinationProvider), Destination.home);
      expect(find.byKey(const Key('status-wake')), findsNothing);
    });

    testWidgets('settings: no autostart, minimised or tray options; the azan '
        'section explains phone notifications', (tester) async {
      final h = await openPhone(tester);
      h.container
          .read(destinationProvider.notifier)
          .select(Destination.settings);
      h.container
          .read(selectedSettingsSectionProvider.notifier)
          .select(SettingsSection.app);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('set-app-autostart')), findsNothing);
      expect(find.byKey(const Key('set-app-minimized')), findsNothing);
      expect(find.byKey(const Key('set-app-close-to-tray')), findsNothing);
      expect(find.byKey(const Key('set-backup-export')), findsOneWidget);
      h.container
          .read(selectedSettingsSectionProvider.notifier)
          .select(SettingsSection.azan);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('set-azan-phone-note')), findsOneWidget);
    });

    testWidgets('onboarding has no "start with Windows" switch', (
      tester,
    ) async {
      await openPhone(tester, onboardingDone: false);
      await tester.tap(find.byKey(const Key('onboarding-next')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('onboarding-next')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('onboarding-preview')), findsOneWidget);
      expect(find.byKey(const Key('onboarding-startup')), findsNothing);
    });

    testWidgets('the banner asks for exact timing with an Allow button', (
      tester,
    ) async {
      final h = await openPhone(tester);
      final scheduler =
          h.container.read(noticeSchedulerProvider) as FakeNoticeScheduler;
      scheduler.exact = false;
      await h.container.read(noticePermissionsProvider.notifier).refresh();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('banner-exact-timing')), findsOneWidget);
      expect(find.textContaining('Alarms & reminders'), findsOneWidget);
      await tester.tap(find.byKey(const Key('banner-action')));
      await tester.pumpAndSettle();
      expect(scheduler.exactRequests, 1);
    });

    testWidgets('desktop keeps the rail, six screens and all options', (
      tester,
    ) async {
      final h = await AppHarness.pump(
        tester,
        repository: repo,
        settings: englishSettings,
      );
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byKey(const Key('shell-bottom-nav')), findsNothing);
      expect(h.container.read(visibleDestinationsProvider).length, 6);
    });
  });
}

/// The planned notices of a world's current state.
final Provider<List<PlannedNotice>> _plan = Provider(buildPlannedNotices);
