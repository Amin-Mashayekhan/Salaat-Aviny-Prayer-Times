// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutFontNote =>
      'The Vazirmatn font is bundled under the SIL Open Font License 1.1.';

  @override
  String get aboutLicences => 'Open-source licences';

  @override
  String get aboutSoundNote =>
      'The bundled sounds (the default azan and the reminder chime) are simple generated placeholders, not recordings of anyone, released under CC0. Choose your own azan sound in Settings.';

  @override
  String get aboutTagline =>
      'Prayer times and azan for Windows. Works offline, with no ads, no account and no tracking.';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get appName => 'Salaat | Avini Prayer Times';

  @override
  String get calendarAdjustEarlier => 'One day earlier';

  @override
  String get calendarAdjustLater => 'One day later';

  @override
  String calendarAdjustValue(String value) {
    return '$value days';
  }

  @override
  String calendarConvErrDay(String first, String days) {
    return 'The day must be from $first to $days.';
  }

  @override
  String get calendarConvErrIncomplete => 'Fill in the year, month and day.';

  @override
  String get calendarConvErrMonth => 'The month must be from 1 to 12.';

  @override
  String get calendarConvErrNumber => 'Use digits only.';

  @override
  String get calendarConvErrRange =>
      'This date is outside the range the calendar supports.';

  @override
  String get calendarConverterHint =>
      'Type a date in any of the three calendars; the other two change with it.';

  @override
  String get calendarConverterShow => 'Show in calendar';

  @override
  String get calendarConverterTitle => 'Date converter';

  @override
  String calendarDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get calendarFieldDay => 'Day';

  @override
  String get calendarFieldMonth => 'Month';

  @override
  String get calendarFieldYear => 'Year';

  @override
  String get calendarGridLabel => 'Month calendar';

  @override
  String get calendarHijriAdjust => 'Lunar date adjustment';

  @override
  String get calendarHijriApproxHint =>
      'Approximate: Iran\'s official lunar calendar follows moon sighting and may differ by a day.';

  @override
  String get calendarHijriUnavailable =>
      'No lunar date in the table for this day';

  @override
  String get calendarKindGregorian => 'Gregorian';

  @override
  String get calendarKindHijri => 'Lunar Hijri';

  @override
  String get calendarKindJalali => 'Solar Hijri';

  @override
  String calendarMonthGregorian(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'January',
      'm2': 'February',
      'm3': 'March',
      'm4': 'April',
      'm5': 'May',
      'm6': 'June',
      'm7': 'July',
      'm8': 'August',
      'm9': 'September',
      'm10': 'October',
      'm11': 'November',
      'm12': 'December',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthHijri(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muharram',
      'm2': 'Safar',
      'm3': 'Rabi al-Awwal',
      'm4': 'Rabi al-Thani',
      'm5': 'Jumada al-Awwal',
      'm6': 'Jumada al-Thani',
      'm7': 'Rajab',
      'm8': 'Shaban',
      'm9': 'Ramadan',
      'm10': 'Shawwal',
      'm11': 'Dhu al-Qadah',
      'm12': 'Dhu al-Hijjah',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthJalali(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Farvardin',
      'm2': 'Ordibehesht',
      'm3': 'Khordad',
      'm4': 'Tir',
      'm5': 'Mordad',
      'm6': 'Shahrivar',
      'm7': 'Mehr',
      'm8': 'Aban',
      'm9': 'Azar',
      'm10': 'Dey',
      'm11': 'Bahman',
      'm12': 'Esfand',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthYear(String month, String year) {
    return '$month $year';
  }

  @override
  String get calendarMoonNote =>
      'The lunar date comes from the Umm al-Qura table. Iran\'s official calendar follows moon sighting and can differ by a day; if so, shift it here.';

  @override
  String get calendarNextMonth => 'Next month';

  @override
  String get calendarOpenOnHome => 'Show on the home screen';

  @override
  String get calendarPanelTimes => 'Prayer times for this day';

  @override
  String get calendarPreviousMonth => 'Previous month';

  @override
  String get calendarSeparator => ', ';

  @override
  String get calendarToday => 'Today';

  @override
  String calendarWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'Monday',
      'd2': 'Tuesday',
      'd3': 'Wednesday',
      'd4': 'Thursday',
      'd5': 'Friday',
      'd6': 'Saturday',
      'd7': 'Sunday',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'Mon',
      'd2': 'Tue',
      'd3': 'Wed',
      'd4': 'Thu',
      'd5': 'Fri',
      'd6': 'Sat',
      'd7': 'Sun',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get diagAudioFailed =>
      'The test sound could not be played. Check the speakers and the Windows volume.';

  @override
  String get diagAudioOk => 'The test sound played.';

  @override
  String get diagAudioPlay => 'Play a test sound';

  @override
  String get diagAudioStop => 'Stop';

  @override
  String get diagAudioTitle => 'Audio test';

  @override
  String get diagClockOk => 'No clock problem found.';

  @override
  String get diagClockTitle => 'Clock';

  @override
  String get diagClockUnchecked =>
      'No problem seen, but the network time check is off, so clock skew is not measured.';

  @override
  String get diagCopied =>
      'Copied to the clipboard. It has no names and no exact coordinates.';

  @override
  String get diagCopy => 'Copy diagnostics';

  @override
  String get diagCopyFailed => 'Could not copy.';

  @override
  String diagEventAzan(String prayer) {
    return 'Azan: $prayer';
  }

  @override
  String diagEventReminder(String prayer) {
    return 'Reminder: $prayer';
  }

  @override
  String diagEventTimes(String utc, String local) {
    return 'UTC $utc | local $local';
  }

  @override
  String get diagEventWake => 'Wake-up alarm';

  @override
  String get diagEventsEmpty => 'Nothing is scheduled.';

  @override
  String get diagEventsTitle => 'Next scheduled events';

  @override
  String get diagLogNone => 'Not available.';

  @override
  String get diagLogTitle => 'Log files';

  @override
  String get diagTitle => 'Diagnostics';

  @override
  String diagValue(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'yes': 'yes',
      'no': 'no',
      'unknown': 'unknown',
      'enabled': 'allowed',
      'disabled': 'off',
      'importantOnly': 'important only',
      'ok': 'works',
      'failed': 'failed',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String diagWakeAc(String value) {
    return 'Wake timers, plugged in: $value';
  }

  @override
  String diagWakeBattery(String value) {
    return 'Wake timers, on battery: $value';
  }

  @override
  String get diagWakeCheck => 'Check now';

  @override
  String diagWakeInProcess(String value) {
    return 'Timer inside the app: $value';
  }

  @override
  String diagWakeModern(String value) {
    return 'Modern Standby: $value';
  }

  @override
  String get diagWakeNotChecked => 'Not checked yet.';

  @override
  String diagWakeTask(String value) {
    return 'Scheduled task: $value';
  }

  @override
  String get diagWakeTitle => 'Wake-up check';

  @override
  String get formatAm => 'AM';

  @override
  String formatHours(String hours) {
    return '$hours h';
  }

  @override
  String formatHoursMinutes(String hours, String minutes) {
    return '$hours h $minutes min';
  }

  @override
  String formatMinutes(String minutes) {
    return '$minutes min';
  }

  @override
  String get formatPm => 'PM';

  @override
  String formatRemaining(String duration) {
    return 'in $duration';
  }

  @override
  String formatRemainingLessThan(String minutes) {
    return 'in less than $minutes min';
  }

  @override
  String formatSeconds(String seconds) {
    return '$seconds s';
  }

  @override
  String get homeAzanMutedIndefinite => 'Azan: muted until you turn it back on';

  @override
  String homeAzanMutedUntil(String time) {
    return 'Azan: muted until $time';
  }

  @override
  String get homeAzanOff => 'Azan: off';

  @override
  String get homeAzanOn => 'Azan: on';

  @override
  String homeAzanToggleOff(String prayer) {
    return 'Turn off the azan for $prayer';
  }

  @override
  String homeAzanToggleOn(String prayer) {
    return 'Turn on the azan for $prayer';
  }

  @override
  String get homeBackToToday => 'Back to today';

  @override
  String homeBannerClockSkew(String amount) {
    return 'The PC clock is off by about $amount.';
  }

  @override
  String get homeBannerDismiss => 'Dismiss';

  @override
  String get homeBannerMutedIndefinite =>
      'The azan is muted until you turn it back on.';

  @override
  String homeBannerMutedUntil(String time) {
    return 'The azan is muted until $time.';
  }

  @override
  String get homeBannerSettingsReset =>
      'The settings file could not be read and the settings were reset to the defaults.';

  @override
  String get homeBannerStaleZone =>
      'Windows shows a different time for this place than the time-zone database. The times in this app are correct; check the Windows clock.';

  @override
  String homeCompass(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'p0': 'north',
      'p1': 'north-east',
      'p2': 'east',
      'p3': 'south-east',
      'p4': 'south',
      'p5': 'south-west',
      'p6': 'west',
      'p7': 'north-west',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String homeCountdownSemantics(String event, String duration) {
    return '$event $duration';
  }

  @override
  String homeDayTimes(String date) {
    return 'Times for $date';
  }

  @override
  String homeEventAt(String event, String time) {
    return '$event $time';
  }

  @override
  String get homeHeroNoNext => 'Nothing to count down to';

  @override
  String get homeMute => 'Mute';

  @override
  String get homeMuteCancel => 'Cancel mute';

  @override
  String homeMuteForDuration(String duration) {
    return 'For $duration';
  }

  @override
  String get homeMuteIndefinite => 'Until I turn it back on';

  @override
  String get homeMuteUntilNext => 'Until the next azan';

  @override
  String get homeNextDay => 'Next day';

  @override
  String get homeNextMarker => 'Next';

  @override
  String homeNextWakeAlarm(String value) {
    return 'Next wake-up: $value';
  }

  @override
  String get homeNoTimesAction => 'Calculation settings';

  @override
  String get homeNoTimesInfo =>
      'Not every time can be calculated for this place on this day. You can change the high-latitude rule in the settings.';

  @override
  String get homeNoValue => '—';

  @override
  String homeNowPlaying(String prayer) {
    return 'Playing: $prayer';
  }

  @override
  String get homeNowPlayingGeneric => 'Playing the azan';

  @override
  String get homeOtherDayHint =>
      'Times of this day; the countdown is only for today.';

  @override
  String get homePreviousDay => 'Previous day';

  @override
  String homeQiblaSummary(String degrees, String direction) {
    return 'Qibla: $degrees° $direction';
  }

  @override
  String homeReminderMinutes(String minutes) {
    return 'Reminder: $minutes min before';
  }

  @override
  String get homeReminderOff => 'Reminders: off';

  @override
  String homeReminderRange(String min, String max) {
    return 'Reminders: $min to $max min before';
  }

  @override
  String get homeStatusTitle => 'Status';

  @override
  String get homeStop => 'Stop';

  @override
  String get homeSwitchLocation => 'Change location';

  @override
  String get homeTimelineLabel => 'Day timeline';

  @override
  String get homeToday => 'Today';

  @override
  String get homeTodayTimes => 'Today\'s times';

  @override
  String get homeTomorrowTimes => 'Tomorrow\'s times';

  @override
  String homeUntilEvent(String event) {
    return 'Until $event';
  }

  @override
  String homeViewingDay(String date) {
    return 'Viewing $date';
  }

  @override
  String get navCalendar => 'Calendar';

  @override
  String get navHome => 'Home';

  @override
  String get navQibla => 'Qibla';

  @override
  String get navSettings => 'Settings';

  @override
  String get navTimetable => 'Timetable';

  @override
  String get navWakeUp => 'Wake-up';

  @override
  String notifAzanBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String get notifAzanFailed => 'The azan could not be played.';

  @override
  String notifAzanTitle(String prayer) {
    return '$prayer azan';
  }

  @override
  String notifMissedBody(String time) {
    return 'The computer was asleep at $time.';
  }

  @override
  String notifMissedTitle(String prayer) {
    return '$prayer azan was not played';
  }

  @override
  String notifReminderBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String notifReminderTitle(String minutes, String prayer) {
    return '$minutes min to $prayer';
  }

  @override
  String get notifSoundFallback =>
      'The azan sound file was not found; the default sound was played.';

  @override
  String get notifStopAction => 'Stop';

  @override
  String get notifTrayHint =>
      'The app keeps running next to the Windows clock.';

  @override
  String get onboardingAzanBody =>
      'Listen to the azan and choose whether the app starts with Windows.';

  @override
  String get onboardingAzanTitle => 'Azan and start-up';

  @override
  String get onboardingBack => 'Back';

  @override
  String get onboardingCityBody =>
      'Search for your city or pick it from a province.';

  @override
  String get onboardingCityNone => 'No city found.';

  @override
  String get onboardingCitySearchHint => 'Search for a city';

  @override
  String onboardingCitySelected(String city) {
    return 'Selected: $city';
  }

  @override
  String get onboardingCityTitle => 'Your city';

  @override
  String get onboardingFinish => 'Start';

  @override
  String get onboardingLanguageBody =>
      'Choose your language. You can change it later in the settings.';

  @override
  String get onboardingLanguageEn => 'English';

  @override
  String get onboardingLanguageFa => 'فارسی';

  @override
  String get onboardingLanguageTitle => 'Language';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingPreview => 'Play a sample azan';

  @override
  String get onboardingProvinceAll => 'All provinces';

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingStartWithWindows => 'Start with Windows';

  @override
  String get onboardingStartWithWindowsHint =>
      'The app starts quietly in the system tray.';

  @override
  String onboardingStepProgress(String step, String total) {
    return 'Step $step of $total';
  }

  @override
  String get onboardingStopPreview => 'Stop';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerDhuhr => 'Dhuhr';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerImsak => 'Imsak';

  @override
  String get prayerIsha => 'Isha';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerMidnight => 'Midnight';

  @override
  String get prayerSunrise => 'Sunrise';

  @override
  String get prayerSunset => 'Sunset';

  @override
  String get qiblaBearingLabel => 'Bearing (clockwise from true north)';

  @override
  String qiblaBearingValue(String degrees, String direction) {
    return '$degrees° ($direction)';
  }

  @override
  String qiblaCardinal(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'n': 'N',
      'e': 'E',
      's': 'S',
      'w': 'W',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String qiblaCompassSemantics(String degrees, String direction) {
    return 'Compass rose: the qibla is at $degrees degrees ($direction)';
  }

  @override
  String qiblaCompassSemanticsSun(String base, String azimuth) {
    return '$base; the sun is at $azimuth degrees';
  }

  @override
  String get qiblaDistanceLabel => 'Distance to the Kaaba';

  @override
  String qiblaDistanceValue(String km) {
    return '$km km';
  }

  @override
  String qiblaForLocation(String place) {
    return 'Qibla direction for $place';
  }

  @override
  String get qiblaNoCompassNote =>
      'A PC has no compass, so the drawing is relative to true north (north is at the top).';

  @override
  String get qiblaSunBelow => 'The sun is below the horizon.';

  @override
  String get qiblaSunInHelp =>
      'At this moment the sun is exactly in the qibla direction; face the sun.';

  @override
  String get qiblaSunInTitle => 'Sun in the qibla direction';

  @override
  String get qiblaSunNone => 'Does not happen today.';

  @override
  String get qiblaSunNowLabel => 'Sun now';

  @override
  String qiblaSunNowValue(String azimuth, String altitude) {
    return 'Azimuth $azimuth°, altitude $altitude°';
  }

  @override
  String get qiblaSunOppHelp =>
      'At this moment the shadow of an upright rod points toward the qibla.';

  @override
  String get qiblaSunOppTitle => 'Sun opposite the qibla';

  @override
  String get qiblaSunTimesTitle => 'The sun and the qibla today';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String get settingsAboutPlaceholder =>
      'Version, licences and the diagnostics page appear in this section.';

  @override
  String get settingsAppAutostart => 'Start with Windows';

  @override
  String get settingsAppAutostartHelp =>
      'The app starts quietly next to the clock when you sign in to Windows.';

  @override
  String get settingsAppCloseToTray => 'Close to the tray';

  @override
  String get settingsAppCloseToTrayHelp =>
      'Closing the window keeps the app next to the Windows clock so the azan still plays. When off, closing quits the app.';

  @override
  String get settingsAppMinimized => 'Start minimised';

  @override
  String get settingsAppMinimizedHelp =>
      'The window stays closed when Windows starts the app.';

  @override
  String get settingsAsrHanafi => 'Hanafi (shadow twice the object)';

  @override
  String get settingsAsrStandard => 'Standard (shadow equals the object)';

  @override
  String get settingsAzanChoose => 'Choose a file…';

  @override
  String get settingsAzanEnabled => 'Play the azan';

  @override
  String get settingsAzanEnabledHelp =>
      'The master switch; when it is off no azan plays.';

  @override
  String get settingsAzanFade => 'Fade in';

  @override
  String get settingsAzanFadeHelp => 'The azan rises gently to full volume.';

  @override
  String get settingsAzanMute => 'Quick mute';

  @override
  String get settingsAzanMuteHelp => 'Silence the azan for a while.';

  @override
  String get settingsAzanNotMuted => 'Not muted';

  @override
  String settingsAzanPrayerSwitch(String prayer) {
    return '$prayer azan';
  }

  @override
  String get settingsAzanPrayerVolume => 'Volume of this azan';

  @override
  String get settingsAzanPreview => 'Preview';

  @override
  String get settingsAzanSound => 'Sound';

  @override
  String get settingsAzanSoundDefault => 'Bundled azan';

  @override
  String settingsAzanSoundFile(String name) {
    return 'File: $name';
  }

  @override
  String get settingsAzanUseDefault => 'Use the bundled sound';

  @override
  String get settingsAzanVolume => 'Volume';

  @override
  String get settingsAzanVolumeHelp => 'The overall volume of every azan';

  @override
  String get settingsBackupExport => 'Export backup';

  @override
  String get settingsBackupExportFailed => 'The backup could not be saved.';

  @override
  String get settingsBackupExportHelp =>
      'All settings, locations and wake-up alarms are saved in one file.';

  @override
  String settingsBackupExported(String path) {
    return 'Backup saved: $path';
  }

  @override
  String get settingsBackupImport => 'Import backup';

  @override
  String get settingsBackupImportBody =>
      'All current settings are replaced by the content of this file.';

  @override
  String get settingsBackupImportConfirm => 'Restore';

  @override
  String get settingsBackupImportHelp =>
      'Restores the settings from a backup file.';

  @override
  String get settingsBackupImportInvalid =>
      'This file is not a valid settings backup; the settings were not changed.';

  @override
  String get settingsBackupImportReadFailed =>
      'The file could not be read; the settings were not changed.';

  @override
  String get settingsBackupImportTitle => 'Restore the settings?';

  @override
  String get settingsBackupImported => 'The settings were restored.';

  @override
  String get settingsBackupTitle => 'Backup and restore';

  @override
  String get settingsCalcAngleHelp =>
      'Angle of the sun below the horizon, in degrees';

  @override
  String get settingsCalcAsr => 'Asr rule';

  @override
  String get settingsCalcFajrAngle => 'Fajr angle';

  @override
  String get settingsCalcHighLat => 'High latitudes';

  @override
  String get settingsCalcHighLatHelp =>
      'For places where the night is very short and the twilight angle is never reached.';

  @override
  String get settingsCalcImsak => 'Imsak';

  @override
  String get settingsCalcImsakHelp => 'Minutes before Fajr';

  @override
  String get settingsCalcIshaAngle => 'Isha angle';

  @override
  String get settingsCalcIshaMinutes => 'Minutes after Maghrib';

  @override
  String get settingsCalcIshaMode => 'Isha definition';

  @override
  String get settingsCalcIshaModeAngle => 'Sun angle';

  @override
  String get settingsCalcIshaModeMinutes => 'Minutes after Maghrib';

  @override
  String get settingsCalcMaghribAngle => 'Maghrib angle';

  @override
  String get settingsCalcMaghribSunset => 'Maghrib at sunset';

  @override
  String get settingsCalcMaghribSunsetHelp =>
      'When off, Maghrib is calculated with the angle below.';

  @override
  String get settingsCalcMethod => 'Method';

  @override
  String get settingsCalcMethodHelp =>
      'Changing any angle turns the method into Custom.';

  @override
  String get settingsCalcMidnight => 'Midnight';

  @override
  String settingsCalcOffsetsHelp(String max) {
    return 'Move any time earlier or later by up to $max minutes.';
  }

  @override
  String get settingsCalcOffsetsReset => 'Reset all';

  @override
  String get settingsCalcOffsetsTitle => 'Minute adjustment per time';

  @override
  String settingsCalcPreviewHelp(String date) {
    return 'Today\'s times ($date) with the settings above';
  }

  @override
  String get settingsCalcPreviewTitle => 'Live preview';

  @override
  String get settingsCalcRestore => 'Restore defaults for this method';

  @override
  String settingsCalcRestoreHelp(String method) {
    return 'Angles, rules and Imsak return to the values of $method; the minute adjustments of each time are not changed.';
  }

  @override
  String get settingsCalcRowsHelp =>
      'Fajr, Sunrise, Dhuhr, Maghrib and Midnight are always shown.';

  @override
  String get settingsCalcRowsTitle => 'Rows to show';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsDecrease => 'Decrease';

  @override
  String get settingsDigitsLatin => 'Latin (123)';

  @override
  String get settingsDigitsPersian => 'Persian (۱۲۳)';

  @override
  String get settingsDispDigits => 'Digits';

  @override
  String get settingsDispHijri => 'Hijri date adjustment';

  @override
  String get settingsDispHijriHelp =>
      'Iran follows moon sighting, so the shown Hijri date can differ from the official one; shift it by a day or two here.';

  @override
  String get settingsDispHour => 'Clock';

  @override
  String get settingsDispLanguage => 'Language';

  @override
  String get settingsDispLanguageHelp => 'Applies without a restart.';

  @override
  String get settingsDispTheme => 'Theme';

  @override
  String get settingsHighLatAngleBased => 'Angle based';

  @override
  String get settingsHighLatNightMiddle => 'Middle of the night';

  @override
  String get settingsHighLatNone => 'No adjustment';

  @override
  String get settingsHighLatOneSeventh => 'One seventh of the night';

  @override
  String get settingsHour12 => '12-hour';

  @override
  String get settingsHour24 => '24-hour';

  @override
  String get settingsIncrease => 'Increase';

  @override
  String settingsInvalidNumber(String min, String max) {
    return 'Enter a number between $min and $max.';
  }

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsLanguageFa => 'فارسی';

  @override
  String get settingsLocActive => 'Active';

  @override
  String get settingsLocAdd => 'Add';

  @override
  String get settingsLocAddCustom => 'Custom location';

  @override
  String get settingsLocAddFromDb => 'From the city list';

  @override
  String get settingsLocAddTitle => 'Add a location';

  @override
  String settingsLocAdded(String name) {
    return '$name was added.';
  }

  @override
  String get settingsLocAllProvinces => 'All provinces';

  @override
  String get settingsLocAlreadySaved => 'Already saved';

  @override
  String get settingsLocClose => 'Close';

  @override
  String settingsLocCoords(String lat, String lon) {
    return 'Lat $lat, lon $lon';
  }

  @override
  String get settingsLocCustomBadge => 'Custom';

  @override
  String get settingsLocDegrees => 'Degrees';

  @override
  String get settingsLocDelete => 'Delete';

  @override
  String get settingsLocDeleteBody =>
      'This location is removed from your list.';

  @override
  String get settingsLocDeleteLast => 'The last location cannot be deleted.';

  @override
  String settingsLocDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get settingsLocEast => 'East';

  @override
  String get settingsLocEdit => 'Edit';

  @override
  String get settingsLocElevation => 'Elevation (metres)';

  @override
  String settingsLocErrElevation(String min, String max) {
    return 'Elevation must be between $min and $max metres.';
  }

  @override
  String settingsLocErrLatitude(String min, String max) {
    return 'Latitude must be a number between $min and $max.';
  }

  @override
  String settingsLocErrLongitude(String min, String max) {
    return 'Longitude must be a number between $min and $max.';
  }

  @override
  String get settingsLocErrName => 'Enter a name.';

  @override
  String settingsLocErrOffset(String min, String max) {
    return 'The offset must be between $min and $max.';
  }

  @override
  String get settingsLocErrZone => 'Choose a time zone from the list.';

  @override
  String get settingsLocFormatDecimal => 'Decimal degrees';

  @override
  String get settingsLocFormatDms => 'Degrees, minutes, seconds';

  @override
  String get settingsLocLatitude => 'Latitude';

  @override
  String get settingsLocLongitude => 'Longitude';

  @override
  String get settingsLocMinutes => 'Minutes';

  @override
  String get settingsLocName => 'Name';

  @override
  String get settingsLocNoResults => 'No city found.';

  @override
  String get settingsLocNorth => 'North';

  @override
  String get settingsLocProvince => 'Province';

  @override
  String get settingsLocSave => 'Save';

  @override
  String get settingsLocSavedHelp =>
      'The times are calculated for the active location.';

  @override
  String get settingsLocSavedTitle => 'Saved locations';

  @override
  String get settingsLocSearchHint => 'Search for a city';

  @override
  String get settingsLocSeconds => 'Seconds';

  @override
  String get settingsLocSetActive => 'Set active';

  @override
  String get settingsLocSouth => 'South';

  @override
  String get settingsLocWest => 'West';

  @override
  String get settingsLocZoneNone => 'No time zone found.';

  @override
  String get settingsLocZoneSearch => 'Search time zones';

  @override
  String settingsLocZoneSelected(String zone) {
    return 'Selected time zone: $zone';
  }

  @override
  String get settingsMethodCustom => 'Custom';

  @override
  String get settingsMethodEgypt => 'Egyptian General Authority of Survey';

  @override
  String get settingsMethodIsna => 'Islamic Society of North America';

  @override
  String get settingsMethodJafari => 'Shia Ithna-Ashari, Leva Institute (Qom)';

  @override
  String get settingsMethodKarachi => 'University of Islamic Sciences, Karachi';

  @override
  String get settingsMethodMakkah => 'Umm al-Qura University, Makkah';

  @override
  String get settingsMethodMwl => 'Muslim World League';

  @override
  String get settingsMethodTehran =>
      'University of Tehran, Institute of Geophysics';

  @override
  String get settingsMidnightJafari => 'Between sunset and Fajr';

  @override
  String get settingsMidnightStandard => 'Between sunset and sunrise';

  @override
  String get settingsOff => 'Off';

  @override
  String settingsPercent(String value) {
    return '$value%';
  }

  @override
  String get settingsRemChime => 'Soft chime';

  @override
  String get settingsRemChimeHelp =>
      'A soft chime plays with the reminder notification.';

  @override
  String get settingsRemChimeTest => 'Play a sample';

  @override
  String settingsRemHelp(String max) {
    return '0 means off; up to $max minutes before the azan.';
  }

  @override
  String get settingsRemIndependent =>
      'Turning reminders off never affects the azan.';

  @override
  String settingsRemSummary(String minutes) {
    return '$minutes min before the azan';
  }

  @override
  String settingsRemTitle(String prayer) {
    return 'Reminder before $prayer';
  }

  @override
  String get settingsResetConfirm => 'Clear';

  @override
  String get settingsResetConfirmBody =>
      'The settings return to their defaults and the active location becomes Tehran. This cannot be undone.';

  @override
  String get settingsResetConfirmTitle => 'Clear all settings?';

  @override
  String get settingsResetDone => 'The settings were reset to the defaults.';

  @override
  String get settingsResetHelp =>
      'All settings, saved locations and wake-up alarms are cleared.';

  @override
  String get settingsResetTitle => 'Reset to defaults';

  @override
  String get settingsSaved => 'Saved';

  @override
  String get settingsSectionAbout => 'About and diagnostics';

  @override
  String get settingsSectionApp => 'App';

  @override
  String get settingsSectionAzan => 'Azan';

  @override
  String get settingsSectionCalculation => 'Calculation';

  @override
  String get settingsSectionDisplay => 'Display';

  @override
  String get settingsSectionLocation => 'Location';

  @override
  String get settingsSectionReminders => 'Reminders';

  @override
  String get settingsSectionTime => 'Time';

  @override
  String get settingsSectionsLabel => 'Settings sections';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeSystem => 'Follow Windows';

  @override
  String get settingsTimeCheck => 'Check the clock against network time';

  @override
  String get settingsTimeCheckHelp =>
      'When the app starts and every six hours; off by default.';

  @override
  String get settingsTimeCheckNow => 'Check now';

  @override
  String settingsTimeCheckedAt(String time) {
    return 'Checked at $time';
  }

  @override
  String get settingsTimeChecking => 'Checking…';

  @override
  String get settingsTimeCorrect => 'Correct the time inside the app';

  @override
  String get settingsTimeCorrectHelp => 'The Windows clock is never changed.';

  @override
  String settingsTimeDiagLocation(String offset) {
    return 'Offset of the active location (database): $offset';
  }

  @override
  String get settingsTimeDiagOk => 'No clock problem found.';

  @override
  String get settingsTimeDiagTitle => 'Clock diagnostics';

  @override
  String settingsTimeDiagWindows(String offset) {
    return 'Windows offset from UTC: $offset';
  }

  @override
  String get settingsTimeError =>
      'Could not reach the time server. Check the internet connection and the server name.';

  @override
  String get settingsTimeNever => 'Not checked yet.';

  @override
  String get settingsTimeServer => 'Time server';

  @override
  String get settingsTimeServerHelp =>
      'Name of the time server, for example pool.ntp.org';

  @override
  String get settingsTimeServerInvalid => 'The server name is not valid.';

  @override
  String settingsTimeSkewAhead(String amount) {
    return 'The PC clock is $amount ahead.';
  }

  @override
  String settingsTimeSkewBehind(String amount) {
    return 'The PC clock is $amount behind.';
  }

  @override
  String get settingsTimeSkewZero => 'The PC clock matches network time.';

  @override
  String get settingsTimeStatusTitle => 'Last check';

  @override
  String get settingsZoneAuto => 'Automatic (recommended)';

  @override
  String settingsZoneAutoHelp(String zone) {
    return 'Uses the time-zone database built into the app: $zone';
  }

  @override
  String get settingsZoneFixed => 'Fixed offset';

  @override
  String get settingsZoneFixedAllYear =>
      'The offset is fixed and stays the same on every day of the year.';

  @override
  String get settingsZoneFixedHelp =>
      'One fixed difference from UTC that applies on every day of the year.';

  @override
  String settingsZoneFixedValue(String offset) {
    return 'Fixed offset: $offset';
  }

  @override
  String get settingsZoneHourLess => 'One hour less';

  @override
  String get settingsZoneHourMore => 'One hour more';

  @override
  String settingsZoneNext(String date, String time, String offset) {
    return 'Next change: $date at $time, offset $offset';
  }

  @override
  String get settingsZoneNoChange =>
      'No further change is planned for this time zone.';

  @override
  String settingsZoneNow(String offset) {
    return 'Offset in effect today: $offset';
  }

  @override
  String get settingsZoneQuarterLess => 'A quarter of an hour less';

  @override
  String get settingsZoneQuarterMore => 'A quarter of an hour more';

  @override
  String get settingsZoneTitle => 'Time zone';

  @override
  String get timetableCalendarSwitch => 'Calendar type';

  @override
  String get timetableColDay => 'Day';

  @override
  String get timetableColWeekday => 'Weekday';

  @override
  String get timetableMonthUnavailable =>
      'This month is outside the lunar calendar table.';

  @override
  String get timetableNextMonth => 'Next month';

  @override
  String timetableOpenDay(String date) {
    return 'Show $date on the home screen';
  }

  @override
  String get timetablePreviousMonth => 'Previous month';

  @override
  String get timetableToday => 'Today';

  @override
  String get trayMenuLocation => 'Location';

  @override
  String get trayMenuMute => 'Mute';

  @override
  String get trayMenuMuted => 'Muted';

  @override
  String get trayMenuQuit => 'Quit';

  @override
  String get trayMenuSettings => 'Settings';

  @override
  String get trayMenuShow => 'Show window';

  @override
  String get trayMenuStopAzan => 'Stop azan';

  @override
  String get trayMuteCancel => 'Cancel mute';

  @override
  String trayMuteHours(String n) {
    return '$n h';
  }

  @override
  String get trayMuteIndefinite => 'Until I turn it off';

  @override
  String get trayMuteUntilNext => 'Until the next azan';

  @override
  String trayNextLine(String prayer, String time) {
    return 'Next: $prayer · $time';
  }

  @override
  String trayTimeRow(String prayer, String time) {
    return '$prayer   $time';
  }

  @override
  String trayTooltip(String prayer, String time, String remaining) {
    return '$prayer $time · $remaining';
  }

  @override
  String get wakeAdd => 'Add alarm';

  @override
  String get wakeAfterHibernate => 'After the sound: hibernate';

  @override
  String get wakeAfterHibernateChoice => 'Hibernate';

  @override
  String get wakeAfterNote =>
      'Before the PC sleeps or hibernates, a 30-second countdown lets you cancel.';

  @override
  String get wakeAfterNothing => 'Do nothing';

  @override
  String get wakeAfterSleep => 'After the sound: sleep';

  @override
  String get wakeAfterSleepChoice => 'Sleep';

  @override
  String get wakeAfterTitle => 'After the sound';

  @override
  String get wakeCancel => 'Cancel';

  @override
  String get wakeCapabilityChecking => 'Checking this PC…';

  @override
  String get wakeCapabilityOkBody =>
      'The check found no obstacle. Run the two-minute test to be sure.';

  @override
  String get wakeCapabilityOkTitle => 'This PC can wake itself';

  @override
  String get wakeCapabilityRefresh => 'Check again';

  @override
  String get wakeCapabilityUnknown => 'Not checked yet.';

  @override
  String get wakeCapabilityWarnTitle => 'This PC may not wake up for an alarm';

  @override
  String get wakeChoiceFixed => 'At a fixed time';

  @override
  String get wakeChoiceRelative => 'Before a prayer';

  @override
  String get wakeChooseFile => 'Choose a file…';

  @override
  String get wakeCountdownAfterAlarm => 'The alarm has finished.';

  @override
  String get wakeCountdownCancel => 'Cancel';

  @override
  String wakeCountdownHibernate(String time) {
    return 'The PC will hibernate in $time.';
  }

  @override
  String wakeCountdownSleep(String time) {
    return 'The PC will go to sleep in $time.';
  }

  @override
  String get wakeDelete => 'Delete';

  @override
  String get wakeDeleteBody =>
      'The alarm and its wake-up request will be removed.';

  @override
  String get wakeDeleteConfirm => 'Delete';

  @override
  String get wakeDeleteTitle => 'Delete this alarm?';

  @override
  String get wakeDismiss => 'Dismiss';

  @override
  String get wakeEdit => 'Edit';

  @override
  String get wakeEditorTitleAdd => 'New alarm';

  @override
  String get wakeEditorTitleEdit => 'Edit alarm';

  @override
  String get wakeEmpty =>
      'No alarms yet. Add one to wake this PC at a time you choose.';

  @override
  String get wakeEnabledSwitch => 'On';

  @override
  String wakeErrorMinutes(String min, String max) {
    return 'Enter a whole number from $min to $max.';
  }

  @override
  String get wakeFieldHour => 'Hour';

  @override
  String get wakeFieldLabel => 'Name (optional)';

  @override
  String get wakeFieldMinute => 'Minute';

  @override
  String get wakeFieldMinutesBefore => 'Minutes before';

  @override
  String get wakeFieldPrayer => 'Prayer';

  @override
  String get wakeHibernateNow => 'Hibernate now';

  @override
  String get wakeIssueImportantOnly =>
      'Windows only allows important wake timers, which usually does not include this app.';

  @override
  String get wakeIssueInProcessTimer =>
      'The backup timer inside the app could not be created.';

  @override
  String get wakeIssueModernStandby =>
      'This PC uses Modern Standby, where waking at a set time is often unreliable.';

  @override
  String get wakeIssueTaskCreationFailed =>
      'Windows did not allow a scheduled wake-up task for your account, so an alarm only works while this app is running.';

  @override
  String get wakeIssueTimersOffAc =>
      'Windows has wake timers turned off while the PC is plugged in.';

  @override
  String get wakeIssueTimersOffBattery =>
      'Windows has wake timers turned off while the PC runs on battery.';

  @override
  String get wakeIssueUnknown =>
      'The Windows wake-timer setting could not be read.';

  @override
  String get wakeListSeparator => ', ';

  @override
  String wakeNext(String remaining, String time) {
    return 'Next: $remaining ($time)';
  }

  @override
  String get wakeNextNone => 'Next: —';

  @override
  String wakeNextOtherDay(String remaining, String weekday, String time) {
    return 'Next: $remaining ($weekday $time)';
  }

  @override
  String get wakeOff => 'Off';

  @override
  String get wakeOpenPowerFailed =>
      'The power settings could not be opened. Open Control Panel > Power Options yourself.';

  @override
  String get wakeOpenPowerOptions => 'Open Windows power settings';

  @override
  String wakePercent(String percent) {
    return '$percent%';
  }

  @override
  String get wakePlaySound => 'Play a sound';

  @override
  String get wakePowerHint =>
      'In Windows: Power Options > Change plan settings > Change advanced power settings > Sleep > Allow wake timers. This app never changes a power setting by itself.';

  @override
  String get wakePreview => 'Preview';

  @override
  String get wakePreviewStop => 'Stop preview';

  @override
  String get wakeProblemHibernateUnavailable =>
      'Hibernation is not turned on for this PC.';

  @override
  String get wakeProblemProbeFailed =>
      'The check of this PC could not be completed.';

  @override
  String get wakeProblemSoundFailed =>
      'The alarm sound could not be played. Check the sound file and the speakers.';

  @override
  String get wakeProblemSuspendRefused =>
      'Windows did not allow the PC to sleep.';

  @override
  String get wakeRepeatDaily => 'Every day';

  @override
  String get wakeRepeatOnce => 'Once';

  @override
  String get wakeRepeatTitle => 'Repeat';

  @override
  String wakeRepeatWeekdays(String days) {
    return 'On $days';
  }

  @override
  String get wakeRepeatWeekdaysChoice => 'Chosen days';

  @override
  String get wakeRinging => 'An alarm is ringing';

  @override
  String get wakeSave => 'Save';

  @override
  String get wakeSaveFailed =>
      'These values could not be saved. Check the time and the days.';

  @override
  String get wakeSleepHint =>
      'The PC goes to sleep after a five-second countdown that you can cancel.';

  @override
  String get wakeSleepNow => 'Sleep now';

  @override
  String get wakeSoundDefault => 'Default azan sound';

  @override
  String wakeSoundFile(String name) {
    return 'File: $name';
  }

  @override
  String get wakeSoundTitle => 'Sound';

  @override
  String get wakeStop => 'Stop';

  @override
  String get wakeSyncError =>
      'The wake-up request could not be registered with Windows; an alarm may only work while the app is running.';

  @override
  String get wakeTest => 'Test in 2 minutes';

  @override
  String get wakeTestCancel => 'Cancel the test';

  @override
  String wakeTestPending(String time) {
    return 'A test alarm will ring at $time. Put the PC to sleep now to see whether it wakes.';
  }

  @override
  String get wakeTitle => 'Wake-up alarms';

  @override
  String wakeTriggerAtPrayer(String prayer) {
    return 'At $prayer';
  }

  @override
  String wakeTriggerFixed(String time) {
    return 'At $time';
  }

  @override
  String wakeTriggerRelative(String minutes, String prayer) {
    return '$minutes before $prayer';
  }

  @override
  String get wakeTriggerTypeTitle => 'When';

  @override
  String get wakeUseDefault => 'Use the default';

  @override
  String get wakeVolume => 'Volume';

  @override
  String get wakeWeekdaysError => 'Choose at least one day.';
}
