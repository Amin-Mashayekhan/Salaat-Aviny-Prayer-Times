/// Opens a web address or a mail link in the program the person has chosen
/// for it (the browser, the mail program).
///
/// Only `https:` and `mailto:` links are ever opened. The Windows
/// implementation lives in the app package.
abstract interface class LinkOpener {
  /// Opens [uri]. Returns false when it is not an allowed kind of link or
  /// when nothing could open it.
  Future<bool> open(Uri uri);
}

/// Whether [uri] is a kind of link the app is willing to open.
bool isOpenableLink(Uri uri) {
  if (uri.scheme == 'mailto') return uri.path.isNotEmpty;
  return uri.scheme == 'https' && uri.host.isNotEmpty;
}

/// The opener of a platform that cannot open links.
class UnsupportedLinkOpener implements LinkOpener {
  /// Creates it.
  const UnsupportedLinkOpener();

  @override
  Future<bool> open(Uri uri) async => false;
}
