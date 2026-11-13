// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get aboutAuthorIntro =>
      'یہ ایپ ایک آزاد ڈیولپر نے بنائی ہے اور وہی اس کی دیکھ بھال کرتا ہے۔ کوئی مسئلہ بتانے، تجویز دینے یا مل کر کام کرنے کے لیے رابطہ کریں۔';

  @override
  String get aboutAuthorTitle => 'ڈیولپر کے بارے میں';

  @override
  String get aboutContactEmail => 'ای میل';

  @override
  String get aboutContactGithub => 'GitHub';

  @override
  String get aboutContactName => 'نام';

  @override
  String get aboutContactPhone => 'موبائل';

  @override
  String get aboutContactTelegram => 'ٹیلیگرام';

  @override
  String get aboutCopiedValue => 'کاپی ہو گیا۔';

  @override
  String get aboutCopy => 'کاپی';

  @override
  String get aboutFontNote =>
      'Vazirmatn فونٹ SIL Open Font License 1.1 کے تحت ایپ کے ساتھ شامل ہے۔';

  @override
  String get aboutLicenceNote =>
      'یہ ایپ MIT لائسنس کے تحت جاری کی گئی ہے: آپ اسے آزادی سے استعمال، تبدیل اور شیئر کر سکتے ہیں۔';

  @override
  String get aboutLicences => 'اوپن سورس لائسنس';

  @override
  String get aboutOpen => 'کھولیں';

  @override
  String get aboutOpenFailed =>
      'کھولا نہیں جا سکا۔ پتہ کاپی کریں اور اپنے براؤزر یا میل پروگرام میں چسپاں کر دیں۔';

  @override
  String get aboutPhoneNote =>
      'کال اور ایس ایم ایس صرف ایران کے اندر سے۔ ایران سے باہر سے صرف ٹیلیگرام استعمال کریں۔';

  @override
  String get aboutSoundNote =>
      'ایپ کے ساتھ شامل آوازیں (طے شدہ اذان اور یاد دہانی کی گھنٹی) سادہ مصنوعی نمونے ہیں، کسی کی ریکارڈنگ نہیں ہیں اور CC0 کے تحت جاری کی گئی ہیں۔ اپنی پسند کی اذان کی آواز ترتیبات میں منتخب کریں۔';

  @override
  String get aboutTagline =>
      'Windows کے لیے اوقاتِ نماز اور اذان۔ انٹرنیٹ کے بغیر چلتی ہے، نہ اشتہارات، نہ اکاؤنٹ اور نہ ٹریکنگ۔';

  @override
  String get aboutTitle => 'تعارف';

  @override
  String aboutVersion(String version) {
    return 'ورژن $version';
  }

  @override
  String get appName => 'Salaat | Aviny Prayer Times';

  @override
  String get calendarAdjustEarlier => 'ایک دن پہلے';

  @override
  String get calendarAdjustLater => 'ایک دن بعد';

  @override
  String calendarAdjustValue(String value) {
    return '$value دن';
  }

  @override
  String calendarConvErrDay(String first, String days) {
    return 'دن $first سے $days تک ہونا چاہیے۔';
  }

  @override
  String get calendarConvErrIncomplete => 'سال، مہینہ اور دن مکمل کریں۔';

  @override
  String get calendarConvErrMonth => 'مہینہ ایک سے بارہ تک ہونا چاہیے۔';

  @override
  String get calendarConvErrNumber => 'صرف ہندسے لکھیں۔';

  @override
  String get calendarConvErrRange => 'یہ تاریخ کیلنڈر کی معاون حد سے باہر ہے۔';

  @override
  String get calendarConverterHint =>
      'تینوں کیلنڈروں میں سے کسی ایک میں تاریخ لکھیں؛ باقی دو ساتھ ہی بدل جائیں گے۔';

  @override
  String get calendarConverterShow => 'کیلنڈر میں دکھائیں';

  @override
  String get calendarConverterTitle => 'تاریخ کنورٹر';

  @override
  String calendarDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get calendarFieldDay => 'دن';

  @override
  String get calendarFieldMonth => 'مہینہ';

  @override
  String get calendarFieldYear => 'سال';

  @override
  String get calendarGridLabel => 'ماہانہ کیلنڈر';

  @override
  String get calendarHijriAdjust => 'قمری تاریخ میں ردوبدل';

  @override
  String get calendarHijriApproxHint =>
      'تقریبی: ایران کا سرکاری قمری کیلنڈر چاند دیکھنے پر مبنی ہے اور ایک دن کا فرق ہو سکتا ہے۔';

  @override
  String get calendarHijriUnavailable =>
      'جدول میں اس دن کی قمری تاریخ موجود نہیں';

  @override
  String get calendarKindGregorian => 'عیسوی';

  @override
  String get calendarKindHijri => 'قمری ہجری';

  @override
  String get calendarKindJalali => 'شمسی ہجری';

  @override
  String calendarMonthGregorian(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'جنوری',
      'm2': 'فروری',
      'm3': 'مارچ',
      'm4': 'اپریل',
      'm5': 'مئی',
      'm6': 'جون',
      'm7': 'جولائی',
      'm8': 'اگست',
      'm9': 'ستمبر',
      'm10': 'اکتوبر',
      'm11': 'نومبر',
      'm12': 'دسمبر',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthHijri(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'محرم',
      'm2': 'صفر',
      'm3': 'ربیع الاول',
      'm4': 'ربیع الثانی',
      'm5': 'جمادی الاول',
      'm6': 'جمادی الثانی',
      'm7': 'رجب',
      'm8': 'شعبان',
      'm9': 'رمضان',
      'm10': 'شوال',
      'm11': 'ذی قعدہ',
      'm12': 'ذی الحجہ',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthJalali(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'فروردین',
      'm2': 'اردیبہشت',
      'm3': 'خرداد',
      'm4': 'تیر',
      'm5': 'مرداد',
      'm6': 'شہریور',
      'm7': 'مہر',
      'm8': 'آبان',
      'm9': 'آذر',
      'm10': 'دی',
      'm11': 'بہمن',
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
      'قمری تاریخ ام القریٰ جدول سے لی گئی ہے۔ ایران کا سرکاری کیلنڈر چاند دیکھنے پر مبنی ہے اور ایک دن کا فرق ہو سکتا ہے؛ ایسی صورت میں اسے یہاں آگے پیچھے کر لیں۔';

  @override
  String get calendarNextMonth => 'اگلا مہینہ';

  @override
  String get calendarOpenOnHome => 'ہوم اسکرین پر دکھائیں';

  @override
  String get calendarPanelTimes => 'اس دن کے اوقاتِ نماز';

  @override
  String get calendarPreviousMonth => 'پچھلا مہینہ';

  @override
  String get calendarSeparator => '، ';

  @override
  String get calendarToday => 'آج';

  @override
  String calendarWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'پیر',
      'd2': 'منگل',
      'd3': 'بدھ',
      'd4': 'جمعرات',
      'd5': 'جمعہ',
      'd6': 'ہفتہ',
      'd7': 'اتوار',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'پیر',
      'd2': 'منگل',
      'd3': 'بدھ',
      'd4': 'جمعرات',
      'd5': 'جمعہ',
      'd6': 'ہفتہ',
      'd7': 'اتوار',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get contributeIntro =>
      'اس ایپ کا کوڈ GitHub پر ہے اور ہر طرح کی مدد کا خیر مقدم ہے۔ شرکت کے طریقے:';

  @override
  String get contributeOpenGuide => 'شرکت کی گائیڈ';

  @override
  String get contributeOpenIssues => 'مسئلہ یا تجویز بھیجیں';

  @override
  String get contributeOpenRepo => 'GitHub پر ریپوزٹری کھولیں';

  @override
  String get contributeTitle => 'حصہ ڈالیں';

  @override
  String get contributeWayCode =>
      'کوڈ: ریپوزٹری کو Fork کریں، تبدیلی کسی برانچ میں کریں، ٹیسٹ چلائیں اور Pull Request بھیجیں۔ بلڈ اور ٹیسٹ کے مراحل CONTRIBUTING.md میں ہیں۔';

  @override
  String get contributeWayData =>
      'ڈیٹا: کسی شہر کا نام، نقاط یا ٹائم زون درست کریں، یا نیا شہر شامل کریں۔';

  @override
  String get contributeWayIssues =>
      'مسئلہ یا تجویز: GitHub پر Issue کھولیں اور اس صفحے سے ورژن اور تشخیصی رپورٹ ساتھ لگائیں (اس میں نام یا نقاط نہیں ہوتے)۔';

  @override
  String get contributeWayTest =>
      'ٹیسٹنگ: ایپ کو Windows کے مختلف ورژنز اور ہارڈویئر پر آزمائیں (اذان، ٹرے، جگانے والے الارم) اور جو کچھ دیکھیں اس کی رپورٹ دیں۔';

  @override
  String get contributeWayTranslate =>
      'ترجمہ: ایپ کی عبارتیں lib/l10n فولڈر میں ہیں۔ نئی زبان یا موجودہ ترجمے کی اصلاح بھیجیں؛ کسی اہلِ زبان کی جانچ بہت قیمتی ہے۔';

  @override
  String get diagAudioFailed =>
      'آزمائشی آواز نہیں چل سکی۔ اسپیکر اور Windows کی آواز چیک کریں۔';

  @override
  String get diagAudioOk => 'آزمائشی آواز چل گئی۔';

  @override
  String get diagAudioPlay => 'آزمائشی آواز چلائیں';

  @override
  String get diagAudioStop => 'روکیں';

  @override
  String get diagAudioTitle => 'آواز کی آزمائش';

  @override
  String get diagClockOk => 'گھڑی میں کوئی مسئلہ نہیں ملا۔';

  @override
  String get diagClockTitle => 'گھڑی';

  @override
  String get diagClockUnchecked =>
      'کوئی مسئلہ نظر نہیں آیا، لیکن نیٹ ورک ٹائم سے جانچ بند ہے، اس لیے گھڑی کا فرق ناپا نہیں جاتا۔';

  @override
  String get diagCopied =>
      'کلپ بورڈ پر کاپی ہو گیا۔ اس میں نام اور درست نقاط شامل نہیں ہیں۔';

  @override
  String get diagCopy => 'تشخیصی رپورٹ کاپی کریں';

  @override
  String get diagCopyFailed => 'کاپی نہیں ہو سکا۔';

  @override
  String diagEventAzan(String prayer) {
    return 'اذان: $prayer';
  }

  @override
  String diagEventReminder(String prayer) {
    return 'یاد دہانی: $prayer';
  }

  @override
  String diagEventTimes(String utc, String local) {
    return 'UTC $utc | مقامی $local';
  }

  @override
  String get diagEventWake => 'جگانے والا الارم';

  @override
  String get diagEventsEmpty => 'کچھ بھی شیڈول نہیں ہے۔';

  @override
  String get diagEventsTitle => 'اگلے شیڈول شدہ واقعات';

  @override
  String get diagLogNone => 'دستیاب نہیں۔';

  @override
  String get diagLogTitle => 'لاگ فائلیں';

  @override
  String get diagTitle => 'تشخیص';

  @override
  String diagValue(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'yes': 'ہاں',
      'no': 'نہیں',
      'unknown': 'نامعلوم',
      'enabled': 'اجازت ہے',
      'disabled': 'بند',
      'importantOnly': 'صرف اہم',
      'ok': 'درست چلتا ہے',
      'failed': 'ناکام',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String diagWakeAc(String value) {
    return 'جگانے والے ٹائمر، بجلی لگی ہونے پر: $value';
  }

  @override
  String diagWakeBattery(String value) {
    return 'جگانے والے ٹائمر، بیٹری پر: $value';
  }

  @override
  String get diagWakeCheck => 'ابھی جانچیں';

  @override
  String diagWakeInProcess(String value) {
    return 'ایپ کے اندر ٹائمر: $value';
  }

  @override
  String diagWakeModern(String value) {
    return 'ماڈرن اسٹینڈ بائی: $value';
  }

  @override
  String get diagWakeNotChecked => 'ابھی جانچ نہیں ہوئی۔';

  @override
  String diagWakeTask(String value) {
    return 'شیڈول شدہ ٹاسک: $value';
  }

  @override
  String get diagWakeTitle => 'جگانے کی جانچ';

  @override
  String get formatAm => 'صبح';

  @override
  String formatHours(String hours) {
    return '$hours گھنٹے';
  }

  @override
  String formatHoursMinutes(String hours, String minutes) {
    return '$hours گھنٹے $minutes منٹ';
  }

  @override
  String formatMinutes(String minutes) {
    return '$minutes منٹ';
  }

  @override
  String get formatPm => 'شام';

  @override
  String formatRemaining(String duration) {
    return '$duration بعد';
  }

  @override
  String formatRemainingLessThan(String minutes) {
    return '$minutes منٹ سے بھی کم میں';
  }

  @override
  String formatSeconds(String seconds) {
    return '$seconds سیکنڈ';
  }

  @override
  String get homeAzanMutedIndefinite =>
      'اذان: خاموش، جب تک آپ دوبارہ آن نہ کریں';

  @override
  String homeAzanMutedUntil(String time) {
    return 'اذان: $time تک خاموش';
  }

  @override
  String get homeAzanOff => 'اذان: بند';

  @override
  String get homeAzanOn => 'اذان: چالو';

  @override
  String homeAzanToggleOff(String prayer) {
    return '$prayer کی اذان بند کریں';
  }

  @override
  String homeAzanToggleOn(String prayer) {
    return '$prayer کی اذان چالو کریں';
  }

  @override
  String get homeBackToToday => 'آج پر واپس';

  @override
  String get homeBannerAllow => 'اجازت';

  @override
  String homeBannerClockSkew(String amount) {
    return 'کمپیوٹر کی گھڑی تقریباً $amount غلط ہے۔';
  }

  @override
  String get homeBannerDismiss => 'بند کریں';

  @override
  String get homeBannerExactTiming =>
      'اینڈرائیڈ اذان چند منٹ دیر سے دے سکتا ہے۔ «اجازت» دبائیں اور کھلنے والے صفحے پر Salaat کے لیے Alarms & reminders آن کریں تاکہ اذان ٹھیک وقت پر آئے۔';

  @override
  String get homeBannerMutedIndefinite =>
      'اذان خاموش ہے، جب تک آپ دوبارہ آن نہ کریں۔';

  @override
  String homeBannerMutedUntil(String time) {
    return 'اذان $time تک خاموش ہے۔';
  }

  @override
  String get homeBannerNotificationsOff =>
      'اطلاعات بند ہیں، اس لیے ایپ بند ہونے پر اذان نہیں بجے گی۔ «اجازت» دبائیں اور Salaat کے لیے اطلاعات آن کریں۔';

  @override
  String get homeBannerSettingsReset =>
      'ترتیبات کی فائل پڑھی نہیں جا سکی اور ترتیبات طے شدہ قدروں پر واپس کر دی گئیں۔';

  @override
  String get homeBannerStaleZone =>
      'Windows اس مقام کے لیے ٹائم زون ڈیٹا بیس سے مختلف وقت دکھا رہی ہے۔ ایپ کے اوقات درست ہیں؛ Windows کی گھڑی چیک کریں۔';

  @override
  String homeCompass(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'p0': 'شمال',
      'p1': 'شمال مشرق',
      'p2': 'مشرق',
      'p3': 'جنوب مشرق',
      'p4': 'جنوب',
      'p5': 'جنوب مغرب',
      'p6': 'مغرب',
      'p7': 'شمال مغرب',
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
    return '$date کے اوقات';
  }

  @override
  String homeEventAt(String event, String time) {
    return '$event $time';
  }

  @override
  String get homeHeroNoNext => 'الٹی گنتی کے لیے کوئی وقت نہیں';

  @override
  String get homeMute => 'خاموش';

  @override
  String get homeMuteCancel => 'خاموشی ختم کریں';

  @override
  String homeMuteForDuration(String duration) {
    return '$duration کے لیے';
  }

  @override
  String get homeMuteIndefinite => 'جب تک میں دوبارہ آن نہ کروں';

  @override
  String get homeMuteUntilNext => 'اگلی اذان تک';

  @override
  String get homeNextDay => 'اگلا دن';

  @override
  String get homeNextMarker => 'اگلی';

  @override
  String homeNextWakeAlarm(String value) {
    return 'اگلا الارم: $value';
  }

  @override
  String get homeNoTimesAction => 'حساب کی ترتیبات';

  @override
  String get homeNoTimesInfo =>
      'اس دن اس مقام کے لیے تمام اوقات کا حساب نہیں لگایا جا سکتا۔ آپ ترتیبات میں بلند عرض بلد کا اصول بدل سکتے ہیں۔';

  @override
  String get homeNoValue => '—';

  @override
  String homeNowPlaying(String prayer) {
    return 'چل رہی ہے: $prayer';
  }

  @override
  String get homeNowPlayingGeneric => 'اذان چل رہی ہے';

  @override
  String get homeOtherDayHint => 'اس دن کے اوقات؛ الٹی گنتی صرف آج کے لیے ہے۔';

  @override
  String get homePreviousDay => 'پچھلا دن';

  @override
  String homeQiblaSummary(String degrees, String direction) {
    return 'قبلہ: $degrees° $direction';
  }

  @override
  String homeReminderMinutes(String minutes) {
    return 'یاد دہانی: $minutes منٹ پہلے';
  }

  @override
  String get homeReminderOff => 'یاد دہانیاں: بند';

  @override
  String homeReminderRange(String min, String max) {
    return 'یاد دہانیاں: $min سے $max منٹ پہلے';
  }

  @override
  String get homeStatusTitle => 'کیفیت';

  @override
  String get homeStop => 'روکیں';

  @override
  String get homeSwitchLocation => 'مقام بدلیں';

  @override
  String get homeTimelineLabel => 'دن کی ٹائم لائن';

  @override
  String get homeToday => 'آج';

  @override
  String get homeTodayTimes => 'آج کے اوقات';

  @override
  String get homeTomorrowTimes => 'کل کے اوقات';

  @override
  String homeUntilEvent(String event) {
    return '$event تک';
  }

  @override
  String homeViewingDay(String date) {
    return '$date دیکھ رہے ہیں';
  }

  @override
  String get navCalendar => 'کیلنڈر';

  @override
  String get navHome => 'ہوم';

  @override
  String get navQibla => 'قبلہ';

  @override
  String get navSettings => 'ترتیبات';

  @override
  String get navTimetable => 'جدول';

  @override
  String get navWakeUp => 'جگانا';

  @override
  String notifAzanBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String get notifAzanFailed => 'اذان نہیں چلائی جا سکی۔';

  @override
  String notifAzanTitle(String prayer) {
    return '$prayer کی اذان';
  }

  @override
  String notifMissedBody(String time) {
    return '$time پر کمپیوٹر سو رہا تھا۔';
  }

  @override
  String notifMissedTitle(String prayer) {
    return '$prayer کی اذان نہیں چلی';
  }

  @override
  String notifReminderBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String notifReminderTitle(String minutes, String prayer) {
    return '$prayer میں $minutes منٹ باقی';
  }

  @override
  String get notifSoundFallback =>
      'اذان کی آواز کی فائل نہیں ملی؛ طے شدہ آواز چلائی گئی۔';

  @override
  String get notifStopAction => 'روکیں';

  @override
  String get notifTrayHint => 'ایپ Windows کی گھڑی کے ساتھ چلتی رہتی ہے۔';

  @override
  String get onboardingAzanBody =>
      'اذان سنیں اور طے کریں کہ ایپ Windows کے ساتھ شروع ہو یا نہیں۔';

  @override
  String get onboardingAzanTitle => 'اذان اور آغاز';

  @override
  String get onboardingBack => 'پیچھے';

  @override
  String get onboardingCityBody =>
      'اپنا شہر تلاش کریں یا کسی صوبے سے منتخب کریں۔';

  @override
  String get onboardingCityNone => 'کوئی شہر نہیں ملا۔';

  @override
  String get onboardingCitySearchHint => 'شہر تلاش کریں';

  @override
  String onboardingCitySelected(String city) {
    return 'منتخب: $city';
  }

  @override
  String get onboardingCityTitle => 'آپ کا شہر';

  @override
  String get onboardingFinish => 'شروع کریں';

  @override
  String get onboardingLanguageBody =>
      'اپنی زبان منتخب کریں۔ آپ اسے بعد میں ترتیبات میں بدل سکتے ہیں۔';

  @override
  String get onboardingLanguageTitle => 'زبان';

  @override
  String get onboardingModeList => 'ایران کے شہر (آف لائن فہرست)';

  @override
  String get onboardingModeOnline => 'دنیا کا کوئی بھی شہر (آن لائن تلاش)';

  @override
  String get onboardingNext => 'آگے';

  @override
  String get onboardingOnlineBody =>
      'آپ کا شہر فہرست میں نہیں؟ دنیا کا کوئی بھی شہر تلاش کریں۔ انٹرنیٹ صرف اسی تلاش کے لیے چاہیے، اس کے بعد ایپ انٹرنیٹ کے بغیر چلتی ہے۔';

  @override
  String get onboardingPreview => 'نمونے کی اذان چلائیں';

  @override
  String get onboardingProvinceAll => 'تمام صوبے';

  @override
  String get onboardingSkip => 'چھوڑیں';

  @override
  String get onboardingStartWithWindows => 'Windows کے ساتھ شروع کریں';

  @override
  String get onboardingStartWithWindowsHint =>
      'ایپ خاموشی سے سسٹم ٹرے میں شروع ہوتی ہے۔';

  @override
  String onboardingStepProgress(String step, String total) {
    return 'مرحلہ $step از $total';
  }

  @override
  String get onboardingStopPreview => 'روکیں';

  @override
  String get placeSearchAttribution =>
      'مقامات © OpenStreetMap کے معاونین (Nominatim)۔ ٹائم زون اور بلندی: Open-Meteo۔';

  @override
  String get placeSearchButton => 'تلاش';

  @override
  String get placeSearchFailBusy =>
      'تلاش کی سروس مصروف ہے۔ ایک منٹ رک کر دوبارہ کوشش کریں۔';

  @override
  String get placeSearchFailDetails =>
      'جگہ مل گئی مگر اس کا ٹائم زون حاصل نہیں ہو سکا۔ کنکشن جانچیں اور اسے دوبارہ منتخب کریں۔';

  @override
  String get placeSearchFailGeneric =>
      'تلاش نہیں ہو سکی۔ تھوڑی دیر بعد دوبارہ کوشش کریں۔';

  @override
  String get placeSearchFailOffline =>
      'انٹرنیٹ کنکشن نہیں ہے۔ جڑیں اور دوبارہ تلاش دبائیں۔ ایپ کا باقی حصہ انٹرنیٹ کے بغیر چلتا ہے۔';

  @override
  String get placeSearchFailTimeout =>
      'تلاش کی سروس نے وقت پر جواب نہیں دیا۔ دوبارہ کوشش کریں۔';

  @override
  String get placeSearchHint => 'شہر، ملک (مثلاً ممبئی، بھارت)';

  @override
  String placeSearchNone(String query) {
    return '«$query» کے لیے کوئی جگہ نہیں ملی۔ ہجے جانچیں یا ملک بھی لکھیں، مثلاً ممبئی، بھارت۔';
  }

  @override
  String get placeSearchNotice =>
      'تلاش کے لیے انٹرنیٹ صرف اسی بار درکار ہے۔ آپ جو لکھتے ہیں وہ OpenStreetMap کی تلاش کی سروس (Nominatim) کو بھیجا جاتا ہے، اور کچھ اور نہیں بھیجا جاتا۔ جگہ منتخب کرنے کے بعد ایپ ضروری معلومات محفوظ رکھتی ہے اور دوبارہ انٹرنیٹ کے بغیر چلتی ہے۔';

  @override
  String get placeSearchNoticeDetails =>
      'جب آپ کوئی جگہ منتخب کرتے ہیں تو اس کا ٹائم زون اور بلندی معلوم کرنے کے لیے اس جگہ کے نقاط Open-Meteo کو بھیجے جاتے ہیں۔';

  @override
  String placeSearchResolving(String place) {
    return '$place کا ٹائم زون اور بلندی حاصل کی جا رہی ہے…';
  }

  @override
  String get placeSearchResultsTitle => 'نتائج: اپنی جگہ منتخب کریں';

  @override
  String get placeSearchTitle => 'جگہ تلاش کریں';

  @override
  String get placeSearchTooShort => 'کم از کم دو حروف لکھیں، پھر تلاش دبائیں۔';

  @override
  String get placeSearchUnknownZone =>
      'اس جگہ کا ٹائم زون ایپ کے ڈیٹا بیس میں نہیں ہے۔ کوئی اور جگہ آزمائیں یا اسے ترتیبات میں «حسبِ ضرورت جگہ» سے شامل کریں۔';

  @override
  String get placeSearching => 'تلاش جاری ہے…';

  @override
  String get prayerAsr => 'عصر';

  @override
  String get prayerDhuhr => 'ظہر';

  @override
  String get prayerFajr => 'فجر';

  @override
  String get prayerImsak => 'امساک';

  @override
  String get prayerIsha => 'عشاء';

  @override
  String get prayerMaghrib => 'مغرب';

  @override
  String get prayerMidnight => 'نصفِ شب';

  @override
  String get prayerSunrise => 'طلوعِ آفتاب';

  @override
  String get prayerSunset => 'غروبِ آفتاب';

  @override
  String qiblaAccuracyValue(String meters) {
    return 'درستگی: تقریباً $meters میٹر';
  }

  @override
  String get qiblaBearingLabel => 'زاویہ (حقیقی شمال سے گھڑی کی سمت میں)';

  @override
  String qiblaBearingValue(String degrees, String direction) {
    return '$degrees° ($direction)';
  }

  @override
  String get qiblaCamKaaba => 'کعبہ';

  @override
  String get qiblaCamNearby => 'میرے اردگرد';

  @override
  String get qiblaCamOverview => 'پورا راستہ';

  @override
  String qiblaCardinal(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'n': 'شمال',
      'e': 'مشرق',
      's': 'جنوب',
      'w': 'مغرب',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String qiblaCompassSemantics(String degrees, String direction) {
    return 'قطب نما: قبلہ $degrees درجے پر ہے ($direction)';
  }

  @override
  String qiblaCompassSemanticsSun(String base, String azimuth) {
    return '$base؛ سورج $azimuth درجے پر ہے';
  }

  @override
  String get qiblaCoordsApply => 'دکھائیں';

  @override
  String get qiblaCoordsHint => 'مثلاً 36.2133, 58.7958';

  @override
  String get qiblaCoordsInvalid =>
      'نقاط درست نہیں ہیں۔ عرض بلد -90 اور 90 کے درمیان اور طول بلد -180 اور 180 کے درمیان ہونا چاہیے۔';

  @override
  String get qiblaCoordsLabel => 'عرض بلد اور طول بلد';

  @override
  String get qiblaCoordsOr => 'یا نقاط خود درج کریں';

  @override
  String qiblaCustomPlaceShown(String place) {
    return '$place سے پیمائش ہو رہی ہے۔';
  }

  @override
  String get qiblaDeviceFixShown => 'اس ڈیوائس کا مقام دکھایا جا رہا ہے۔';

  @override
  String get qiblaDistanceLabel => 'کعبہ تک فاصلہ';

  @override
  String qiblaDistanceValue(String km) {
    return '$km کلومیٹر';
  }

  @override
  String get qiblaFailGeneric =>
      'مقام پڑھا نہیں جا سکا؛ منتخب شہر دکھایا جا رہا ہے۔';

  @override
  String get qiblaFailPermissionDenied =>
      'Windows نے اس ایپ کو مقام پڑھنے کی اجازت نہیں دی۔ نیچے دیے گئے مراحل پر عمل کریں اور دوبارہ کوشش کریں؛ یا منتخب شہر استعمال کریں۔';

  @override
  String get qiblaFailPermissionForever =>
      'مقام تک رسائی مسترد کر دی گئی تھی۔ اسے دوبارہ اجازت دینے کے لیے نیچے دیے گئے مراحل پر عمل کریں۔';

  @override
  String get qiblaFailServiceDisabled =>
      'اس ڈیوائس پر مقام کی سروسز بند ہیں۔ نیچے دیے گئے مراحل پر عمل کریں؛ یا منتخب شہر یا کوئی بھی نقطہ استعمال کریں۔';

  @override
  String get qiblaFailTimeout =>
      'وقت پر مقام نہیں ملا۔ کمپیوٹرز میں عموماً GPS نہیں ہوتا اور Windows مقام کا اندازہ Wi-Fi سے لگاتی ہے۔ دوبارہ کوشش کریں یا شہر استعمال کریں۔';

  @override
  String get qiblaFailUnsupported =>
      'یہ ڈیوائس مقام نہیں بتا سکتی؛ منتخب شہر دکھایا جا رہا ہے۔';

  @override
  String qiblaForLocation(String place) {
    return '$place کے لیے قبلے کی سمت';
  }

  @override
  String get qiblaHelpOther =>
      'آپریٹنگ سسٹم کی ترتیبات میں مقام آن کریں، اس ایپ کو اسے استعمال کرنے کی اجازت دیں اور دوبارہ کوشش کریں۔';

  @override
  String get qiblaHelpTitleOther => 'مقام کیسے آن کروں؟';

  @override
  String get qiblaHelpTitleWindows => 'Windows میں مقام کیسے آن کروں؟';

  @override
  String get qiblaHelpWin1 =>
      'اوپر والا بٹن دبائیں تاکہ Windows Settings کا Location صفحہ کھل جائے۔ نہ کھلے تو خود وہاں جائیں: Start > Settings > Privacy & security > Location (Windows 10 میں: Privacy > Location)';

  @override
  String get qiblaHelpWin2 =>
      'Location services آن کریں۔ اگر صفحے کے اوپر Location for this device is off لکھا ہو تو Change دبائیں اور اسے آن کریں۔';

  @override
  String get qiblaHelpWin3 =>
      'ذرا نیچے Let desktop apps access your location آن کریں (Windows 10 میں: Allow desktop apps to access your location)۔ Salaat ایک ڈیسک ٹاپ ایپ ہے اور اسے صرف اسی سوئچ سے اجازت ملتی ہے۔';

  @override
  String get qiblaHelpWin4 =>
      'Salaat میں واپس آئیں اور “میرا مقام تلاش کریں” دوبارہ دبائیں۔ پھر بھی نہ ہو تو ایپ کو ایک بار بند کر کے دوبارہ کھولیں۔';

  @override
  String get qiblaLocateAgain => 'دوبارہ تلاش کریں';

  @override
  String get qiblaLocateButton => 'میرا مقام تلاش کریں';

  @override
  String get qiblaLocating => 'آپ کا مقام تلاش کیا جا رہا ہے…';

  @override
  String get qiblaMapAttribution => '© OpenStreetMap contributors';

  @override
  String get qiblaMapAttributionSatellite =>
      'تصاویر © Esri، Maxar، Earthstar Geographics اور GIS صارف برادری';

  @override
  String get qiblaMapConsentBody =>
      'قبلے کی لکیر نقشے پر دکھانے کے لیے نقشے کی تصاویر انٹرنیٹ سے لی جاتی ہیں اور آپ جو علاقہ دیکھ رہے ہوں وہ اس سرور کو بھیجا جاتا ہے: گلیوں کا نقشہ OpenStreetMap سے، اور اگر آپ “سیٹلائٹ” منتخب کریں تو فضائی تصاویر Esri سے۔ آپ کی رضامندی تک کوئی درخواست نہیں بھیجی جاتی۔ قبلے کا زاویہ اور فاصلہ نقشے کے بغیر بھی درست دکھائے جاتے ہیں۔';

  @override
  String get qiblaMapConsentButton => 'نقشہ دکھائیں';

  @override
  String get qiblaMapConsentTitle => 'قبلہ نقشہ';

  @override
  String get qiblaMapKaaba => 'کعبہ';

  @override
  String get qiblaMapLineNote =>
      'لکیر کرۂ ارض پر کعبے کے مرکز تک مختصر ترین راستہ ہے۔ چپٹے نقشے پر یہ خمیدہ نظر آتی ہے، لیکن اس کا آغاز قبلے کی سمت میں ہوتا ہے۔ کعبے کا پرنالہ مرکز سے صرف چند میٹر دور ہے اور سمت میں کوئی نمایاں فرق نہیں ڈالتا۔ گلیوں اور عمارتوں سے موازنہ کرنے کے لیے “میرے اردگرد” دبائیں۔';

  @override
  String get qiblaMapOfflineBanner =>
      'نقشے کی تصاویر لوڈ نہیں ہو سکیں (انٹرنیٹ نہیں ہے؟)۔ قبلے کی لکیر اور زاویہ پھر بھی درست ہیں۔';

  @override
  String qiblaMapSemantics(String place, String bearing, String distance) {
    return 'قبلہ نقشہ: $place سے کعبہ تک، $bearing، $distance';
  }

  @override
  String get qiblaMapTapHint => 'کوئی اور نقطہ چننے کے لیے نقشے پر ٹیپ کریں۔';

  @override
  String get qiblaMapTurnOff => 'نقشہ بند کریں';

  @override
  String get qiblaMapYou => 'آپ کا مقام';

  @override
  String get qiblaNoCompassNote =>
      'PC میں قطب نما نہیں ہوتا، اس لیے خاکہ حقیقی شمال کے مطابق بنایا گیا ہے (شمال اوپر ہے)۔';

  @override
  String get qiblaOpenSettingsFailed =>
      'ترتیبات کا صفحہ کھولا نہیں جا سکا؛ مراحل خود کر لیں۔';

  @override
  String get qiblaOpenSettingsOther => 'مقام کی ترتیبات کھولیں';

  @override
  String get qiblaOpenSettingsWindows => 'Windows کی مقام کی ترتیبات کھولیں';

  @override
  String get qiblaSourceCity => 'منتخب شہر';

  @override
  String qiblaSourceCityHelp(String city) {
    return 'وہ شہر جو آپ نے اوقاتِ نماز کے لیے چنا ہے: $city۔';
  }

  @override
  String get qiblaSourceCustom => 'کوئی بھی نقطہ';

  @override
  String get qiblaSourceCustomHelp =>
      'جگہ کو نام سے تلاش کریں (ایک بار انٹرنیٹ چاہیے)، نقشے کو چھوئیں یا نقاط درج کریں۔';

  @override
  String get qiblaSourceDevice => 'یہ ڈیوائس';

  @override
  String get qiblaSourceDeviceHelp =>
      'مقام ڈیوائس سے صرف تب پڑھا جاتا ہے جب آپ بٹن دبائیں؛ اسے محفوظ نہیں کیا جاتا اور نہ کہیں بھیجا جاتا ہے۔';

  @override
  String get qiblaSourceTitle => 'قبلہ کہاں سے ناپیں';

  @override
  String get qiblaStatLatitude => 'عرض بلد';

  @override
  String get qiblaStatLongitude => 'طول بلد';

  @override
  String get qiblaStyleLabel => 'نقشے کی قسم';

  @override
  String get qiblaStyleSatellite => 'سیٹلائٹ';

  @override
  String get qiblaStyleStreet => 'نقشہ';

  @override
  String get qiblaSunBelow => 'سورج افق سے نیچے ہے۔';

  @override
  String get qiblaSunInHelp =>
      'اس لمحے سورج ٹھیک قبلے کی سمت میں ہے؛ سورج کی طرف رخ کریں۔';

  @override
  String get qiblaSunInTitle => 'سورج قبلے کی سمت میں';

  @override
  String get qiblaSunNone => 'آج ایسا نہیں ہوتا۔';

  @override
  String get qiblaSunNowLabel => 'سورج اس وقت';

  @override
  String qiblaSunNowValue(String azimuth, String altitude) {
    return 'سمتی زاویہ $azimuth°، بلندی $altitude°';
  }

  @override
  String get qiblaSunOppHelp =>
      'اس لمحے سیدھی کھڑی چھڑی کا سایہ قبلے کی طرف پڑتا ہے۔';

  @override
  String get qiblaSunOppTitle => 'سورج قبلے کے مخالف';

  @override
  String get qiblaSunTimesTitle => 'آج سورج اور قبلہ';

  @override
  String get qiblaTabCompass => 'قطب نما اور سورج';

  @override
  String get qiblaTabMap => 'نقشہ';

  @override
  String get qiblaTitle => 'قبلہ';

  @override
  String get settingsAboutPlaceholder =>
      'ورژن، لائسنس اور تشخیص کا صفحہ اس حصے میں نظر آتے ہیں۔';

  @override
  String get settingsAppAutostart => 'Windows کے ساتھ شروع کریں';

  @override
  String get settingsAppAutostartHelp =>
      'Windows میں سائن اِن کرنے پر ایپ خاموشی سے گھڑی کے ساتھ شروع ہو جاتی ہے۔';

  @override
  String get settingsAppCloseToTray => 'ٹرے میں بند کریں';

  @override
  String get settingsAppCloseToTrayHelp =>
      'ونڈو بند کرنے پر ایپ Windows کی گھڑی کے ساتھ چلتی رہتی ہے تاکہ اذان بجتی رہے۔ بند ہونے پر ونڈو بند کرنے سے ایپ بند ہو جاتی ہے۔';

  @override
  String get settingsAppMinimized => 'چھوٹی حالت میں شروع کریں';

  @override
  String get settingsAppMinimizedHelp =>
      'Windows کے ایپ شروع کرنے پر ونڈو بند رہتی ہے۔';

  @override
  String get settingsAsrHanafi => 'حنفی (سایہ شے سے دگنا)';

  @override
  String get settingsAsrStandard => 'معیاری (سایہ شے کے برابر)';

  @override
  String get settingsAzanChoose => 'فائل منتخب کریں…';

  @override
  String get settingsAzanEnabled => 'اذان چلائیں';

  @override
  String get settingsAzanEnabledHelp =>
      'مرکزی سوئچ؛ بند ہونے پر کوئی اذان نہیں بجتی۔';

  @override
  String get settingsAzanFade => 'آواز آہستہ آہستہ بڑھائیں';

  @override
  String get settingsAzanFadeHelp => 'اذان نرمی سے پوری آواز تک پہنچتی ہے۔';

  @override
  String get settingsAzanMute => 'فوری خاموشی';

  @override
  String get settingsAzanMuteHelp => 'اذان کو کچھ دیر کے لیے خاموش کریں۔';

  @override
  String get settingsAzanNotMuted => 'خاموش نہیں';

  @override
  String get settingsAzanPhoneNote =>
      'فون پر اذان اور یاددہانیاں سسٹم کی اطلاعات کے طور پر آتی ہیں، اس لیے ایپ بند ہونے پر بھی پہنچتی ہیں۔ اذان کی اطلاع ایپ کے ساتھ آنے والی اذان کی آواز بجاتی ہے؛ اس صفحے پر چنی گئی آواز اور بلندی ایپ کے اندر پیش نظارے کے لیے ہیں۔ آواز کی بلندی فون کی اطلاعات کی آواز سے طے کریں۔';

  @override
  String settingsAzanPrayerSwitch(String prayer) {
    return '$prayer کی اذان';
  }

  @override
  String get settingsAzanPrayerVolume => 'اس اذان کی آواز';

  @override
  String get settingsAzanPreview => 'پیش نظارہ';

  @override
  String get settingsAzanSound => 'آواز';

  @override
  String get settingsAzanSoundDefault => 'ایپ کی شامل اذان';

  @override
  String settingsAzanSoundFile(String name) {
    return 'فائل: $name';
  }

  @override
  String get settingsAzanUseDefault => 'شامل آواز استعمال کریں';

  @override
  String get settingsAzanVolume => 'آواز';

  @override
  String get settingsAzanVolumeHelp => 'ہر اذان کی مجموعی آواز';

  @override
  String get settingsBackupExport => 'بیک اپ محفوظ کریں';

  @override
  String get settingsBackupExportFailed => 'بیک اپ محفوظ نہیں ہو سکا۔';

  @override
  String get settingsBackupExportHelp =>
      'تمام ترتیبات، مقامات اور جگانے والے الارم ایک فائل میں محفوظ ہوتے ہیں۔';

  @override
  String settingsBackupExported(String path) {
    return 'بیک اپ محفوظ ہو گیا: $path';
  }

  @override
  String get settingsBackupImport => 'بیک اپ بحال کریں';

  @override
  String get settingsBackupImportBody =>
      'موجودہ تمام ترتیبات اس فائل کے مواد سے بدل دی جائیں گی۔';

  @override
  String get settingsBackupImportConfirm => 'بحال کریں';

  @override
  String get settingsBackupImportHelp => 'بیک اپ فائل سے ترتیبات بحال کرتا ہے۔';

  @override
  String get settingsBackupImportInvalid =>
      'یہ فائل ترتیبات کا درست بیک اپ نہیں ہے؛ ترتیبات نہیں بدلیں۔';

  @override
  String get settingsBackupImportReadFailed =>
      'فائل پڑھی نہیں جا سکی؛ ترتیبات نہیں بدلیں۔';

  @override
  String get settingsBackupImportTitle => 'ترتیبات بحال کریں؟';

  @override
  String get settingsBackupImported => 'ترتیبات بحال ہو گئیں۔';

  @override
  String get settingsBackupTitle => 'بیک اپ اور بحالی';

  @override
  String get settingsCalcAngleHelp => 'افق کے نیچے سورج کا زاویہ، درجوں میں';

  @override
  String get settingsCalcAsr => 'عصر کا اصول';

  @override
  String get settingsCalcFajrAngle => 'فجر کا زاویہ';

  @override
  String get settingsCalcHighLat => 'بلند عرض بلد';

  @override
  String get settingsCalcHighLatHelp =>
      'ایسے مقامات کے لیے جہاں رات بہت چھوٹی ہوتی ہے اور شفق کا زاویہ کبھی حاصل نہیں ہوتا۔';

  @override
  String get settingsCalcImsak => 'امساک';

  @override
  String get settingsCalcImsakHelp => 'فجر سے پہلے کے منٹ';

  @override
  String get settingsCalcIshaAngle => 'عشاء کا زاویہ';

  @override
  String get settingsCalcIshaMinutes => 'مغرب کے بعد کے منٹ';

  @override
  String get settingsCalcIshaMode => 'عشاء کی تعریف';

  @override
  String get settingsCalcIshaModeAngle => 'سورج کا زاویہ';

  @override
  String get settingsCalcIshaModeMinutes => 'مغرب کے بعد کے منٹ';

  @override
  String get settingsCalcMaghribAngle => 'مغرب کا زاویہ';

  @override
  String get settingsCalcMaghribSunset => 'مغرب غروبِ آفتاب پر';

  @override
  String get settingsCalcMaghribSunsetHelp =>
      'بند ہو تو مغرب کا حساب نیچے دیے گئے زاویے سے ہوتا ہے۔';

  @override
  String get settingsCalcMethod => 'طریقہ';

  @override
  String get settingsCalcMethodHelp =>
      'کوئی بھی زاویہ بدلنے سے طریقہ حسبِ ضرورت ہو جاتا ہے۔';

  @override
  String get settingsCalcMidnight => 'نصفِ شب';

  @override
  String settingsCalcOffsetsHelp(String max) {
    return 'ہر وقت کو $max منٹ تک آگے یا پیچھے کریں۔';
  }

  @override
  String get settingsCalcOffsetsReset => 'سب صفر کریں';

  @override
  String get settingsCalcOffsetsTitle => 'ہر وقت کے لیے منٹوں کی ایڈجسٹمنٹ';

  @override
  String settingsCalcPreviewHelp(String date) {
    return 'اوپر کی ترتیبات کے ساتھ آج کے اوقات ($date)';
  }

  @override
  String get settingsCalcPreviewTitle => 'لائیو پیش نظارہ';

  @override
  String get settingsCalcRestore => 'اس طریقے کی طے شدہ قدریں بحال کریں';

  @override
  String settingsCalcRestoreHelp(String method) {
    return 'زاویے، اصول اور امساک $method کی قدروں پر واپس آ جاتے ہیں؛ ہر وقت کی منٹ ایڈجسٹمنٹ نہیں بدلتی۔';
  }

  @override
  String get settingsCalcRowsHelp =>
      'فجر، طلوعِ آفتاب، ظہر، مغرب اور نصفِ شب ہمیشہ دکھائے جاتے ہیں۔';

  @override
  String get settingsCalcRowsTitle => 'دکھائی جانے والی قطاریں';

  @override
  String get settingsCancel => 'منسوخ کریں';

  @override
  String get settingsDecrease => 'کم کریں';

  @override
  String get settingsDigitsArabic => 'عربی (٠١٢)';

  @override
  String get settingsDigitsLatin => 'لاطینی (123)';

  @override
  String get settingsDigitsPersian => 'فارسی (۱۲۳)';

  @override
  String get settingsDispDigits => 'ہندسے';

  @override
  String get settingsDispHijri => 'ہجری تاریخ میں ردوبدل';

  @override
  String get settingsDispHijriHelp =>
      'ایران میں مہینے کا تعین چاند دیکھنے سے ہوتا ہے، اس لیے دکھائی گئی ہجری تاریخ سرکاری تاریخ سے مختلف ہو سکتی ہے؛ یہاں اسے ایک دو دن آگے پیچھے کر لیں۔';

  @override
  String get settingsDispHour => 'گھڑی';

  @override
  String get settingsDispLanguage => 'زبان';

  @override
  String get settingsDispLanguageHelp => 'دوبارہ شروع کیے بغیر لاگو ہوتی ہے۔';

  @override
  String get settingsDispTheme => 'تھیم';

  @override
  String get settingsHighLatAngleBased => 'زاویے پر مبنی';

  @override
  String get settingsHighLatNightMiddle => 'رات کا درمیان';

  @override
  String get settingsHighLatNone => 'کوئی ایڈجسٹمنٹ نہیں';

  @override
  String get settingsHighLatOneSeventh => 'رات کا ساتواں حصہ';

  @override
  String get settingsHour12 => '۱۲ گھنٹے';

  @override
  String get settingsHour24 => '۲۴ گھنٹے';

  @override
  String get settingsIncrease => 'بڑھائیں';

  @override
  String settingsInvalidNumber(String min, String max) {
    return '$min اور $max کے درمیان کوئی عدد درج کریں۔';
  }

  @override
  String get settingsLocActive => 'فعال';

  @override
  String get settingsLocAdd => 'شامل کریں';

  @override
  String get settingsLocAddCustom => 'حسبِ ضرورت مقام';

  @override
  String get settingsLocAddFromDb => 'شہروں کی فہرست سے';

  @override
  String get settingsLocAddSearch => 'آن لائن تلاش';

  @override
  String get settingsLocAddTitle => 'مقام شامل کریں';

  @override
  String settingsLocAdded(String name) {
    return '$name شامل کر دیا گیا۔';
  }

  @override
  String get settingsLocAllProvinces => 'تمام صوبے';

  @override
  String get settingsLocAlreadySaved => 'پہلے سے محفوظ';

  @override
  String settingsLocAlreadySavedName(String name) {
    return '$name پہلے سے محفوظ مقامات میں موجود ہے۔';
  }

  @override
  String get settingsLocClose => 'بند کریں';

  @override
  String settingsLocCoords(String lat, String lon) {
    return 'عرض $lat، طول $lon';
  }

  @override
  String get settingsLocCustomBadge => 'حسبِ ضرورت';

  @override
  String get settingsLocDegrees => 'درجے';

  @override
  String get settingsLocDelete => 'حذف کریں';

  @override
  String get settingsLocDeleteBody => 'یہ مقام آپ کی فہرست سے ہٹا دیا جائے گا۔';

  @override
  String get settingsLocDeleteLast => 'آخری مقام حذف نہیں کیا جا سکتا۔';

  @override
  String settingsLocDeleteTitle(String name) {
    return '$name حذف کریں؟';
  }

  @override
  String get settingsLocEast => 'مشرق';

  @override
  String get settingsLocEdit => 'ترمیم';

  @override
  String get settingsLocElevation => 'بلندی (میٹر)';

  @override
  String settingsLocErrElevation(String min, String max) {
    return 'بلندی $min اور $max میٹر کے درمیان ہونی چاہیے۔';
  }

  @override
  String settingsLocErrLatitude(String min, String max) {
    return 'عرض بلد $min اور $max کے درمیان کوئی عدد ہونا چاہیے۔';
  }

  @override
  String settingsLocErrLongitude(String min, String max) {
    return 'طول بلد $min اور $max کے درمیان کوئی عدد ہونا چاہیے۔';
  }

  @override
  String get settingsLocErrName => 'نام درج کریں۔';

  @override
  String settingsLocErrOffset(String min, String max) {
    return 'فرق $min اور $max کے درمیان ہونا چاہیے۔';
  }

  @override
  String get settingsLocErrZone => 'فہرست سے ٹائم زون منتخب کریں۔';

  @override
  String get settingsLocFormatDecimal => 'اعشاری درجے';

  @override
  String get settingsLocFormatDms => 'درجے، منٹ، سیکنڈ';

  @override
  String get settingsLocLatitude => 'عرض بلد';

  @override
  String get settingsLocLongitude => 'طول بلد';

  @override
  String get settingsLocMinutes => 'منٹ';

  @override
  String get settingsLocName => 'نام';

  @override
  String get settingsLocNoResults => 'کوئی شہر نہیں ملا۔';

  @override
  String get settingsLocNorth => 'شمال';

  @override
  String get settingsLocProvince => 'صوبہ';

  @override
  String get settingsLocSave => 'محفوظ کریں';

  @override
  String get settingsLocSavedHelp => 'اوقات فعال مقام کے لیے نکالے جاتے ہیں۔';

  @override
  String get settingsLocSavedTitle => 'محفوظ شدہ مقامات';

  @override
  String get settingsLocSearchHint => 'شہر تلاش کریں';

  @override
  String get settingsLocSeconds => 'سیکنڈ';

  @override
  String get settingsLocSetActive => 'فعال کریں';

  @override
  String get settingsLocSouth => 'جنوب';

  @override
  String get settingsLocWest => 'مغرب';

  @override
  String get settingsLocZoneNone => 'کوئی ٹائم زون نہیں ملا۔';

  @override
  String get settingsLocZoneSearch => 'ٹائم زون تلاش کریں';

  @override
  String settingsLocZoneSelected(String zone) {
    return 'منتخب ٹائم زون: $zone';
  }

  @override
  String get settingsMethodCustom => 'حسبِ ضرورت';

  @override
  String get settingsMethodEgypt => 'مصری جنرل اتھارٹی آف سروے';

  @override
  String get settingsMethodIsna => 'اسلامک سوسائٹی آف نارتھ امریکا';

  @override
  String get settingsMethodJafari => 'شیعہ اثنا عشری، لیوا انسٹی ٹیوٹ (قم)';

  @override
  String get settingsMethodKarachi => 'یونیورسٹی آف اسلامک سائنسز، کراچی';

  @override
  String get settingsMethodMakkah => 'جامعہ ام القریٰ، مکہ مکرمہ';

  @override
  String get settingsMethodMwl => 'رابطہ عالمِ اسلامی';

  @override
  String get settingsMethodTehran =>
      'انسٹی ٹیوٹ آف جیوفزکس، یونیورسٹی آف تہران';

  @override
  String get settingsMidnightJafari => 'غروبِ آفتاب اور فجر کے درمیان';

  @override
  String get settingsMidnightStandard =>
      'غروبِ آفتاب اور طلوعِ آفتاب کے درمیان';

  @override
  String get settingsOff => 'بند';

  @override
  String settingsPercent(String value) {
    return '$value%';
  }

  @override
  String get settingsRemChime => 'ہلکی گھنٹی';

  @override
  String get settingsRemChimeHelp =>
      'یاد دہانی کی اطلاع کے ساتھ ہلکی گھنٹی بجتی ہے۔';

  @override
  String get settingsRemChimeTest => 'نمونہ چلائیں';

  @override
  String settingsRemHelp(String max) {
    return '۰ کا مطلب بند ہے؛ اذان سے $max منٹ پہلے تک۔';
  }

  @override
  String get settingsRemIndependent =>
      'یاد دہانیاں بند کرنے سے اذان پر کبھی اثر نہیں پڑتا۔';

  @override
  String settingsRemSummary(String minutes) {
    return 'اذان سے $minutes منٹ پہلے';
  }

  @override
  String settingsRemTitle(String prayer) {
    return '$prayer سے پہلے یاد دہانی';
  }

  @override
  String get settingsResetConfirm => 'صاف کریں';

  @override
  String get settingsResetConfirmBody =>
      'ترتیبات طے شدہ قدروں پر واپس آ جائیں گی اور فعال مقام تہران ہو جائے گا۔ اس عمل کو واپس نہیں کیا جا سکتا۔';

  @override
  String get settingsResetConfirmTitle => 'تمام ترتیبات صاف کریں؟';

  @override
  String get settingsResetDone => 'ترتیبات طے شدہ قدروں پر واپس کر دی گئیں۔';

  @override
  String get settingsResetHelp =>
      'تمام ترتیبات، محفوظ شدہ مقامات اور جگانے والے الارم صاف ہو جاتے ہیں۔';

  @override
  String get settingsResetTitle => 'طے شدہ ترتیبات پر واپس';

  @override
  String get settingsSaved => 'محفوظ ہو گیا';

  @override
  String get settingsSectionAbout => 'تعارف اور تشخیص';

  @override
  String get settingsSectionApp => 'ایپ';

  @override
  String get settingsSectionAzan => 'اذان';

  @override
  String get settingsSectionCalculation => 'حساب';

  @override
  String get settingsSectionDisplay => 'ڈسپلے';

  @override
  String get settingsSectionLocation => 'مقام';

  @override
  String get settingsSectionReminders => 'یاد دہانیاں';

  @override
  String get settingsSectionTime => 'وقت';

  @override
  String get settingsSectionsLabel => 'ترتیبات کے حصے';

  @override
  String get settingsThemeDark => 'گہرا';

  @override
  String get settingsThemeLight => 'روشن';

  @override
  String get settingsThemeSystem => 'Windows کے مطابق';

  @override
  String get settingsTimeCheck => 'گھڑی کو نیٹ ورک ٹائم سے جانچیں';

  @override
  String get settingsTimeCheckHelp =>
      'ایپ شروع ہونے پر اور ہر چھ گھنٹے بعد؛ پہلے سے بند ہے۔';

  @override
  String get settingsTimeCheckNow => 'ابھی جانچیں';

  @override
  String settingsTimeCheckedAt(String time) {
    return '$time پر جانچا گیا';
  }

  @override
  String get settingsTimeChecking => 'جانچ ہو رہی ہے…';

  @override
  String get settingsTimeCorrect => 'ایپ کے اندر وقت درست کریں';

  @override
  String get settingsTimeCorrectHelp => 'Windows کی گھڑی کبھی نہیں بدلی جاتی۔';

  @override
  String settingsTimeDiagLocation(String offset) {
    return 'فعال مقام کا فرق (ڈیٹا بیس): $offset';
  }

  @override
  String get settingsTimeDiagOk => 'گھڑی میں کوئی مسئلہ نہیں ملا۔';

  @override
  String get settingsTimeDiagTitle => 'گھڑی کی تشخیص';

  @override
  String settingsTimeDiagWindows(String offset) {
    return 'UTC سے Windows کا فرق: $offset';
  }

  @override
  String get settingsTimeError =>
      'ٹائم سرور تک رسائی نہیں ہو سکی۔ انٹرنیٹ کنکشن اور سرور کا نام چیک کریں۔';

  @override
  String get settingsTimeNever => 'ابھی جانچ نہیں ہوئی۔';

  @override
  String get settingsTimeServer => 'ٹائم سرور';

  @override
  String get settingsTimeServerHelp => 'ٹائم سرور کا نام، مثلاً pool.ntp.org';

  @override
  String get settingsTimeServerInvalid => 'سرور کا نام درست نہیں ہے۔';

  @override
  String settingsTimeSkewAhead(String amount) {
    return 'کمپیوٹر کی گھڑی $amount آگے ہے۔';
  }

  @override
  String settingsTimeSkewBehind(String amount) {
    return 'کمپیوٹر کی گھڑی $amount پیچھے ہے۔';
  }

  @override
  String get settingsTimeSkewZero =>
      'کمپیوٹر کی گھڑی نیٹ ورک ٹائم کے مطابق ہے۔';

  @override
  String get settingsTimeStatusTitle => 'آخری جانچ';

  @override
  String get settingsZoneAuto => 'خودکار (تجویز کردہ)';

  @override
  String settingsZoneAutoHelp(String zone) {
    return 'ایپ میں شامل ٹائم زون ڈیٹا بیس استعمال ہوتا ہے: $zone';
  }

  @override
  String get settingsZoneFixed => 'مقررہ فرق';

  @override
  String get settingsZoneFixedAllYear =>
      'فرق مقرر ہے اور سال کے ہر دن یکساں رہتا ہے۔';

  @override
  String get settingsZoneFixedHelp =>
      'UTC سے ایک مقررہ فرق جو سال کے ہر دن لاگو ہوتا ہے۔';

  @override
  String settingsZoneFixedValue(String offset) {
    return 'مقررہ فرق: $offset';
  }

  @override
  String get settingsZoneHourLess => 'ایک گھنٹہ کم';

  @override
  String get settingsZoneHourMore => 'ایک گھنٹہ زیادہ';

  @override
  String settingsZoneNext(String date, String time, String offset) {
    return 'اگلی تبدیلی: $date کو $time پر، فرق $offset';
  }

  @override
  String get settingsZoneNoChange =>
      'اس ٹائم زون کے لیے مزید کوئی تبدیلی طے نہیں ہے۔';

  @override
  String settingsZoneNow(String offset) {
    return 'آج نافذ فرق: $offset';
  }

  @override
  String get settingsZoneQuarterLess => 'پندرہ منٹ کم';

  @override
  String get settingsZoneQuarterMore => 'پندرہ منٹ زیادہ';

  @override
  String get settingsZoneTitle => 'ٹائم زون';

  @override
  String get supportAvailableIn => 'ان میں استعمال کے قابل:';

  @override
  String get supportCardCountries =>
      'صرف ایران: Shetab نیٹ ورک پر ایرانی بینک کارڈ۔ ایران سے باہر سے اس سے ادائیگی نہیں ہو سکتی؛ اس کے بجائے کرپٹو کرنسی کا طریقہ استعمال کریں۔';

  @override
  String get supportCardNumberLabel => 'کارڈ نمبر';

  @override
  String get supportCardTitle => 'ایرانی بینک کارڈ';

  @override
  String get supportCheckNote =>
      'ادائیگی سے پہلے نمبر یا پتے کو GitHub پر پروجیکٹ کے سرکاری صفحے سے ملا لیں۔ آپ کی معاونت کا شکریہ۔';

  @override
  String get supportCryptoAddressLabel => 'والٹ ایڈریس';

  @override
  String get supportCryptoCountries =>
      'تمام ممالک: ہر اس جگہ سے جہاں کرپٹو والٹ یا ایکسچینج دستیاب ہو، بینک کارڈ کی ضرورت کے بغیر۔';

  @override
  String get supportCryptoNetworkLabel => 'نیٹ ورک';

  @override
  String get supportCryptoNetworkValue =>
      'BEP20 (BNB Smart Chain، جسے BSC بھی کہا جاتا ہے)';

  @override
  String get supportCryptoTitle => 'USDT (ٹیدر) کرپٹو کرنسی';

  @override
  String get supportCryptoWarning =>
      'صرف BEP20 نیٹ ورک پر USDT بھیجیں۔ اس ایڈریس پر کوئی اور کوائن بھیجنے یا کوئی اور نیٹ ورک استعمال کرنے سے رقم ضائع ہو جاتی ہے۔';

  @override
  String get supportIntro =>
      'یہ ایپ مفت ہے، اس میں اشتہارات نہیں، اکاؤنٹ کی ضرورت نہیں اور کوئی خصوصیت ادائیگی کے پیچھے بند نہیں۔ اگر یہ آپ کے کام آئے اور آپ اسے آگے بڑھانے میں مدد کرنا چاہیں تو نیچے دیے گئے طریقوں میں سے کوئی ایک اپنا سکتے ہیں۔ معاونت مکمل طور پر اختیاری ہے اور ہر رقم کی قدر کی جاتی ہے۔';

  @override
  String get supportTitle => 'منصوبے کی معاونت کریں';

  @override
  String get timetableCalendarSwitch => 'کیلنڈر کی قسم';

  @override
  String get timetableColDay => 'دن';

  @override
  String get timetableColWeekday => 'ہفتے کا دن';

  @override
  String get timetableMonthUnavailable =>
      'یہ مہینہ قمری کیلنڈر کے جدول سے باہر ہے۔';

  @override
  String get timetableNextMonth => 'اگلا مہینہ';

  @override
  String timetableOpenDay(String date) {
    return '$date کو ہوم اسکرین پر دکھائیں';
  }

  @override
  String get timetablePreviousMonth => 'پچھلا مہینہ';

  @override
  String get timetableToday => 'آج';

  @override
  String get trayMenuLocation => 'مقام';

  @override
  String get trayMenuMute => 'خاموش';

  @override
  String get trayMenuMuted => 'خاموش ہے';

  @override
  String get trayMenuQuit => 'باہر نکلیں';

  @override
  String get trayMenuSettings => 'ترتیبات';

  @override
  String get trayMenuShow => 'ونڈو دکھائیں';

  @override
  String get trayMenuStopAzan => 'اذان روکیں';

  @override
  String get trayMuteCancel => 'خاموشی ختم کریں';

  @override
  String trayMuteHours(String n) {
    return '$n گھنٹے';
  }

  @override
  String get trayMuteIndefinite => 'جب تک میں بند نہ کروں';

  @override
  String get trayMuteUntilNext => 'اگلی اذان تک';

  @override
  String trayNextLine(String prayer, String time) {
    return 'اگلی: $prayer · $time';
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
  String get wakeAdd => 'الارم شامل کریں';

  @override
  String get wakeAfterHibernate => 'آواز کے بعد: ہائبرنیٹ';

  @override
  String get wakeAfterHibernateChoice => 'ہائبرنیٹ';

  @override
  String get wakeAfterNote =>
      'PC کے سلیپ یا ہائبرنیٹ ہونے سے پہلے تیس سیکنڈ کی الٹی گنتی آپ کو منسوخ کرنے کا موقع دیتی ہے۔';

  @override
  String get wakeAfterNothing => 'کچھ نہ کریں';

  @override
  String get wakeAfterSleep => 'آواز کے بعد: سلیپ';

  @override
  String get wakeAfterSleepChoice => 'سلیپ';

  @override
  String get wakeAfterTitle => 'آواز کے بعد';

  @override
  String get wakeCancel => 'منسوخ کریں';

  @override
  String get wakeCapabilityChecking => 'اس PC کی جانچ ہو رہی ہے…';

  @override
  String get wakeCapabilityOkBody =>
      'جانچ میں کوئی رکاوٹ نہیں ملی۔ یقین کے لیے دو منٹ کی آزمائش چلائیں۔';

  @override
  String get wakeCapabilityOkTitle => 'یہ PC خود کو جگا سکتا ہے';

  @override
  String get wakeCapabilityRefresh => 'دوبارہ جانچیں';

  @override
  String get wakeCapabilityUnknown => 'ابھی جانچ نہیں ہوئی۔';

  @override
  String get wakeCapabilityWarnTitle => 'ہو سکتا ہے یہ PC الارم کے لیے نہ جاگے';

  @override
  String get wakeChoiceFixed => 'مقررہ وقت پر';

  @override
  String get wakeChoiceRelative => 'نماز سے پہلے';

  @override
  String get wakeChooseFile => 'فائل منتخب کریں…';

  @override
  String get wakeCountdownAfterAlarm => 'الارم ختم ہو گیا۔';

  @override
  String get wakeCountdownCancel => 'منسوخ کریں';

  @override
  String wakeCountdownHibernate(String time) {
    return 'PC $time میں ہائبرنیٹ ہو جائے گا۔';
  }

  @override
  String wakeCountdownSleep(String time) {
    return 'PC $time میں سلیپ میں چلا جائے گا۔';
  }

  @override
  String get wakeDelete => 'حذف کریں';

  @override
  String get wakeDeleteBody =>
      'الارم اور اس کی جاگنے کی درخواست ہٹا دی جائے گی۔';

  @override
  String get wakeDeleteConfirm => 'حذف کریں';

  @override
  String get wakeDeleteTitle => 'یہ الارم حذف کریں؟';

  @override
  String get wakeDismiss => 'بند کریں';

  @override
  String get wakeEdit => 'ترمیم';

  @override
  String get wakeEditorTitleAdd => 'نیا الارم';

  @override
  String get wakeEditorTitleEdit => 'الارم میں ترمیم';

  @override
  String get wakeEmpty =>
      'ابھی کوئی الارم نہیں ہے۔ اپنی پسند کے وقت PC کو جگانے کے لیے ایک شامل کریں۔';

  @override
  String get wakeEnabledSwitch => 'آن';

  @override
  String wakeErrorMinutes(String min, String max) {
    return '$min سے $max تک کوئی پورا عدد درج کریں۔';
  }

  @override
  String get wakeFieldHour => 'گھنٹہ';

  @override
  String get wakeFieldLabel => 'نام (اختیاری)';

  @override
  String get wakeFieldMinute => 'منٹ';

  @override
  String get wakeFieldMinutesBefore => 'کتنے منٹ پہلے';

  @override
  String get wakeFieldPrayer => 'نماز';

  @override
  String get wakeHibernateNow => 'ابھی ہائبرنیٹ کریں';

  @override
  String get wakeIssueImportantOnly =>
      'Windows صرف اہم جگانے والے ٹائمرز کی اجازت دیتی ہے، جن میں عموماً یہ ایپ شامل نہیں ہوتی۔';

  @override
  String get wakeIssueInProcessTimer =>
      'ایپ کے اندر بیک اپ ٹائمر نہیں بنایا جا سکا۔';

  @override
  String get wakeIssueModernStandby =>
      'یہ PC ماڈرن اسٹینڈ بائی استعمال کرتا ہے جس میں مقررہ وقت پر جاگنا اکثر ناقابلِ بھروسا ہوتا ہے۔';

  @override
  String get wakeIssueTaskCreationFailed =>
      'Windows نے آپ کے اکاؤنٹ کے لیے شیڈول شدہ جگانے والے ٹاسک کی اجازت نہیں دی، اس لیے الارم صرف اسی وقت کام کرتا ہے جب یہ ایپ چل رہی ہو۔';

  @override
  String get wakeIssueTimersOffAc =>
      'Windows میں PC کے بجلی سے لگے ہونے کی حالت میں جگانے والے ٹائمر بند ہیں۔';

  @override
  String get wakeIssueTimersOffBattery =>
      'Windows میں PC کے بیٹری پر چلنے کی حالت میں جگانے والے ٹائمر بند ہیں۔';

  @override
  String get wakeIssueUnknown =>
      'Windows کے جگانے والے ٹائمر کی ترتیب پڑھی نہیں جا سکی۔';

  @override
  String get wakeListSeparator => '، ';

  @override
  String wakeNext(String remaining, String time) {
    return 'اگلا: $remaining ($time)';
  }

  @override
  String get wakeNextNone => 'اگلا: —';

  @override
  String wakeNextOtherDay(String remaining, String weekday, String time) {
    return 'اگلا: $remaining ($weekday $time)';
  }

  @override
  String get wakeOff => 'بند';

  @override
  String get wakeOpenPowerFailed =>
      'پاور کی ترتیبات نہیں کھل سکیں۔ Control Panel > Power Options خود کھولیں۔';

  @override
  String get wakeOpenPowerOptions => 'Windows کی پاور کی ترتیبات کھولیں';

  @override
  String wakePercent(String percent) {
    return '$percent%';
  }

  @override
  String get wakePlaySound => 'آواز چلائیں';

  @override
  String get wakePowerHint =>
      'Windows میں: Power Options > Change plan settings > Change advanced power settings > Sleep > Allow wake timers۔ یہ ایپ پاور کی کوئی ترتیب خود نہیں بدلتی۔';

  @override
  String get wakePreview => 'پیش نظارہ';

  @override
  String get wakePreviewStop => 'پیش نظارہ روکیں';

  @override
  String get wakeProblemHibernateUnavailable =>
      'اس PC پر ہائبرنیشن آن نہیں ہے۔';

  @override
  String get wakeProblemProbeFailed => 'اس PC کی جانچ مکمل نہیں ہو سکی۔';

  @override
  String get wakeProblemSoundFailed =>
      'الارم کی آواز نہیں چل سکی۔ آواز کی فائل اور اسپیکر چیک کریں۔';

  @override
  String get wakeProblemSuspendRefused =>
      'Windows نے PC کو سلیپ میں جانے کی اجازت نہیں دی۔';

  @override
  String get wakeRepeatDaily => 'ہر دن';

  @override
  String get wakeRepeatOnce => 'ایک بار';

  @override
  String get wakeRepeatTitle => 'تکرار';

  @override
  String wakeRepeatWeekdays(String days) {
    return '$days کو';
  }

  @override
  String get wakeRepeatWeekdaysChoice => 'منتخب دن';

  @override
  String get wakeRinging => 'الارم بج رہا ہے';

  @override
  String get wakeSave => 'محفوظ کریں';

  @override
  String get wakeSaveFailed =>
      'یہ قدریں محفوظ نہیں ہو سکیں۔ وقت اور دن چیک کریں۔';

  @override
  String get wakeSleepHint =>
      'PC پانچ سیکنڈ کی الٹی گنتی کے بعد سلیپ میں چلا جاتا ہے، جسے آپ منسوخ کر سکتے ہیں۔';

  @override
  String get wakeSleepNow => 'ابھی سلیپ کریں';

  @override
  String get wakeSoundDefault => 'طے شدہ اذان کی آواز';

  @override
  String wakeSoundFile(String name) {
    return 'فائل: $name';
  }

  @override
  String get wakeSoundTitle => 'آواز';

  @override
  String get wakeStop => 'روکیں';

  @override
  String get wakeSyncError =>
      'جاگنے کی درخواست Windows میں درج نہیں ہو سکی؛ الارم شاید صرف ایپ چلنے کے دوران کام کرے۔';

  @override
  String get wakeTest => 'دو منٹ میں آزمائش';

  @override
  String get wakeTestCancel => 'آزمائش منسوخ کریں';

  @override
  String wakeTestPending(String time) {
    return 'آزمائشی الارم $time پر بجے گا۔ اب PC کو سلیپ میں ڈال دیں تاکہ دیکھ سکیں کہ وہ جاگتا ہے یا نہیں۔';
  }

  @override
  String get wakeTitle => 'جگانے والے الارم';

  @override
  String wakeTriggerAtPrayer(String prayer) {
    return '$prayer کے وقت';
  }

  @override
  String wakeTriggerFixed(String time) {
    return '$time پر';
  }

  @override
  String wakeTriggerRelative(String minutes, String prayer) {
    return '$prayer سے $minutes پہلے';
  }

  @override
  String get wakeTriggerTypeTitle => 'کب';

  @override
  String get wakeUseDefault => 'طے شدہ آواز استعمال کریں';

  @override
  String get wakeVolume => 'آواز';

  @override
  String get wakeWeekdaysError => 'کم از کم ایک دن منتخب کریں۔';
}
