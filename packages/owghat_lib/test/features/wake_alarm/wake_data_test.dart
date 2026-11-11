import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/composite_wake_timer_service.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/powercfg_parser.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/schtasks.dart';
import 'package:owghat_lib/src/features/wake_alarm/data/wake_task_xml.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_capability.dart';
import 'package:owghat_lib/src/features/wake_alarm/domain/wake_services.dart';

/// `powercfg /query SCHEME_CURRENT SUB_SLEEP RTCWAKE` on an English PC.
const _rtcwakeEnglish = '''
Power Scheme GUID: 381b4222-f694-41f0-9685-ff5bb260df2e  (Balanced)
  Subgroup GUID: 238c9fa8-0aad-41ed-83f4-97be242c8f20  (Sleep)
    Power Setting GUID: bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d  (Allow wake timers)
      Possible Setting Index: 000
      Possible Setting Friendly Name: Disable
      Possible Setting Index: 001
      Possible Setting Friendly Name: Enable
      Possible Setting Index: 002
      Possible Setting Friendly Name: Important Wake Timers Only
    Current AC Power Setting Index: 0x00000001
    Current DC Power Setting Index: 0x00000000
''';

/// The same query on a Persian-language Windows (labels differ, numbers not).
const _rtcwakePersian = '''
GUID طرح انرژی: 381b4222-f694-41f0-9685-ff5bb260df2e  (متعادل)
  GUID زیرگروه: 238c9fa8-0aad-41ed-83f4-97be242c8f20  (خواب)
    GUID تنظیم انرژی: bd3b718a-0680-4d9d-8ab2-e1d2b4ac806d  (مجاز کردن زمان‌سنج‌های بیدارسازی)
      فهرست تنظیم ممکن: 000
      فهرست تنظیم ممکن: 001
      فهرست تنظیم ممکن: 002
    فهرست تنظیم جاری انرژی AC: 0x00000002
    فهرست تنظیم جاری انرژی DC: 0x00000001
''';

const _statesClassic = '''
The following sleep states are available on this system:
    Standby (S3)
    Hibernate
    Fast Startup

The following sleep states are not available on this system:
    Standby (S1)
        The system firmware does not support this standby state.

    Standby (S2)
        The system firmware does not support this standby state.

    Standby (S0 Low Power Idle)
        The system firmware does not support this standby state.
''';

const _statesModern = '''
The following sleep states are available on this system:
    Standby (S0 Low Power Idle) Network Connected
    Hibernate
    Fast Startup

The following sleep states are not available on this system:
    Standby (S1)
        The system firmware does not support this standby state.

    Standby (S2)
        The system firmware does not support this standby state.

    Standby (S3)
        This standby state is disabled when S0 low power idle is supported.
''';

void main() {
  group('task XML', () {
    final start = DateTime.utc(2026, 11, 12, 0, 30);
    final xml = buildWakeTaskXml(
      alarmId: 'wake-123',
      startUtc: start,
      executablePath:
          r'C:\Users\Ali Rezaei\AppData\Local\Programs\Owghat\owghat.exe',
      workingDirectory: r'C:\Users\Ali Rezaei\AppData\Local\Programs\Owghat',
    );

    test('contains every required element', () {
      expect(xml, contains('<WakeToRun>true</WakeToRun>'));
      expect(xml, contains('<LogonType>InteractiveToken</LogonType>'));
      expect(xml, contains('<RunLevel>LeastPrivilege</RunLevel>'));
      expect(xml, contains('<StartWhenAvailable>true</StartWhenAvailable>'));
      expect(xml, contains('<ExecutionTimeLimit>PT0S</ExecutionTimeLimit>'));
      expect(xml, contains('<TimeTrigger>'));
      expect(
        xml,
        contains('<StartBoundary>2026-11-12T00:30:00Z</StartBoundary>'),
      );
      expect(xml, contains('<Arguments>--wake wake-123</Arguments>'));
      expect(xml, contains('encoding="UTF-16"'));
    });

    test('never asks for elevation or another account', () {
      expect(xml, isNot(contains('HighestAvailable')));
      expect(xml, isNot(contains('SYSTEM')));
      expect(xml, isNot(contains('<UserId>')));
      expect(xml, isNot(contains('S4U')));
    });

    test('quotes the path, which may contain spaces', () {
      expect(
        xml,
        contains(
          r'<Command>&quot;C:\Users\Ali Rezaei\AppData\Local\Programs\Owghat\owghat.exe&quot;</Command>',
        ),
      );
    });

    test('is well-formed enough: balanced tags', () {
      final opens = RegExp('<([A-Za-z]+)[ >]').allMatches(xml).length;
      final closes = RegExp('</([A-Za-z]+)>').allMatches(xml).length;
      // Task, RegistrationInfo, ... each open has a close; the xml
      // declaration is not matched by the pattern.
      expect(opens, closes);
    });

    test('escapes markup in the path', () {
      final odd = buildWakeTaskXml(
        alarmId: 'a',
        startUtc: start,
        executablePath: r'C:\a&b\<x>.exe',
      );
      expect(odd, contains('a&amp;b'));
      expect(odd, contains('&lt;x&gt;'));
    });

    test('start boundary styles', () {
      expect(formatStartBoundary(start), '2026-11-12T00:30:00Z');
      expect(
        formatStartBoundary(
          start,
          style: StartBoundaryStyle.localWithOffset,
          localOffset: const Duration(minutes: 210),
        ),
        '2026-11-12T04:00:00+03:30',
      );
      expect(
        formatStartBoundary(
          start,
          style: StartBoundaryStyle.localWithOffset,
          localOffset: const Duration(hours: -5),
        ),
        '2026-11-11T19:30:00-05:00',
      );
      expect(
        formatStartBoundary(
          start,
          style: StartBoundaryStyle.localFloating,
          localOffset: const Duration(minutes: 210),
        ),
        '2026-11-12T04:00:00',
      );
      expect(
        () =>
            formatStartBoundary(start, style: StartBoundaryStyle.localFloating),
        throwsArgumentError,
      );
    });

    test('durations', () {
      expect(formatTaskDuration(Duration.zero), 'PT0S');
      expect(formatTaskDuration(const Duration(minutes: 5)), 'PT5M');
      expect(
        formatTaskDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        'PT1H2M3S',
      );
    });

    test('refuses an unsafe alarm id', () {
      for (final bad in ['', 'a b', r'a\b', 'a"b', '../x', '-x', 'a;b']) {
        expect(isSafeWakeId(bad), isFalse, reason: bad);
        expect(
          () => buildWakeTaskXml(
            alarmId: bad,
            startUtc: start,
            executablePath: 'x.exe',
          ),
          throwsArgumentError,
        );
      }
      expect(isSafeWakeId('wake-1700000000000000'), isTrue);
    });

    test('task name', () {
      expect(wakeTaskName('wake-1'), r'Owghat\Wake-wake-1');
      expect(() => wakeTaskName('a b'), throwsArgumentError);
    });

    test('UTF-16LE with BOM', () {
      final bytes = encodeUtf16LeWithBom('A\u0634');
      expect(bytes, [0xFF, 0xFE, 0x41, 0x00, 0x34, 0x06]);
      // The whole document round-trips.
      final text = String.fromCharCodes([
        for (var i = 2; i < bytes.length; i += 2)
          bytes[i] | (bytes[i + 1] << 8),
      ]);
      expect(text, 'A\u0634');
    });
  });

  group('schtasks arguments and parsing', () {
    test('argument lists', () {
      expect(
        schtasksCreateArgs(taskName: r'Owghat\Wake-a', xmlPath: r'C:\t\a.xml'),
        ['/Create', '/TN', r'Owghat\Wake-a', '/XML', r'C:\t\a.xml', '/F'],
      );
      expect(schtasksDeleteArgs(r'Owghat\Wake-a'), [
        '/Delete',
        '/TN',
        r'Owghat\Wake-a',
        '/F',
      ]);
      expect(schtasksQueryAllArgs(), ['/Query', '/FO', 'CSV', '/NH']);
      expect(schtasksQueryOneArgs(r'Owghat\Wake-a'), [
        '/Query',
        '/TN',
        r'Owghat\Wake-a',
        '/FO',
        'LIST',
      ]);
    });

    test('lists only our wake tasks', () {
      const csv = r'''
"\Microsoft\Windows\Defrag\ScheduledDefrag","N/A","Ready"
"\Owghat\Wake-wake-1","11/12/2026 4:00:00 AM","Ready"
"\Owghat\Wake-wake-test-5","11/12/2026 5:00:00 AM","Ready"
"\Owghat\Probe","N/A","Ready"
"\Owghat\Wake-bad id","N/A","Ready"
"\Other\Wake-x","N/A","Ready"
''';
      expect(parseWakeTaskIds(csv), {'wake-1', 'wake-test-5'});
      expect(parseWakeTaskIds(''), isEmpty);
      expect(parseWakeTaskIds('INFO: no tasks'), isEmpty);
    });
  });

  group('powercfg parsing', () {
    test('reads AC and battery from an English PC', () {
      final s = parseWakeTimerSettings(_rtcwakeEnglish);
      expect(s.onAc, WakeTimerPolicy.enabled);
      expect(s.onBattery, WakeTimerPolicy.disabled);
    });

    test('does not depend on the Windows language', () {
      final s = parseWakeTimerSettings(_rtcwakePersian);
      expect(s.onAc, WakeTimerPolicy.importantOnly);
      expect(s.onBattery, WakeTimerPolicy.enabled);
    });

    test('a PC with only an AC value', () {
      final s = parseWakeTimerSettings(
        '    Current AC Power Setting Index: 0x00000001\n',
      );
      expect(s.onAc, WakeTimerPolicy.enabled);
      expect(s.onBattery, WakeTimerPolicy.unknown);
    });

    test('garbage and unknown values', () {
      expect(parseWakeTimerSettings('').onAc, WakeTimerPolicy.unknown);
      expect(
        parseWakeTimerSettings('Access is denied.').onBattery,
        WakeTimerPolicy.unknown,
      );
      final odd = parseWakeTimerSettings('0x00000009\n0x0000000a');
      expect(odd.onAc, WakeTimerPolicy.unknown);
      expect(odd.onBattery, WakeTimerPolicy.unknown);
    });

    test('Modern Standby detection', () {
      expect(parseModernStandby(_statesClassic), isFalse);
      expect(parseModernStandby(_statesModern), isTrue);
      expect(parseModernStandby(''), isNull);
      expect(parseModernStandby('Access is denied.'), isNull);
    });

    test('the only powercfg commands are read-only', () {
      for (final args in [
        powercfgQueryWakeTimersArgs,
        powercfgAvailableStatesArgs,
      ]) {
        final first = args.first.toLowerCase();
        expect(first == '/query' || first == '/a', isTrue);
        for (final a in args) {
          expect(
            [
              '/s',
              '/setacvalueindex',
              '/setdcvalueindex',
              '/change',
              '-set',
            ].any((bad) => a.toLowerCase().startsWith(bad)),
            isFalse,
            reason: a,
          );
        }
      }
    });
  });

  group('CompositeWakeTimerService', () {
    late Directory temp;
    late List<List<String>> commands;
    late _FakeInProcess timer;
    late _FakeAwake awake;
    var failCreate = false;
    var failCreateUtc = false;
    var tasksExist = <String>{};

    Future<CommandResult> runner(String exe, List<String> args) async {
      commands.add([exe, ...args]);
      if (exe == 'powercfg') {
        if (args.first == '/query') {
          return const CommandResult(exitCode: 0, stdout: _rtcwakeEnglish);
        }
        return const CommandResult(exitCode: 0, stdout: _statesClassic);
      }
      switch (args.first) {
        case '/Create':
          final xml = File(args[args.indexOf('/XML') + 1]);
          final bytes = xml.readAsBytesSync();
          expect(bytes.sublist(0, 2), [0xFF, 0xFE]);
          final text = String.fromCharCodes([
            for (var i = 2; i < bytes.length; i += 2)
              bytes[i] | (bytes[i + 1] << 8),
          ]);
          final unitsOk = bytes.length.isEven;
          expect(unitsOk, isTrue);
          if (failCreate) {
            return const CommandResult(
              exitCode: 1,
              stderr: 'Access is denied.',
            );
          }
          if (failCreateUtc && text.contains('Z</StartBoundary>')) {
            return const CommandResult(exitCode: 1, stderr: 'XML error');
          }
          tasksExist.add(args[args.indexOf('/TN') + 1]);
          return const CommandResult(exitCode: 0);
        case '/Delete':
          final name = args[args.indexOf('/TN') + 1];
          return tasksExist.remove(name)
              ? const CommandResult(exitCode: 0)
              : const CommandResult(exitCode: 1, stderr: 'not found');
        case '/Query':
          if (args.contains('/TN')) {
            return tasksExist.contains(args[args.indexOf('/TN') + 1])
                ? const CommandResult(exitCode: 0)
                : const CommandResult(exitCode: 1);
          }
          return CommandResult(
            exitCode: 0,
            stdout: [for (final t in tasksExist) '"\\$t","N/A","Ready"']
                .join('\n'),
          );
      }
      return const CommandResult(exitCode: 2);
    }

    CompositeWakeTimerService make({bool withTasks = true}) =>
        CompositeWakeTimerService(
          run: runner,
          timer: timer,
          awake: awake,
          openPowerOptionsAction: () async => true,
          tasks: withTasks
              ? SchtasksWakeScheduler(
                  run: runner,
                  executablePath: r'C:\app\owghat.exe',
                  tempDirectory: temp.path,
                  localOffsetAt: (_) => const Duration(minutes: 210),
                )
              : null,
        );

    setUp(() {
      temp = Directory.systemTemp.createTempSync('owghat_wake_');
      commands = [];
      timer = _FakeInProcess();
      awake = _FakeAwake();
      failCreate = false;
      failCreateUtc = false;
      tasksExist = {};
    });
    tearDown(() => temp.deleteSync(recursive: true));

    test('probe combines every source and removes its test task', () async {
      final capability = await make().probe();
      expect(capability.taskCreationOk, isTrue);
      expect(capability.inProcessTimerOk, isTrue);
      expect(capability.wakeTimersOnAc, WakeTimerPolicy.enabled);
      expect(capability.wakeTimersOnBattery, WakeTimerPolicy.disabled);
      expect(capability.modernStandby, isFalse);
      expect(capability.issues, [WakeIssue.wakeTimersDisabledOnBattery]);
      expect(tasksExist, isEmpty, reason: 'probe task removed');
      expect(temp.listSync(), isEmpty, reason: 'xml temp file removed');
    });

    test('probe reports a failed task creation with the reason', () async {
      failCreate = true;
      final capability = await make().probe();
      expect(capability.taskCreationOk, isFalse);
      expect(capability.lastError, contains('Access is denied'));
      expect(capability.issues.first, WakeIssue.taskCreationFailed);
      expect(capability.canWake, isTrue, reason: 'the in-process timer works');
    });

    test('probe without an app path cannot create tasks', () async {
      final capability = await make(withTasks: false).probe();
      expect(capability.taskCreationOk, isFalse);
      expect(capability.inProcessTimerOk, isTrue);
    });

    test(
      'only schtasks and read-only powercfg commands are ever run',
      () async {
        final service = make();
        await service.probe();
        await service.scheduleWake(DateTime.utc(2026, 11, 12), 'wake-1');
        await service.cancel('wake-1');
        await service.pendingIds();
        await service.cancelAll();
        for (final c in commands) {
          if (c.first == 'powercfg') {
            expect(c[1].toLowerCase(), anyOf('/query', '/a'));
          } else {
            expect(c.first, 'schtasks');
            expect(c[1], anyOf('/Create', '/Delete', '/Query'));
          }
        }
      },
    );

    test('scheduleWake arms both mechanisms', () async {
      final service = make();
      await service.scheduleWake(DateTime.utc(2026, 11, 12, 0, 30), 'wake-1');
      expect(timer.armed['wake-1'], DateTime.utc(2026, 11, 12, 0, 30));
      expect(tasksExist, {r'Owghat\Wake-wake-1'});
      expect(await service.pendingIds(), {'wake-1'});
    });

    test('a rejected UTC trigger falls back to the local forms', () async {
      failCreateUtc = true;
      final service = make();
      await service.scheduleWake(DateTime.utc(2026, 11, 12, 0, 30), 'wake-1');
      expect(tasksExist, {r'Owghat\Wake-wake-1'});
      final creates = commands.where((c) => c[1] == '/Create').length;
      expect(creates, 2);
    });

    test(
      'works with the timer alone when the task cannot be created',
      () async {
        failCreate = true;
        final service = make();
        await service.scheduleWake(DateTime.utc(2026, 11, 12), 'wake-1');
        expect(timer.armed, contains('wake-1'));
        expect(service.lastError, contains('Access is denied'));
      },
    );

    test('fails only when both mechanisms fail', () async {
      failCreate = true;
      timer.failSchedule = true;
      await expectLater(
        make().scheduleWake(DateTime.utc(2026, 11, 12), 'wake-1'),
        throwsA(isA<WakeServiceException>()),
      );
    });

    test('rejects an unsafe id before touching anything', () async {
      await expectLater(
        make().scheduleWake(DateTime.utc(2026, 11, 12), 'a b'),
        throwsA(isA<WakeServiceException>()),
      );
      expect(commands, isEmpty);
      expect(timer.armed, isEmpty);
    });

    test('cancel removes both; cancelling a missing task is fine', () async {
      final service = make();
      await service.scheduleWake(DateTime.utc(2026, 11, 12), 'wake-1');
      await service.cancel('wake-1');
      expect(timer.armed, isEmpty);
      expect(tasksExist, isEmpty);
      await service.cancel('wake-1'); // already gone: no exception
    });

    test('cancelAll removes every task of ours', () async {
      final service = make();
      await service.scheduleWake(DateTime.utc(2026, 11, 12), 'wake-1');
      await service.scheduleWake(DateTime.utc(2026, 11, 13), 'wake-2');
      tasksExist.add(r'Other\Wake-x');
      await service.cancelAll();
      expect(tasksExist, {r'Other\Wake-x'});
      expect(timer.armed, isEmpty);
    });

    test('keepAwake and releaseAwake drive the hold', () async {
      final service = make();
      await service.keepAwake(const Duration(minutes: 3));
      expect(awake.held, isTrue);
      await service.releaseAwake();
      expect(awake.held, isFalse);
    });
  });
}

class _FakeInProcess implements InProcessWakeTimer {
  final Map<String, DateTime> armed = {};
  bool failSchedule = false;

  @override
  Future<bool> probe() async => true;

  @override
  Future<void> schedule(String id, DateTime utc) async {
    if (failSchedule) throw StateError('no timer');
    armed[id] = utc;
  }

  @override
  Future<void> cancel(String id) async => armed.remove(id);

  @override
  Future<void> cancelAll() async => armed.clear();
}

class _FakeAwake implements AwakeHold {
  bool held = false;

  @override
  void hold() => held = true;

  @override
  void release() => held = false;
}
