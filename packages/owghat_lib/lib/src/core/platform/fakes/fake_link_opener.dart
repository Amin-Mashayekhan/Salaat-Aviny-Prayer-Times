import 'package:owghat_lib/src/core/platform/link_opener.dart';

/// A [LinkOpener] for tests: remembers what it was asked to open.
class FakeLinkOpener implements LinkOpener {
  /// The addresses it was asked to open, in order.
  final List<Uri> opened = [];

  /// What `open` answers.
  bool result = true;

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return result;
  }
}
