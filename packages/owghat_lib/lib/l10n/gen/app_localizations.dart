import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @aboutFontNote.
  ///
  /// In fa, this message translates to:
  /// **'قلم وزیرمتن با مجوز SIL Open Font License 1.1 همراه برنامه است.'**
  String get aboutFontNote;

  /// No description provided for @aboutLicences.
  ///
  /// In fa, this message translates to:
  /// **'مجوزهای نرم‌افزارهای متن‌باز'**
  String get aboutLicences;

  /// No description provided for @aboutSoundNote.
  ///
  /// In fa, this message translates to:
  /// **'صداهای همراه برنامه (اذان پیش‌فرض و زنگ یادآوری) نمونه‌هایی ساده و ساختگی‌اند، ضبط هیچ مؤذنی نیستند و با مجوز CC0 منتشر شده‌اند. صدای اذان دلخواه خود را از بخش تنظیمات انتخاب کنید.'**
  String get aboutSoundNote;

  /// No description provided for @aboutTagline.
  ///
  /// In fa, this message translates to:
  /// **'اوقات شرعی و اذان برای ویندوز؛ بدون اینترنت، بدون تبلیغ، بدون حساب کاربری و بدون ردیابی.'**
  String get aboutTagline;

  /// No description provided for @aboutTitle.
  ///
  /// In fa, this message translates to:
  /// **'درباره'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In fa, this message translates to:
  /// **'نسخه‌ی {version}'**
  String aboutVersion(String version);

  /// No description provided for @appName.
  ///
  /// In fa, this message translates to:
  /// **'Salaat | Avini Prayer Times'**
  String get appName;

  /// No description provided for @calendarAdjustEarlier.
  ///
  /// In fa, this message translates to:
  /// **'یک روز زودتر'**
  String get calendarAdjustEarlier;

  /// No description provided for @calendarAdjustLater.
  ///
  /// In fa, this message translates to:
  /// **'یک روز دیرتر'**
  String get calendarAdjustLater;

  /// No description provided for @calendarAdjustValue.
  ///
  /// In fa, this message translates to:
  /// **'{value} روز'**
  String calendarAdjustValue(String value);

  /// No description provided for @calendarConvErrDay.
  ///
  /// In fa, this message translates to:
  /// **'روز باید از {first} تا {days} باشد.'**
  String calendarConvErrDay(String first, String days);

  /// No description provided for @calendarConvErrIncomplete.
  ///
  /// In fa, this message translates to:
  /// **'سال، ماه و روز را کامل کنید.'**
  String get calendarConvErrIncomplete;

  /// No description provided for @calendarConvErrMonth.
  ///
  /// In fa, this message translates to:
  /// **'ماه باید از یک تا دوازده باشد.'**
  String get calendarConvErrMonth;

  /// No description provided for @calendarConvErrNumber.
  ///
  /// In fa, this message translates to:
  /// **'فقط عدد بنویسید.'**
  String get calendarConvErrNumber;

  /// No description provided for @calendarConvErrRange.
  ///
  /// In fa, this message translates to:
  /// **'این تاریخ بیرون از بازه‌ی پشتیبانی‌شده‌ی تقویم است.'**
  String get calendarConvErrRange;

  /// No description provided for @calendarConverterHint.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ را در یکی از سه تقویم بنویسید؛ دو تقویم دیگر هم‌زمان تغییر می‌کنند.'**
  String get calendarConverterHint;

  /// No description provided for @calendarConverterShow.
  ///
  /// In fa, this message translates to:
  /// **'نمایش در تقویم'**
  String get calendarConverterShow;

  /// No description provided for @calendarConverterTitle.
  ///
  /// In fa, this message translates to:
  /// **'مبدل تاریخ'**
  String get calendarConverterTitle;

  /// No description provided for @calendarDayMonthYear.
  ///
  /// In fa, this message translates to:
  /// **'{day} {month} {year}'**
  String calendarDayMonthYear(String day, String month, String year);

  /// No description provided for @calendarFieldDay.
  ///
  /// In fa, this message translates to:
  /// **'روز'**
  String get calendarFieldDay;

  /// No description provided for @calendarFieldMonth.
  ///
  /// In fa, this message translates to:
  /// **'ماه'**
  String get calendarFieldMonth;

  /// No description provided for @calendarFieldYear.
  ///
  /// In fa, this message translates to:
  /// **'سال'**
  String get calendarFieldYear;

  /// No description provided for @calendarGridLabel.
  ///
  /// In fa, this message translates to:
  /// **'تقویم ماهانه'**
  String get calendarGridLabel;

  /// No description provided for @calendarHijriAdjust.
  ///
  /// In fa, this message translates to:
  /// **'تنظیم تاریخ قمری'**
  String get calendarHijriAdjust;

  /// No description provided for @calendarHijriApproxHint.
  ///
  /// In fa, this message translates to:
  /// **'تقریبی؛ تقویم قمری رسمی ایران بر پایه‌ی رؤیت ماه است و ممکن است یک روز متفاوت باشد.'**
  String get calendarHijriApproxHint;

  /// No description provided for @calendarHijriUnavailable.
  ///
  /// In fa, this message translates to:
  /// **'برای این روز تاریخ قمری در جدول نیست'**
  String get calendarHijriUnavailable;

  /// No description provided for @calendarKindGregorian.
  ///
  /// In fa, this message translates to:
  /// **'میلادی'**
  String get calendarKindGregorian;

  /// No description provided for @calendarKindHijri.
  ///
  /// In fa, this message translates to:
  /// **'قمری'**
  String get calendarKindHijri;

  /// No description provided for @calendarKindJalali.
  ///
  /// In fa, this message translates to:
  /// **'شمسی'**
  String get calendarKindJalali;

  /// No description provided for @calendarMonthGregorian.
  ///
  /// In fa, this message translates to:
  /// **'{month, select, m1{ژانویه} m2{فوریه} m3{مارس} m4{آوریل} m5{مه} m6{ژوئن} m7{ژوئیه} m8{اوت} m9{سپتامبر} m10{اکتبر} m11{نوامبر} m12{دسامبر} other{}}'**
  String calendarMonthGregorian(String month);

  /// No description provided for @calendarMonthHijri.
  ///
  /// In fa, this message translates to:
  /// **'{month, select, m1{محرم} m2{صفر} m3{ربیع‌الاول} m4{ربیع‌الثانی} m5{جمادی‌الاول} m6{جمادی‌الثانی} m7{رجب} m8{شعبان} m9{رمضان} m10{شوال} m11{ذی‌القعده} m12{ذی‌الحجه} other{}}'**
  String calendarMonthHijri(String month);

  /// No description provided for @calendarMonthJalali.
  ///
  /// In fa, this message translates to:
  /// **'{month, select, m1{فروردین} m2{اردیبهشت} m3{خرداد} m4{تیر} m5{مرداد} m6{شهریور} m7{مهر} m8{آبان} m9{آذر} m10{دی} m11{بهمن} m12{اسفند} other{}}'**
  String calendarMonthJalali(String month);

  /// No description provided for @calendarMonthYear.
  ///
  /// In fa, this message translates to:
  /// **'{month} {year}'**
  String calendarMonthYear(String month, String year);

  /// No description provided for @calendarMoonNote.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ قمری بر پایه‌ی جدول ام‌القری است. تقویم رسمی ایران با رؤیت ماه تعیین می‌شود و ممکن است یک روز تفاوت داشته باشد؛ در این صورت آن را اینجا یک روز جابه‌جا کنید.'**
  String get calendarMoonNote;

  /// No description provided for @calendarNextMonth.
  ///
  /// In fa, this message translates to:
  /// **'ماه بعد'**
  String get calendarNextMonth;

  /// No description provided for @calendarOpenOnHome.
  ///
  /// In fa, this message translates to:
  /// **'نمایش در صفحه‌ی اصلی'**
  String get calendarOpenOnHome;

  /// No description provided for @calendarPanelTimes.
  ///
  /// In fa, this message translates to:
  /// **'اوقات این روز'**
  String get calendarPanelTimes;

  /// No description provided for @calendarPreviousMonth.
  ///
  /// In fa, this message translates to:
  /// **'ماه قبل'**
  String get calendarPreviousMonth;

  /// No description provided for @calendarSeparator.
  ///
  /// In fa, this message translates to:
  /// **'، '**
  String get calendarSeparator;

  /// No description provided for @calendarToday.
  ///
  /// In fa, this message translates to:
  /// **'امروز'**
  String get calendarToday;

  /// No description provided for @calendarWeekday.
  ///
  /// In fa, this message translates to:
  /// **'{day, select, d1{دوشنبه} d2{سه‌شنبه} d3{چهارشنبه} d4{پنجشنبه} d5{جمعه} d6{شنبه} d7{یکشنبه} other{}}'**
  String calendarWeekday(String day);

  /// No description provided for @calendarWeekdayShort.
  ///
  /// In fa, this message translates to:
  /// **'{day, select, d1{د} d2{س} d3{چ} d4{پ} d5{ج} d6{ش} d7{ی} other{}}'**
  String calendarWeekdayShort(String day);

  /// No description provided for @diagAudioFailed.
  ///
  /// In fa, this message translates to:
  /// **'صدای آزمایشی پخش نشد. بلندگو و میزان صدای ویندوز را بررسی کنید.'**
  String get diagAudioFailed;

  /// No description provided for @diagAudioOk.
  ///
  /// In fa, this message translates to:
  /// **'صدای آزمایشی پخش شد.'**
  String get diagAudioOk;

  /// No description provided for @diagAudioPlay.
  ///
  /// In fa, this message translates to:
  /// **'پخش صدای آزمایشی'**
  String get diagAudioPlay;

  /// No description provided for @diagAudioStop.
  ///
  /// In fa, this message translates to:
  /// **'توقف'**
  String get diagAudioStop;

  /// No description provided for @diagAudioTitle.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش صدا'**
  String get diagAudioTitle;

  /// No description provided for @diagClockOk.
  ///
  /// In fa, this message translates to:
  /// **'مشکلی در ساعت رایانه پیدا نشد.'**
  String get diagClockOk;

  /// No description provided for @diagClockTitle.
  ///
  /// In fa, this message translates to:
  /// **'ساعت'**
  String get diagClockTitle;

  /// No description provided for @diagClockUnchecked.
  ///
  /// In fa, this message translates to:
  /// **'مشکلی دیده نشد، ولی بررسی ساعت با اینترنت خاموش است و انحراف ساعت اندازه‌گیری نمی‌شود.'**
  String get diagClockUnchecked;

  /// No description provided for @diagCopied.
  ///
  /// In fa, this message translates to:
  /// **'رونوشت شد. نام، مکان دقیق و مختصات دقیق در آن نیست.'**
  String get diagCopied;

  /// No description provided for @diagCopy.
  ///
  /// In fa, this message translates to:
  /// **'رونوشت عیب‌یابی'**
  String get diagCopy;

  /// No description provided for @diagCopyFailed.
  ///
  /// In fa, this message translates to:
  /// **'رونوشت انجام نشد.'**
  String get diagCopyFailed;

  /// No description provided for @diagEventAzan.
  ///
  /// In fa, this message translates to:
  /// **'{prayer}'**
  String diagEventAzan(String prayer);

  /// No description provided for @diagEventReminder.
  ///
  /// In fa, this message translates to:
  /// **'یادآوری {prayer}'**
  String diagEventReminder(String prayer);

  /// No description provided for @diagEventTimes.
  ///
  /// In fa, this message translates to:
  /// **'UTC {utc} | محلی {local}'**
  String diagEventTimes(String utc, String local);

  /// No description provided for @diagEventWake.
  ///
  /// In fa, this message translates to:
  /// **'بیدارباش'**
  String get diagEventWake;

  /// No description provided for @diagEventsEmpty.
  ///
  /// In fa, this message translates to:
  /// **'چیزی زمان‌بندی نشده است.'**
  String get diagEventsEmpty;

  /// No description provided for @diagEventsTitle.
  ///
  /// In fa, this message translates to:
  /// **'رویدادهای زمان‌بندی‌شده‌ی بعدی'**
  String get diagEventsTitle;

  /// No description provided for @diagLogNone.
  ///
  /// In fa, this message translates to:
  /// **'در دسترس نیست.'**
  String get diagLogNone;

  /// No description provided for @diagLogTitle.
  ///
  /// In fa, this message translates to:
  /// **'فایل‌های گزارش'**
  String get diagLogTitle;

  /// No description provided for @diagTitle.
  ///
  /// In fa, this message translates to:
  /// **'عیب‌یابی'**
  String get diagTitle;

  /// No description provided for @diagValue.
  ///
  /// In fa, this message translates to:
  /// **'{value, select, yes{بله} no{نه} unknown{نامشخص} enabled{مجاز} disabled{خاموش} importantOnly{فقط مهم‌ها} ok{سالم} failed{ناموفق} other{}}'**
  String diagValue(String value);

  /// No description provided for @diagWakeAc.
  ///
  /// In fa, this message translates to:
  /// **'تایمر بیدارکننده با برق شهر: {value}'**
  String diagWakeAc(String value);

  /// No description provided for @diagWakeBattery.
  ///
  /// In fa, this message translates to:
  /// **'تایمر بیدارکننده با باتری: {value}'**
  String diagWakeBattery(String value);

  /// No description provided for @diagWakeCheck.
  ///
  /// In fa, this message translates to:
  /// **'بررسی کن'**
  String get diagWakeCheck;

  /// No description provided for @diagWakeInProcess.
  ///
  /// In fa, this message translates to:
  /// **'تایمر داخل برنامه: {value}'**
  String diagWakeInProcess(String value);

  /// No description provided for @diagWakeModern.
  ///
  /// In fa, this message translates to:
  /// **'آماده‌به‌کار مدرن: {value}'**
  String diagWakeModern(String value);

  /// No description provided for @diagWakeNotChecked.
  ///
  /// In fa, this message translates to:
  /// **'هنوز بررسی نشده است.'**
  String get diagWakeNotChecked;

  /// No description provided for @diagWakeTask.
  ///
  /// In fa, this message translates to:
  /// **'وظیفه‌ی زمان‌بندی‌شده: {value}'**
  String diagWakeTask(String value);

  /// No description provided for @diagWakeTitle.
  ///
  /// In fa, this message translates to:
  /// **'بررسی بیدارباش'**
  String get diagWakeTitle;

  /// No description provided for @formatAm.
  ///
  /// In fa, this message translates to:
  /// **'ق.ظ'**
  String get formatAm;

  /// No description provided for @formatHours.
  ///
  /// In fa, this message translates to:
  /// **'{hours} ساعت'**
  String formatHours(String hours);

  /// No description provided for @formatHoursMinutes.
  ///
  /// In fa, this message translates to:
  /// **'{hours} ساعت و {minutes} دقیقه'**
  String formatHoursMinutes(String hours, String minutes);

  /// No description provided for @formatMinutes.
  ///
  /// In fa, this message translates to:
  /// **'{minutes} دقیقه'**
  String formatMinutes(String minutes);

  /// No description provided for @formatPm.
  ///
  /// In fa, this message translates to:
  /// **'ب.ظ'**
  String get formatPm;

  /// No description provided for @formatRemaining.
  ///
  /// In fa, this message translates to:
  /// **'{duration} دیگر'**
  String formatRemaining(String duration);

  /// No description provided for @formatRemainingLessThan.
  ///
  /// In fa, this message translates to:
  /// **'کمتر از {minutes} دقیقه دیگر'**
  String formatRemainingLessThan(String minutes);

  /// No description provided for @formatSeconds.
  ///
  /// In fa, this message translates to:
  /// **'{seconds} ثانیه'**
  String formatSeconds(String seconds);

  /// No description provided for @homeAzanMutedIndefinite.
  ///
  /// In fa, this message translates to:
  /// **'اذان: بی‌صدا تا اطلاع ثانوی'**
  String get homeAzanMutedIndefinite;

  /// No description provided for @homeAzanMutedUntil.
  ///
  /// In fa, this message translates to:
  /// **'اذان: بی‌صدا تا {time}'**
  String homeAzanMutedUntil(String time);

  /// No description provided for @homeAzanOff.
  ///
  /// In fa, this message translates to:
  /// **'اذان: خاموش'**
  String get homeAzanOff;

  /// No description provided for @homeAzanOn.
  ///
  /// In fa, this message translates to:
  /// **'اذان: روشن'**
  String get homeAzanOn;

  /// No description provided for @homeAzanToggleOff.
  ///
  /// In fa, this message translates to:
  /// **'خاموش کردن اذان {prayer}'**
  String homeAzanToggleOff(String prayer);

  /// No description provided for @homeAzanToggleOn.
  ///
  /// In fa, this message translates to:
  /// **'روشن کردن اذان {prayer}'**
  String homeAzanToggleOn(String prayer);

  /// No description provided for @homeBackToToday.
  ///
  /// In fa, this message translates to:
  /// **'بازگشت به امروز'**
  String get homeBackToToday;

  /// No description provided for @homeBannerClockSkew.
  ///
  /// In fa, this message translates to:
  /// **'ساعت رایانه حدود {amount} با ساعت دقیق اختلاف دارد.'**
  String homeBannerClockSkew(String amount);

  /// No description provided for @homeBannerDismiss.
  ///
  /// In fa, this message translates to:
  /// **'بستن'**
  String get homeBannerDismiss;

  /// No description provided for @homeBannerMutedIndefinite.
  ///
  /// In fa, this message translates to:
  /// **'اذان تا اطلاع ثانوی بی‌صدا است.'**
  String get homeBannerMutedIndefinite;

  /// No description provided for @homeBannerMutedUntil.
  ///
  /// In fa, this message translates to:
  /// **'اذان تا {time} بی‌صدا است.'**
  String homeBannerMutedUntil(String time);

  /// No description provided for @homeBannerSettingsReset.
  ///
  /// In fa, this message translates to:
  /// **'فایل تنظیمات خوانده نشد و تنظیمات به حالت اولیه برگشت.'**
  String get homeBannerSettingsReset;

  /// No description provided for @homeBannerStaleZone.
  ///
  /// In fa, this message translates to:
  /// **'ویندوز برای این مکان ساعتی متفاوت از پایگاه داده‌ی منطقه‌ی زمانی نشان می‌دهد. اوقات برنامه درست است؛ ساعت ویندوز را بررسی کنید.'**
  String get homeBannerStaleZone;

  /// No description provided for @homeCompass.
  ///
  /// In fa, this message translates to:
  /// **'{point, select, p0{شمال} p1{شمال شرقی} p2{شرق} p3{جنوب شرقی} p4{جنوب} p5{جنوب غربی} p6{غرب} p7{شمال غربی} other{}}'**
  String homeCompass(String point);

  /// No description provided for @homeCountdownSemantics.
  ///
  /// In fa, this message translates to:
  /// **'{event} {duration}'**
  String homeCountdownSemantics(String event, String duration);

  /// No description provided for @homeDayTimes.
  ///
  /// In fa, this message translates to:
  /// **'اوقات {date}'**
  String homeDayTimes(String date);

  /// No description provided for @homeEventAt.
  ///
  /// In fa, this message translates to:
  /// **'{event} {time}'**
  String homeEventAt(String event, String time);

  /// No description provided for @homeHeroNoNext.
  ///
  /// In fa, this message translates to:
  /// **'وقتی برای شمارش معکوس نیست'**
  String get homeHeroNoNext;

  /// No description provided for @homeMute.
  ///
  /// In fa, this message translates to:
  /// **'بی‌صدا'**
  String get homeMute;

  /// No description provided for @homeMuteCancel.
  ///
  /// In fa, this message translates to:
  /// **'لغو بی‌صدا'**
  String get homeMuteCancel;

  /// No description provided for @homeMuteForDuration.
  ///
  /// In fa, this message translates to:
  /// **'{duration}'**
  String homeMuteForDuration(String duration);

  /// No description provided for @homeMuteIndefinite.
  ///
  /// In fa, this message translates to:
  /// **'تا اطلاع ثانوی'**
  String get homeMuteIndefinite;

  /// No description provided for @homeMuteUntilNext.
  ///
  /// In fa, this message translates to:
  /// **'تا اذان بعدی'**
  String get homeMuteUntilNext;

  /// No description provided for @homeNextDay.
  ///
  /// In fa, this message translates to:
  /// **'روز بعد'**
  String get homeNextDay;

  /// No description provided for @homeNextMarker.
  ///
  /// In fa, this message translates to:
  /// **'وقت بعدی'**
  String get homeNextMarker;

  /// No description provided for @homeNextWakeAlarm.
  ///
  /// In fa, this message translates to:
  /// **'بیدارباش بعدی: {value}'**
  String homeNextWakeAlarm(String value);

  /// No description provided for @homeNoTimesAction.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات محاسبه'**
  String get homeNoTimesAction;

  /// No description provided for @homeNoTimesInfo.
  ///
  /// In fa, this message translates to:
  /// **'در این روز برای این مکان همه‌ی وقت‌ها قابل محاسبه نیست. قاعده‌ی عرض‌های جغرافیایی بالا را در تنظیمات می‌توانید تغییر دهید.'**
  String get homeNoTimesInfo;

  /// No description provided for @homeNoValue.
  ///
  /// In fa, this message translates to:
  /// **'—'**
  String get homeNoValue;

  /// No description provided for @homeNowPlaying.
  ///
  /// In fa, this message translates to:
  /// **'در حال پخش: {prayer}'**
  String homeNowPlaying(String prayer);

  /// No description provided for @homeNowPlayingGeneric.
  ///
  /// In fa, this message translates to:
  /// **'در حال پخش اذان'**
  String get homeNowPlayingGeneric;

  /// No description provided for @homeOtherDayHint.
  ///
  /// In fa, this message translates to:
  /// **'اوقات این روز؛ شمارش معکوس فقط برای امروز است.'**
  String get homeOtherDayHint;

  /// No description provided for @homePreviousDay.
  ///
  /// In fa, this message translates to:
  /// **'روز قبل'**
  String get homePreviousDay;

  /// No description provided for @homeQiblaSummary.
  ///
  /// In fa, this message translates to:
  /// **'قبله: {degrees}° {direction}'**
  String homeQiblaSummary(String degrees, String direction);

  /// No description provided for @homeReminderMinutes.
  ///
  /// In fa, this message translates to:
  /// **'یادآوری: {minutes} دقیقه قبل'**
  String homeReminderMinutes(String minutes);

  /// No description provided for @homeReminderOff.
  ///
  /// In fa, this message translates to:
  /// **'یادآوری: خاموش'**
  String get homeReminderOff;

  /// No description provided for @homeReminderRange.
  ///
  /// In fa, this message translates to:
  /// **'یادآوری: {min} تا {max} دقیقه قبل'**
  String homeReminderRange(String min, String max);

  /// No description provided for @homeStatusTitle.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت'**
  String get homeStatusTitle;

  /// No description provided for @homeStop.
  ///
  /// In fa, this message translates to:
  /// **'توقف'**
  String get homeStop;

  /// No description provided for @homeSwitchLocation.
  ///
  /// In fa, this message translates to:
  /// **'تغییر مکان'**
  String get homeSwitchLocation;

  /// No description provided for @homeTimelineLabel.
  ///
  /// In fa, this message translates to:
  /// **'خط زمانی روز'**
  String get homeTimelineLabel;

  /// No description provided for @homeToday.
  ///
  /// In fa, this message translates to:
  /// **'امروز'**
  String get homeToday;

  /// No description provided for @homeTodayTimes.
  ///
  /// In fa, this message translates to:
  /// **'اوقات امروز'**
  String get homeTodayTimes;

  /// No description provided for @homeTomorrowTimes.
  ///
  /// In fa, this message translates to:
  /// **'اوقات فردا'**
  String get homeTomorrowTimes;

  /// No description provided for @homeUntilEvent.
  ///
  /// In fa, this message translates to:
  /// **'تا {event}'**
  String homeUntilEvent(String event);

  /// No description provided for @homeViewingDay.
  ///
  /// In fa, this message translates to:
  /// **'نمایش {date}'**
  String homeViewingDay(String date);

  /// No description provided for @navCalendar.
  ///
  /// In fa, this message translates to:
  /// **'تقویم'**
  String get navCalendar;

  /// No description provided for @navHome.
  ///
  /// In fa, this message translates to:
  /// **'خانه'**
  String get navHome;

  /// No description provided for @navQibla.
  ///
  /// In fa, this message translates to:
  /// **'قبله'**
  String get navQibla;

  /// No description provided for @navSettings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get navSettings;

  /// No description provided for @navTimetable.
  ///
  /// In fa, this message translates to:
  /// **'جدول ماهانه'**
  String get navTimetable;

  /// No description provided for @navWakeUp.
  ///
  /// In fa, this message translates to:
  /// **'بیدارباش'**
  String get navWakeUp;

  /// No description provided for @notifAzanBody.
  ///
  /// In fa, this message translates to:
  /// **'{place} · {time}'**
  String notifAzanBody(String place, String time);

  /// No description provided for @notifAzanFailed.
  ///
  /// In fa, this message translates to:
  /// **'پخش اذان ممکن نشد.'**
  String get notifAzanFailed;

  /// No description provided for @notifAzanTitle.
  ///
  /// In fa, this message translates to:
  /// **'{prayer}'**
  String notifAzanTitle(String prayer);

  /// No description provided for @notifMissedBody.
  ///
  /// In fa, this message translates to:
  /// **'رایانه در ساعت {time} در حالت خواب بود.'**
  String notifMissedBody(String time);

  /// No description provided for @notifMissedTitle.
  ///
  /// In fa, this message translates to:
  /// **'{prayer} پخش نشد'**
  String notifMissedTitle(String prayer);

  /// No description provided for @notifReminderBody.
  ///
  /// In fa, this message translates to:
  /// **'{place} · ساعت {time}'**
  String notifReminderBody(String place, String time);

  /// No description provided for @notifReminderTitle.
  ///
  /// In fa, this message translates to:
  /// **'{minutes} دقیقه تا {prayer}'**
  String notifReminderTitle(String minutes, String prayer);

  /// No description provided for @notifSoundFallback.
  ///
  /// In fa, this message translates to:
  /// **'فایل صدای اذان پیدا نشد؛ صدای پیش‌فرض پخش شد.'**
  String get notifSoundFallback;

  /// No description provided for @notifStopAction.
  ///
  /// In fa, this message translates to:
  /// **'توقف'**
  String get notifStopAction;

  /// No description provided for @notifTrayHint.
  ///
  /// In fa, this message translates to:
  /// **'برنامه در کنار ساعت ویندوز فعال می‌ماند.'**
  String get notifTrayHint;

  /// No description provided for @onboardingAzanBody.
  ///
  /// In fa, this message translates to:
  /// **'صدای اذان را بشنوید و تعیین کنید برنامه با روشن شدن ویندوز هم اجرا شود.'**
  String get onboardingAzanBody;

  /// No description provided for @onboardingAzanTitle.
  ///
  /// In fa, this message translates to:
  /// **'اذان و شروع برنامه'**
  String get onboardingAzanTitle;

  /// No description provided for @onboardingBack.
  ///
  /// In fa, this message translates to:
  /// **'قبلی'**
  String get onboardingBack;

  /// No description provided for @onboardingCityBody.
  ///
  /// In fa, this message translates to:
  /// **'شهر خود را جستجو کنید یا از فهرست استان‌ها انتخاب کنید.'**
  String get onboardingCityBody;

  /// No description provided for @onboardingCityNone.
  ///
  /// In fa, this message translates to:
  /// **'شهری پیدا نشد.'**
  String get onboardingCityNone;

  /// No description provided for @onboardingCitySearchHint.
  ///
  /// In fa, this message translates to:
  /// **'جستجوی شهر'**
  String get onboardingCitySearchHint;

  /// No description provided for @onboardingCitySelected.
  ///
  /// In fa, this message translates to:
  /// **'مکان انتخاب‌شده: {city}'**
  String onboardingCitySelected(String city);

  /// No description provided for @onboardingCityTitle.
  ///
  /// In fa, this message translates to:
  /// **'شهر شما'**
  String get onboardingCityTitle;

  /// No description provided for @onboardingFinish.
  ///
  /// In fa, this message translates to:
  /// **'شروع'**
  String get onboardingFinish;

  /// No description provided for @onboardingLanguageBody.
  ///
  /// In fa, this message translates to:
  /// **'زبان را انتخاب کنید. بعداً در تنظیمات هم می‌توانید آن را عوض کنید.'**
  String get onboardingLanguageBody;

  /// No description provided for @onboardingLanguageEn.
  ///
  /// In fa, this message translates to:
  /// **'English'**
  String get onboardingLanguageEn;

  /// No description provided for @onboardingLanguageFa.
  ///
  /// In fa, this message translates to:
  /// **'فارسی'**
  String get onboardingLanguageFa;

  /// No description provided for @onboardingLanguageTitle.
  ///
  /// In fa, this message translates to:
  /// **'زبان برنامه'**
  String get onboardingLanguageTitle;

  /// No description provided for @onboardingNext.
  ///
  /// In fa, this message translates to:
  /// **'بعدی'**
  String get onboardingNext;

  /// No description provided for @onboardingPreview.
  ///
  /// In fa, this message translates to:
  /// **'پخش نمونه‌ی اذان'**
  String get onboardingPreview;

  /// No description provided for @onboardingProvinceAll.
  ///
  /// In fa, this message translates to:
  /// **'همه‌ی استان‌ها'**
  String get onboardingProvinceAll;

  /// No description provided for @onboardingSkip.
  ///
  /// In fa, this message translates to:
  /// **'رد کردن'**
  String get onboardingSkip;

  /// No description provided for @onboardingStartWithWindows.
  ///
  /// In fa, this message translates to:
  /// **'اجرا همراه با ویندوز'**
  String get onboardingStartWithWindows;

  /// No description provided for @onboardingStartWithWindowsHint.
  ///
  /// In fa, this message translates to:
  /// **'برنامه بی‌صدا در کنار ساعت ویندوز شروع می‌شود.'**
  String get onboardingStartWithWindowsHint;

  /// No description provided for @onboardingStepProgress.
  ///
  /// In fa, this message translates to:
  /// **'مرحله {step} از {total}'**
  String onboardingStepProgress(String step, String total);

  /// No description provided for @onboardingStopPreview.
  ///
  /// In fa, this message translates to:
  /// **'توقف'**
  String get onboardingStopPreview;

  /// No description provided for @prayerAsr.
  ///
  /// In fa, this message translates to:
  /// **'عصر'**
  String get prayerAsr;

  /// No description provided for @prayerDhuhr.
  ///
  /// In fa, this message translates to:
  /// **'اذان ظهر'**
  String get prayerDhuhr;

  /// No description provided for @prayerFajr.
  ///
  /// In fa, this message translates to:
  /// **'اذان صبح'**
  String get prayerFajr;

  /// No description provided for @prayerImsak.
  ///
  /// In fa, this message translates to:
  /// **'امساک'**
  String get prayerImsak;

  /// No description provided for @prayerIsha.
  ///
  /// In fa, this message translates to:
  /// **'عشا'**
  String get prayerIsha;

  /// No description provided for @prayerMaghrib.
  ///
  /// In fa, this message translates to:
  /// **'اذان مغرب'**
  String get prayerMaghrib;

  /// No description provided for @prayerMidnight.
  ///
  /// In fa, this message translates to:
  /// **'نیمه‌شب شرعی'**
  String get prayerMidnight;

  /// No description provided for @prayerSunrise.
  ///
  /// In fa, this message translates to:
  /// **'طلوع آفتاب'**
  String get prayerSunrise;

  /// No description provided for @prayerSunset.
  ///
  /// In fa, this message translates to:
  /// **'غروب آفتاب'**
  String get prayerSunset;

  /// No description provided for @qiblaBearingLabel.
  ///
  /// In fa, this message translates to:
  /// **'زاویه‌ی قبله (از شمال حقیقی، ساعت‌گرد)'**
  String get qiblaBearingLabel;

  /// No description provided for @qiblaBearingValue.
  ///
  /// In fa, this message translates to:
  /// **'{degrees}° ({direction})'**
  String qiblaBearingValue(String degrees, String direction);

  /// No description provided for @qiblaCardinal.
  ///
  /// In fa, this message translates to:
  /// **'{point, select, n{شمال} e{شرق} s{جنوب} w{غرب} other{}}'**
  String qiblaCardinal(String point);

  /// No description provided for @qiblaCompassSemantics.
  ///
  /// In fa, this message translates to:
  /// **'قطب‌نما: قبله در {degrees} درجه ({direction})'**
  String qiblaCompassSemantics(String degrees, String direction);

  /// No description provided for @qiblaCompassSemanticsSun.
  ///
  /// In fa, this message translates to:
  /// **'{base}؛ خورشید در {azimuth} درجه'**
  String qiblaCompassSemanticsSun(String base, String azimuth);

  /// No description provided for @qiblaDistanceLabel.
  ///
  /// In fa, this message translates to:
  /// **'فاصله تا کعبه'**
  String get qiblaDistanceLabel;

  /// No description provided for @qiblaDistanceValue.
  ///
  /// In fa, this message translates to:
  /// **'{km} کیلومتر'**
  String qiblaDistanceValue(String km);

  /// No description provided for @qiblaForLocation.
  ///
  /// In fa, this message translates to:
  /// **'جهت قبله برای {place}'**
  String qiblaForLocation(String place);

  /// No description provided for @qiblaNoCompassNote.
  ///
  /// In fa, this message translates to:
  /// **'رایانه قطب‌نما ندارد؛ شکل نسبت به شمال حقیقی رسم شده است (شمال بالاست).'**
  String get qiblaNoCompassNote;

  /// No description provided for @qiblaSunBelow.
  ///
  /// In fa, this message translates to:
  /// **'خورشید زیر افق است.'**
  String get qiblaSunBelow;

  /// No description provided for @qiblaSunInHelp.
  ///
  /// In fa, this message translates to:
  /// **'در این لحظه خورشید دقیقاً در جهت قبله است؛ رو به خورشید بایستید.'**
  String get qiblaSunInHelp;

  /// No description provided for @qiblaSunInTitle.
  ///
  /// In fa, this message translates to:
  /// **'خورشید در جهت قبله (مقارنه)'**
  String get qiblaSunInTitle;

  /// No description provided for @qiblaSunNone.
  ///
  /// In fa, this message translates to:
  /// **'امروز رخ نمی‌دهد.'**
  String get qiblaSunNone;

  /// No description provided for @qiblaSunNowLabel.
  ///
  /// In fa, this message translates to:
  /// **'خورشید اکنون'**
  String get qiblaSunNowLabel;

  /// No description provided for @qiblaSunNowValue.
  ///
  /// In fa, this message translates to:
  /// **'سمت {azimuth}°، ارتفاع {altitude}°'**
  String qiblaSunNowValue(String azimuth, String altitude);

  /// No description provided for @qiblaSunOppHelp.
  ///
  /// In fa, this message translates to:
  /// **'در این لحظه سایه‌ی شاخص جهت قبله را نشان می‌دهد.'**
  String get qiblaSunOppHelp;

  /// No description provided for @qiblaSunOppTitle.
  ///
  /// In fa, this message translates to:
  /// **'خورشید در جهت مخالف قبله (مقابله)'**
  String get qiblaSunOppTitle;

  /// No description provided for @qiblaSunTimesTitle.
  ///
  /// In fa, this message translates to:
  /// **'خورشید و قبله امروز'**
  String get qiblaSunTimesTitle;

  /// No description provided for @qiblaTitle.
  ///
  /// In fa, this message translates to:
  /// **'قبله'**
  String get qiblaTitle;

  /// No description provided for @settingsAboutPlaceholder.
  ///
  /// In fa, this message translates to:
  /// **'نسخه، مجوزها و صفحه‌ی عیب‌یابی در این بخش نمایش داده می‌شود.'**
  String get settingsAboutPlaceholder;

  /// No description provided for @settingsAppAutostart.
  ///
  /// In fa, this message translates to:
  /// **'اجرا با ویندوز'**
  String get settingsAppAutostart;

  /// No description provided for @settingsAppAutostartHelp.
  ///
  /// In fa, this message translates to:
  /// **'برنامه با ورود به ویندوز بی‌سروصدا در کنار ساعت اجرا می‌شود.'**
  String get settingsAppAutostartHelp;

  /// No description provided for @settingsAppCloseToTray.
  ///
  /// In fa, this message translates to:
  /// **'بستن پنجره به کنار ساعت'**
  String get settingsAppCloseToTray;

  /// No description provided for @settingsAppCloseToTrayHelp.
  ///
  /// In fa, this message translates to:
  /// **'با بستن پنجره، برنامه در کنار ساعت ویندوز می‌ماند و اذان پخش می‌شود. اگر خاموش باشد، برنامه بسته می‌شود.'**
  String get settingsAppCloseToTrayHelp;

  /// No description provided for @settingsAppMinimized.
  ///
  /// In fa, this message translates to:
  /// **'شروع در کنار ساعت'**
  String get settingsAppMinimized;

  /// No description provided for @settingsAppMinimizedHelp.
  ///
  /// In fa, this message translates to:
  /// **'هنگام اجرا با ویندوز پنجره باز نمی‌شود.'**
  String get settingsAppMinimizedHelp;

  /// No description provided for @settingsAsrHanafi.
  ///
  /// In fa, this message translates to:
  /// **'حنفی (سایه دو برابر شاخص)'**
  String get settingsAsrHanafi;

  /// No description provided for @settingsAsrStandard.
  ///
  /// In fa, this message translates to:
  /// **'استاندارد (سایه برابر شاخص)'**
  String get settingsAsrStandard;

  /// No description provided for @settingsAzanChoose.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب پرونده…'**
  String get settingsAzanChoose;

  /// No description provided for @settingsAzanEnabled.
  ///
  /// In fa, this message translates to:
  /// **'پخش اذان'**
  String get settingsAzanEnabled;

  /// No description provided for @settingsAzanEnabledHelp.
  ///
  /// In fa, this message translates to:
  /// **'کلید اصلی؛ با خاموش کردن آن هیچ اذانی پخش نمی‌شود.'**
  String get settingsAzanEnabledHelp;

  /// No description provided for @settingsAzanFade.
  ///
  /// In fa, this message translates to:
  /// **'شروع تدریجی صدا'**
  String get settingsAzanFade;

  /// No description provided for @settingsAzanFadeHelp.
  ///
  /// In fa, this message translates to:
  /// **'اذان به آرامی به بلندی کامل می‌رسد.'**
  String get settingsAzanFadeHelp;

  /// No description provided for @settingsAzanMute.
  ///
  /// In fa, this message translates to:
  /// **'بی‌صدا'**
  String get settingsAzanMute;

  /// No description provided for @settingsAzanMuteHelp.
  ///
  /// In fa, this message translates to:
  /// **'اذان را موقتاً بی‌صدا کنید.'**
  String get settingsAzanMuteHelp;

  /// No description provided for @settingsAzanNotMuted.
  ///
  /// In fa, this message translates to:
  /// **'بی‌صدا نیست'**
  String get settingsAzanNotMuted;

  /// No description provided for @settingsAzanPrayerSwitch.
  ///
  /// In fa, this message translates to:
  /// **'اذان {prayer}'**
  String settingsAzanPrayerSwitch(String prayer);

  /// No description provided for @settingsAzanPrayerVolume.
  ///
  /// In fa, this message translates to:
  /// **'بلندی این اذان'**
  String get settingsAzanPrayerVolume;

  /// No description provided for @settingsAzanPreview.
  ///
  /// In fa, this message translates to:
  /// **'پیش‌شنیدن'**
  String get settingsAzanPreview;

  /// No description provided for @settingsAzanSound.
  ///
  /// In fa, this message translates to:
  /// **'صدا'**
  String get settingsAzanSound;

  /// No description provided for @settingsAzanSoundDefault.
  ///
  /// In fa, this message translates to:
  /// **'اذان پیش‌فرض برنامه'**
  String get settingsAzanSoundDefault;

  /// No description provided for @settingsAzanSoundFile.
  ///
  /// In fa, this message translates to:
  /// **'پرونده: {name}'**
  String settingsAzanSoundFile(String name);

  /// No description provided for @settingsAzanUseDefault.
  ///
  /// In fa, this message translates to:
  /// **'استفاده از صدای پیش‌فرض'**
  String get settingsAzanUseDefault;

  /// No description provided for @settingsAzanVolume.
  ///
  /// In fa, this message translates to:
  /// **'بلندی صدا'**
  String get settingsAzanVolume;

  /// No description provided for @settingsAzanVolumeHelp.
  ///
  /// In fa, this message translates to:
  /// **'بلندی کلی همه‌ی اذان‌ها'**
  String get settingsAzanVolumeHelp;

  /// No description provided for @settingsBackupExport.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره‌ی پشتیبان'**
  String get settingsBackupExport;

  /// No description provided for @settingsBackupExportFailed.
  ///
  /// In fa, this message translates to:
  /// **'پشتیبان ذخیره نشد.'**
  String get settingsBackupExportFailed;

  /// No description provided for @settingsBackupExportHelp.
  ///
  /// In fa, this message translates to:
  /// **'همه‌ی تنظیمات، مکان‌ها و بیدارباش‌ها در یک پرونده ذخیره می‌شود.'**
  String get settingsBackupExportHelp;

  /// No description provided for @settingsBackupExported.
  ///
  /// In fa, this message translates to:
  /// **'پشتیبان ذخیره شد: {path}'**
  String settingsBackupExported(String path);

  /// No description provided for @settingsBackupImport.
  ///
  /// In fa, this message translates to:
  /// **'بازیابی از پشتیبان'**
  String get settingsBackupImport;

  /// No description provided for @settingsBackupImportBody.
  ///
  /// In fa, this message translates to:
  /// **'همه‌ی تنظیمات فعلی با محتوای این پرونده جایگزین می‌شود.'**
  String get settingsBackupImportBody;

  /// No description provided for @settingsBackupImportConfirm.
  ///
  /// In fa, this message translates to:
  /// **'بازیابی'**
  String get settingsBackupImportConfirm;

  /// No description provided for @settingsBackupImportHelp.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات را از پرونده‌ی پشتیبان برمی‌گرداند.'**
  String get settingsBackupImportHelp;

  /// No description provided for @settingsBackupImportInvalid.
  ///
  /// In fa, this message translates to:
  /// **'این پرونده پشتیبان تنظیمات معتبر نیست؛ تنظیمات تغییری نکرد.'**
  String get settingsBackupImportInvalid;

  /// No description provided for @settingsBackupImportReadFailed.
  ///
  /// In fa, this message translates to:
  /// **'پرونده خوانده نشد؛ تنظیمات تغییری نکرد.'**
  String get settingsBackupImportReadFailed;

  /// No description provided for @settingsBackupImportTitle.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات بازیابی شود؟'**
  String get settingsBackupImportTitle;

  /// No description provided for @settingsBackupImported.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات بازیابی شد.'**
  String get settingsBackupImported;

  /// No description provided for @settingsBackupTitle.
  ///
  /// In fa, this message translates to:
  /// **'پشتیبان‌گیری و بازیابی'**
  String get settingsBackupTitle;

  /// No description provided for @settingsCalcAngleHelp.
  ///
  /// In fa, this message translates to:
  /// **'زاویه‌ی خورشید زیر افق، به درجه'**
  String get settingsCalcAngleHelp;

  /// No description provided for @settingsCalcAsr.
  ///
  /// In fa, this message translates to:
  /// **'قاعده‌ی عصر'**
  String get settingsCalcAsr;

  /// No description provided for @settingsCalcFajrAngle.
  ///
  /// In fa, this message translates to:
  /// **'زاویه‌ی اذان صبح'**
  String get settingsCalcFajrAngle;

  /// No description provided for @settingsCalcHighLat.
  ///
  /// In fa, this message translates to:
  /// **'عرض‌های جغرافیایی بالا'**
  String get settingsCalcHighLat;

  /// No description provided for @settingsCalcHighLatHelp.
  ///
  /// In fa, this message translates to:
  /// **'برای جاهایی که شب بسیار کوتاه است و زاویه‌ی گرگ‌ومیش به دست نمی‌آید.'**
  String get settingsCalcHighLatHelp;

  /// No description provided for @settingsCalcImsak.
  ///
  /// In fa, this message translates to:
  /// **'امساک'**
  String get settingsCalcImsak;

  /// No description provided for @settingsCalcImsakHelp.
  ///
  /// In fa, this message translates to:
  /// **'چند دقیقه پیش از اذان صبح'**
  String get settingsCalcImsakHelp;

  /// No description provided for @settingsCalcIshaAngle.
  ///
  /// In fa, this message translates to:
  /// **'زاویه‌ی عشا'**
  String get settingsCalcIshaAngle;

  /// No description provided for @settingsCalcIshaMinutes.
  ///
  /// In fa, this message translates to:
  /// **'دقیقه پس از مغرب'**
  String get settingsCalcIshaMinutes;

  /// No description provided for @settingsCalcIshaMode.
  ///
  /// In fa, this message translates to:
  /// **'تعریف عشا'**
  String get settingsCalcIshaMode;

  /// No description provided for @settingsCalcIshaModeAngle.
  ///
  /// In fa, this message translates to:
  /// **'زاویه‌ی خورشید'**
  String get settingsCalcIshaModeAngle;

  /// No description provided for @settingsCalcIshaModeMinutes.
  ///
  /// In fa, this message translates to:
  /// **'دقیقه پس از مغرب'**
  String get settingsCalcIshaModeMinutes;

  /// No description provided for @settingsCalcMaghribAngle.
  ///
  /// In fa, this message translates to:
  /// **'زاویه‌ی مغرب'**
  String get settingsCalcMaghribAngle;

  /// No description provided for @settingsCalcMaghribSunset.
  ///
  /// In fa, this message translates to:
  /// **'مغرب هنگام غروب خورشید'**
  String get settingsCalcMaghribSunset;

  /// No description provided for @settingsCalcMaghribSunsetHelp.
  ///
  /// In fa, this message translates to:
  /// **'اگر خاموش باشد، مغرب با زاویه‌ی زیر محاسبه می‌شود.'**
  String get settingsCalcMaghribSunsetHelp;

  /// No description provided for @settingsCalcMethod.
  ///
  /// In fa, this message translates to:
  /// **'روش محاسبه'**
  String get settingsCalcMethod;

  /// No description provided for @settingsCalcMethodHelp.
  ///
  /// In fa, this message translates to:
  /// **'با تغییر هر زاویه، روش به «دلخواه» تبدیل می‌شود.'**
  String get settingsCalcMethodHelp;

  /// No description provided for @settingsCalcMidnight.
  ///
  /// In fa, this message translates to:
  /// **'نیمه‌شب شرعی'**
  String get settingsCalcMidnight;

  /// No description provided for @settingsCalcOffsetsHelp.
  ///
  /// In fa, this message translates to:
  /// **'هر وقت را تا {max} دقیقه جلو یا عقب ببرید.'**
  String settingsCalcOffsetsHelp(String max);

  /// No description provided for @settingsCalcOffsetsReset.
  ///
  /// In fa, this message translates to:
  /// **'صفر کردن همه'**
  String get settingsCalcOffsetsReset;

  /// No description provided for @settingsCalcOffsetsTitle.
  ///
  /// In fa, this message translates to:
  /// **'تنظیم دقیقه‌ای هر وقت'**
  String get settingsCalcOffsetsTitle;

  /// No description provided for @settingsCalcPreviewHelp.
  ///
  /// In fa, this message translates to:
  /// **'اوقات امروز ({date}) با تنظیمات بالا'**
  String settingsCalcPreviewHelp(String date);

  /// No description provided for @settingsCalcPreviewTitle.
  ///
  /// In fa, this message translates to:
  /// **'پیش‌نمایش زنده'**
  String get settingsCalcPreviewTitle;

  /// No description provided for @settingsCalcRestore.
  ///
  /// In fa, this message translates to:
  /// **'بازگرداندن مقدارهای پیش‌فرض این روش'**
  String get settingsCalcRestore;

  /// No description provided for @settingsCalcRestoreHelp.
  ///
  /// In fa, this message translates to:
  /// **'زاویه‌ها، قاعده‌ها و امساک به مقدار «{method}» برمی‌گردد؛ دقیقه‌های تنظیم‌شده‌ی هر وقت تغییر نمی‌کند.'**
  String settingsCalcRestoreHelp(String method);

  /// No description provided for @settingsCalcRowsHelp.
  ///
  /// In fa, this message translates to:
  /// **'اذان صبح، طلوع آفتاب، اذان ظهر، اذان مغرب و نیمه‌شب شرعی همیشه نمایش داده می‌شوند.'**
  String get settingsCalcRowsHelp;

  /// No description provided for @settingsCalcRowsTitle.
  ///
  /// In fa, this message translates to:
  /// **'ردیف‌های نمایش‌داده‌شده'**
  String get settingsCalcRowsTitle;

  /// No description provided for @settingsCancel.
  ///
  /// In fa, this message translates to:
  /// **'انصراف'**
  String get settingsCancel;

  /// No description provided for @settingsDecrease.
  ///
  /// In fa, this message translates to:
  /// **'کم کردن'**
  String get settingsDecrease;

  /// No description provided for @settingsDigitsLatin.
  ///
  /// In fa, this message translates to:
  /// **'لاتین (123)'**
  String get settingsDigitsLatin;

  /// No description provided for @settingsDigitsPersian.
  ///
  /// In fa, this message translates to:
  /// **'فارسی (۱۲۳)'**
  String get settingsDigitsPersian;

  /// No description provided for @settingsDispDigits.
  ///
  /// In fa, this message translates to:
  /// **'رقم‌ها'**
  String get settingsDispDigits;

  /// No description provided for @settingsDispHijri.
  ///
  /// In fa, this message translates to:
  /// **'تنظیم تاریخ قمری'**
  String get settingsDispHijri;

  /// No description provided for @settingsDispHijriHelp.
  ///
  /// In fa, this message translates to:
  /// **'ایران ماه قمری را با رؤیت هلال تعیین می‌کند؛ اگر تاریخ نمایش‌داده‌شده با اعلام رسمی تفاوت دارد، آن را یک یا دو روز جابه‌جا کنید.'**
  String get settingsDispHijriHelp;

  /// No description provided for @settingsDispHour.
  ///
  /// In fa, this message translates to:
  /// **'ساعت'**
  String get settingsDispHour;

  /// No description provided for @settingsDispLanguage.
  ///
  /// In fa, this message translates to:
  /// **'زبان'**
  String get settingsDispLanguage;

  /// No description provided for @settingsDispLanguageHelp.
  ///
  /// In fa, this message translates to:
  /// **'بدون راه‌اندازی دوباره اعمال می‌شود.'**
  String get settingsDispLanguageHelp;

  /// No description provided for @settingsDispTheme.
  ///
  /// In fa, this message translates to:
  /// **'پوسته'**
  String get settingsDispTheme;

  /// No description provided for @settingsHighLatAngleBased.
  ///
  /// In fa, this message translates to:
  /// **'بر پایه‌ی زاویه'**
  String get settingsHighLatAngleBased;

  /// No description provided for @settingsHighLatNightMiddle.
  ///
  /// In fa, this message translates to:
  /// **'نیمه‌ی شب'**
  String get settingsHighLatNightMiddle;

  /// No description provided for @settingsHighLatNone.
  ///
  /// In fa, this message translates to:
  /// **'بدون تغییر'**
  String get settingsHighLatNone;

  /// No description provided for @settingsHighLatOneSeventh.
  ///
  /// In fa, this message translates to:
  /// **'یک‌هفتم شب'**
  String get settingsHighLatOneSeventh;

  /// No description provided for @settingsHour12.
  ///
  /// In fa, this message translates to:
  /// **'۱۲ ساعته'**
  String get settingsHour12;

  /// No description provided for @settingsHour24.
  ///
  /// In fa, this message translates to:
  /// **'۲۴ ساعته'**
  String get settingsHour24;

  /// No description provided for @settingsIncrease.
  ///
  /// In fa, this message translates to:
  /// **'افزایش'**
  String get settingsIncrease;

  /// No description provided for @settingsInvalidNumber.
  ///
  /// In fa, this message translates to:
  /// **'یک عدد معتبر بین {min} و {max} وارد کنید.'**
  String settingsInvalidNumber(String min, String max);

  /// No description provided for @settingsLanguageEn.
  ///
  /// In fa, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsLanguageFa.
  ///
  /// In fa, this message translates to:
  /// **'فارسی'**
  String get settingsLanguageFa;

  /// No description provided for @settingsLocActive.
  ///
  /// In fa, this message translates to:
  /// **'فعال'**
  String get settingsLocActive;

  /// No description provided for @settingsLocAdd.
  ///
  /// In fa, this message translates to:
  /// **'افزودن'**
  String get settingsLocAdd;

  /// No description provided for @settingsLocAddCustom.
  ///
  /// In fa, this message translates to:
  /// **'مکان دلخواه'**
  String get settingsLocAddCustom;

  /// No description provided for @settingsLocAddFromDb.
  ///
  /// In fa, this message translates to:
  /// **'از فهرست شهرها'**
  String get settingsLocAddFromDb;

  /// No description provided for @settingsLocAddTitle.
  ///
  /// In fa, this message translates to:
  /// **'افزودن مکان'**
  String get settingsLocAddTitle;

  /// No description provided for @settingsLocAdded.
  ///
  /// In fa, this message translates to:
  /// **'{name} اضافه شد.'**
  String settingsLocAdded(String name);

  /// No description provided for @settingsLocAllProvinces.
  ///
  /// In fa, this message translates to:
  /// **'همه‌ی استان‌ها'**
  String get settingsLocAllProvinces;

  /// No description provided for @settingsLocAlreadySaved.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره شده'**
  String get settingsLocAlreadySaved;

  /// No description provided for @settingsLocClose.
  ///
  /// In fa, this message translates to:
  /// **'بستن'**
  String get settingsLocClose;

  /// No description provided for @settingsLocCoords.
  ///
  /// In fa, this message translates to:
  /// **'عرض {lat}، طول {lon}'**
  String settingsLocCoords(String lat, String lon);

  /// No description provided for @settingsLocCustomBadge.
  ///
  /// In fa, this message translates to:
  /// **'دلخواه'**
  String get settingsLocCustomBadge;

  /// No description provided for @settingsLocDegrees.
  ///
  /// In fa, this message translates to:
  /// **'درجه'**
  String get settingsLocDegrees;

  /// No description provided for @settingsLocDelete.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get settingsLocDelete;

  /// No description provided for @settingsLocDeleteBody.
  ///
  /// In fa, this message translates to:
  /// **'این مکان از فهرست شما برداشته می‌شود.'**
  String get settingsLocDeleteBody;

  /// No description provided for @settingsLocDeleteLast.
  ///
  /// In fa, this message translates to:
  /// **'آخرین مکان را نمی‌توان حذف کرد.'**
  String get settingsLocDeleteLast;

  /// No description provided for @settingsLocDeleteTitle.
  ///
  /// In fa, this message translates to:
  /// **'{name} حذف شود؟'**
  String settingsLocDeleteTitle(String name);

  /// No description provided for @settingsLocEast.
  ///
  /// In fa, this message translates to:
  /// **'شرقی'**
  String get settingsLocEast;

  /// No description provided for @settingsLocEdit.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش'**
  String get settingsLocEdit;

  /// No description provided for @settingsLocElevation.
  ///
  /// In fa, this message translates to:
  /// **'ارتفاع از سطح دریا (متر)'**
  String get settingsLocElevation;

  /// No description provided for @settingsLocErrElevation.
  ///
  /// In fa, this message translates to:
  /// **'ارتفاع باید بین {min} و {max} متر باشد.'**
  String settingsLocErrElevation(String min, String max);

  /// No description provided for @settingsLocErrLatitude.
  ///
  /// In fa, this message translates to:
  /// **'عرض جغرافیایی باید عددی بین {min} و {max} باشد.'**
  String settingsLocErrLatitude(String min, String max);

  /// No description provided for @settingsLocErrLongitude.
  ///
  /// In fa, this message translates to:
  /// **'طول جغرافیایی باید عددی بین {min} و {max} باشد.'**
  String settingsLocErrLongitude(String min, String max);

  /// No description provided for @settingsLocErrName.
  ///
  /// In fa, this message translates to:
  /// **'نام را وارد کنید.'**
  String get settingsLocErrName;

  /// No description provided for @settingsLocErrOffset.
  ///
  /// In fa, this message translates to:
  /// **'اختلاف ساعت باید بین {min} و {max} باشد.'**
  String settingsLocErrOffset(String min, String max);

  /// No description provided for @settingsLocErrZone.
  ///
  /// In fa, this message translates to:
  /// **'منطقه‌ی زمانی را از فهرست انتخاب کنید.'**
  String get settingsLocErrZone;

  /// No description provided for @settingsLocFormatDecimal.
  ///
  /// In fa, this message translates to:
  /// **'درجه‌ی اعشاری'**
  String get settingsLocFormatDecimal;

  /// No description provided for @settingsLocFormatDms.
  ///
  /// In fa, this message translates to:
  /// **'درجه، دقیقه، ثانیه'**
  String get settingsLocFormatDms;

  /// No description provided for @settingsLocLatitude.
  ///
  /// In fa, this message translates to:
  /// **'عرض جغرافیایی'**
  String get settingsLocLatitude;

  /// No description provided for @settingsLocLongitude.
  ///
  /// In fa, this message translates to:
  /// **'طول جغرافیایی'**
  String get settingsLocLongitude;

  /// No description provided for @settingsLocMinutes.
  ///
  /// In fa, this message translates to:
  /// **'دقیقه'**
  String get settingsLocMinutes;

  /// No description provided for @settingsLocName.
  ///
  /// In fa, this message translates to:
  /// **'نام'**
  String get settingsLocName;

  /// No description provided for @settingsLocNoResults.
  ///
  /// In fa, this message translates to:
  /// **'شهری پیدا نشد.'**
  String get settingsLocNoResults;

  /// No description provided for @settingsLocNorth.
  ///
  /// In fa, this message translates to:
  /// **'شمالی'**
  String get settingsLocNorth;

  /// No description provided for @settingsLocProvince.
  ///
  /// In fa, this message translates to:
  /// **'استان'**
  String get settingsLocProvince;

  /// No description provided for @settingsLocSave.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره'**
  String get settingsLocSave;

  /// No description provided for @settingsLocSavedHelp.
  ///
  /// In fa, this message translates to:
  /// **'اوقات شرعی برای مکان فعال محاسبه می‌شود.'**
  String get settingsLocSavedHelp;

  /// No description provided for @settingsLocSavedTitle.
  ///
  /// In fa, this message translates to:
  /// **'مکان‌های ذخیره‌شده'**
  String get settingsLocSavedTitle;

  /// No description provided for @settingsLocSearchHint.
  ///
  /// In fa, this message translates to:
  /// **'جستجوی شهر'**
  String get settingsLocSearchHint;

  /// No description provided for @settingsLocSeconds.
  ///
  /// In fa, this message translates to:
  /// **'ثانیه'**
  String get settingsLocSeconds;

  /// No description provided for @settingsLocSetActive.
  ///
  /// In fa, this message translates to:
  /// **'فعال کن'**
  String get settingsLocSetActive;

  /// No description provided for @settingsLocSouth.
  ///
  /// In fa, this message translates to:
  /// **'جنوبی'**
  String get settingsLocSouth;

  /// No description provided for @settingsLocWest.
  ///
  /// In fa, this message translates to:
  /// **'غربی'**
  String get settingsLocWest;

  /// No description provided for @settingsLocZoneNone.
  ///
  /// In fa, this message translates to:
  /// **'منطقه‌ای پیدا نشد.'**
  String get settingsLocZoneNone;

  /// No description provided for @settingsLocZoneSearch.
  ///
  /// In fa, this message translates to:
  /// **'جستجوی منطقه‌ی زمانی'**
  String get settingsLocZoneSearch;

  /// No description provided for @settingsLocZoneSelected.
  ///
  /// In fa, this message translates to:
  /// **'منطقه‌ی زمانی انتخاب‌شده: {zone}'**
  String settingsLocZoneSelected(String zone);

  /// No description provided for @settingsMethodCustom.
  ///
  /// In fa, this message translates to:
  /// **'دلخواه'**
  String get settingsMethodCustom;

  /// No description provided for @settingsMethodEgypt.
  ///
  /// In fa, this message translates to:
  /// **'سازمان نقشه‌برداری مصر'**
  String get settingsMethodEgypt;

  /// No description provided for @settingsMethodIsna.
  ///
  /// In fa, this message translates to:
  /// **'جامعه‌ی اسلامی آمریکای شمالی'**
  String get settingsMethodIsna;

  /// No description provided for @settingsMethodJafari.
  ///
  /// In fa, this message translates to:
  /// **'شیعه اثنی‌عشری، مؤسسه‌ی لوا (قم)'**
  String get settingsMethodJafari;

  /// No description provided for @settingsMethodKarachi.
  ///
  /// In fa, this message translates to:
  /// **'دانشگاه علوم اسلامی کراچی'**
  String get settingsMethodKarachi;

  /// No description provided for @settingsMethodMakkah.
  ///
  /// In fa, this message translates to:
  /// **'دانشگاه ام‌القری، مکه'**
  String get settingsMethodMakkah;

  /// No description provided for @settingsMethodMwl.
  ///
  /// In fa, this message translates to:
  /// **'رابطه‌ی جهان اسلام'**
  String get settingsMethodMwl;

  /// No description provided for @settingsMethodTehran.
  ///
  /// In fa, this message translates to:
  /// **'مؤسسه‌ی ژئوفیزیک دانشگاه تهران'**
  String get settingsMethodTehran;

  /// No description provided for @settingsMidnightJafari.
  ///
  /// In fa, this message translates to:
  /// **'میانه‌ی غروب تا اذان صبح'**
  String get settingsMidnightJafari;

  /// No description provided for @settingsMidnightStandard.
  ///
  /// In fa, this message translates to:
  /// **'میانه‌ی غروب تا طلوع'**
  String get settingsMidnightStandard;

  /// No description provided for @settingsOff.
  ///
  /// In fa, this message translates to:
  /// **'خاموش'**
  String get settingsOff;

  /// No description provided for @settingsPercent.
  ///
  /// In fa, this message translates to:
  /// **'{value}٪'**
  String settingsPercent(String value);

  /// No description provided for @settingsRemChime.
  ///
  /// In fa, this message translates to:
  /// **'صدای ملایم یادآوری'**
  String get settingsRemChime;

  /// No description provided for @settingsRemChimeHelp.
  ///
  /// In fa, this message translates to:
  /// **'همراه اعلان یادآوری یک زنگ آرام پخش می‌شود.'**
  String get settingsRemChimeHelp;

  /// No description provided for @settingsRemChimeTest.
  ///
  /// In fa, this message translates to:
  /// **'پخش نمونه'**
  String get settingsRemChimeTest;

  /// No description provided for @settingsRemHelp.
  ///
  /// In fa, this message translates to:
  /// **'۰ یعنی خاموش؛ تا {max} دقیقه پیش از اذان.'**
  String settingsRemHelp(String max);

  /// No description provided for @settingsRemIndependent.
  ///
  /// In fa, this message translates to:
  /// **'خاموش کردن یادآوری هرگز روی اذان اثر نمی‌گذارد.'**
  String get settingsRemIndependent;

  /// No description provided for @settingsRemSummary.
  ///
  /// In fa, this message translates to:
  /// **'{minutes} دقیقه پیش از اذان'**
  String settingsRemSummary(String minutes);

  /// No description provided for @settingsRemTitle.
  ///
  /// In fa, this message translates to:
  /// **'یادآوری پیش از {prayer}'**
  String settingsRemTitle(String prayer);

  /// No description provided for @settingsResetConfirm.
  ///
  /// In fa, this message translates to:
  /// **'پاک کردن'**
  String get settingsResetConfirm;

  /// No description provided for @settingsResetConfirmBody.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات به حالت اولیه برمی‌گردد و مکان فعال تهران می‌شود. این کار برگشت‌پذیر نیست.'**
  String get settingsResetConfirmBody;

  /// No description provided for @settingsResetConfirmTitle.
  ///
  /// In fa, this message translates to:
  /// **'همه‌ی تنظیمات پاک شود؟'**
  String get settingsResetConfirmTitle;

  /// No description provided for @settingsResetDone.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات به حالت اولیه برگشت.'**
  String get settingsResetDone;

  /// No description provided for @settingsResetHelp.
  ///
  /// In fa, this message translates to:
  /// **'همه‌ی تنظیمات، مکان‌های ذخیره‌شده و بیدارباش‌ها پاک می‌شود.'**
  String get settingsResetHelp;

  /// No description provided for @settingsResetTitle.
  ///
  /// In fa, this message translates to:
  /// **'بازگشت به تنظیمات اولیه'**
  String get settingsResetTitle;

  /// No description provided for @settingsSaved.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره شد'**
  String get settingsSaved;

  /// No description provided for @settingsSectionAbout.
  ///
  /// In fa, this message translates to:
  /// **'درباره و عیب‌یابی'**
  String get settingsSectionAbout;

  /// No description provided for @settingsSectionApp.
  ///
  /// In fa, this message translates to:
  /// **'برنامه'**
  String get settingsSectionApp;

  /// No description provided for @settingsSectionAzan.
  ///
  /// In fa, this message translates to:
  /// **'اذان'**
  String get settingsSectionAzan;

  /// No description provided for @settingsSectionCalculation.
  ///
  /// In fa, this message translates to:
  /// **'محاسبه'**
  String get settingsSectionCalculation;

  /// No description provided for @settingsSectionDisplay.
  ///
  /// In fa, this message translates to:
  /// **'نمایش'**
  String get settingsSectionDisplay;

  /// No description provided for @settingsSectionLocation.
  ///
  /// In fa, this message translates to:
  /// **'مکان'**
  String get settingsSectionLocation;

  /// No description provided for @settingsSectionReminders.
  ///
  /// In fa, this message translates to:
  /// **'یادآوری'**
  String get settingsSectionReminders;

  /// No description provided for @settingsSectionTime.
  ///
  /// In fa, this message translates to:
  /// **'زمان'**
  String get settingsSectionTime;

  /// No description provided for @settingsSectionsLabel.
  ///
  /// In fa, this message translates to:
  /// **'بخش‌های تنظیمات'**
  String get settingsSectionsLabel;

  /// No description provided for @settingsThemeDark.
  ///
  /// In fa, this message translates to:
  /// **'تیره'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeLight.
  ///
  /// In fa, this message translates to:
  /// **'روشن'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In fa, this message translates to:
  /// **'مطابق ویندوز'**
  String get settingsThemeSystem;

  /// No description provided for @settingsTimeCheck.
  ///
  /// In fa, this message translates to:
  /// **'بررسی ساعت با زمان شبکه'**
  String get settingsTimeCheck;

  /// No description provided for @settingsTimeCheckHelp.
  ///
  /// In fa, this message translates to:
  /// **'هنگام شروع برنامه و هر شش ساعت یک بار؛ پیش‌فرض خاموش است.'**
  String get settingsTimeCheckHelp;

  /// No description provided for @settingsTimeCheckNow.
  ///
  /// In fa, this message translates to:
  /// **'اکنون بررسی کن'**
  String get settingsTimeCheckNow;

  /// No description provided for @settingsTimeCheckedAt.
  ///
  /// In fa, this message translates to:
  /// **'بررسی در ساعت {time}'**
  String settingsTimeCheckedAt(String time);

  /// No description provided for @settingsTimeChecking.
  ///
  /// In fa, this message translates to:
  /// **'در حال بررسی…'**
  String get settingsTimeChecking;

  /// No description provided for @settingsTimeCorrect.
  ///
  /// In fa, this message translates to:
  /// **'اصلاح ساعت در برنامه'**
  String get settingsTimeCorrect;

  /// No description provided for @settingsTimeCorrectHelp.
  ///
  /// In fa, this message translates to:
  /// **'ساعت ویندوز هرگز تغییر نمی‌کند.'**
  String get settingsTimeCorrectHelp;

  /// No description provided for @settingsTimeDiagLocation.
  ///
  /// In fa, this message translates to:
  /// **'اختلاف مکان فعال طبق پایگاه‌داده: {offset}'**
  String settingsTimeDiagLocation(String offset);

  /// No description provided for @settingsTimeDiagOk.
  ///
  /// In fa, this message translates to:
  /// **'مشکلی در ساعت دیده نشد.'**
  String get settingsTimeDiagOk;

  /// No description provided for @settingsTimeDiagTitle.
  ///
  /// In fa, this message translates to:
  /// **'عیب‌یابی ساعت'**
  String get settingsTimeDiagTitle;

  /// No description provided for @settingsTimeDiagWindows.
  ///
  /// In fa, this message translates to:
  /// **'اختلاف ساعت ویندوز با زمان جهانی: {offset}'**
  String settingsTimeDiagWindows(String offset);

  /// No description provided for @settingsTimeError.
  ///
  /// In fa, this message translates to:
  /// **'اتصال به کارساز زمان ممکن نشد. اینترنت و نام کارساز را بررسی کنید.'**
  String get settingsTimeError;

  /// No description provided for @settingsTimeNever.
  ///
  /// In fa, this message translates to:
  /// **'هنوز بررسی نشده است.'**
  String get settingsTimeNever;

  /// No description provided for @settingsTimeServer.
  ///
  /// In fa, this message translates to:
  /// **'کارساز زمان'**
  String get settingsTimeServer;

  /// No description provided for @settingsTimeServerHelp.
  ///
  /// In fa, this message translates to:
  /// **'نام کارساز زمان، مثلاً pool.ntp.org'**
  String get settingsTimeServerHelp;

  /// No description provided for @settingsTimeServerInvalid.
  ///
  /// In fa, this message translates to:
  /// **'نام کارساز معتبر نیست.'**
  String get settingsTimeServerInvalid;

  /// No description provided for @settingsTimeSkewAhead.
  ///
  /// In fa, this message translates to:
  /// **'ساعت رایانه {amount} جلو است.'**
  String settingsTimeSkewAhead(String amount);

  /// No description provided for @settingsTimeSkewBehind.
  ///
  /// In fa, this message translates to:
  /// **'ساعت رایانه {amount} عقب است.'**
  String settingsTimeSkewBehind(String amount);

  /// No description provided for @settingsTimeSkewZero.
  ///
  /// In fa, this message translates to:
  /// **'ساعت رایانه با زمان شبکه یکی است.'**
  String get settingsTimeSkewZero;

  /// No description provided for @settingsTimeStatusTitle.
  ///
  /// In fa, this message translates to:
  /// **'آخرین بررسی'**
  String get settingsTimeStatusTitle;

  /// No description provided for @settingsZoneAuto.
  ///
  /// In fa, this message translates to:
  /// **'خودکار (پیشنهادی)'**
  String get settingsZoneAuto;

  /// No description provided for @settingsZoneAutoHelp.
  ///
  /// In fa, this message translates to:
  /// **'از پایگاه‌داده‌ی منطقه‌های زمانی برنامه استفاده می‌شود: {zone}'**
  String settingsZoneAutoHelp(String zone);

  /// No description provided for @settingsZoneFixed.
  ///
  /// In fa, this message translates to:
  /// **'اختلاف ثابت'**
  String get settingsZoneFixed;

  /// No description provided for @settingsZoneFixedAllYear.
  ///
  /// In fa, this message translates to:
  /// **'اختلاف ثابت است و در همه‌ی روزهای سال یکسان می‌ماند.'**
  String get settingsZoneFixedAllYear;

  /// No description provided for @settingsZoneFixedHelp.
  ///
  /// In fa, this message translates to:
  /// **'یک اختلاف ثابت با زمان جهانی که در همه‌ی روزهای سال یکسان است.'**
  String get settingsZoneFixedHelp;

  /// No description provided for @settingsZoneFixedValue.
  ///
  /// In fa, this message translates to:
  /// **'اختلاف ثابت: {offset}'**
  String settingsZoneFixedValue(String offset);

  /// No description provided for @settingsZoneHourLess.
  ///
  /// In fa, this message translates to:
  /// **'یک ساعت کمتر'**
  String get settingsZoneHourLess;

  /// No description provided for @settingsZoneHourMore.
  ///
  /// In fa, this message translates to:
  /// **'یک ساعت بیشتر'**
  String get settingsZoneHourMore;

  /// No description provided for @settingsZoneNext.
  ///
  /// In fa, this message translates to:
  /// **'تغییر بعدی: {date}، ساعت {time}، اختلاف {offset}'**
  String settingsZoneNext(String date, String time, String offset);

  /// No description provided for @settingsZoneNoChange.
  ///
  /// In fa, this message translates to:
  /// **'تغییر دیگری برای این منطقه‌ی زمانی برنامه‌ریزی نشده است.'**
  String get settingsZoneNoChange;

  /// No description provided for @settingsZoneNow.
  ///
  /// In fa, this message translates to:
  /// **'اختلاف با زمان جهانی در امروز: {offset}'**
  String settingsZoneNow(String offset);

  /// No description provided for @settingsZoneQuarterLess.
  ///
  /// In fa, this message translates to:
  /// **'یک ربع ساعت کمتر'**
  String get settingsZoneQuarterLess;

  /// No description provided for @settingsZoneQuarterMore.
  ///
  /// In fa, this message translates to:
  /// **'یک ربع ساعت بیشتر'**
  String get settingsZoneQuarterMore;

  /// No description provided for @settingsZoneTitle.
  ///
  /// In fa, this message translates to:
  /// **'منطقه‌ی زمانی'**
  String get settingsZoneTitle;

  /// No description provided for @timetableCalendarSwitch.
  ///
  /// In fa, this message translates to:
  /// **'نوع تقویم'**
  String get timetableCalendarSwitch;

  /// No description provided for @timetableColDay.
  ///
  /// In fa, this message translates to:
  /// **'روز'**
  String get timetableColDay;

  /// No description provided for @timetableColWeekday.
  ///
  /// In fa, this message translates to:
  /// **'روز هفته'**
  String get timetableColWeekday;

  /// No description provided for @timetableMonthUnavailable.
  ///
  /// In fa, this message translates to:
  /// **'این ماه در جدول تقویم قمری نیست.'**
  String get timetableMonthUnavailable;

  /// No description provided for @timetableNextMonth.
  ///
  /// In fa, this message translates to:
  /// **'ماه بعد'**
  String get timetableNextMonth;

  /// No description provided for @timetableOpenDay.
  ///
  /// In fa, this message translates to:
  /// **'نمایش {date} در صفحه‌ی خانه'**
  String timetableOpenDay(String date);

  /// No description provided for @timetablePreviousMonth.
  ///
  /// In fa, this message translates to:
  /// **'ماه قبل'**
  String get timetablePreviousMonth;

  /// No description provided for @timetableToday.
  ///
  /// In fa, this message translates to:
  /// **'امروز'**
  String get timetableToday;

  /// No description provided for @trayMenuLocation.
  ///
  /// In fa, this message translates to:
  /// **'مکان'**
  String get trayMenuLocation;

  /// No description provided for @trayMenuMute.
  ///
  /// In fa, this message translates to:
  /// **'بی‌صدا'**
  String get trayMenuMute;

  /// No description provided for @trayMenuMuted.
  ///
  /// In fa, this message translates to:
  /// **'بی‌صدا (فعال)'**
  String get trayMenuMuted;

  /// No description provided for @trayMenuQuit.
  ///
  /// In fa, this message translates to:
  /// **'خروج'**
  String get trayMenuQuit;

  /// No description provided for @trayMenuSettings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get trayMenuSettings;

  /// No description provided for @trayMenuShow.
  ///
  /// In fa, this message translates to:
  /// **'نمایش پنجره'**
  String get trayMenuShow;

  /// No description provided for @trayMenuStopAzan.
  ///
  /// In fa, this message translates to:
  /// **'توقف اذان'**
  String get trayMenuStopAzan;

  /// No description provided for @trayMuteCancel.
  ///
  /// In fa, this message translates to:
  /// **'لغو بی‌صدا'**
  String get trayMuteCancel;

  /// No description provided for @trayMuteHours.
  ///
  /// In fa, this message translates to:
  /// **'{n} ساعت'**
  String trayMuteHours(String n);

  /// No description provided for @trayMuteIndefinite.
  ///
  /// In fa, this message translates to:
  /// **'تا اطلاع ثانوی'**
  String get trayMuteIndefinite;

  /// No description provided for @trayMuteUntilNext.
  ///
  /// In fa, this message translates to:
  /// **'تا اذان بعدی'**
  String get trayMuteUntilNext;

  /// No description provided for @trayNextLine.
  ///
  /// In fa, this message translates to:
  /// **'بعدی: {prayer} · {time}'**
  String trayNextLine(String prayer, String time);

  /// No description provided for @trayTimeRow.
  ///
  /// In fa, this message translates to:
  /// **'{prayer}   {time}'**
  String trayTimeRow(String prayer, String time);

  /// No description provided for @trayTooltip.
  ///
  /// In fa, this message translates to:
  /// **'{prayer} {time} · {remaining}'**
  String trayTooltip(String prayer, String time, String remaining);

  /// No description provided for @wakeAdd.
  ///
  /// In fa, this message translates to:
  /// **'افزودن'**
  String get wakeAdd;

  /// No description provided for @wakeAfterHibernate.
  ///
  /// In fa, this message translates to:
  /// **'پس از صدا: خواب زمستانی'**
  String get wakeAfterHibernate;

  /// No description provided for @wakeAfterHibernateChoice.
  ///
  /// In fa, this message translates to:
  /// **'خواب زمستانی'**
  String get wakeAfterHibernateChoice;

  /// No description provided for @wakeAfterNote.
  ///
  /// In fa, this message translates to:
  /// **'پیش از خواب یا خواب زمستانی، یک شمارش معکوس سی‌ثانیه‌ای فرصت لغو می‌دهد.'**
  String get wakeAfterNote;

  /// No description provided for @wakeAfterNothing.
  ///
  /// In fa, this message translates to:
  /// **'کاری نکن'**
  String get wakeAfterNothing;

  /// No description provided for @wakeAfterSleep.
  ///
  /// In fa, this message translates to:
  /// **'پس از صدا: خواب'**
  String get wakeAfterSleep;

  /// No description provided for @wakeAfterSleepChoice.
  ///
  /// In fa, this message translates to:
  /// **'خواب'**
  String get wakeAfterSleepChoice;

  /// No description provided for @wakeAfterTitle.
  ///
  /// In fa, this message translates to:
  /// **'پس از پایان صدا'**
  String get wakeAfterTitle;

  /// No description provided for @wakeCancel.
  ///
  /// In fa, this message translates to:
  /// **'انصراف'**
  String get wakeCancel;

  /// No description provided for @wakeCapabilityChecking.
  ///
  /// In fa, this message translates to:
  /// **'در حال بررسی این رایانه…'**
  String get wakeCapabilityChecking;

  /// No description provided for @wakeCapabilityOkBody.
  ///
  /// In fa, this message translates to:
  /// **'بررسی مانعی پیدا نکرد. برای اطمینان، آزمایش دو دقیقه‌ای را اجرا کنید.'**
  String get wakeCapabilityOkBody;

  /// No description provided for @wakeCapabilityOkTitle.
  ///
  /// In fa, this message translates to:
  /// **'این رایانه می‌تواند خودش را بیدار کند'**
  String get wakeCapabilityOkTitle;

  /// No description provided for @wakeCapabilityRefresh.
  ///
  /// In fa, this message translates to:
  /// **'بررسی دوباره'**
  String get wakeCapabilityRefresh;

  /// No description provided for @wakeCapabilityUnknown.
  ///
  /// In fa, this message translates to:
  /// **'هنوز بررسی نشده است.'**
  String get wakeCapabilityUnknown;

  /// No description provided for @wakeCapabilityWarnTitle.
  ///
  /// In fa, this message translates to:
  /// **'ممکن است این رایانه برای بیدارباش بیدار نشود'**
  String get wakeCapabilityWarnTitle;

  /// No description provided for @wakeChoiceFixed.
  ///
  /// In fa, this message translates to:
  /// **'ساعت معین'**
  String get wakeChoiceFixed;

  /// No description provided for @wakeChoiceRelative.
  ///
  /// In fa, this message translates to:
  /// **'قبل از یک نماز'**
  String get wakeChoiceRelative;

  /// No description provided for @wakeChooseFile.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب فایل…'**
  String get wakeChooseFile;

  /// No description provided for @wakeCountdownAfterAlarm.
  ///
  /// In fa, this message translates to:
  /// **'بیدارباش تمام شد.'**
  String get wakeCountdownAfterAlarm;

  /// No description provided for @wakeCountdownCancel.
  ///
  /// In fa, this message translates to:
  /// **'لغو'**
  String get wakeCountdownCancel;

  /// No description provided for @wakeCountdownHibernate.
  ///
  /// In fa, this message translates to:
  /// **'رایانه تا {time} دیگر به خواب زمستانی می‌رود.'**
  String wakeCountdownHibernate(String time);

  /// No description provided for @wakeCountdownSleep.
  ///
  /// In fa, this message translates to:
  /// **'رایانه تا {time} دیگر به خواب می‌رود.'**
  String wakeCountdownSleep(String time);

  /// No description provided for @wakeDelete.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get wakeDelete;

  /// No description provided for @wakeDeleteBody.
  ///
  /// In fa, this message translates to:
  /// **'بیدارباش و درخواست بیدار شدن آن از ویندوز برداشته می‌شود.'**
  String get wakeDeleteBody;

  /// No description provided for @wakeDeleteConfirm.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get wakeDeleteConfirm;

  /// No description provided for @wakeDeleteTitle.
  ///
  /// In fa, this message translates to:
  /// **'این بیدارباش حذف شود؟'**
  String get wakeDeleteTitle;

  /// No description provided for @wakeDismiss.
  ///
  /// In fa, this message translates to:
  /// **'بستن'**
  String get wakeDismiss;

  /// No description provided for @wakeEdit.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش'**
  String get wakeEdit;

  /// No description provided for @wakeEditorTitleAdd.
  ///
  /// In fa, this message translates to:
  /// **'بیدارباش جدید'**
  String get wakeEditorTitleAdd;

  /// No description provided for @wakeEditorTitleEdit.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش بیدارباش'**
  String get wakeEditorTitleEdit;

  /// No description provided for @wakeEmpty.
  ///
  /// In fa, this message translates to:
  /// **'هنوز بیدارباشی نساخته‌اید. یکی اضافه کنید تا رایانه در ساعت دلخواه بیدار شود.'**
  String get wakeEmpty;

  /// No description provided for @wakeEnabledSwitch.
  ///
  /// In fa, this message translates to:
  /// **'روشن'**
  String get wakeEnabledSwitch;

  /// No description provided for @wakeErrorMinutes.
  ///
  /// In fa, this message translates to:
  /// **'عددی صحیح بین {min} تا {max} بنویسید.'**
  String wakeErrorMinutes(String min, String max);

  /// No description provided for @wakeFieldHour.
  ///
  /// In fa, this message translates to:
  /// **'ساعت'**
  String get wakeFieldHour;

  /// No description provided for @wakeFieldLabel.
  ///
  /// In fa, this message translates to:
  /// **'نام (اختیاری)'**
  String get wakeFieldLabel;

  /// No description provided for @wakeFieldMinute.
  ///
  /// In fa, this message translates to:
  /// **'دقیقه'**
  String get wakeFieldMinute;

  /// No description provided for @wakeFieldMinutesBefore.
  ///
  /// In fa, this message translates to:
  /// **'چند دقیقه قبل'**
  String get wakeFieldMinutesBefore;

  /// No description provided for @wakeFieldPrayer.
  ///
  /// In fa, this message translates to:
  /// **'وقت'**
  String get wakeFieldPrayer;

  /// No description provided for @wakeHibernateNow.
  ///
  /// In fa, this message translates to:
  /// **'خواب زمستانی'**
  String get wakeHibernateNow;

  /// No description provided for @wakeIssueImportantOnly.
  ///
  /// In fa, this message translates to:
  /// **'ویندوز فقط تایمرهای «مهم» را اجازه می‌دهد که معمولاً شامل این برنامه نیست.'**
  String get wakeIssueImportantOnly;

  /// No description provided for @wakeIssueInProcessTimer.
  ///
  /// In fa, this message translates to:
  /// **'تایمر پشتیبان داخل برنامه ساخته نشد.'**
  String get wakeIssueInProcessTimer;

  /// No description provided for @wakeIssueModernStandby.
  ///
  /// In fa, this message translates to:
  /// **'این رایانه از حالت «آماده‌به‌کار مدرن» استفاده می‌کند که بیدار شدن در ساعت معین در آن اغلب نامطمئن است.'**
  String get wakeIssueModernStandby;

  /// No description provided for @wakeIssueTaskCreationFailed.
  ///
  /// In fa, this message translates to:
  /// **'ویندوز اجازه‌ی ساختن وظیفه‌ی زمان‌بندی‌شده برای حساب شما را نداد؛ بیدارباش فقط تا وقتی برنامه باز است کار می‌کند.'**
  String get wakeIssueTaskCreationFailed;

  /// No description provided for @wakeIssueTimersOffAc.
  ///
  /// In fa, this message translates to:
  /// **'ویندوز هنگام اتصال به برق، تایمرهای بیدارکننده را خاموش کرده است.'**
  String get wakeIssueTimersOffAc;

  /// No description provided for @wakeIssueTimersOffBattery.
  ///
  /// In fa, this message translates to:
  /// **'ویندوز هنگام کار با باتری، تایمرهای بیدارکننده را خاموش کرده است.'**
  String get wakeIssueTimersOffBattery;

  /// No description provided for @wakeIssueUnknown.
  ///
  /// In fa, this message translates to:
  /// **'تنظیم تایمرهای بیدارکننده‌ی ویندوز خوانده نشد.'**
  String get wakeIssueUnknown;

  /// No description provided for @wakeListSeparator.
  ///
  /// In fa, this message translates to:
  /// **'، '**
  String get wakeListSeparator;

  /// No description provided for @wakeNext.
  ///
  /// In fa, this message translates to:
  /// **'بعدی: {remaining} ({time})'**
  String wakeNext(String remaining, String time);

  /// No description provided for @wakeNextNone.
  ///
  /// In fa, this message translates to:
  /// **'بعدی: —'**
  String get wakeNextNone;

  /// No description provided for @wakeNextOtherDay.
  ///
  /// In fa, this message translates to:
  /// **'بعدی: {remaining} ({weekday} {time})'**
  String wakeNextOtherDay(String remaining, String weekday, String time);

  /// No description provided for @wakeOff.
  ///
  /// In fa, this message translates to:
  /// **'خاموش'**
  String get wakeOff;

  /// No description provided for @wakeOpenPowerFailed.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات برق باز نشد. از «کنترل پنل ← گزینه‌های برق» خودتان آن را باز کنید.'**
  String get wakeOpenPowerFailed;

  /// No description provided for @wakeOpenPowerOptions.
  ///
  /// In fa, this message translates to:
  /// **'باز کردن تنظیمات برق ویندوز'**
  String get wakeOpenPowerOptions;

  /// No description provided for @wakePercent.
  ///
  /// In fa, this message translates to:
  /// **'{percent}٪'**
  String wakePercent(String percent);

  /// No description provided for @wakePlaySound.
  ///
  /// In fa, this message translates to:
  /// **'پخش صدا'**
  String get wakePlaySound;

  /// No description provided for @wakePowerHint.
  ///
  /// In fa, this message translates to:
  /// **'در ویندوز: گزینه‌های برق ← تغییر تنظیمات طرح ← تنظیمات پیشرفته ← خواب ← اجازه‌ی تایمرهای بیدارکننده. برنامه هیچ تنظیم برقی را خودش تغییر نمی‌دهد.'**
  String get wakePowerHint;

  /// No description provided for @wakePreview.
  ///
  /// In fa, this message translates to:
  /// **'پیش‌شنود'**
  String get wakePreview;

  /// No description provided for @wakePreviewStop.
  ///
  /// In fa, this message translates to:
  /// **'توقف پیش‌شنود'**
  String get wakePreviewStop;

  /// No description provided for @wakeProblemHibernateUnavailable.
  ///
  /// In fa, this message translates to:
  /// **'خواب زمستانی در این رایانه روشن نیست.'**
  String get wakeProblemHibernateUnavailable;

  /// No description provided for @wakeProblemProbeFailed.
  ///
  /// In fa, this message translates to:
  /// **'بررسی این رایانه کامل نشد.'**
  String get wakeProblemProbeFailed;

  /// No description provided for @wakeProblemSoundFailed.
  ///
  /// In fa, this message translates to:
  /// **'صدای بیدارباش پخش نشد. فایل صدا و بلندگو را بررسی کنید.'**
  String get wakeProblemSoundFailed;

  /// No description provided for @wakeProblemSuspendRefused.
  ///
  /// In fa, this message translates to:
  /// **'ویندوز اجازه‌ی خواب نداد.'**
  String get wakeProblemSuspendRefused;

  /// No description provided for @wakeRepeatDaily.
  ///
  /// In fa, this message translates to:
  /// **'هر روز'**
  String get wakeRepeatDaily;

  /// No description provided for @wakeRepeatOnce.
  ///
  /// In fa, this message translates to:
  /// **'یک بار'**
  String get wakeRepeatOnce;

  /// No description provided for @wakeRepeatTitle.
  ///
  /// In fa, this message translates to:
  /// **'تکرار'**
  String get wakeRepeatTitle;

  /// No description provided for @wakeRepeatWeekdays.
  ///
  /// In fa, this message translates to:
  /// **'در روزهای {days}'**
  String wakeRepeatWeekdays(String days);

  /// No description provided for @wakeRepeatWeekdaysChoice.
  ///
  /// In fa, this message translates to:
  /// **'روزهای انتخابی'**
  String get wakeRepeatWeekdaysChoice;

  /// No description provided for @wakeRinging.
  ///
  /// In fa, this message translates to:
  /// **'بیدارباش در حال پخش است'**
  String get wakeRinging;

  /// No description provided for @wakeSave.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره'**
  String get wakeSave;

  /// No description provided for @wakeSaveFailed.
  ///
  /// In fa, this message translates to:
  /// **'این مقادیر ذخیره نشد. ساعت و روزها را بررسی کنید.'**
  String get wakeSaveFailed;

  /// No description provided for @wakeSleepHint.
  ///
  /// In fa, this message translates to:
  /// **'رایانه پس از یک شمارش معکوس پنج‌ثانیه‌ای که می‌توانید لغو کنید، می‌خوابد.'**
  String get wakeSleepHint;

  /// No description provided for @wakeSleepNow.
  ///
  /// In fa, this message translates to:
  /// **'خواب'**
  String get wakeSleepNow;

  /// No description provided for @wakeSoundDefault.
  ///
  /// In fa, this message translates to:
  /// **'صدای پیش‌فرض اذان'**
  String get wakeSoundDefault;

  /// No description provided for @wakeSoundFile.
  ///
  /// In fa, this message translates to:
  /// **'فایل: {name}'**
  String wakeSoundFile(String name);

  /// No description provided for @wakeSoundTitle.
  ///
  /// In fa, this message translates to:
  /// **'صدا'**
  String get wakeSoundTitle;

  /// No description provided for @wakeStop.
  ///
  /// In fa, this message translates to:
  /// **'توقف'**
  String get wakeStop;

  /// No description provided for @wakeSyncError.
  ///
  /// In fa, this message translates to:
  /// **'درخواست بیدار شدن به ویندوز ثبت نشد؛ بیدارباش ممکن است فقط تا وقتی برنامه باز است کار کند.'**
  String get wakeSyncError;

  /// No description provided for @wakeTest.
  ///
  /// In fa, this message translates to:
  /// **'آزمایش در دو دقیقه'**
  String get wakeTest;

  /// No description provided for @wakeTestCancel.
  ///
  /// In fa, this message translates to:
  /// **'لغو آزمایش'**
  String get wakeTestCancel;

  /// No description provided for @wakeTestPending.
  ///
  /// In fa, this message translates to:
  /// **'بیدارباش آزمایشی ساعت {time} زنگ می‌زند. حالا رایانه را بخوابانید تا ببینید بیدار می‌شود.'**
  String wakeTestPending(String time);

  /// No description provided for @wakeTitle.
  ///
  /// In fa, this message translates to:
  /// **'بیدارباش'**
  String get wakeTitle;

  /// No description provided for @wakeTriggerAtPrayer.
  ///
  /// In fa, this message translates to:
  /// **'هنگام {prayer}'**
  String wakeTriggerAtPrayer(String prayer);

  /// No description provided for @wakeTriggerFixed.
  ///
  /// In fa, this message translates to:
  /// **'ساعت {time}'**
  String wakeTriggerFixed(String time);

  /// No description provided for @wakeTriggerRelative.
  ///
  /// In fa, this message translates to:
  /// **'{minutes} قبل از {prayer}'**
  String wakeTriggerRelative(String minutes, String prayer);

  /// No description provided for @wakeTriggerTypeTitle.
  ///
  /// In fa, this message translates to:
  /// **'زمان'**
  String get wakeTriggerTypeTitle;

  /// No description provided for @wakeUseDefault.
  ///
  /// In fa, this message translates to:
  /// **'صدای پیش‌فرض'**
  String get wakeUseDefault;

  /// No description provided for @wakeVolume.
  ///
  /// In fa, this message translates to:
  /// **'بلندی صدا'**
  String get wakeVolume;

  /// No description provided for @wakeWeekdaysError.
  ///
  /// In fa, this message translates to:
  /// **'دست‌کم یک روز را انتخاب کنید.'**
  String get wakeWeekdaysError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
