import 'package:prayer_core/src/calculation/calculation_params.dart';

/// Built-in calculation methods plus [custom].
enum CalculationMethod {
  /// Institute of Geophysics, University of Tehran.
  tehran(
    'tehran',
    CalculationParams(
      fajrAngle: 17.7,
      ishaAngle: 14,
      maghribAngle: 4.5,
      midnight: MidnightRule.jafari,
    ),
  ),

  /// Shia Ithna-Ashari, Leva Institute, Qom.
  jafari(
    'jafari',
    CalculationParams(
      fajrAngle: 16,
      ishaAngle: 14,
      maghribAngle: 4,
      midnight: MidnightRule.jafari,
    ),
  ),

  /// Muslim World League.
  mwl('mwl', CalculationParams(fajrAngle: 18, ishaAngle: 17)),

  /// Islamic Society of North America.
  isna('isna', CalculationParams(fajrAngle: 15, ishaAngle: 15)),

  /// Egyptian General Authority of Survey.
  egypt('egypt', CalculationParams(fajrAngle: 19.5, ishaAngle: 17.5)),

  /// Umm al-Qura University, Makkah.
  makkah('makkah', CalculationParams(fajrAngle: 18.5, ishaMinutes: 90)),

  /// University of Islamic Sciences, Karachi.
  karachi('karachi', CalculationParams(fajrAngle: 18, ishaAngle: 18)),

  /// User-defined parameters; [params] is only a starting point.
  custom(
    'custom',
    CalculationParams(
      fajrAngle: 17.7,
      ishaAngle: 14,
      maghribAngle: 4.5,
      midnight: MidnightRule.jafari,
    ),
  );

  CalculationMethod(this.id, this.params);

  /// Stable identifier used in settings files.
  final String id;

  /// Parameters of the method (the starting point for [custom]).
  final CalculationParams params;

  /// Finds a method by [id]; returns null if unknown.
  static CalculationMethod? fromId(String id) {
    for (final method in values) {
      if (method.id == id) return method;
    }
    return null;
  }

  /// The built-in method whose parameters equal [params], or [custom].
  static CalculationMethod matching(CalculationParams params) {
    for (final method in values) {
      if (method != custom && method.params == params) return method;
    }
    return custom;
  }
}
