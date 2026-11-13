import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The version of the app, as in `version:` of `app/pubspec.yaml` (without
/// the build number). A test keeps the two equal, and the release workflow
/// checks that the tag matches the pubspec, so the About page, the
/// diagnostics report and the installer always agree.
const String appVersion = '1.0.1';

/// The app version shown on the About page and in the diagnostics. Tests may
/// override it.
final appVersionProvider = Provider<String>((ref) => appVersion);
