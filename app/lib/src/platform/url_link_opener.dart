import 'package:owghat_lib/owghat_lib.dart';
import 'package:url_launcher/url_launcher.dart';

/// [LinkOpener] with `url_launcher`: the browser, mail or Telegram app of the
/// phone (or of any platform other than Windows). Only `https:` and `mailto:`
/// links are opened.
class UrlLinkOpener implements LinkOpener {
  /// Creates the opener.
  const UrlLinkOpener();

  @override
  Future<bool> open(Uri uri) async {
    if (!isOpenableLink(uri)) return false;
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
