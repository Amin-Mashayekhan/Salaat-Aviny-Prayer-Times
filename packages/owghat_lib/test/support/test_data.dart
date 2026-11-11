import 'dart:io';

import 'package:owghat_lib/src/features/locations/data/location_repository.dart';

/// Loads the real bundled city database from disk (tests run with the
/// package folder as working directory).
Future<LocationRepository> loadTestRepository() async {
  return await LocationRepository.load((path) async {
    final relative = path.replaceFirst('packages/owghat_lib/', '');
    return await File(relative).readAsString();
  });
}
