import 'dart:convert';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';
import 'package:owghat_lib/src/core/format/formatter.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_simple_services.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/core/time/location_offset.dart';
import 'package:owghat_lib/src/core/time/zone_offset_resolver.dart';
import 'package:owghat_lib/src/features/locations/domain/custom_location_input.dart';
import 'package:owghat_lib/src/features/settings/application/location_draft.dart';
import 'package:owghat_lib/src/features/settings/application/number_input.dart';
import 'package:owghat_lib/src/features/settings/application/settings_actions.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/zone_info.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';
import 'package:owghat_lib/src/features/settings/domain/sound_ref.dart';
import 'package:prayer_core/prayer_core.dart';

import '../../support/settings_rig.dart';

void main() {
  final resolver = ZoneOffsetResolver();

  group('ZoneOffsetResolver.nextOffsetChange', () {
    test('finds the next change of a zone that has one', () {
      final next = resolver.nextOffsetChange(
        'Europe/Berlin',
        DateTime.utc(2026, 11, 11, 12),
      )!;
      expect(next.at, DateTime.utc(2027, 3, 28, 1));
      expect(next.before, const Duration(hours: 1));
      expect(next.after, const Duration(hours: 2));
    });

    test('Tehran has no change after 2022 (no daylight saving)', () {
      expect(
        resolver.nextOffsetChange(
          'Asia/Tehran',
          DateTime.utc(2026, 11, 11, 12),
        ),
        isNull,
      );
    });

    test('a zone without changes has none', () {
      expect(
        resolver.nextOffsetChange('Etc/GMT-3', DateTime.utc(2026)),
        isNull,
      );
    });
  });

  group('describeOffset', () {
    final now = DateTime.utc(2026, 11, 11, 12);

    test('automatic Tehran: +03:30, nothing planned', () {
      final info = describeOffset(
        resolver: resolver,
        rule: const LocationOffset.automatic(),
        zoneId: 'Asia/Tehran',
        now: now,
      );
      expect(info.current, const Duration(hours: 3, minutes: 30));
      expect(info.fixed, isFalse);
      expect(info.nextChangeAt, isNull);
    });

    test('automatic Berlin: current and next offset', () {
      final info = describeOffset(
        resolver: resolver,
        rule: const LocationOffset.automatic(),
        zoneId: 'Europe/Berlin',
        now: now,
      );
      expect(info.current, const Duration(hours: 1));
      expect(info.nextOffset, const Duration(hours: 2));
    });

    test('a fixed offset applies as typed and never changes', () {
      final info = describeOffset(
        resolver: resolver,
        rule: const LocationOffset.fixed(-210),
        zoneId: 'Europe/Berlin',
        now: now,
      );
      expect(info.current, const Duration(minutes: -210));
      expect(info.fixed, isTrue);
      expect(info.nextChangeAt, isNull);
    });

    test('an unknown zone does not throw', () {
      final info = describeOffset(
        resolver: resolver,
        rule: const LocationOffset.automatic(),
        zoneId: 'Mars/Olympus',
        now: now,
      );
      expect(info.current, Duration.zero);
    });

    test('formatUtcOffset and roundToQuarterHour', () {
      final fa = Formatter(
        persianDigits: true,
        twelveHour: false,
        l10n: lookupAppLocalizations(const Locale('fa')),
      );
      expect(roundToQuarterHour(212), 210);
      expect(roundToQuarterHour(5000), LocationOffset.maxFixedMinutes);
      expect(roundToQuarterHour(-5000), LocationOffset.minFixedMinutes);
      expect(
        formatUtcOffset(fa, const Duration(hours: 3, minutes: 30)),
        '\u2066UTC+۰۳:۳۰\u2069',
      );
      expect(
        formatUtcOffset(fa, const Duration(minutes: -90)),
        '\u2066UTC−۰۱:۳۰\u2069',
      );
    });
  });

  group('number input', () {
    test('reads Latin, Persian and Arabic digits and separators', () {
      expect(parseNumberInput('17.7'), 17.7);
      expect(parseNumberInput('۱۷٫۷'), 17.7);
      expect(parseNumberInput('١٧,٧'), 17.7);
      expect(parseNumberInput('−۶۰'), -60);
      expect(parseNumberInput(' +3 '), 3);
      expect(parseNumberInput('\u2066۲۰\u2069'), 20);
    });

    test('rejects text that is not a number', () {
      for (final text in ['', 'abc', '1.2.3', '--1', '12x', '.', '+']) {
        expect(parseNumberInput(text), isNull, reason: text);
      }
      expect(parseIntInput('2.5'), isNull);
      expect(parseIntInput('۲'), 2);
    });
  });

  group('custom location drafts', () {
    CustomLocationDraft draft({
      String name = 'Spot',
      CoordinateInput? lat,
      CoordinateInput? lon,
      String elevation = '',
      String zone = 'Asia/Tehran',
      LocationOffset offset = const LocationOffset.automatic(),
    }) => CustomLocationDraft(
      name: name,
      latitude: lat ?? const CoordinateInput.decimal('36.3'),
      longitude: lon ?? const CoordinateInput.decimal('59.6'),
      elevationText: elevation,
      zoneId: zone,
      offset: offset,
    );

    test('a valid draft builds a saved location', () {
      final d = draft(elevation: '985');
      expect(d.validate(resolver), isNull);
      final saved = d.build('custom:1');
      expect(saved.latitude, 36.3);
      expect(saved.elevationMeters, 985);
      expect(saved.zoneId, 'Asia/Tehran');
    });

    test('each field reports its own error', () {
      expect(
        draft(name: '  ').validate(resolver),
        LocationInputError.nameEmpty,
      );
      expect(
        draft(lat: const CoordinateInput.decimal('abc')).validate(resolver),
        LocationInputError.latitudeRange,
      );
      expect(
        draft(lat: const CoordinateInput.decimal('90')).validate(resolver),
        LocationInputError.latitudeRange,
      );
      expect(
        draft(lon: const CoordinateInput.decimal('181')).validate(resolver),
        LocationInputError.longitudeRange,
      );
      expect(
        draft(elevation: '-1').validate(resolver),
        LocationInputError.elevationRange,
      );
      expect(
        draft(zone: 'Mars/Olympus').validate(resolver),
        LocationInputError.unknownZone,
      );
      expect(
        draft(offset: const LocationOffset.fixed(900)).validate(resolver),
        LocationInputError.offsetRange,
      );
    });

    test('degrees, minutes and seconds are converted with Dms', () {
      const lat = CoordinateInput.dms(
        degrees: '35',
        minutes: '41',
        seconds: '21.12',
      );
      expect(lat.parse(), closeTo(35.6892, 1e-6));
      const west = CoordinateInput.dms(
        degrees: '51',
        minutes: '23',
        seconds: '20.4',
        negative: true,
      );
      expect(west.parse(), closeTo(-51.389, 1e-6));
      // Minutes out of range make the coordinate unreadable.
      expect(
        const CoordinateInput.dms(degrees: '35', minutes: '75').parse(),
        isNull,
      );
      expect(const CoordinateInput.dms(degrees: '').parse(), isNull);
      // Empty minutes and seconds count as zero.
      expect(const CoordinateInput.dms(degrees: '12').parse(), 12);
    });

    test('ids are unique and zone filtering ignores case and spaces', () {
      expect(nextCustomLocationId(['city:1']), 'custom:1');
      expect(nextCustomLocationId(['city:1', 'custom:1']), 'custom:2');
      expect(nextCustomLocationId(['custom:7', 'custom:2']), 'custom:8');
      expect(builtinLocationId(12), 'city:12');
      final ids = resolver.zoneIds;
      expect(filterZoneIds(ids, 'new york'), contains('America/New_York'));
      expect(filterZoneIds(ids, 'TEHRAN'), contains('Asia/Tehran'));
      expect(filterZoneIds(ids, ''), hasLength(40));
      expect(filterZoneIds(ids, 'zzzz-none'), isEmpty);
    });
  });

  group('SettingsActions', () {
    late ProviderContainer container;
    late FakeFileDialogs dialogs;
    late FakeBackupFiles files;

    SettingsActions actions() => container.read(settingsActionsProvider);
    AppSettings state() => container.read(settingsProvider);

    setUp(() {
      dialogs = FakeFileDialogs();
      files = FakeBackupFiles();
      container = ProviderContainer(
        overrides: [
          fileDialogsProvider.overrideWithValue(dialogs),
          backupFilesProvider.overrideWithValue(files),
        ],
      );
      addTearDown(container.dispose);
    });

    test('pickSound stores the chosen file for that prayer only', () async {
      dialogs.soundPath = r'C:\sounds\fajr.mp3';
      expect(await actions().pickSound(Prayer.fajr), r'C:\sounds\fajr.mp3');
      expect(
        state().azan.perPrayer[Prayer.fajr]!.sound,
        const SoundRef.file(r'C:\sounds\fajr.mp3'),
      );
      expect(state().azan.perPrayer[Prayer.dhuhr]!.sound, SoundRef.defaultAzan);
      actions().useDefaultSound(Prayer.fajr);
      expect(state().azan.perPrayer[Prayer.fajr]!.sound, SoundRef.defaultAzan);
    });

    test('a cancelled sound dialog changes nothing', () async {
      final before = state();
      expect(await actions().pickSound(Prayer.asr), isNull);
      expect(state(), before);
    });

    test('export writes the settings JSON to the chosen path', () async {
      dialogs.savePath = 'C:/backup.json';
      container.read(settingsProvider.notifier).setDigits(DigitStyle.latin);
      final result = await actions().exportBackup();
      expect(result.outcome, BackupOutcome.exported);
      final written = jsonDecode(files.files['C:/backup.json']!) as Map;
      expect(written['digits'], 'latin');
      expect(written['locations'], isNotEmpty);
    });

    test('export reports a cancelled dialog and a failed write', () async {
      expect((await actions().exportBackup()).outcome, BackupOutcome.cancelled);
      dialogs.savePath = 'C:/backup.json';
      files.failWrite = true;
      expect(
        (await actions().exportBackup()).outcome,
        BackupOutcome.exportFailed,
      );
    });

    test(
      'import parses a valid backup but changes nothing by itself',
      () async {
        final source = const AppSettings.defaults().copyWith(
          language: AppLanguage.en,
          theme: ThemeSetting.dark,
        );
        files.files['C:/in.json'] = jsonEncode(source.toJson());
        dialogs.openPath = 'C:/in.json';
        final before = state();
        final result = await actions().readBackup();
        expect(result.outcome, BackupOutcome.importReady);
        expect(result.settings!.theme, ThemeSetting.dark);
        expect(state(), before);
        actions().applyBackup(result.settings!);
        expect(state().theme, ThemeSetting.dark);
        expect(state().onboardingCompleted, isTrue);
      },
    );

    test('invalid, unreadable and cancelled imports leave the state', () async {
      final before = state();
      dialogs.openPath = 'C:/bad.json';
      files.files['C:/bad.json'] = 'not json';
      expect(
        (await actions().readBackup()).outcome,
        BackupOutcome.importInvalid,
      );
      files.files['C:/bad.json'] = '{"hello": 1}';
      expect(
        (await actions().readBackup()).outcome,
        BackupOutcome.importInvalid,
      );
      files.files['C:/bad.json'] = '[1, 2]';
      expect(
        (await actions().readBackup()).outcome,
        BackupOutcome.importInvalid,
      );
      dialogs.openPath = 'C:/missing.json';
      expect(
        (await actions().readBackup()).outcome,
        BackupOutcome.importReadFailed,
      );
      dialogs.openPath = null;
      expect((await actions().readBackup()).outcome, BackupOutcome.cancelled);
      expect(state(), before);
    });
  });
}
