import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app version shown on the About page and in the diagnostics. The
/// runner overrides it with the packaged version; the default is the
/// version of the library.
final appVersionProvider = Provider<String>((ref) => '1.0.0');
