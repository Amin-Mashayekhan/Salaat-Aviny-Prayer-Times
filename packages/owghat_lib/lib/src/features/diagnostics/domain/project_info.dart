/// Who makes the app, where the code is and how to support it. Shown on the
/// About page. Change a value here and every language follows.
abstract final class ProjectInfo {
  /// The developer's name in Latin letters (shown in languages written with
  /// the Latin alphabet).
  static const String authorNameLatin = 'Mohammad Amin Mashayekhan';

  /// The developer's name in Persian (shown in the languages written with the
  /// Arabic script: Persian, Arabic and Urdu).
  static const String authorNameFa = 'محمد امین مشایخان';

  /// The developer's Telegram user name.
  static const String authorTelegram = '@Amin_NiceDesign';

  /// The developer's GitHub page.
  static const String authorGithub = 'https://github.com/Amin-Mashayekhan';

  /// The developer's e-mail address.
  static const String authorEmail = 'amin.mashayekhan@gmail.com';

  /// The developer's mobile number, with the country code. Calls and text
  /// messages work only from inside Iran; from abroad, Telegram. Empty hides
  /// the row.
  static const String authorPhone = '+9892128870991';

  /// The code repository.
  static const String repository =
      'https://github.com/Amin-Mashayekhan/Salaat-Aviny-Prayer-Times';

  /// Where bugs and ideas are reported.
  static const String issues = '$repository/issues';

  /// How to build, test and send a change.
  static const String contributingGuide =
      '$repository/blob/main/CONTRIBUTING.md';

  /// Iranian bank card for gifts from inside Iran.
  static const String bankCard = '6219861838019973';

  /// The wallet that receives USDT on the BNB Smart Chain (BEP20).
  static const String usdtAddress =
      '0x4319c7ad3dd5099d93f8128b68494486b01bede1';

  /// The link that opens [authorTelegram].
  static Uri get telegramLink =>
      Uri.https('t.me', authorTelegram.replaceFirst('@', ''));

  /// The e-mail link of [authorEmail].
  static Uri get emailLink => Uri(scheme: 'mailto', path: authorEmail);

  /// [bankCard] in groups of four, the way it is printed on the card.
  static String get bankCardGrouped => [
    for (var i = 0; i < bankCard.length; i += 4)
      bankCard.substring(i, i + 4 > bankCard.length ? bankCard.length : i + 4),
  ].join(' ');
}
