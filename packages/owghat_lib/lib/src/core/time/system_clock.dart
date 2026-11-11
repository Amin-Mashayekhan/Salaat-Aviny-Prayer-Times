import 'package:clock/clock.dart';

/// The real clock. The only reader of the system time in the app (besides
/// the quarantine file naming in the JSON store); everything else asks the
/// injected clock so tests control time.
const Clock systemClock = Clock(_systemNow);

DateTime _systemNow() => DateTime.now(); // allow-now
