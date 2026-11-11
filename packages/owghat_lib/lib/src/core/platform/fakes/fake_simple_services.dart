import 'dart:async';

import 'package:owghat_lib/src/core/platform/autostart_service.dart';
import 'package:owghat_lib/src/core/platform/file_dialogs.dart';
import 'package:owghat_lib/src/core/platform/single_instance.dart';

/// An [AutostartService] that remembers the flag in memory.
class FakeAutostartService implements AutostartService {
  /// Creates the fake, optionally already enabled.
  FakeAutostartService({this.enabled = false});

  /// The remembered flag.
  bool enabled;

  /// Number of `enable` calls.
  int enableCalls = 0;

  /// Number of `disable` calls.
  int disableCalls = 0;

  /// Makes `enable`/`disable` throw.
  bool failing = false;

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<void> enable() async {
    enableCalls++;
    if (failing) throw StateError('registry unavailable');
    enabled = true;
  }

  @override
  Future<void> disable() async {
    disableCalls++;
    if (failing) throw StateError('registry unavailable');
    enabled = false;
  }
}

/// A [FileDialogs] that returns preset answers.
class FakeFileDialogs implements FileDialogs {
  /// Creates the fake.
  FakeFileDialogs({this.soundPath, this.savePath, this.openPath});

  /// Answer of `pickSoundFile`.
  String? soundPath;

  /// Answer of `pickBackupSavePath`.
  String? savePath;

  /// Answer of `pickBackupOpenPath`.
  String? openPath;

  @override
  Future<String?> pickSoundFile() async => soundPath;

  @override
  Future<String?> pickBackupSavePath({required String suggestedName}) async =>
      savePath;

  @override
  Future<String?> pickBackupOpenPath() async => openPath;
}

/// A [SingleInstance] that is always the first copy, and can simulate later
/// launches.
class FakeSingleInstance implements SingleInstance {
  /// Creates the fake; [primary] false simulates "another copy is running".
  FakeSingleInstance({this.primary = true});

  /// Whether this process is the first copy.
  final bool primary;

  final StreamController<List<String>> _forwarded =
      StreamController<List<String>>.broadcast();

  @override
  Stream<List<String>> get forwardedArgs => _forwarded.stream;

  @override
  Future<bool> ensure(List<String> args) async => primary;

  /// Simulates a second launch with [args].
  void secondLaunch(List<String> args) => _forwarded.add(args);

  /// Closes the stream.
  Future<void> dispose() => _forwarded.close();
}
