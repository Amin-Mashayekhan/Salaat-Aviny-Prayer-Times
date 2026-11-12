// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get aboutAuthorIntro =>
      'این برنامه را یک توسعه‌دهنده‌ی مستقل می‌سازد و نگهداری می‌کند. برای گزارش مشکل، پیشنهاد یا همکاری با من در تماس باشید.';

  @override
  String get aboutAuthorTitle => 'درباره‌ی سازنده';

  @override
  String get aboutContactEmail => 'ایمیل';

  @override
  String get aboutContactGithub => 'GitHub';

  @override
  String get aboutContactName => 'نام';

  @override
  String get aboutContactPhone => 'موبایل';

  @override
  String get aboutContactTelegram => 'تلگرام';

  @override
  String get aboutCopiedValue => 'کپی شد.';

  @override
  String get aboutCopy => 'کپی';

  @override
  String get aboutFontNote =>
      'قلم وزیرمتن با مجوز SIL Open Font License 1.1 همراه برنامه است.';

  @override
  String get aboutLicenceNote =>
      'این برنامه با مجوز MIT منتشر شده است: می‌توانید آزادانه از آن استفاده کنید، آن را تغییر دهید و پخش کنید.';

  @override
  String get aboutLicences => 'مجوزهای نرم‌افزارهای متن‌باز';

  @override
  String get aboutOpen => 'باز کردن';

  @override
  String get aboutOpenFailed =>
      'باز نشد. نشانی را کپی کنید و در مرورگر یا برنامه‌ی ایمیل خود بگذارید.';

  @override
  String get aboutPhoneNote =>
      'تماس و پیامک فقط از داخل ایران. از خارج از ایران فقط تلگرام.';

  @override
  String get aboutSoundNote =>
      'صداهای همراه برنامه (اذان پیش‌فرض و زنگ یادآوری) نمونه‌هایی ساده و ساختگی‌اند، ضبط هیچ مؤذنی نیستند و با مجوز CC0 منتشر شده‌اند. صدای اذان دلخواه خود را از بخش تنظیمات انتخاب کنید.';

  @override
  String get aboutTagline =>
      'اوقات شرعی و اذان برای ویندوز؛ بدون اینترنت، بدون تبلیغ، بدون حساب کاربری و بدون ردیابی.';

  @override
  String get aboutTitle => 'درباره';

  @override
  String aboutVersion(String version) {
    return 'نسخه‌ی $version';
  }

  @override
  String get appName => 'Salaat | Aviny Prayer Times';

  @override
  String get calendarAdjustEarlier => 'یک روز زودتر';

  @override
  String get calendarAdjustLater => 'یک روز دیرتر';

  @override
  String calendarAdjustValue(String value) {
    return '$value روز';
  }

  @override
  String calendarConvErrDay(String first, String days) {
    return 'روز باید از $first تا $days باشد.';
  }

  @override
  String get calendarConvErrIncomplete => 'سال، ماه و روز را کامل کنید.';

  @override
  String get calendarConvErrMonth => 'ماه باید از یک تا دوازده باشد.';

  @override
  String get calendarConvErrNumber => 'فقط عدد بنویسید.';

  @override
  String get calendarConvErrRange =>
      'این تاریخ بیرون از بازه‌ی پشتیبانی‌شده‌ی تقویم است.';

  @override
  String get calendarConverterHint =>
      'تاریخ را در یکی از سه تقویم بنویسید؛ دو تقویم دیگر هم‌زمان تغییر می‌کنند.';

  @override
  String get calendarConverterShow => 'نمایش در تقویم';

  @override
  String get calendarConverterTitle => 'مبدل تاریخ';

  @override
  String calendarDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get calendarFieldDay => 'روز';

  @override
  String get calendarFieldMonth => 'ماه';

  @override
  String get calendarFieldYear => 'سال';

  @override
  String get calendarGridLabel => 'تقویم ماهانه';

  @override
  String get calendarHijriAdjust => 'تنظیم تاریخ قمری';

  @override
  String get calendarHijriApproxHint =>
      'تقریبی؛ تقویم قمری رسمی ایران بر پایه‌ی رؤیت ماه است و ممکن است یک روز متفاوت باشد.';

  @override
  String get calendarHijriUnavailable => 'برای این روز تاریخ قمری در جدول نیست';

  @override
  String get calendarKindGregorian => 'میلادی';

  @override
  String get calendarKindHijri => 'قمری';

  @override
  String get calendarKindJalali => 'شمسی';

  @override
  String calendarMonthGregorian(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'ژانویه',
      'm2': 'فوریه',
      'm3': 'مارس',
      'm4': 'آوریل',
      'm5': 'مه',
      'm6': 'ژوئن',
      'm7': 'ژوئیه',
      'm8': 'اوت',
      'm9': 'سپتامبر',
      'm10': 'اکتبر',
      'm11': 'نوامبر',
      'm12': 'دسامبر',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthHijri(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'محرم',
      'm2': 'صفر',
      'm3': 'ربیع‌الاول',
      'm4': 'ربیع‌الثانی',
      'm5': 'جمادی‌الاول',
      'm6': 'جمادی‌الثانی',
      'm7': 'رجب',
      'm8': 'شعبان',
      'm9': 'رمضان',
      'm10': 'شوال',
      'm11': 'ذی‌القعده',
      'm12': 'ذی‌الحجه',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthJalali(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'فروردین',
      'm2': 'اردیبهشت',
      'm3': 'خرداد',
      'm4': 'تیر',
      'm5': 'مرداد',
      'm6': 'شهریور',
      'm7': 'مهر',
      'm8': 'آبان',
      'm9': 'آذر',
      'm10': 'دی',
      'm11': 'بهمن',
      'm12': 'اسفند',
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
      'تاریخ قمری بر پایه‌ی جدول ام‌القری است. تقویم رسمی ایران با رؤیت ماه تعیین می‌شود و ممکن است یک روز تفاوت داشته باشد؛ در این صورت آن را اینجا یک روز جابه‌جا کنید.';

  @override
  String get calendarNextMonth => 'ماه بعد';

  @override
  String get calendarOpenOnHome => 'نمایش در صفحه‌ی اصلی';

  @override
  String get calendarPanelTimes => 'اوقات این روز';

  @override
  String get calendarPreviousMonth => 'ماه قبل';

  @override
  String get calendarSeparator => '، ';

  @override
  String get calendarToday => 'امروز';

  @override
  String calendarWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'دوشنبه',
      'd2': 'سه‌شنبه',
      'd3': 'چهارشنبه',
      'd4': 'پنجشنبه',
      'd5': 'جمعه',
      'd6': 'شنبه',
      'd7': 'یکشنبه',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'د',
      'd2': 'س',
      'd3': 'چ',
      'd4': 'پ',
      'd5': 'ج',
      'd6': 'ش',
      'd7': 'ی',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get contributeIntro =>
      'کد این برنامه در GitHub است و هر کمکی پذیرفته می‌شود. راه‌های مشارکت:';

  @override
  String get contributeOpenGuide => 'راهنمای مشارکت';

  @override
  String get contributeOpenIssues => 'گزارش خطا یا پیشنهاد';

  @override
  String get contributeOpenRepo => 'باز کردن مخزن در GitHub';

  @override
  String get contributeTitle => 'مشارکت در پروژه';

  @override
  String get contributeWayCode =>
      'کد: مخزن را Fork کنید، تغییر را در یک شاخه انجام دهید، آزمون‌ها را اجرا کنید و Pull Request بفرستید. راهنمای ساخت و آزمون در CONTRIBUTING.md است.';

  @override
  String get contributeWayData =>
      'داده: نام، مختصات یا منطقه‌ی زمانی شهرها را اصلاح کنید یا شهر تازه اضافه کنید.';

  @override
  String get contributeWayIssues =>
      'گزارش خطا یا پیشنهاد: در GitHub یک Issue بسازید و شماره‌ی نسخه و گزارش عیب‌یابی همین صفحه را ضمیمه کنید (نام و مختصات ندارد).';

  @override
  String get contributeWayTest =>
      'آزمایش: برنامه را روی نسخه‌ها و سخت‌افزارهای مختلف ویندوز بیازمایید (اذان، سینی سیستم، بیدارباش) و نتیجه را گزارش کنید.';

  @override
  String get contributeWayTranslate =>
      'ترجمه: متن‌های برنامه در پوشه‌ی lib/l10n هستند. ترجمه‌ی یک زبان تازه یا اصلاح ترجمه‌ی موجود را بفرستید؛ بازبینی یک گویشور بومی بسیار ارزشمند است.';

  @override
  String get diagAudioFailed =>
      'صدای آزمایشی پخش نشد. بلندگو و میزان صدای ویندوز را بررسی کنید.';

  @override
  String get diagAudioOk => 'صدای آزمایشی پخش شد.';

  @override
  String get diagAudioPlay => 'پخش صدای آزمایشی';

  @override
  String get diagAudioStop => 'توقف';

  @override
  String get diagAudioTitle => 'آزمایش صدا';

  @override
  String get diagClockOk => 'مشکلی در ساعت رایانه پیدا نشد.';

  @override
  String get diagClockTitle => 'ساعت';

  @override
  String get diagClockUnchecked =>
      'مشکلی دیده نشد، ولی بررسی ساعت با اینترنت خاموش است و انحراف ساعت اندازه‌گیری نمی‌شود.';

  @override
  String get diagCopied =>
      'رونوشت شد. نام، مکان دقیق و مختصات دقیق در آن نیست.';

  @override
  String get diagCopy => 'رونوشت عیب‌یابی';

  @override
  String get diagCopyFailed => 'رونوشت انجام نشد.';

  @override
  String diagEventAzan(String prayer) {
    return '$prayer';
  }

  @override
  String diagEventReminder(String prayer) {
    return 'یادآوری $prayer';
  }

  @override
  String diagEventTimes(String utc, String local) {
    return 'UTC $utc | محلی $local';
  }

  @override
  String get diagEventWake => 'بیدارباش';

  @override
  String get diagEventsEmpty => 'چیزی زمان‌بندی نشده است.';

  @override
  String get diagEventsTitle => 'رویدادهای زمان‌بندی‌شده‌ی بعدی';

  @override
  String get diagLogNone => 'در دسترس نیست.';

  @override
  String get diagLogTitle => 'فایل‌های گزارش';

  @override
  String get diagTitle => 'عیب‌یابی';

  @override
  String diagValue(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'yes': 'بله',
      'no': 'نه',
      'unknown': 'نامشخص',
      'enabled': 'مجاز',
      'disabled': 'خاموش',
      'importantOnly': 'فقط مهم‌ها',
      'ok': 'سالم',
      'failed': 'ناموفق',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String diagWakeAc(String value) {
    return 'تایمر بیدارکننده با برق شهر: $value';
  }

  @override
  String diagWakeBattery(String value) {
    return 'تایمر بیدارکننده با باتری: $value';
  }

  @override
  String get diagWakeCheck => 'بررسی کن';

  @override
  String diagWakeInProcess(String value) {
    return 'تایمر داخل برنامه: $value';
  }

  @override
  String diagWakeModern(String value) {
    return 'آماده‌به‌کار مدرن: $value';
  }

  @override
  String get diagWakeNotChecked => 'هنوز بررسی نشده است.';

  @override
  String diagWakeTask(String value) {
    return 'وظیفه‌ی زمان‌بندی‌شده: $value';
  }

  @override
  String get diagWakeTitle => 'بررسی بیدارباش';

  @override
  String get formatAm => 'ق.ظ';

  @override
  String formatHours(String hours) {
    return '$hours ساعت';
  }

  @override
  String formatHoursMinutes(String hours, String minutes) {
    return '$hours ساعت و $minutes دقیقه';
  }

  @override
  String formatMinutes(String minutes) {
    return '$minutes دقیقه';
  }

  @override
  String get formatPm => 'ب.ظ';

  @override
  String formatRemaining(String duration) {
    return '$duration دیگر';
  }

  @override
  String formatRemainingLessThan(String minutes) {
    return 'کمتر از $minutes دقیقه دیگر';
  }

  @override
  String formatSeconds(String seconds) {
    return '$seconds ثانیه';
  }

  @override
  String get homeAzanMutedIndefinite => 'اذان: بی‌صدا تا اطلاع ثانوی';

  @override
  String homeAzanMutedUntil(String time) {
    return 'اذان: بی‌صدا تا $time';
  }

  @override
  String get homeAzanOff => 'اذان: خاموش';

  @override
  String get homeAzanOn => 'اذان: روشن';

  @override
  String homeAzanToggleOff(String prayer) {
    return 'خاموش کردن اذان $prayer';
  }

  @override
  String homeAzanToggleOn(String prayer) {
    return 'روشن کردن اذان $prayer';
  }

  @override
  String get homeBackToToday => 'بازگشت به امروز';

  @override
  String homeBannerClockSkew(String amount) {
    return 'ساعت رایانه حدود $amount با ساعت دقیق اختلاف دارد.';
  }

  @override
  String get homeBannerDismiss => 'بستن';

  @override
  String get homeBannerMutedIndefinite => 'اذان تا اطلاع ثانوی بی‌صدا است.';

  @override
  String homeBannerMutedUntil(String time) {
    return 'اذان تا $time بی‌صدا است.';
  }

  @override
  String get homeBannerSettingsReset =>
      'فایل تنظیمات خوانده نشد و تنظیمات به حالت اولیه برگشت.';

  @override
  String get homeBannerStaleZone =>
      'ویندوز برای این مکان ساعتی متفاوت از پایگاه داده‌ی منطقه‌ی زمانی نشان می‌دهد. اوقات برنامه درست است؛ ساعت ویندوز را بررسی کنید.';

  @override
  String homeCompass(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'p0': 'شمال',
      'p1': 'شمال شرقی',
      'p2': 'شرق',
      'p3': 'جنوب شرقی',
      'p4': 'جنوب',
      'p5': 'جنوب غربی',
      'p6': 'غرب',
      'p7': 'شمال غربی',
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
    return 'اوقات $date';
  }

  @override
  String homeEventAt(String event, String time) {
    return '$event $time';
  }

  @override
  String get homeHeroNoNext => 'وقتی برای شمارش معکوس نیست';

  @override
  String get homeMute => 'بی‌صدا';

  @override
  String get homeMuteCancel => 'لغو بی‌صدا';

  @override
  String homeMuteForDuration(String duration) {
    return '$duration';
  }

  @override
  String get homeMuteIndefinite => 'تا اطلاع ثانوی';

  @override
  String get homeMuteUntilNext => 'تا اذان بعدی';

  @override
  String get homeNextDay => 'روز بعد';

  @override
  String get homeNextMarker => 'وقت بعدی';

  @override
  String homeNextWakeAlarm(String value) {
    return 'بیدارباش بعدی: $value';
  }

  @override
  String get homeNoTimesAction => 'تنظیمات محاسبه';

  @override
  String get homeNoTimesInfo =>
      'در این روز برای این مکان همه‌ی وقت‌ها قابل محاسبه نیست. قاعده‌ی عرض‌های جغرافیایی بالا را در تنظیمات می‌توانید تغییر دهید.';

  @override
  String get homeNoValue => '—';

  @override
  String homeNowPlaying(String prayer) {
    return 'در حال پخش: $prayer';
  }

  @override
  String get homeNowPlayingGeneric => 'در حال پخش اذان';

  @override
  String get homeOtherDayHint =>
      'اوقات این روز؛ شمارش معکوس فقط برای امروز است.';

  @override
  String get homePreviousDay => 'روز قبل';

  @override
  String homeQiblaSummary(String degrees, String direction) {
    return 'قبله: $degrees° $direction';
  }

  @override
  String homeReminderMinutes(String minutes) {
    return 'یادآوری: $minutes دقیقه قبل';
  }

  @override
  String get homeReminderOff => 'یادآوری: خاموش';

  @override
  String homeReminderRange(String min, String max) {
    return 'یادآوری: $min تا $max دقیقه قبل';
  }

  @override
  String get homeStatusTitle => 'وضعیت';

  @override
  String get homeStop => 'توقف';

  @override
  String get homeSwitchLocation => 'تغییر مکان';

  @override
  String get homeTimelineLabel => 'خط زمانی روز';

  @override
  String get homeToday => 'امروز';

  @override
  String get homeTodayTimes => 'اوقات امروز';

  @override
  String get homeTomorrowTimes => 'اوقات فردا';

  @override
  String homeUntilEvent(String event) {
    return 'تا $event';
  }

  @override
  String homeViewingDay(String date) {
    return 'نمایش $date';
  }

  @override
  String get navCalendar => 'تقویم';

  @override
  String get navHome => 'خانه';

  @override
  String get navQibla => 'قبله';

  @override
  String get navSettings => 'تنظیمات';

  @override
  String get navTimetable => 'جدول ماهانه';

  @override
  String get navWakeUp => 'بیدارباش';

  @override
  String notifAzanBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String get notifAzanFailed => 'پخش اذان ممکن نشد.';

  @override
  String notifAzanTitle(String prayer) {
    return '$prayer';
  }

  @override
  String notifMissedBody(String time) {
    return 'رایانه در ساعت $time در حالت خواب بود.';
  }

  @override
  String notifMissedTitle(String prayer) {
    return '$prayer پخش نشد';
  }

  @override
  String notifReminderBody(String place, String time) {
    return '$place · ساعت $time';
  }

  @override
  String notifReminderTitle(String minutes, String prayer) {
    return '$minutes دقیقه تا $prayer';
  }

  @override
  String get notifSoundFallback =>
      'فایل صدای اذان پیدا نشد؛ صدای پیش‌فرض پخش شد.';

  @override
  String get notifStopAction => 'توقف';

  @override
  String get notifTrayHint => 'برنامه در کنار ساعت ویندوز فعال می‌ماند.';

  @override
  String get onboardingAzanBody =>
      'صدای اذان را بشنوید و تعیین کنید برنامه با روشن شدن ویندوز هم اجرا شود.';

  @override
  String get onboardingAzanTitle => 'اذان و شروع برنامه';

  @override
  String get onboardingBack => 'قبلی';

  @override
  String get onboardingCityBody =>
      'شهر خود را جستجو کنید یا از فهرست استان‌ها انتخاب کنید.';

  @override
  String get onboardingCityNone => 'شهری پیدا نشد.';

  @override
  String get onboardingCitySearchHint => 'جستجوی شهر';

  @override
  String onboardingCitySelected(String city) {
    return 'مکان انتخاب‌شده: $city';
  }

  @override
  String get onboardingCityTitle => 'شهر شما';

  @override
  String get onboardingFinish => 'شروع';

  @override
  String get onboardingLanguageBody =>
      'زبان را انتخاب کنید. بعداً در تنظیمات هم می‌توانید آن را عوض کنید.';

  @override
  String get onboardingLanguageTitle => 'زبان برنامه';

  @override
  String get onboardingModeList => 'شهرهای ایران (فهرست آفلاین)';

  @override
  String get onboardingModeOnline => 'هر شهر دنیا (جستجوی آنلاین)';

  @override
  String get onboardingNext => 'بعدی';

  @override
  String get onboardingOnlineBody =>
      'شهرتان در فهرست نیست؟ هر شهری در دنیا را جستجو کنید. اینترنت فقط برای همین جستجو لازم است و بعد برنامه بدون اینترنت کار می‌کند.';

  @override
  String get onboardingPreview => 'پخش نمونه‌ی اذان';

  @override
  String get onboardingProvinceAll => 'همه‌ی استان‌ها';

  @override
  String get onboardingSkip => 'رد کردن';

  @override
  String get onboardingStartWithWindows => 'اجرا همراه با ویندوز';

  @override
  String get onboardingStartWithWindowsHint =>
      'برنامه بی‌صدا در کنار ساعت ویندوز شروع می‌شود.';

  @override
  String onboardingStepProgress(String step, String total) {
    return 'مرحله $step از $total';
  }

  @override
  String get onboardingStopPreview => 'توقف';

  @override
  String get placeSearchAttribution =>
      'مکان‌ها © مشارکت‌کنندگان OpenStreetMap (Nominatim). منطقه‌ی زمانی و ارتفاع: Open-Meteo.';

  @override
  String get placeSearchButton => 'جستجو';

  @override
  String get placeSearchFailBusy =>
      'سرویس جستجو شلوغ است. یک دقیقه صبر کنید و دوباره امتحان کنید.';

  @override
  String get placeSearchFailDetails =>
      'مکان پیدا شد، اما منطقه‌ی زمانی آن دریافت نشد. اتصال را بررسی کنید و دوباره آن را انتخاب کنید.';

  @override
  String get placeSearchFailGeneric =>
      'جستجو انجام نشد. کمی بعد دوباره امتحان کنید.';

  @override
  String get placeSearchFailOffline =>
      'اینترنت وصل نیست. وصل شوید و دوباره جستجو را بزنید. بقیه‌ی برنامه بدون اینترنت کار می‌کند.';

  @override
  String get placeSearchFailTimeout =>
      'سرویس جستجو به‌موقع پاسخ نداد. دوباره امتحان کنید.';

  @override
  String get placeSearchHint => 'شهر، کشور (مثلاً بمبئی، هند)';

  @override
  String placeSearchNone(String query) {
    return 'مکانی برای «$query» پیدا نشد. املا را بررسی کنید یا کشور را هم بنویسید، مثلاً بمبئی، هند.';
  }

  @override
  String get placeSearchNotice =>
      'جستجو فقط همین یک بار به اینترنت نیاز دارد. متنی که می‌نویسید به سرویس جستجوی OpenStreetMap (Nominatim) فرستاده می‌شود و چیز دیگری فرستاده نمی‌شود. بعد از انتخاب مکان، برنامه آنچه لازم دارد را نگه می‌دارد و دوباره بدون اینترنت کار می‌کند.';

  @override
  String get placeSearchNoticeDetails =>
      'وقتی مکانی را انتخاب کنید، مختصات همان مکان به Open-Meteo فرستاده می‌شود تا منطقه‌ی زمانی و ارتفاعش گرفته شود.';

  @override
  String placeSearchResolving(String place) {
    return 'در حال دریافت منطقه‌ی زمانی و ارتفاع $place…';
  }

  @override
  String get placeSearchResultsTitle => 'نتایج: مکان خود را انتخاب کنید';

  @override
  String get placeSearchTitle => 'جستجوی مکان';

  @override
  String get placeSearchTooShort => 'دست‌کم دو حرف بنویسید و جستجو را بزنید.';

  @override
  String get placeSearchUnknownZone =>
      'منطقه‌ی زمانی این مکان در پایگاه داده‌ی برنامه نیست. مکان دیگری را امتحان کنید یا آن را با «مکان دلخواه» در تنظیمات اضافه کنید.';

  @override
  String get placeSearching => 'در حال جستجو…';

  @override
  String get prayerAsr => 'عصر';

  @override
  String get prayerDhuhr => 'اذان ظهر';

  @override
  String get prayerFajr => 'اذان صبح';

  @override
  String get prayerImsak => 'امساک';

  @override
  String get prayerIsha => 'عشا';

  @override
  String get prayerMaghrib => 'اذان مغرب';

  @override
  String get prayerMidnight => 'نیمه‌شب شرعی';

  @override
  String get prayerSunrise => 'طلوع آفتاب';

  @override
  String get prayerSunset => 'غروب آفتاب';

  @override
  String qiblaAccuracyValue(String meters) {
    return 'دقت تقریبی: $meters متر';
  }

  @override
  String get qiblaBearingLabel => 'زاویه‌ی قبله (از شمال حقیقی، ساعت‌گرد)';

  @override
  String qiblaBearingValue(String degrees, String direction) {
    return '$degrees° ($direction)';
  }

  @override
  String get qiblaCamKaaba => 'کعبه';

  @override
  String get qiblaCamNearby => 'اطراف من';

  @override
  String get qiblaCamOverview => 'مسیر کامل';

  @override
  String qiblaCardinal(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'n': 'شمال',
      'e': 'شرق',
      's': 'جنوب',
      'w': 'غرب',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String qiblaCompassSemantics(String degrees, String direction) {
    return 'قطب‌نما: قبله در $degrees درجه ($direction)';
  }

  @override
  String qiblaCompassSemanticsSun(String base, String azimuth) {
    return '$base؛ خورشید در $azimuth درجه';
  }

  @override
  String get qiblaCoordsApply => 'نمایش';

  @override
  String get qiblaCoordsHint => 'مثلاً ۳۶٫۲۱۳۳، ۵۸٫۷۹۵۸';

  @override
  String get qiblaCoordsInvalid =>
      'مختصات معتبر نیست. عرض باید بین ۹۰- و ۹۰ و طول بین ۱۸۰- و ۱۸۰ باشد.';

  @override
  String get qiblaCoordsLabel => 'عرض و طول جغرافیایی';

  @override
  String get qiblaCoordsOr => 'یا مختصات را خودتان وارد کنید';

  @override
  String qiblaCustomPlaceShown(String place) {
    return 'اندازه‌گیری از $place.';
  }

  @override
  String get qiblaDeviceFixShown => 'موقعیت دستگاه نشان داده می‌شود.';

  @override
  String get qiblaDistanceLabel => 'فاصله تا کعبه';

  @override
  String qiblaDistanceValue(String km) {
    return '$km کیلومتر';
  }

  @override
  String get qiblaFailGeneric =>
      'موقعیت خوانده نشد؛ شهر انتخاب‌شده نشان داده می‌شود.';

  @override
  String get qiblaFailPermissionDenied =>
      'ویندوز اجازه‌ی خواندن موقعیت را به این برنامه نداده است. مراحل زیر را انجام دهید و دوباره امتحان کنید؛ یا از شهر انتخاب‌شده استفاده کنید.';

  @override
  String get qiblaFailPermissionForever =>
      'دسترسی به موقعیت مکانی رد شده است. برای فعال‌کردن دوباره، مراحل زیر را انجام دهید.';

  @override
  String get qiblaFailServiceDisabled =>
      'سرویس موقعیت مکانی دستگاه خاموش است. مراحل زیر را انجام دهید؛ یا از شهر انتخاب‌شده یا هر نقطه‌ی دلخواه استفاده کنید.';

  @override
  String get qiblaFailTimeout =>
      'موقعیت به‌موقع به دست نیامد. رایانه‌ها معمولاً GPS ندارند و ویندوز موقعیت را از Wi-Fi تخمین می‌زند. دوباره امتحان کنید یا شهر را به کار ببرید.';

  @override
  String get qiblaFailUnsupported =>
      'این دستگاه موقعیت‌یابی ندارد؛ شهر انتخاب‌شده نشان داده می‌شود.';

  @override
  String qiblaForLocation(String place) {
    return 'جهت قبله برای $place';
  }

  @override
  String get qiblaHelpOther =>
      'موقعیت مکانی را در تنظیمات سیستم‌عامل روشن کنید، به این برنامه اجازه‌ی استفاده از آن را بدهید و دوباره امتحان کنید.';

  @override
  String get qiblaHelpTitleOther => 'چطور موقعیت مکانی را روشن کنم؟';

  @override
  String get qiblaHelpTitleWindows =>
      'چطور موقعیت مکانی را در ویندوز روشن کنم؟';

  @override
  String get qiblaHelpWin1 =>
      'دکمه‌ی بالا را بزنید تا صفحه‌ی Location در تنظیمات ویندوز باز شود. اگر باز نشد، دستی بروید: Start > Settings > Privacy & security > Location (در ویندوز ۱۰: Privacy > Location)';

  @override
  String get qiblaHelpWin2 =>
      'کلید Location services را روشن کنید. اگر بالای صفحه نوشته Location for this device is off، دکمه‌ی Change را بزنید و آن را روشن کنید.';

  @override
  String get qiblaHelpWin3 =>
      'کمی پایین‌تر کلید Let desktop apps access your location را روشن کنید (در ویندوز ۱۰: Allow desktop apps to access your location). Salaat یک برنامه‌ی رومیزی است و فقط با همین کلید اجازه می‌گیرد.';

  @override
  String get qiblaHelpWin4 =>
      'به Salaat برگردید و «یافتن موقعیت من» را دوباره بزنید. اگر باز هم نشد، برنامه را یک بار ببندید و باز کنید.';

  @override
  String get qiblaLocateAgain => 'یافتن دوباره';

  @override
  String get qiblaLocateButton => 'یافتن موقعیت من';

  @override
  String get qiblaLocating => 'در حال یافتن موقعیت…';

  @override
  String get qiblaMapAttribution => '© مشارکت‌کنندگان OpenStreetMap';

  @override
  String get qiblaMapAttributionSatellite =>
      'تصاویر © Esri، Maxar، Earthstar Geographics و جامعه‌ی کاربران GIS';

  @override
  String get qiblaMapConsentBody =>
      'برای دیدن خط قبله روی نقشه، تصاویر نقشه از اینترنت گرفته می‌شود و ناحیه‌ای که می‌بینید به آن سرور فرستاده می‌شود: نقشه‌ی خیابانی از OpenStreetMap، و اگر «ماهواره» را انتخاب کنید عکس‌های هوایی از Esri. تا شما نخواهید هیچ درخواستی فرستاده نمی‌شود. بدون نقشه هم زاویه و فاصله‌ی قبله درست نشان داده می‌شود.';

  @override
  String get qiblaMapConsentButton => 'نمایش نقشه';

  @override
  String get qiblaMapConsentTitle => 'نقشه‌ی قبله';

  @override
  String get qiblaMapKaaba => 'کعبه';

  @override
  String get qiblaMapLineNote =>
      'خط، کوتاه‌ترین مسیر روی کره‌ی زمین تا مرکز کعبه است. روی نقشه‌ی تخت منحنی دیده می‌شود، ولی جهت شروعش همان زاویه‌ی قبله است. ناودان کعبه فقط چند متر با مرکز فاصله دارد و در جهت قبله اثری قابل‌دیدن ندارد. برای مقایسه با خیابان‌ها و ساختمان‌ها «اطراف من» را بزنید.';

  @override
  String get qiblaMapOfflineBanner =>
      'تصاویر نقشه گرفته نمی‌شود (اینترنت قطع است؟). خط و زاویه‌ی قبله همچنان درست است.';

  @override
  String qiblaMapSemantics(String place, String bearing, String distance) {
    return 'نقشه‌ی قبله: از $place تا کعبه، $bearing، $distance';
  }

  @override
  String get qiblaMapTapHint => 'برای انتخاب نقطه‌ی دیگر، روی نقشه بزنید.';

  @override
  String get qiblaMapTurnOff => 'خاموش‌کردن نقشه';

  @override
  String get qiblaMapYou => 'موقعیت شما';

  @override
  String get qiblaNoCompassNote =>
      'رایانه قطب‌نما ندارد؛ شکل نسبت به شمال حقیقی رسم شده است (شمال بالاست).';

  @override
  String get qiblaOpenSettingsFailed =>
      'تنظیمات باز نشد؛ مراحل بالا را دستی انجام دهید.';

  @override
  String get qiblaOpenSettingsOther => 'باز کردن تنظیمات موقعیت';

  @override
  String get qiblaOpenSettingsWindows => 'باز کردن تنظیمات موقعیت ویندوز';

  @override
  String get qiblaSourceCity => 'شهر انتخاب‌شده';

  @override
  String qiblaSourceCityHelp(String city) {
    return 'شهری که برای اوقات شرعی انتخاب کرده‌اید: $city.';
  }

  @override
  String get qiblaSourceCustom => 'نقطه‌ی دلخواه';

  @override
  String get qiblaSourceCustomHelp =>
      'مکان را با نام جستجو کنید (یک‌بار اینترنت لازم است)، روی نقشه بزنید یا مختصات را وارد کنید.';

  @override
  String get qiblaSourceDevice => 'موقعیت دستگاه';

  @override
  String get qiblaSourceDeviceHelp =>
      'موقعیت فقط وقتی دکمه را بزنید از دستگاه خوانده می‌شود و ذخیره یا فرستاده نمی‌شود.';

  @override
  String get qiblaSourceTitle => 'قبله را از کجا حساب کنم؟';

  @override
  String get qiblaStatLatitude => 'عرض جغرافیایی';

  @override
  String get qiblaStatLongitude => 'طول جغرافیایی';

  @override
  String get qiblaStyleLabel => 'نوع نقشه';

  @override
  String get qiblaStyleSatellite => 'ماهواره';

  @override
  String get qiblaStyleStreet => 'نقشه';

  @override
  String get qiblaSunBelow => 'خورشید زیر افق است.';

  @override
  String get qiblaSunInHelp =>
      'در این لحظه خورشید دقیقاً در جهت قبله است؛ رو به خورشید بایستید.';

  @override
  String get qiblaSunInTitle => 'خورشید در جهت قبله (مقارنه)';

  @override
  String get qiblaSunNone => 'امروز رخ نمی‌دهد.';

  @override
  String get qiblaSunNowLabel => 'خورشید اکنون';

  @override
  String qiblaSunNowValue(String azimuth, String altitude) {
    return 'سمت $azimuth°، ارتفاع $altitude°';
  }

  @override
  String get qiblaSunOppHelp =>
      'در این لحظه سایه‌ی شاخص جهت قبله را نشان می‌دهد.';

  @override
  String get qiblaSunOppTitle => 'خورشید در جهت مخالف قبله (مقابله)';

  @override
  String get qiblaSunTimesTitle => 'خورشید و قبله امروز';

  @override
  String get qiblaTabCompass => 'قطب‌نما و خورشید';

  @override
  String get qiblaTabMap => 'نقشه';

  @override
  String get qiblaTitle => 'قبله';

  @override
  String get settingsAboutPlaceholder =>
      'نسخه، مجوزها و صفحه‌ی عیب‌یابی در این بخش نمایش داده می‌شود.';

  @override
  String get settingsAppAutostart => 'اجرا با ویندوز';

  @override
  String get settingsAppAutostartHelp =>
      'برنامه با ورود به ویندوز بی‌سروصدا در کنار ساعت اجرا می‌شود.';

  @override
  String get settingsAppCloseToTray => 'بستن پنجره به کنار ساعت';

  @override
  String get settingsAppCloseToTrayHelp =>
      'با بستن پنجره، برنامه در کنار ساعت ویندوز می‌ماند و اذان پخش می‌شود. اگر خاموش باشد، برنامه بسته می‌شود.';

  @override
  String get settingsAppMinimized => 'شروع در کنار ساعت';

  @override
  String get settingsAppMinimizedHelp =>
      'هنگام اجرا با ویندوز پنجره باز نمی‌شود.';

  @override
  String get settingsAsrHanafi => 'حنفی (سایه دو برابر شاخص)';

  @override
  String get settingsAsrStandard => 'استاندارد (سایه برابر شاخص)';

  @override
  String get settingsAzanChoose => 'انتخاب پرونده…';

  @override
  String get settingsAzanEnabled => 'پخش اذان';

  @override
  String get settingsAzanEnabledHelp =>
      'کلید اصلی؛ با خاموش کردن آن هیچ اذانی پخش نمی‌شود.';

  @override
  String get settingsAzanFade => 'شروع تدریجی صدا';

  @override
  String get settingsAzanFadeHelp => 'اذان به آرامی به بلندی کامل می‌رسد.';

  @override
  String get settingsAzanMute => 'بی‌صدا';

  @override
  String get settingsAzanMuteHelp => 'اذان را موقتاً بی‌صدا کنید.';

  @override
  String get settingsAzanNotMuted => 'بی‌صدا نیست';

  @override
  String settingsAzanPrayerSwitch(String prayer) {
    return 'اذان $prayer';
  }

  @override
  String get settingsAzanPrayerVolume => 'بلندی این اذان';

  @override
  String get settingsAzanPreview => 'پیش‌شنیدن';

  @override
  String get settingsAzanSound => 'صدا';

  @override
  String get settingsAzanSoundDefault => 'اذان پیش‌فرض برنامه';

  @override
  String settingsAzanSoundFile(String name) {
    return 'پرونده: $name';
  }

  @override
  String get settingsAzanUseDefault => 'استفاده از صدای پیش‌فرض';

  @override
  String get settingsAzanVolume => 'بلندی صدا';

  @override
  String get settingsAzanVolumeHelp => 'بلندی کلی همه‌ی اذان‌ها';

  @override
  String get settingsBackupExport => 'ذخیره‌ی پشتیبان';

  @override
  String get settingsBackupExportFailed => 'پشتیبان ذخیره نشد.';

  @override
  String get settingsBackupExportHelp =>
      'همه‌ی تنظیمات، مکان‌ها و بیدارباش‌ها در یک پرونده ذخیره می‌شود.';

  @override
  String settingsBackupExported(String path) {
    return 'پشتیبان ذخیره شد: $path';
  }

  @override
  String get settingsBackupImport => 'بازیابی از پشتیبان';

  @override
  String get settingsBackupImportBody =>
      'همه‌ی تنظیمات فعلی با محتوای این پرونده جایگزین می‌شود.';

  @override
  String get settingsBackupImportConfirm => 'بازیابی';

  @override
  String get settingsBackupImportHelp =>
      'تنظیمات را از پرونده‌ی پشتیبان برمی‌گرداند.';

  @override
  String get settingsBackupImportInvalid =>
      'این پرونده پشتیبان تنظیمات معتبر نیست؛ تنظیمات تغییری نکرد.';

  @override
  String get settingsBackupImportReadFailed =>
      'پرونده خوانده نشد؛ تنظیمات تغییری نکرد.';

  @override
  String get settingsBackupImportTitle => 'تنظیمات بازیابی شود؟';

  @override
  String get settingsBackupImported => 'تنظیمات بازیابی شد.';

  @override
  String get settingsBackupTitle => 'پشتیبان‌گیری و بازیابی';

  @override
  String get settingsCalcAngleHelp => 'زاویه‌ی خورشید زیر افق، به درجه';

  @override
  String get settingsCalcAsr => 'قاعده‌ی عصر';

  @override
  String get settingsCalcFajrAngle => 'زاویه‌ی اذان صبح';

  @override
  String get settingsCalcHighLat => 'عرض‌های جغرافیایی بالا';

  @override
  String get settingsCalcHighLatHelp =>
      'برای جاهایی که شب بسیار کوتاه است و زاویه‌ی گرگ‌ومیش به دست نمی‌آید.';

  @override
  String get settingsCalcImsak => 'امساک';

  @override
  String get settingsCalcImsakHelp => 'چند دقیقه پیش از اذان صبح';

  @override
  String get settingsCalcIshaAngle => 'زاویه‌ی عشا';

  @override
  String get settingsCalcIshaMinutes => 'دقیقه پس از مغرب';

  @override
  String get settingsCalcIshaMode => 'تعریف عشا';

  @override
  String get settingsCalcIshaModeAngle => 'زاویه‌ی خورشید';

  @override
  String get settingsCalcIshaModeMinutes => 'دقیقه پس از مغرب';

  @override
  String get settingsCalcMaghribAngle => 'زاویه‌ی مغرب';

  @override
  String get settingsCalcMaghribSunset => 'مغرب هنگام غروب خورشید';

  @override
  String get settingsCalcMaghribSunsetHelp =>
      'اگر خاموش باشد، مغرب با زاویه‌ی زیر محاسبه می‌شود.';

  @override
  String get settingsCalcMethod => 'روش محاسبه';

  @override
  String get settingsCalcMethodHelp =>
      'با تغییر هر زاویه، روش به «دلخواه» تبدیل می‌شود.';

  @override
  String get settingsCalcMidnight => 'نیمه‌شب شرعی';

  @override
  String settingsCalcOffsetsHelp(String max) {
    return 'هر وقت را تا $max دقیقه جلو یا عقب ببرید.';
  }

  @override
  String get settingsCalcOffsetsReset => 'صفر کردن همه';

  @override
  String get settingsCalcOffsetsTitle => 'تنظیم دقیقه‌ای هر وقت';

  @override
  String settingsCalcPreviewHelp(String date) {
    return 'اوقات امروز ($date) با تنظیمات بالا';
  }

  @override
  String get settingsCalcPreviewTitle => 'پیش‌نمایش زنده';

  @override
  String get settingsCalcRestore => 'بازگرداندن مقدارهای پیش‌فرض این روش';

  @override
  String settingsCalcRestoreHelp(String method) {
    return 'زاویه‌ها، قاعده‌ها و امساک به مقدار «$method» برمی‌گردد؛ دقیقه‌های تنظیم‌شده‌ی هر وقت تغییر نمی‌کند.';
  }

  @override
  String get settingsCalcRowsHelp =>
      'اذان صبح، طلوع آفتاب، اذان ظهر، اذان مغرب و نیمه‌شب شرعی همیشه نمایش داده می‌شوند.';

  @override
  String get settingsCalcRowsTitle => 'ردیف‌های نمایش‌داده‌شده';

  @override
  String get settingsCancel => 'انصراف';

  @override
  String get settingsDecrease => 'کم کردن';

  @override
  String get settingsDigitsArabic => 'عربی (٠١٢)';

  @override
  String get settingsDigitsLatin => 'لاتین (123)';

  @override
  String get settingsDigitsPersian => 'فارسی (۱۲۳)';

  @override
  String get settingsDispDigits => 'رقم‌ها';

  @override
  String get settingsDispHijri => 'تنظیم تاریخ قمری';

  @override
  String get settingsDispHijriHelp =>
      'ایران ماه قمری را با رؤیت هلال تعیین می‌کند؛ اگر تاریخ نمایش‌داده‌شده با اعلام رسمی تفاوت دارد، آن را یک یا دو روز جابه‌جا کنید.';

  @override
  String get settingsDispHour => 'ساعت';

  @override
  String get settingsDispLanguage => 'زبان';

  @override
  String get settingsDispLanguageHelp => 'بدون راه‌اندازی دوباره اعمال می‌شود.';

  @override
  String get settingsDispTheme => 'پوسته';

  @override
  String get settingsHighLatAngleBased => 'بر پایه‌ی زاویه';

  @override
  String get settingsHighLatNightMiddle => 'نیمه‌ی شب';

  @override
  String get settingsHighLatNone => 'بدون تغییر';

  @override
  String get settingsHighLatOneSeventh => 'یک‌هفتم شب';

  @override
  String get settingsHour12 => '۱۲ ساعته';

  @override
  String get settingsHour24 => '۲۴ ساعته';

  @override
  String get settingsIncrease => 'افزایش';

  @override
  String settingsInvalidNumber(String min, String max) {
    return 'یک عدد معتبر بین $min و $max وارد کنید.';
  }

  @override
  String get settingsLocActive => 'فعال';

  @override
  String get settingsLocAdd => 'افزودن';

  @override
  String get settingsLocAddCustom => 'مکان دلخواه';

  @override
  String get settingsLocAddFromDb => 'از فهرست شهرها';

  @override
  String get settingsLocAddSearch => 'جستجوی آنلاین';

  @override
  String get settingsLocAddTitle => 'افزودن مکان';

  @override
  String settingsLocAdded(String name) {
    return '$name اضافه شد.';
  }

  @override
  String get settingsLocAllProvinces => 'همه‌ی استان‌ها';

  @override
  String get settingsLocAlreadySaved => 'ذخیره شده';

  @override
  String settingsLocAlreadySavedName(String name) {
    return '$name از قبل در مکان‌های ذخیره‌شده هست.';
  }

  @override
  String get settingsLocClose => 'بستن';

  @override
  String settingsLocCoords(String lat, String lon) {
    return 'عرض $lat، طول $lon';
  }

  @override
  String get settingsLocCustomBadge => 'دلخواه';

  @override
  String get settingsLocDegrees => 'درجه';

  @override
  String get settingsLocDelete => 'حذف';

  @override
  String get settingsLocDeleteBody => 'این مکان از فهرست شما برداشته می‌شود.';

  @override
  String get settingsLocDeleteLast => 'آخرین مکان را نمی‌توان حذف کرد.';

  @override
  String settingsLocDeleteTitle(String name) {
    return '$name حذف شود؟';
  }

  @override
  String get settingsLocEast => 'شرقی';

  @override
  String get settingsLocEdit => 'ویرایش';

  @override
  String get settingsLocElevation => 'ارتفاع از سطح دریا (متر)';

  @override
  String settingsLocErrElevation(String min, String max) {
    return 'ارتفاع باید بین $min و $max متر باشد.';
  }

  @override
  String settingsLocErrLatitude(String min, String max) {
    return 'عرض جغرافیایی باید عددی بین $min و $max باشد.';
  }

  @override
  String settingsLocErrLongitude(String min, String max) {
    return 'طول جغرافیایی باید عددی بین $min و $max باشد.';
  }

  @override
  String get settingsLocErrName => 'نام را وارد کنید.';

  @override
  String settingsLocErrOffset(String min, String max) {
    return 'اختلاف ساعت باید بین $min و $max باشد.';
  }

  @override
  String get settingsLocErrZone => 'منطقه‌ی زمانی را از فهرست انتخاب کنید.';

  @override
  String get settingsLocFormatDecimal => 'درجه‌ی اعشاری';

  @override
  String get settingsLocFormatDms => 'درجه، دقیقه، ثانیه';

  @override
  String get settingsLocLatitude => 'عرض جغرافیایی';

  @override
  String get settingsLocLongitude => 'طول جغرافیایی';

  @override
  String get settingsLocMinutes => 'دقیقه';

  @override
  String get settingsLocName => 'نام';

  @override
  String get settingsLocNoResults => 'شهری پیدا نشد.';

  @override
  String get settingsLocNorth => 'شمالی';

  @override
  String get settingsLocProvince => 'استان';

  @override
  String get settingsLocSave => 'ذخیره';

  @override
  String get settingsLocSavedHelp => 'اوقات شرعی برای مکان فعال محاسبه می‌شود.';

  @override
  String get settingsLocSavedTitle => 'مکان‌های ذخیره‌شده';

  @override
  String get settingsLocSearchHint => 'جستجوی شهر';

  @override
  String get settingsLocSeconds => 'ثانیه';

  @override
  String get settingsLocSetActive => 'فعال کن';

  @override
  String get settingsLocSouth => 'جنوبی';

  @override
  String get settingsLocWest => 'غربی';

  @override
  String get settingsLocZoneNone => 'منطقه‌ای پیدا نشد.';

  @override
  String get settingsLocZoneSearch => 'جستجوی منطقه‌ی زمانی';

  @override
  String settingsLocZoneSelected(String zone) {
    return 'منطقه‌ی زمانی انتخاب‌شده: $zone';
  }

  @override
  String get settingsMethodCustom => 'دلخواه';

  @override
  String get settingsMethodEgypt => 'سازمان نقشه‌برداری مصر';

  @override
  String get settingsMethodIsna => 'جامعه‌ی اسلامی آمریکای شمالی';

  @override
  String get settingsMethodJafari => 'شیعه اثنی‌عشری، مؤسسه‌ی لوا (قم)';

  @override
  String get settingsMethodKarachi => 'دانشگاه علوم اسلامی کراچی';

  @override
  String get settingsMethodMakkah => 'دانشگاه ام‌القری، مکه';

  @override
  String get settingsMethodMwl => 'رابطه‌ی جهان اسلام';

  @override
  String get settingsMethodTehran => 'مؤسسه‌ی ژئوفیزیک دانشگاه تهران';

  @override
  String get settingsMidnightJafari => 'میانه‌ی غروب تا اذان صبح';

  @override
  String get settingsMidnightStandard => 'میانه‌ی غروب تا طلوع';

  @override
  String get settingsOff => 'خاموش';

  @override
  String settingsPercent(String value) {
    return '$value٪';
  }

  @override
  String get settingsRemChime => 'صدای ملایم یادآوری';

  @override
  String get settingsRemChimeHelp =>
      'همراه اعلان یادآوری یک زنگ آرام پخش می‌شود.';

  @override
  String get settingsRemChimeTest => 'پخش نمونه';

  @override
  String settingsRemHelp(String max) {
    return '۰ یعنی خاموش؛ تا $max دقیقه پیش از اذان.';
  }

  @override
  String get settingsRemIndependent =>
      'خاموش کردن یادآوری هرگز روی اذان اثر نمی‌گذارد.';

  @override
  String settingsRemSummary(String minutes) {
    return '$minutes دقیقه پیش از اذان';
  }

  @override
  String settingsRemTitle(String prayer) {
    return 'یادآوری پیش از $prayer';
  }

  @override
  String get settingsResetConfirm => 'پاک کردن';

  @override
  String get settingsResetConfirmBody =>
      'تنظیمات به حالت اولیه برمی‌گردد و مکان فعال تهران می‌شود. این کار برگشت‌پذیر نیست.';

  @override
  String get settingsResetConfirmTitle => 'همه‌ی تنظیمات پاک شود؟';

  @override
  String get settingsResetDone => 'تنظیمات به حالت اولیه برگشت.';

  @override
  String get settingsResetHelp =>
      'همه‌ی تنظیمات، مکان‌های ذخیره‌شده و بیدارباش‌ها پاک می‌شود.';

  @override
  String get settingsResetTitle => 'بازگشت به تنظیمات اولیه';

  @override
  String get settingsSaved => 'ذخیره شد';

  @override
  String get settingsSectionAbout => 'درباره و عیب‌یابی';

  @override
  String get settingsSectionApp => 'برنامه';

  @override
  String get settingsSectionAzan => 'اذان';

  @override
  String get settingsSectionCalculation => 'محاسبه';

  @override
  String get settingsSectionDisplay => 'نمایش';

  @override
  String get settingsSectionLocation => 'مکان';

  @override
  String get settingsSectionReminders => 'یادآوری';

  @override
  String get settingsSectionTime => 'زمان';

  @override
  String get settingsSectionsLabel => 'بخش‌های تنظیمات';

  @override
  String get settingsThemeDark => 'تیره';

  @override
  String get settingsThemeLight => 'روشن';

  @override
  String get settingsThemeSystem => 'مطابق ویندوز';

  @override
  String get settingsTimeCheck => 'بررسی ساعت با زمان شبکه';

  @override
  String get settingsTimeCheckHelp =>
      'هنگام شروع برنامه و هر شش ساعت یک بار؛ پیش‌فرض خاموش است.';

  @override
  String get settingsTimeCheckNow => 'اکنون بررسی کن';

  @override
  String settingsTimeCheckedAt(String time) {
    return 'بررسی در ساعت $time';
  }

  @override
  String get settingsTimeChecking => 'در حال بررسی…';

  @override
  String get settingsTimeCorrect => 'اصلاح ساعت در برنامه';

  @override
  String get settingsTimeCorrectHelp => 'ساعت ویندوز هرگز تغییر نمی‌کند.';

  @override
  String settingsTimeDiagLocation(String offset) {
    return 'اختلاف مکان فعال طبق پایگاه‌داده: $offset';
  }

  @override
  String get settingsTimeDiagOk => 'مشکلی در ساعت دیده نشد.';

  @override
  String get settingsTimeDiagTitle => 'عیب‌یابی ساعت';

  @override
  String settingsTimeDiagWindows(String offset) {
    return 'اختلاف ساعت ویندوز با زمان جهانی: $offset';
  }

  @override
  String get settingsTimeError =>
      'اتصال به کارساز زمان ممکن نشد. اینترنت و نام کارساز را بررسی کنید.';

  @override
  String get settingsTimeNever => 'هنوز بررسی نشده است.';

  @override
  String get settingsTimeServer => 'کارساز زمان';

  @override
  String get settingsTimeServerHelp => 'نام کارساز زمان، مثلاً pool.ntp.org';

  @override
  String get settingsTimeServerInvalid => 'نام کارساز معتبر نیست.';

  @override
  String settingsTimeSkewAhead(String amount) {
    return 'ساعت رایانه $amount جلو است.';
  }

  @override
  String settingsTimeSkewBehind(String amount) {
    return 'ساعت رایانه $amount عقب است.';
  }

  @override
  String get settingsTimeSkewZero => 'ساعت رایانه با زمان شبکه یکی است.';

  @override
  String get settingsTimeStatusTitle => 'آخرین بررسی';

  @override
  String get settingsZoneAuto => 'خودکار (پیشنهادی)';

  @override
  String settingsZoneAutoHelp(String zone) {
    return 'از پایگاه‌داده‌ی منطقه‌های زمانی برنامه استفاده می‌شود: $zone';
  }

  @override
  String get settingsZoneFixed => 'اختلاف ثابت';

  @override
  String get settingsZoneFixedAllYear =>
      'اختلاف ثابت است و در همه‌ی روزهای سال یکسان می‌ماند.';

  @override
  String get settingsZoneFixedHelp =>
      'یک اختلاف ثابت با زمان جهانی که در همه‌ی روزهای سال یکسان است.';

  @override
  String settingsZoneFixedValue(String offset) {
    return 'اختلاف ثابت: $offset';
  }

  @override
  String get settingsZoneHourLess => 'یک ساعت کمتر';

  @override
  String get settingsZoneHourMore => 'یک ساعت بیشتر';

  @override
  String settingsZoneNext(String date, String time, String offset) {
    return 'تغییر بعدی: $date، ساعت $time، اختلاف $offset';
  }

  @override
  String get settingsZoneNoChange =>
      'تغییر دیگری برای این منطقه‌ی زمانی برنامه‌ریزی نشده است.';

  @override
  String settingsZoneNow(String offset) {
    return 'اختلاف با زمان جهانی در امروز: $offset';
  }

  @override
  String get settingsZoneQuarterLess => 'یک ربع ساعت کمتر';

  @override
  String get settingsZoneQuarterMore => 'یک ربع ساعت بیشتر';

  @override
  String get settingsZoneTitle => 'منطقه‌ی زمانی';

  @override
  String get supportAvailableIn => 'قابل استفاده در:';

  @override
  String get supportCardCountries =>
      'فقط ایران: کارت‌های بانکی ایرانی عضو شبکه‌ی شتاب. از خارج از ایران با این کارت نمی‌شود پرداخت کرد؛ از رمزارز استفاده کنید.';

  @override
  String get supportCardNumberLabel => 'شماره‌ی کارت';

  @override
  String get supportCardTitle => 'کارت بانکی ایران';

  @override
  String get supportCheckNote =>
      'پیش از پرداخت، شماره یا آدرس را با نشانی رسمی پروژه در GitHub هم تطبیق دهید. ممنون از حمایت شما.';

  @override
  String get supportCryptoAddressLabel => 'آدرس کیف پول';

  @override
  String get supportCryptoCountries =>
      'همه‌ی کشورها: از هر جا که کیف پول یا صرافی رمزارز در دسترس باشد، بدون نیاز به کارت بانکی.';

  @override
  String get supportCryptoNetworkLabel => 'شبکه';

  @override
  String get supportCryptoNetworkValue => 'BEP20 (BNB Smart Chain یا BSC)';

  @override
  String get supportCryptoTitle => 'رمزارز USDT (تتر)';

  @override
  String get supportCryptoWarning =>
      'فقط USDT را از طریق شبکه‌ی BEP20 بفرستید. ارسال رمزارز دیگر یا ارسال از شبکه‌ی دیگر به این آدرس باعث از دست رفتن مبلغ می‌شود.';

  @override
  String get supportIntro =>
      'این برنامه رایگان است، تبلیغ ندارد، حساب کاربری نمی‌خواهد و هیچ قابلیتی پشت پرداخت قفل نیست. اگر برایتان مفید بود و خواستید از ادامه‌ی توسعه‌ی آن حمایت کنید، از یکی از راه‌های زیر استفاده کنید. حمایت کاملاً اختیاری است و از هر مبلغی سپاسگزارم.';

  @override
  String get supportTitle => 'حمایت مالی';

  @override
  String get timetableCalendarSwitch => 'نوع تقویم';

  @override
  String get timetableColDay => 'روز';

  @override
  String get timetableColWeekday => 'روز هفته';

  @override
  String get timetableMonthUnavailable => 'این ماه در جدول تقویم قمری نیست.';

  @override
  String get timetableNextMonth => 'ماه بعد';

  @override
  String timetableOpenDay(String date) {
    return 'نمایش $date در صفحه‌ی خانه';
  }

  @override
  String get timetablePreviousMonth => 'ماه قبل';

  @override
  String get timetableToday => 'امروز';

  @override
  String get trayMenuLocation => 'مکان';

  @override
  String get trayMenuMute => 'بی‌صدا';

  @override
  String get trayMenuMuted => 'بی‌صدا (فعال)';

  @override
  String get trayMenuQuit => 'خروج';

  @override
  String get trayMenuSettings => 'تنظیمات';

  @override
  String get trayMenuShow => 'نمایش پنجره';

  @override
  String get trayMenuStopAzan => 'توقف اذان';

  @override
  String get trayMuteCancel => 'لغو بی‌صدا';

  @override
  String trayMuteHours(String n) {
    return '$n ساعت';
  }

  @override
  String get trayMuteIndefinite => 'تا اطلاع ثانوی';

  @override
  String get trayMuteUntilNext => 'تا اذان بعدی';

  @override
  String trayNextLine(String prayer, String time) {
    return 'بعدی: $prayer · $time';
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
  String get wakeAdd => 'افزودن';

  @override
  String get wakeAfterHibernate => 'پس از صدا: خواب زمستانی';

  @override
  String get wakeAfterHibernateChoice => 'خواب زمستانی';

  @override
  String get wakeAfterNote =>
      'پیش از خواب یا خواب زمستانی، یک شمارش معکوس سی‌ثانیه‌ای فرصت لغو می‌دهد.';

  @override
  String get wakeAfterNothing => 'کاری نکن';

  @override
  String get wakeAfterSleep => 'پس از صدا: خواب';

  @override
  String get wakeAfterSleepChoice => 'خواب';

  @override
  String get wakeAfterTitle => 'پس از پایان صدا';

  @override
  String get wakeCancel => 'انصراف';

  @override
  String get wakeCapabilityChecking => 'در حال بررسی این رایانه…';

  @override
  String get wakeCapabilityOkBody =>
      'بررسی مانعی پیدا نکرد. برای اطمینان، آزمایش دو دقیقه‌ای را اجرا کنید.';

  @override
  String get wakeCapabilityOkTitle => 'این رایانه می‌تواند خودش را بیدار کند';

  @override
  String get wakeCapabilityRefresh => 'بررسی دوباره';

  @override
  String get wakeCapabilityUnknown => 'هنوز بررسی نشده است.';

  @override
  String get wakeCapabilityWarnTitle =>
      'ممکن است این رایانه برای بیدارباش بیدار نشود';

  @override
  String get wakeChoiceFixed => 'ساعت معین';

  @override
  String get wakeChoiceRelative => 'قبل از یک نماز';

  @override
  String get wakeChooseFile => 'انتخاب فایل…';

  @override
  String get wakeCountdownAfterAlarm => 'بیدارباش تمام شد.';

  @override
  String get wakeCountdownCancel => 'لغو';

  @override
  String wakeCountdownHibernate(String time) {
    return 'رایانه تا $time دیگر به خواب زمستانی می‌رود.';
  }

  @override
  String wakeCountdownSleep(String time) {
    return 'رایانه تا $time دیگر به خواب می‌رود.';
  }

  @override
  String get wakeDelete => 'حذف';

  @override
  String get wakeDeleteBody =>
      'بیدارباش و درخواست بیدار شدن آن از ویندوز برداشته می‌شود.';

  @override
  String get wakeDeleteConfirm => 'حذف';

  @override
  String get wakeDeleteTitle => 'این بیدارباش حذف شود؟';

  @override
  String get wakeDismiss => 'بستن';

  @override
  String get wakeEdit => 'ویرایش';

  @override
  String get wakeEditorTitleAdd => 'بیدارباش جدید';

  @override
  String get wakeEditorTitleEdit => 'ویرایش بیدارباش';

  @override
  String get wakeEmpty =>
      'هنوز بیدارباشی نساخته‌اید. یکی اضافه کنید تا رایانه در ساعت دلخواه بیدار شود.';

  @override
  String get wakeEnabledSwitch => 'روشن';

  @override
  String wakeErrorMinutes(String min, String max) {
    return 'عددی صحیح بین $min تا $max بنویسید.';
  }

  @override
  String get wakeFieldHour => 'ساعت';

  @override
  String get wakeFieldLabel => 'نام (اختیاری)';

  @override
  String get wakeFieldMinute => 'دقیقه';

  @override
  String get wakeFieldMinutesBefore => 'چند دقیقه قبل';

  @override
  String get wakeFieldPrayer => 'وقت';

  @override
  String get wakeHibernateNow => 'خواب زمستانی';

  @override
  String get wakeIssueImportantOnly =>
      'ویندوز فقط تایمرهای «مهم» را اجازه می‌دهد که معمولاً شامل این برنامه نیست.';

  @override
  String get wakeIssueInProcessTimer => 'تایمر پشتیبان داخل برنامه ساخته نشد.';

  @override
  String get wakeIssueModernStandby =>
      'این رایانه از حالت «آماده‌به‌کار مدرن» استفاده می‌کند که بیدار شدن در ساعت معین در آن اغلب نامطمئن است.';

  @override
  String get wakeIssueTaskCreationFailed =>
      'ویندوز اجازه‌ی ساختن وظیفه‌ی زمان‌بندی‌شده برای حساب شما را نداد؛ بیدارباش فقط تا وقتی برنامه باز است کار می‌کند.';

  @override
  String get wakeIssueTimersOffAc =>
      'ویندوز هنگام اتصال به برق، تایمرهای بیدارکننده را خاموش کرده است.';

  @override
  String get wakeIssueTimersOffBattery =>
      'ویندوز هنگام کار با باتری، تایمرهای بیدارکننده را خاموش کرده است.';

  @override
  String get wakeIssueUnknown =>
      'تنظیم تایمرهای بیدارکننده‌ی ویندوز خوانده نشد.';

  @override
  String get wakeListSeparator => '، ';

  @override
  String wakeNext(String remaining, String time) {
    return 'بعدی: $remaining ($time)';
  }

  @override
  String get wakeNextNone => 'بعدی: —';

  @override
  String wakeNextOtherDay(String remaining, String weekday, String time) {
    return 'بعدی: $remaining ($weekday $time)';
  }

  @override
  String get wakeOff => 'خاموش';

  @override
  String get wakeOpenPowerFailed =>
      'تنظیمات برق باز نشد. از «کنترل پنل ← گزینه‌های برق» خودتان آن را باز کنید.';

  @override
  String get wakeOpenPowerOptions => 'باز کردن تنظیمات برق ویندوز';

  @override
  String wakePercent(String percent) {
    return '$percent٪';
  }

  @override
  String get wakePlaySound => 'پخش صدا';

  @override
  String get wakePowerHint =>
      'در ویندوز: گزینه‌های برق ← تغییر تنظیمات طرح ← تنظیمات پیشرفته ← خواب ← اجازه‌ی تایمرهای بیدارکننده. برنامه هیچ تنظیم برقی را خودش تغییر نمی‌دهد.';

  @override
  String get wakePreview => 'پیش‌شنود';

  @override
  String get wakePreviewStop => 'توقف پیش‌شنود';

  @override
  String get wakeProblemHibernateUnavailable =>
      'خواب زمستانی در این رایانه روشن نیست.';

  @override
  String get wakeProblemProbeFailed => 'بررسی این رایانه کامل نشد.';

  @override
  String get wakeProblemSoundFailed =>
      'صدای بیدارباش پخش نشد. فایل صدا و بلندگو را بررسی کنید.';

  @override
  String get wakeProblemSuspendRefused => 'ویندوز اجازه‌ی خواب نداد.';

  @override
  String get wakeRepeatDaily => 'هر روز';

  @override
  String get wakeRepeatOnce => 'یک بار';

  @override
  String get wakeRepeatTitle => 'تکرار';

  @override
  String wakeRepeatWeekdays(String days) {
    return 'در روزهای $days';
  }

  @override
  String get wakeRepeatWeekdaysChoice => 'روزهای انتخابی';

  @override
  String get wakeRinging => 'بیدارباش در حال پخش است';

  @override
  String get wakeSave => 'ذخیره';

  @override
  String get wakeSaveFailed =>
      'این مقادیر ذخیره نشد. ساعت و روزها را بررسی کنید.';

  @override
  String get wakeSleepHint =>
      'رایانه پس از یک شمارش معکوس پنج‌ثانیه‌ای که می‌توانید لغو کنید، می‌خوابد.';

  @override
  String get wakeSleepNow => 'خواب';

  @override
  String get wakeSoundDefault => 'صدای پیش‌فرض اذان';

  @override
  String wakeSoundFile(String name) {
    return 'فایل: $name';
  }

  @override
  String get wakeSoundTitle => 'صدا';

  @override
  String get wakeStop => 'توقف';

  @override
  String get wakeSyncError =>
      'درخواست بیدار شدن به ویندوز ثبت نشد؛ بیدارباش ممکن است فقط تا وقتی برنامه باز است کار کند.';

  @override
  String get wakeTest => 'آزمایش در دو دقیقه';

  @override
  String get wakeTestCancel => 'لغو آزمایش';

  @override
  String wakeTestPending(String time) {
    return 'بیدارباش آزمایشی ساعت $time زنگ می‌زند. حالا رایانه را بخوابانید تا ببینید بیدار می‌شود.';
  }

  @override
  String get wakeTitle => 'بیدارباش';

  @override
  String wakeTriggerAtPrayer(String prayer) {
    return 'هنگام $prayer';
  }

  @override
  String wakeTriggerFixed(String time) {
    return 'ساعت $time';
  }

  @override
  String wakeTriggerRelative(String minutes, String prayer) {
    return '$minutes قبل از $prayer';
  }

  @override
  String get wakeTriggerTypeTitle => 'زمان';

  @override
  String get wakeUseDefault => 'صدای پیش‌فرض';

  @override
  String get wakeVolume => 'بلندی صدا';

  @override
  String get wakeWeekdaysError => 'دست‌کم یک روز را انتخاب کنید.';
}
