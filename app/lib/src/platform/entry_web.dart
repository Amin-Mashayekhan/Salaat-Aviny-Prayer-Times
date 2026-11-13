import 'package:owghat/src/platform/web/web_platform_services.dart';
import 'package:owghat_lib/owghat_lib.dart';

/// The browser version.
Future<void> runOnPlatform(List<String> args) =>
    bootstrap(args, createWebPlatformServices());
