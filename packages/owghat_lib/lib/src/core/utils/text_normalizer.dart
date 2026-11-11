/// Normalises Persian, Arabic and Latin text for searching.
///
/// Two strings that a user would consider "the same name" normalise to the
/// same value: Arabic and Persian letter variants are unified, spaces,
/// half-spaces, diacritics and punctuation are removed, digits become Latin
/// and Latin letters become lower case.
abstract final class TextNormalizer {
  static const Map<String, String> _map = {
    'ي': 'ی', // Arabic yeh -> Persian yeh
    'ى': 'ی', // alef maksura -> Persian yeh
    'ك': 'ک', // Arabic kaf -> Persian kaf
    'ة': 'ه', // teh marbuta -> heh
    'أ': 'ا', // alef variants -> alef
    'إ': 'ا',
    'آ': 'ا',
    'ٱ': 'ا',
    'ۀ': 'ه', // heh with yeh above -> heh
    'ە': 'ه',
  };

  /// The normalised form of [input].
  static String normalize(String input) {
    final out = StringBuffer();
    for (final rune in input.runes) {
      final char = String.fromCharCode(rune);
      final mapped = _map[char];
      if (mapped != null) {
        out.write(mapped);
        continue;
      }
      // Persian digits U+06F0..U+06F9 and Arabic-Indic U+0660..U+0669.
      if (rune >= 0x06f0 && rune <= 0x06f9) {
        out.writeCharCode(0x30 + rune - 0x06f0);
        continue;
      }
      if (rune >= 0x0660 && rune <= 0x0669) {
        out.writeCharCode(0x30 + rune - 0x0660);
        continue;
      }
      if (_isIgnorable(rune)) continue;
      out.write(char.toLowerCase());
    }
    return out.toString();
  }

  static bool _isIgnorable(int rune) {
    if (rune == 0x20 || rune == 0xa0 || rune == 0x200c || rune == 0x200d) {
      return true;
    }
    if (rune == 0x200e || rune == 0x200f || rune == 0x0640) return true;
    if (rune >= 0x064b && rune <= 0x065f) return true; // diacritics
    if (rune == 0x0670) return true;
    // ASCII punctuation: - ' ( ) . , _ / \
    return rune < 0x80 &&
        !((rune >= 0x30 && rune <= 0x39) ||
            (rune >= 0x41 && rune <= 0x5a) ||
            (rune >= 0x61 && rune <= 0x7a));
  }
}
