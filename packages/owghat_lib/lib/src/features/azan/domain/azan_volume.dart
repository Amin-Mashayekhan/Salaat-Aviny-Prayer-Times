import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// Length of the optional fade-in at the start of an azan.
const Duration azanFadeInDuration = Duration(seconds: 2);

/// The volume an azan plays at: the master volume times the volume of the
/// prayer, both 0 to 1, so the result is also 0 to 1.
double effectiveAzanVolume({
  required double master,
  required double perPrayer,
}) => (master.clamp(0, 1) * perPrayer.clamp(0, 1)).toDouble();

/// The fade-in to use for [settings]: two seconds, or none.
Duration fadeInFor(AzanSettings settings) =>
    settings.fadeIn ? azanFadeInDuration : Duration.zero;
