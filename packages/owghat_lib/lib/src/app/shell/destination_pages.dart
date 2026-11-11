import 'package:flutter/material.dart';
import 'package:owghat_lib/src/app/shell/destination.dart';
import 'package:owghat_lib/src/features/calendar/presentation/calendar_page.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/home_page.dart';
import 'package:owghat_lib/src/features/prayer_times/presentation/timetable_page.dart';
import 'package:owghat_lib/src/features/qibla/presentation/qibla_page.dart';
import 'package:owghat_lib/src/features/settings/presentation/settings_page.dart';
import 'package:owghat_lib/src/features/wake_alarm/presentation/wake_page.dart';

/// The page widget of [destination].
///
/// Every destination has its page; the switch is exhaustive, so a new
/// destination fails to compile until its page is registered here.
Widget destinationPage(Destination destination) => switch (destination) {
  Destination.home => const HomePage(key: ValueKey(Destination.home)),
  Destination.timetable => const TimetablePage(
    key: ValueKey(Destination.timetable),
  ),
  Destination.calendar => const CalendarPage(
    key: ValueKey(Destination.calendar),
  ),
  Destination.qibla => const QiblaPage(key: ValueKey(Destination.qibla)),
  Destination.wakeUp => const WakeUpPage(key: ValueKey(Destination.wakeUp)),
  Destination.settings => const SettingsPage(
    key: ValueKey(Destination.settings),
  ),
};
