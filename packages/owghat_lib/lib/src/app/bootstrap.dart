import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:owghat_lib/src/app/app.dart';

/// Starts the application.
Future<void> bootstrap(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: OwghatApp()));
}
