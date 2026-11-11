import 'package:meta/meta.dart';

/// How Islamic midnight is defined.
enum MidnightRule {
  /// Midpoint between sunset and the next sunrise.
  standard,

  /// Midpoint between sunset and the next Fajr (Shia convention).
  jafari,
}

/// Shadow factor used for Asr.
enum AsrRule {
  /// Shadow length equals object height plus noon shadow.
  standard(1),

  /// Shadow length equals twice the object height plus noon shadow.
  hanafi(2);

  AsrRule(this.shadowFactor);

  /// Multiplier of the object height.
  final double shadowFactor;
}

/// Rule for places where the twilight angle is never reached or the night is
/// too short for it.
enum HighLatitudeRule {
  /// No adjustment; times may be missing.
  none,

  /// Limit twilight to half of the night.
  nightMiddle,

  /// Limit twilight to one seventh of the night.
  oneSeventh,

  /// Limit twilight to angle/60 of the night.
  angleBased,
}

/// Everything besides place and date that influences the times.
@immutable
class CalculationParams {
  /// Creates parameters.
  const CalculationParams({
    required this.fajrAngle,
    this.ishaAngle,
    this.ishaMinutes,
    this.maghribAngle,
    this.midnight = MidnightRule.standard,
    this.asr = AsrRule.standard,
    this.highLatitude = HighLatitudeRule.nightMiddle,
    this.imsakMinutes = 10,
  }) : assert(
         (ishaAngle == null) != (ishaMinutes == null),
         'Exactly one of ishaAngle and ishaMinutes must be set',
       );

  /// Sun depression below the horizon at Fajr, in degrees.
  final double fajrAngle;

  /// Sun depression at Isha, in degrees; null when [ishaMinutes] is used.
  final double? ishaAngle;

  /// Isha as minutes after Maghrib (Umm al-Qura); null when [ishaAngle] used.
  final double? ishaMinutes;

  /// Sun depression at Maghrib, in degrees; null means Maghrib is sunset.
  final double? maghribAngle;

  /// Definition of Islamic midnight.
  final MidnightRule midnight;

  /// Asr shadow rule.
  final AsrRule asr;

  /// Adjustment for high latitudes.
  final HighLatitudeRule highLatitude;

  /// Imsak is Fajr minus this many minutes.
  final double imsakMinutes;

  /// Copy with changes. Nullable fields are replaced through closures so that
  /// `null` can be set explicitly: `copyWith(maghribAngle: () => null)`.
  CalculationParams copyWith({
    double? fajrAngle,
    double? Function()? ishaAngle,
    double? Function()? ishaMinutes,
    double? Function()? maghribAngle,
    MidnightRule? midnight,
    AsrRule? asr,
    HighLatitudeRule? highLatitude,
    double? imsakMinutes,
  }) {
    return CalculationParams(
      fajrAngle: fajrAngle ?? this.fajrAngle,
      ishaAngle: ishaAngle != null ? ishaAngle() : this.ishaAngle,
      ishaMinutes: ishaMinutes != null ? ishaMinutes() : this.ishaMinutes,
      maghribAngle: maghribAngle != null ? maghribAngle() : this.maghribAngle,
      midnight: midnight ?? this.midnight,
      asr: asr ?? this.asr,
      highLatitude: highLatitude ?? this.highLatitude,
      imsakMinutes: imsakMinutes ?? this.imsakMinutes,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CalculationParams &&
      other.fajrAngle == fajrAngle &&
      other.ishaAngle == ishaAngle &&
      other.ishaMinutes == ishaMinutes &&
      other.maghribAngle == maghribAngle &&
      other.midnight == midnight &&
      other.asr == asr &&
      other.highLatitude == highLatitude &&
      other.imsakMinutes == imsakMinutes;

  @override
  int get hashCode => Object.hash(
    fajrAngle,
    ishaAngle,
    ishaMinutes,
    maghribAngle,
    midnight,
    asr,
    highLatitude,
    imsakMinutes,
  );

  @override
  String toString() =>
      'CalculationParams(fajr $fajrAngle, isha ${ishaAngle ?? ishaMinutes}, '
      'maghrib $maghribAngle, $midnight, $asr, $highLatitude, '
      'imsak $imsakMinutes)';
}
