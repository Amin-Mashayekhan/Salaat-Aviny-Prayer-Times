import 'dart:convert';

import 'package:flutter/foundation.dart';

/// A value type defined by its JSON form.
///
/// Equality and hash code are derived from [toJson], which is fine for the
/// small, plain settings objects that use it and keeps them in sync with
/// what is written to disk.
@immutable
abstract class JsonValue {
  /// Const constructor for subclasses.
  const JsonValue();

  /// The JSON map of this value.
  Map<String, Object?> toJson();

  @override
  bool operator ==(Object other) =>
      other.runtimeType == runtimeType &&
      other is JsonValue &&
      jsonEncode(other.toJson()) == jsonEncode(toJson());

  @override
  int get hashCode => jsonEncode(toJson()).hashCode;

  @override
  String toString() => '$runtimeType(${jsonEncode(toJson())})';
}

/// Lenient readers used when loading settings: a wrong or missing value
/// yields the default instead of an exception.
abstract final class Json {
  /// `raw` as a map, or an empty map.
  static Map<String, Object?> map(Object? raw) =>
      raw is Map ? raw.cast<String, Object?>() : const {};

  /// `raw` as a list, or an empty list.
  static List<Object?> list(Object? raw) => raw is List ? raw : const [];

  /// `raw` as an int, or [fallback].
  static int integer(Object? raw, int fallback) =>
      raw is num ? raw.toInt() : fallback;

  /// `raw` as a double, or [fallback].
  static double number(Object? raw, double fallback) =>
      raw is num ? raw.toDouble() : fallback;

  /// `raw` as a nullable double (null stays null), or [fallback] when the
  /// key holds something that is neither null nor a number.
  static double? numberOrNull(Object? raw, double? fallback) {
    if (raw == null) return null;
    return raw is num ? raw.toDouble() : fallback;
  }

  /// `raw` as a bool, or [fallback].
  static bool boolean(Object? raw, {required bool fallback}) =>
      raw is bool ? raw : fallback;

  /// `raw` as a string, or [fallback].
  static String string(Object? raw, String fallback) =>
      raw is String ? raw : fallback;

  /// The enum value named `raw`, or [fallback].
  static T enumValue<T extends Enum>(List<T> values, Object? raw, T fallback) {
    if (raw is String) {
      for (final value in values) {
        if (value.name == raw) return value;
      }
    }
    return fallback;
  }

  /// Parses an ISO-8601 string into a UTC `DateTime`, or null.
  static DateTime? utcDate(Object? raw) {
    if (raw is! String) return null;
    return DateTime.tryParse(raw)?.toUtc();
  }
}
