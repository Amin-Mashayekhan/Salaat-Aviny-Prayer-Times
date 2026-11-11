import 'package:ntp_dart/ntp_dart.dart';

/// Measures how far the PC clock is from network time.
abstract interface class NetworkTimeSource {
  /// Server time minus local time, measured against [host].
  ///
  /// Throws if the server cannot be reached.
  Future<Duration> measureOffset(String host);
}

/// [NetworkTimeSource] over SNTP using `ntp_dart` (three samples, the one
/// with the lowest round trip wins).
class NtpNetworkTimeSource implements NetworkTimeSource {
  /// Creates the source.
  const NtpNetworkTimeSource();

  @override
  Future<Duration> measureOffset(String host) async {
    final response = await NtpClient(server: host).query(samples: 3);
    return response.offset;
  }
}
