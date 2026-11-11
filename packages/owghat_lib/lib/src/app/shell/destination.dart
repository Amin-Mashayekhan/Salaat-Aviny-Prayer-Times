import 'package:flutter/material.dart';
import 'package:owghat_lib/l10n/gen/app_localizations.dart';

/// The six top-level screens, in navigation-rail order.
enum Destination {
  /// Today times and the countdown.
  home(Icons.home_outlined, Icons.home),

  /// Month table.
  timetable(Icons.calendar_view_month_outlined, Icons.calendar_view_month),

  /// Calendar and converter.
  calendar(Icons.event_outlined, Icons.event),

  /// Qibla compass.
  qibla(Icons.explore_outlined, Icons.explore),

  /// Wake-up alarms.
  wakeUp(Icons.alarm_outlined, Icons.alarm),

  /// Settings (pinned to the bottom of the rail).
  settings(Icons.settings_outlined, Icons.settings);

  Destination(this.icon, this.selectedIcon);

  /// Icon when not selected.
  final IconData icon;

  /// Icon when selected.
  final IconData selectedIcon;

  /// Localised label.
  String label(AppLocalizations l10n) => switch (this) {
    home => l10n.navHome,
    timetable => l10n.navTimetable,
    calendar => l10n.navCalendar,
    qibla => l10n.navQibla,
    wakeUp => l10n.navWakeUp,
    settings => l10n.navSettings,
  };
}
