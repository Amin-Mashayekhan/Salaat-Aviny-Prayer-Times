/// Starts the app with the services of the platform it runs on. The browser
/// build gets its own entry, so it never sees `dart:io` or the Win32 code.
library;

export 'entry_native.dart' if (dart.library.js_interop) 'entry_web.dart';
