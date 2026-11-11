import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/app.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';

void main() {
  Future<void> pump(
    WidgetTester tester,
    Locale locale, {
    Size size = const Size(1200, 800),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localeProvider.overrideWithValue(locale)],
        child: const OwghatApp(),
      ),
    );
    await tester.pumpAndSettle();
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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold)),
    );
    expect(container.read(destinationProvider), Destination.qibla);
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
}
