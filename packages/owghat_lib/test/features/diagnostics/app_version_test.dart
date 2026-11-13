import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/features/diagnostics/application/app_version.dart';

void main() {
  test('the version shown in the app is the version of the app package', () {
    // Run from packages/owghat_lib, like every test of this package.
    final pubspec = File('../../app/pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*(\d+\.\d+\.\d+)',
      multiLine: true,
    ).firstMatch(pubspec);
    expect(match, isNotNull);
    expect(appVersion, match!.group(1));
  });
}
