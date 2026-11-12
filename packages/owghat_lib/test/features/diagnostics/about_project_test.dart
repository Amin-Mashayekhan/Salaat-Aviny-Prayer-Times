import 'package:flutter/material.dart' hide HourFormat;
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/app/theme/app_theme.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_link_opener.dart';
import 'package:owghat_lib/src/core/platform/link_opener.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/features/diagnostics/domain/project_info.dart';
import 'package:owghat_lib/src/features/diagnostics/presentation/about_project_cards.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

void main() {
  late FakeLinkOpener links;
  late List<String> clipboard;

  setUp(() {
    links = FakeLinkOpener();
    clipboard = [];
  });

  Future<void> pump(
    WidgetTester tester, {
    AppLanguage language = AppLanguage.en,
    Size size = const Size(900, 1400),
    double textScale = 1,
    Brightness brightness = Brightness.light,
    bool clipboardWorks = true,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = textScale;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          if (!clipboardWorks) throw PlatformException(code: 'unavailable');
          clipboard.add((call.arguments as Map)['text'] as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSettingsProvider.overrideWithValue(
            const AppSettings.defaults().copyWith(language: language),
          ),
          linkOpenerProvider.overrideWithValue(links),
        ],
        child: MaterialApp(
          locale: Locale(language.name),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: buildTheme(brightness),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [AuthorCard(), ContributeCard(), SupportCard()],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  String text(WidgetTester tester, String key) {
    final widget = tester.widget(find.byKey(Key(key)));
    if (widget is SelectableText) return widget.data!;
    return (widget as Text).data!;
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  group('project info', () {
    test('the card number is shown in groups of four and copied whole', () {
      expect(ProjectInfo.bankCardGrouped, '6219 8618 3801 9973');
      expect(
        ProjectInfo.bankCardGrouped.replaceAll(' ', ''),
        '6219861838019973',
      );
    });

    test('the links are web and mail links the app is willing to open', () {
      for (final uri in [
        Uri.parse(ProjectInfo.authorGithub),
        ProjectInfo.telegramLink,
        Uri.parse(ProjectInfo.repository),
        Uri.parse(ProjectInfo.issues),
        Uri.parse(ProjectInfo.contributingGuide),
        ProjectInfo.emailLink,
      ]) {
        expect(isOpenableLink(uri), isTrue, reason: '$uri');
      }
      expect(ProjectInfo.emailLink.toString(), startsWith('mailto:'));
    });

    test('the wallet address looks like an EVM address', () {
      expect(
        RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(ProjectInfo.usdtAddress),
        isTrue,
      );
    });
  });

  group('link opener rules', () {
    test('only https and mailto links are openable', () {
      expect(isOpenableLink(Uri.parse('https://example.com/a')), isTrue);
      expect(isOpenableLink(Uri.parse('mailto:a@b.c')), isTrue);
      expect(isOpenableLink(Uri.parse('http://example.com')), isFalse);
      expect(isOpenableLink(Uri.parse('file:///C:/Windows/x.exe')), isFalse);
      expect(isOpenableLink(Uri.parse('javascript:alert(1)')), isFalse);
      expect(
        isOpenableLink(Uri.parse('ms-settings:privacy-location')),
        isFalse,
      );
      expect(isOpenableLink(Uri.parse('https:')), isFalse);
      expect(isOpenableLink(Uri(scheme: 'mailto')), isFalse);
    });

    test('the unsupported opener refuses', () async {
      expect(
        await const UnsupportedLinkOpener().open(Uri.parse('https://a.b')),
        isFalse,
      );
    });
  });

  group('author card', () {
    testWidgets('shows the name, GitHub, Telegram, e-mail and mobile', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('About the developer'), findsOneWidget);
      expect(text(tester, 'author-name-value'), ProjectInfo.authorNameLatin);
      expect(text(tester, 'author-github-value'), ProjectInfo.authorGithub);
      expect(text(tester, 'author-telegram-value'), '@Amin_NiceDesign');
      expect(text(tester, 'author-email-value'), ProjectInfo.authorEmail);
      expect(text(tester, 'author-phone-value'), ProjectInfo.authorPhone);
    });

    for (final language in AppLanguage.values) {
      testWidgets('${language.name}: the name is written in Persian for the '
          'Arabic-script languages and in Latin letters for the others', (
        tester,
      ) async {
        await pump(tester, language: language);
        expect(
          text(tester, 'author-name-value'),
          language.rtl ? 'محمد امین مشایخان' : 'Mohammad Amin Mashayekhan',
        );
      });
    }

    testWidgets('the phone note says calls and texts work only from Iran and '
        'that Telegram is for the rest of the world', (tester) async {
      await pump(tester);
      final note = text(tester, 'author-phone-note');
      expect(note, contains('only from Iran'));
      expect(note, contains('Telegram'));
    });

    testWidgets('the licence is named', (tester) async {
      await pump(tester);
      expect(text(tester, 'author-licence-note'), contains('MIT'));
    });

    testWidgets('Telegram opens t.me and the number can be copied', (
      tester,
    ) async {
      await pump(tester);
      await tapKey(tester, 'author-telegram-open');
      expect(links.opened.single.toString(), 'https://t.me/Amin_NiceDesign');
      await tapKey(tester, 'author-phone-copy');
      expect(clipboard.last, ProjectInfo.authorPhone);
      expect(find.byKey(const Key('author-phone-open')), findsNothing);
    });

    testWidgets('Open hands the GitHub page and the mail link to the system', (
      tester,
    ) async {
      await pump(tester);
      await tapKey(tester, 'author-github-open');
      await tapKey(tester, 'author-email-open');
      expect(links.opened, [
        Uri.parse(ProjectInfo.authorGithub),
        ProjectInfo.emailLink,
      ]);
      expect(find.byKey(const Key('author-github-message')), findsNothing);
    });

    testWidgets('a link that cannot be opened says so and can be copied', (
      tester,
    ) async {
      links.result = false;
      await pump(tester);
      await tapKey(tester, 'author-github-open');
      expect(
        text(tester, 'author-github-message'),
        startsWith('Could not be opened'),
      );
      await tapKey(tester, 'author-github-copy');
      expect(clipboard.last, ProjectInfo.authorGithub);
      expect(text(tester, 'author-github-message'), 'Copied.');
    });

    testWidgets('the name row has no Copy and no Open button', (tester) async {
      await pump(tester);
      expect(find.byKey(const Key('author-name-copy')), findsNothing);
      expect(find.byKey(const Key('author-name-open')), findsNothing);
    });
  });

  group('support card', () {
    testWidgets('names the countries each way can be used from', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('Support the project'), findsOneWidget);
      expect(
        text(tester, 'support-card-method-countries'),
        startsWith('Iran only'),
      );
      expect(
        text(tester, 'support-crypto-method-countries'),
        startsWith('All countries'),
      );
      expect(find.text('Can be used in:'), findsNWidgets(2));
    });

    testWidgets('the card number is copied without spaces', (tester) async {
      await pump(tester);
      expect(
        text(tester, 'support-card-number-value'),
        ProjectInfo.bankCardGrouped,
      );
      await tapKey(tester, 'support-card-number-copy');
      expect(clipboard, [ProjectInfo.bankCard]);
      expect(text(tester, 'support-card-number-message'), 'Copied.');
    });

    testWidgets('the wallet address is copied and the network is named', (
      tester,
    ) async {
      await pump(tester);
      expect(text(tester, 'support-crypto-network-value'), contains('BEP20'));
      await tapKey(tester, 'support-crypto-address-copy');
      expect(clipboard, [ProjectInfo.usdtAddress]);
      expect(
        text(tester, 'support-crypto-warning'),
        contains('only USDT over the BEP20 network'),
      );
    });

    testWidgets('a failing clipboard is reported, not thrown', (tester) async {
      await pump(tester, clipboardWorks: false);
      await tapKey(tester, 'support-card-number-copy');
      expect(tester.takeException(), isNull);
      expect(text(tester, 'support-card-number-message'), 'Could not copy.');
    });

    testWidgets('the card says support is optional and nothing is locked', (
      tester,
    ) async {
      await pump(tester);
      expect(
        find.textContaining('keeps no feature behind a payment'),
        findsOneWidget,
      );
    });
  });

  group('contribute card', () {
    testWidgets('lists the five ways to take part', (tester) async {
      await pump(tester);
      expect(find.text('Contribute'), findsOneWidget);
      for (var i = 0; i < 5; i++) {
        expect(find.byKey(Key('contribute-way-$i')), findsOneWidget);
      }
    });

    testWidgets('the three buttons open the repository, issues and guide', (
      tester,
    ) async {
      await pump(tester);
      await tapKey(tester, 'contribute-open-repo');
      await tapKey(tester, 'contribute-open-issues');
      await tapKey(tester, 'contribute-open-guide');
      expect(links.opened.map((u) => u.toString()), [
        ProjectInfo.repository,
        ProjectInfo.issues,
        ProjectInfo.contributingGuide,
      ]);
    });

    testWidgets('a failed open shows one note', (tester) async {
      links.result = false;
      await pump(tester);
      await tapKey(tester, 'contribute-open-repo');
      expect(find.byKey(const Key('contribute-open-failed')), findsOneWidget);
      links.result = true;
      await tapKey(tester, 'contribute-open-issues');
      expect(find.byKey(const Key('contribute-open-failed')), findsNothing);
    });
  });

  group('every language', () {
    for (final language in AppLanguage.values) {
      for (final size in const [Size(360, 800), Size(900, 1400)]) {
        for (final scale in const [1.0, 2.0]) {
          testWidgets(
            '${language.name} ${size.width.toInt()}px x$scale: the three '
            'cards fit and have no empty texts',
            (tester) async {
              await pump(
                tester,
                language: language,
                size: size,
                textScale: scale,
                brightness: language.index.isEven
                    ? Brightness.light
                    : Brightness.dark,
              );
              expect(tester.takeException(), isNull);
              expect(find.byKey(const Key('author-card')), findsOneWidget);
              expect(find.byKey(const Key('support-card')), findsOneWidget);
              expect(find.byKey(const Key('contribute-card')), findsOneWidget);
              final l10n = AppLocalizations.of(
                tester.element(find.byKey(const Key('author-card'))),
              );
              expect(l10n.localeName, language.name);
              expect(l10n.supportCardCountries.trim(), isNotEmpty);
              expect(l10n.supportCryptoCountries.trim(), isNotEmpty);
              // The numbers and addresses stay left to right.
              final directionality = tester.widget<Directionality>(
                find
                    .ancestor(
                      of: find.byKey(const Key('support-crypto-address-value')),
                      matching: find.byType(Directionality),
                    )
                    .first,
              );
              expect(directionality.textDirection, TextDirection.ltr);
            },
          );
        }
      }
    }
  });
}
