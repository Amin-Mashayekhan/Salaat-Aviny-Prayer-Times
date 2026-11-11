import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the settings file was unreadable at start and replaced by the
/// defaults. The home screen then shows a dismissible notice.
///
/// Defaults to false; the start-up code overrides it when it had to reset.
final settingsWasResetProvider = Provider<bool>((ref) => false);
