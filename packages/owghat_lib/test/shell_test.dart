import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/app.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';

import 'support/app_harness.dart';
import 'support/test_data.dart';

void main() {
  // The shell hosts the home page, which needs the city database and a fake
  // clock, so the app harness builds the whole app around the shell.
  late LocationRepository repo;
  late AppHarness harness;
  setUpAll(() async => repo = await loadTestRepository());

  Future<void> pump(
    WidgetTester tester,
    Locale locale, {
    Size size = const Size(1200, 800),
  }) async {
    harness = await AppHarness.pump(
      tester,
      repository: repo,
      size: size,
      overrides: [localeProvider.overrideWithValue(locale)],
    );
  }

  TextDirection directionOf(WidgetTester tester) =>
      Directionality.of(tester.element(find.byType(Scaffold)));

  testWidgets('shell is right-to-left in Persian and switches page', (
    tester,
  ) async {
    await pump(tester, const Locale('fa'));
    expect(directionOf(tester), TextDirection.rtl);
    expect(find.text('خانه'), findsWidgets);
    await tester.tap(find.text('قبله'));
    await tester.pumpAndSettle();
    expect(harness.container.read(destinationProvider), Destination.qibla);
  });

  testWidgets('shell is left-to-right in English', (tester) async {
    await pump(tester, const Locale('en'));
    expect(directionOf(tester), TextDirection.ltr);
    expect(find.text('Home'), findsWidgets);
  });

  testWidgets('narrow window shows an icon-only rail without overflow', (
    tester,
  ) async {
    await pump(tester, const Locale('fa'), size: const Size(800, 560));
    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.home), findsOneWidget);
  });

  group('keyboard shortcuts', () {
    testWidgets('Ctrl+1..6 select the destinations in rail order', (
      tester,
    ) async {
      await pump(tester, const Locale('en'));
      for (var i = 0; i < Destination.values.length; i++) {
        final key = [
          LogicalKeyboardKey.digit1,
          LogicalKeyboardKey.digit2,
          LogicalKeyboardKey.digit3,
          LogicalKeyboardKey.digit4,
          LogicalKeyboardKey.digit5,
          LogicalKeyboardKey.digit6,
        ][i];
        await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
        await tester.sendKeyEvent(key);
        await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
        await tester.pumpAndSettle();
        expect(
          harness.container.read(destinationProvider),
          Destination.values[i],
        );
      }
    });

    testWidgets('Ctrl+comma opens Settings', (tester) async {
      await pump(tester, const Locale('en'));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.comma);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pumpAndSettle();
      expect(harness.container.read(destinationProvider), Destination.settings);
    });
  });
}
