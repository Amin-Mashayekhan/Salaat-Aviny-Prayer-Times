import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/app/shell/destination_controller.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_audio_output.dart';
import 'package:owghat_lib/src/core/platform/fakes/fake_simple_services.dart';
import 'package:owghat_lib/src/core/platform/platform_providers.dart';
import 'package:owghat_lib/src/core/time/network_time_source.dart';
import 'package:owghat_lib/src/features/clock/application/clock_providers.dart';
import 'package:owghat_lib/src/features/locations/data/location_repository.dart';
import 'package:owghat_lib/src/features/settings/application/settings_actions.dart';
import 'package:owghat_lib/src/features/settings/application/settings_controller.dart';
import 'package:owghat_lib/src/features/settings/application/settings_ui.dart';
import 'package:owghat_lib/src/features/settings/data/backup_files.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

import 'app_harness.dart';

/// Backup files held in memory.
class FakeBackupFiles implements BackupFiles {
  /// Content by path.
  final Map<String, String> files = {};

  /// Makes `write` throw.
  bool failWrite = false;

  /// Makes `read` throw.
  bool failRead = false;

  @override
  Future<String> read(String path) async {
    if (failRead || !files.containsKey(path)) {
      throw StateError('cannot read $path');
    }
    return files[path]!;
  }

  @override
  Future<void> write(String path, String text) async {
    if (failWrite) throw StateError('cannot write $path');
    files[path] = text;
  }
}

/// A network time source with a preset answer.
class FakeNetworkTime implements NetworkTimeSource {
  /// Offset returned by `measureOffset`.
  Duration offset = Duration.zero;

  /// When set, `measureOffset` throws it.
  Exception? error;

  /// Hosts asked, in order.
  final List<String> hosts = [];

  @override
  Future<Duration> measureOffset(String host) async {
    hosts.add(host);
    if (error != null) throw error!;
    return offset;
  }
}

/// The settings screen inside the whole app, with fakes for every platform
/// service it touches.
class SettingsRig {
  SettingsRig._(
    this.harness,
    this.dialogs,
    this.audio,
    this.files,
    this.autostart,
    this.ntp,
  );

  /// 2026-11-11 15:30 in Tehran.
  static final DateTime now = DateTime.utc(2026, 11, 11, 12);

  /// The app harness.
  final AppHarness harness;

  /// File pickers.
  final FakeFileDialogs dialogs;

  /// Audio device.
  final FakeAudioOutput audio;

  /// Backup files.
  final FakeBackupFiles files;

  /// Windows autostart.
  final FakeAutostartService autostart;

  /// Network time.
  final FakeNetworkTime ntp;

  /// The provider container.
  ProviderContainer get container => harness.container;

  /// Current settings.
  AppSettings get settings => container.read(settingsProvider);

  /// Opens the settings screen (optionally a given section).
  static Future<SettingsRig> open(
    WidgetTester tester, {
    required LocationRepository repository,
    AppSettings? settings,
    Size size = const Size(1200, 800),
    double textScale = 1,
    Brightness brightness = Brightness.light,
    SettingsSection? section,
    List<Override> overrides = const [],
  }) async {
    final dialogs = FakeFileDialogs();
    final audio = FakeAudioOutput();
    final files = FakeBackupFiles();
    final autostart = FakeAutostartService();
    final ntp = FakeNetworkTime();
    final harness = await AppHarness.pump(
      tester,
      repository: repository,
      now: now,
      settings: settings ?? englishSettings,
      size: size,
      textScale: textScale,
      brightness: brightness,
      overrides: [
        fileDialogsProvider.overrideWithValue(dialogs),
        audioOutputProvider.overrideWithValue(audio),
        backupFilesProvider.overrideWithValue(files),
        autostartServiceProvider.overrideWithValue(autostart),
        networkTimeSourceProvider.overrideWithValue(ntp),
        systemClockProvider.overrideWithValue(Clock.fixed(now)),
        ...overrides,
      ],
    );
    harness.container
        .read(destinationProvider.notifier)
        .select(Destination.settings);
    if (section != null) {
      harness.container
          .read(selectedSettingsSectionProvider.notifier)
          .select(section);
    }
    await tester.pumpAndSettle();
    return SettingsRig._(harness, dialogs, audio, files, autostart, ntp);
  }

  /// Switches the network time check off again, so the periodic timer of
  /// the clock check does not outlive the test.
  Future<void> stopNetworkTime(WidgetTester tester) async {
    container
        .read(settingsProvider.notifier)
        .setNetworkTime(settings.networkTime.copyWith(enabled: false));
    await tester.pumpAndSettle();
  }

  /// Opens [section] and settles.
  Future<void> show(WidgetTester tester, SettingsSection section) async {
    container.read(selectedSettingsSectionProvider.notifier).select(section);
    await tester.pumpAndSettle();
  }
}

/// Finder of the widget with the string key [key].
Finder k(String key) => find.byKey(Key(key));

/// Scrolls [key] into view and taps it.
Future<void> tapKey(WidgetTester tester, String key) async {
  await tester.ensureVisible(k(key));
  await tester.pumpAndSettle();
  await tester.tap(k(key));
  await tester.pumpAndSettle();
}

/// Scrolls the switch row [key] into view and toggles its switch.
Future<void> tapSwitch(WidgetTester tester, String key) async {
  await tester.ensureVisible(k(key));
  await tester.pumpAndSettle();
  await tester.tap(find.descendant(of: k(key), matching: find.byType(Switch)));
  await tester.pumpAndSettle();
}

/// Whether the switch of the row [key] is on.
bool switchValue(WidgetTester tester, String key) => tester
    .widget<Switch>(find.descendant(of: k(key), matching: find.byType(Switch)))
    .value;

/// The text field behind [key] (the key may sit on the field or on a wrapper).
Finder fieldOf(String key) {
  final inner = find.descendant(of: k(key), matching: find.byType(TextField));
  return inner.evaluate().isNotEmpty ? inner : k(key);
}

/// Types [text] in the field [key] and presses Enter.
Future<void> typeKey(
  WidgetTester tester,
  String key,
  String text, {
  bool submit = true,
}) async {
  await tester.ensureVisible(k(key));
  await tester.pumpAndSettle();
  await tester.enterText(fieldOf(key), text);
  if (submit) {
    await tester.testTextInput.receiveAction(TextInputAction.done);
  }
  await tester.pumpAndSettle();
}

/// Opens the drop-down [key] and chooses its entry number [index].
Future<void> pickOption(
  WidgetTester tester,
  String key,
  String itemKeyPrefix,
  int index,
) async {
  await tapKey(tester, key);
  // The item key sits on the menu entry; a long menu reports a harmless
  // "would not hit test" warning for it, so the result is checked by callers.
  await tester.tap(k('$itemKeyPrefix-$index').last, warnIfMissed: false);
  await tester.pumpAndSettle();
}

/// The text of the [Text] widget with key [key] (or of the first [Text]
/// inside the widget with that key), without direction marks.
String textOf(WidgetTester tester, String key) {
  final widget = tester.widget(k(key));
  final text = widget is Text
      ? widget
      : tester.widget<Text>(
          find.descendant(of: k(key), matching: find.byType(Text)).first,
        );
  return (text.data ?? text.textSpan!.toPlainText()).replaceAll(
    RegExp(r'[\u2066\u2067\u2069]'),
    '',
  );
}

/// Every string a [Text] or a tooltip on screen shows.
List<String> allStrings(WidgetTester tester) => [
  for (final t in tester.widgetList<Text>(find.byType(Text)))
    t.data ?? t.textSpan?.toPlainText() ?? '',
  for (final t in tester.widgetList<Tooltip>(find.byType(Tooltip)))
    t.message ?? '',
];
