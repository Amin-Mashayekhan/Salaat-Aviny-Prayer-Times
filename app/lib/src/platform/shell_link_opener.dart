import 'dart:io';

import 'package:owghat_lib/owghat_lib.dart';

/// [LinkOpener] for Windows: hands the address to the shell, which opens it
/// in the default browser or mail program (the same thing a double click on
/// a link does).
///
/// The address is passed as one argument, never through a command line
/// string, and only `https:` and `mailto:` links are accepted.
class ShellLinkOpener implements LinkOpener {
  /// Creates the opener.
  const ShellLinkOpener();

  @override
  Future<bool> open(Uri uri) async {
    if (!isOpenableLink(uri)) return false;
    try {
      await Process.start('rundll32.exe', [
        'url.dll,FileProtocolHandler',
        uri.toString(),
      ], mode: ProcessStartMode.detached);
      return true;
    } on Object {
      return false;
    }
  }
}
