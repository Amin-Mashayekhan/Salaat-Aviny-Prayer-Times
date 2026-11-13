import 'package:flutter/widgets.dart';
import 'package:owghat/src/platform/entry.dart';

/// Entry point: build the services of this platform and hand them to the
/// library, which does the whole startup sequence.
Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await runOnPlatform(args);
}
