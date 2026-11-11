/// Reads a number typed by the user.
///
/// Accepts Latin, Persian and Arabic-Indic digits, `.`, `,` and the Persian
/// decimal separator as the decimal point, and `-` or the real minus sign.
/// Spaces, group separators and Unicode direction marks are ignored. Returns
/// null when the text is not a number.
double? parseNumberInput(String text) {
  final out = StringBuffer();
  for (final rune in text.runes) {
    if (rune >= 0x06f0 && rune <= 0x06f9) {
      out.writeCharCode(0x30 + rune - 0x06f0);
    } else if (rune >= 0x0660 && rune <= 0x0669) {
      out.writeCharCode(0x30 + rune - 0x0660);
    } else if (rune == 0x066b || rune == 0x002c || rune == 0x060c) {
      out.write('.');
    } else if (rune == 0x2212 || rune == 0x2013) {
      out.write('-');
    } else if (rune == 0x066c ||
        rune == 0x200c ||
        rune == 0x00a0 ||
        (rune >= 0x2066 && rune <= 0x2069) ||
        rune == 0x200e ||
        rune == 0x200f ||
        rune == 0x20) {
      continue;
    } else {
      out.writeCharCode(rune);
    }
  }
  final cleaned = out.toString();
  if (!RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)$').hasMatch(cleaned)) return null;
  return double.tryParse(cleaned);
}

/// Like [parseNumberInput] but only accepts whole numbers.
int? parseIntInput(String text) {
  final value = parseNumberInput(text);
  if (value == null || value != value.roundToDouble()) return null;
  return value.toInt();
}
