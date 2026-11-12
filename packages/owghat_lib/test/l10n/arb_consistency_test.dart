import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:owghat_lib/src/features/settings/domain/app_settings.dart';

/// Every translation must have the same messages as the template and use the
/// same placeholders and the same select options, otherwise a language shows
/// holes or crashes at run time.
Map<String, Object?> _load(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync())
        as Map<String, Object?>;

Iterable<String> _messageKeys(Map<String, Object?> arb) =>
    arb.keys.where((k) => !k.startsWith('@'));

List<String> _placeholders(String text) =>
    RegExp(r'(?<!\w)\{(\w+)(?:,|\})')
        .allMatches(text)
        .map((m) => m[1]!)
        .toList()
      ..sort();

List<String> _selectOptions(String text) =>
    RegExp(r'(\w+)\{').allMatches(text).map((m) => m[1]!).toList()..sort();

bool _balanced(String text) {
  var depth = 0;
  for (final unit in text.codeUnits) {
    if (unit == 0x7B) depth++;
    if (unit == 0x7D) depth--;
    if (depth < 0) return false;
  }
  return depth == 0;
}

void main() {
  final template = _load('app_fa.arb');
  final english = _load('app_en.arb');
  final templateKeys = _messageKeys(template).toSet();

  test('Persian and English have the same messages', () {
    expect(_messageKeys(english).toSet(), templateKeys);
  });

  test('every AppLanguage has an ARB file and every ARB file a language', () {
    final files = Directory('lib/l10n')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last)
        .where((n) => RegExp(r'^app_\w+\.arb$').hasMatch(n))
        .map((n) => n.substring(4, n.length - 4))
        .toSet();
    expect(files, {for (final l in AppLanguage.values) l.name});
  });

  for (final language in AppLanguage.values) {
    final code = language.name;
    group('app_$code.arb', () {
      final arb = _load('app_$code.arb');

      test('declares its own locale', () {
        expect(arb['@@locale'], code);
      });

      test('has exactly the messages of the template', () {
        expect(_messageKeys(arb).toSet(), templateKeys);
      });

      test('keeps the placeholders, select options and braces', () {
        final problems = <String>[];
        for (final key in templateKeys) {
          final source = english[key]! as String;
          final value = arb[key];
          if (value is! String || value.trim().isEmpty) {
            problems.add('$key is empty');
            continue;
          }
          if (_placeholders(source).join() != _placeholders(value).join()) {
            problems.add('$key placeholders differ');
          }
          if (_selectOptions(source).join(',') !=
              _selectOptions(value).join(',')) {
            problems.add('$key select options differ');
          }
          if (!_balanced(value)) problems.add('$key has unbalanced braces');
          if ('\n'.allMatches(source).length != '\n'.allMatches(value).length) {
            problems.add('$key line breaks differ');
          }
        }
        expect(problems, isEmpty);
      });

      test('the texts of the two payment ways name their countries', () {
        // The wording differs by language; what must hold is that both texts
        // exist and are not copies of the English text (except English).
        final card = arb['supportCardCountries']! as String;
        final crypto = arb['supportCryptoCountries']! as String;
        expect(card, isNot(crypto));
        if (code != 'en') {
          expect(card, isNot(english['supportCardCountries']));
          expect(crypto, isNot(english['supportCryptoCountries']));
        }
      });
    });
  }

  test('English and Persian texts are really different languages', () {
    expect(english['aboutTitle'], isNot(template['aboutTitle']));
  });
}
