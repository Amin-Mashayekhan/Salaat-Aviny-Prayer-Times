/// Ids of the tray menu rows; the controller maps them back to actions.
abstract final class TrayIds {
  /// The "next prayer" caption.
  static const String next = 'next';

  /// Prefix of a today's-times caption row (followed by the prayer name).
  static const String timeRowPrefix = 'time:';

  /// Stop the azan.
  static const String stop = 'stop';

  /// The mute submenu itself.
  static const String mute = 'mute';

  /// Mute until the next azan.
  static const String muteUntilNext = 'mute:next';

  /// Mute for one hour.
  static const String muteOneHour = 'mute:1h';

  /// Mute for 24 hours.
  static const String muteOneDay = 'mute:24h';

  /// Mute until switched off.
  static const String muteIndefinite = 'mute:forever';

  /// Turn the mute off.
  static const String muteCancel = 'mute:cancel';

  /// The location submenu itself.
  static const String location = 'location';

  /// Prefix of a location row (followed by the saved-location id).
  static const String locationPrefix = 'loc:';

  /// Show the window.
  static const String show = 'show';

  /// Open the settings.
  static const String settings = 'settings';

  /// Quit the app.
  static const String quit = 'quit';
}
