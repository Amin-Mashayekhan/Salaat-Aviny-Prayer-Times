// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get aboutAuthorIntro =>
      'يطوّر هذا التطبيق ويصونه مطوّر مستقل. تواصل معه للإبلاغ عن مشكلة أو لاقتراح فكرة أو للتعاون.';

  @override
  String get aboutAuthorTitle => 'عن المطوّر';

  @override
  String get aboutContactEmail => 'البريد الإلكتروني';

  @override
  String get aboutContactGithub => 'GitHub';

  @override
  String get aboutContactName => 'الاسم';

  @override
  String get aboutContactPhone => 'الجوال';

  @override
  String get aboutContactTelegram => 'تيليجرام';

  @override
  String get aboutCopiedValue => 'تم النسخ.';

  @override
  String get aboutCopy => 'نسخ';

  @override
  String get aboutFontNote =>
      'خط Vazirmatn مرفق مع التطبيق بموجب SIL Open Font License 1.1.';

  @override
  String get aboutLicenceNote =>
      'يُنشر هذا التطبيق برخصة MIT: يمكنك استخدامه وتعديله ومشاركته بحرية.';

  @override
  String get aboutLicences => 'تراخيص المصدر المفتوح';

  @override
  String get aboutOpen => 'فتح';

  @override
  String get aboutOpenFailed =>
      'تعذر الفتح. انسخ العنوان والصقه في المتصفح أو برنامج البريد.';

  @override
  String get aboutPhoneNote =>
      'المكالمات والرسائل النصية من داخل إيران فقط. من خارج إيران استخدم تيليجرام فقط.';

  @override
  String get aboutSoundNote =>
      'الأصوات المرفقة (الأذان الافتراضي ونغمة التذكير) أصوات بسيطة مولّدة للاستخدام المؤقت وليست تسجيلات لأي شخص، وهي منشورة بترخيص CC0. اختر صوت الأذان الذي تريده من الإعدادات.';

  @override
  String get aboutTagline =>
      'مواقيت الصلاة والأذان لنظام Windows. يعمل دون اتصال بالإنترنت، وبلا إعلانات ولا حساب ولا تتبّع.';

  @override
  String get aboutTitle => 'حول';

  @override
  String aboutVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get appName => 'Salaat | Aviny Prayer Times';

  @override
  String get calendarAdjustEarlier => 'قبل يوم واحد';

  @override
  String get calendarAdjustLater => 'بعد يوم واحد';

  @override
  String calendarAdjustValue(String value) {
    return '$value أيام';
  }

  @override
  String calendarConvErrDay(String first, String days) {
    return 'يجب أن يكون اليوم من $first إلى $days.';
  }

  @override
  String get calendarConvErrIncomplete => 'أدخل السنة والشهر واليوم.';

  @override
  String get calendarConvErrMonth => 'يجب أن يكون الشهر من ١ إلى ١٢.';

  @override
  String get calendarConvErrNumber => 'استخدم الأرقام فقط.';

  @override
  String get calendarConvErrRange =>
      'هذا التاريخ خارج النطاق الذي يدعمه التقويم.';

  @override
  String get calendarConverterHint =>
      'اكتب تاريخًا في أي من التقاويم الثلاثة؛ ويتغير التقويمان الآخران معه.';

  @override
  String get calendarConverterShow => 'عرض في التقويم';

  @override
  String get calendarConverterTitle => 'محوّل التاريخ';

  @override
  String calendarDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get calendarFieldDay => 'اليوم';

  @override
  String get calendarFieldMonth => 'الشهر';

  @override
  String get calendarFieldYear => 'السنة';

  @override
  String get calendarGridLabel => 'تقويم الشهر';

  @override
  String get calendarHijriAdjust => 'ضبط التاريخ القمري';

  @override
  String get calendarHijriApproxHint =>
      'تقريبي: التقويم القمري الرسمي في إيران يعتمد على رؤية الهلال وقد يختلف بيوم واحد.';

  @override
  String get calendarHijriUnavailable =>
      'لا يوجد تاريخ قمري لهذا اليوم في الجدول';

  @override
  String get calendarKindGregorian => 'الميلادي';

  @override
  String get calendarKindHijri => 'الهجري القمري';

  @override
  String get calendarKindJalali => 'الهجري الشمسي (الجلالي)';

  @override
  String calendarMonthGregorian(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'يناير',
      'm2': 'فبراير',
      'm3': 'مارس',
      'm4': 'أبريل',
      'm5': 'مايو',
      'm6': 'يونيو',
      'm7': 'يوليو',
      'm8': 'أغسطس',
      'm9': 'سبتمبر',
      'm10': 'أكتوبر',
      'm11': 'نوفمبر',
      'm12': 'ديسمبر',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthHijri(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'محرم',
      'm2': 'صفر',
      'm3': 'ربيع الأول',
      'm4': 'ربيع الآخر',
      'm5': 'جمادى الأولى',
      'm6': 'جمادى الآخرة',
      'm7': 'رجب',
      'm8': 'شعبان',
      'm9': 'رمضان',
      'm10': 'شوال',
      'm11': 'ذو القعدة',
      'm12': 'ذو الحجة',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthJalali(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'فروردين',
      'm2': 'أرديبهشت',
      'm3': 'خرداد',
      'm4': 'تير',
      'm5': 'مرداد',
      'm6': 'شهريور',
      'm7': 'مهر',
      'm8': 'آبان',
      'm9': 'آذر',
      'm10': 'دي',
      'm11': 'بهمن',
      'm12': 'إسفند',
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
      'يؤخذ التاريخ القمري من جدول أم القرى. التقويم الرسمي في إيران يعتمد على رؤية الهلال وقد يختلف بيوم واحد؛ في هذه الحالة أزِحه من هنا.';

  @override
  String get calendarNextMonth => 'الشهر التالي';

  @override
  String get calendarOpenOnHome => 'عرض في الشاشة الرئيسية';

  @override
  String get calendarPanelTimes => 'أوقات الصلاة لهذا اليوم';

  @override
  String get calendarPreviousMonth => 'الشهر السابق';

  @override
  String get calendarSeparator => '، ';

  @override
  String get calendarToday => 'اليوم';

  @override
  String calendarWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'الاثنين',
      'd2': 'الثلاثاء',
      'd3': 'الأربعاء',
      'd4': 'الخميس',
      'd5': 'الجمعة',
      'd6': 'السبت',
      'd7': 'الأحد',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'اثن',
      'd2': 'ثلا',
      'd3': 'أرب',
      'd4': 'خمي',
      'd5': 'جمع',
      'd6': 'سبت',
      'd7': 'أحد',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get contributeIntro =>
      'شيفرة هذا التطبيق على GitHub وكل أشكال المساعدة موضع ترحيب. طرق المشاركة:';

  @override
  String get contributeOpenGuide => 'دليل المساهمة';

  @override
  String get contributeOpenIssues => 'الإبلاغ عن خطأ أو فكرة';

  @override
  String get contributeOpenRepo => 'فتح المستودع على GitHub';

  @override
  String get contributeTitle => 'المساهمة';

  @override
  String get contributeWayCode =>
      'الشيفرة: اعمل Fork للمستودع، وأجرِ التغيير في فرع، وشغّل الاختبارات ثم أرسل Pull Request. خطوات البناء والاختبار في CONTRIBUTING.md.';

  @override
  String get contributeWayData =>
      'البيانات: صحّح اسم مدينة أو إحداثياتها أو منطقتها الزمنية، أو أضف مدينة جديدة.';

  @override
  String get contributeWayIssues =>
      'الإبلاغ عن خطأ أو فكرة: افتح Issue على GitHub وأرفق رقم الإصدار وتقرير التشخيص من هذه الصفحة (لا يحتوي على أسماء أو إحداثيات).';

  @override
  String get contributeWayTest =>
      'الاختبار: جرّب التطبيق على إصدارات وأجهزة مختلفة من Windows (الأذان، علبة النظام، منبهات الإيقاظ) وأبلغ بما تراه.';

  @override
  String get contributeWayTranslate =>
      'الترجمة: نصوص التطبيق في المجلد lib/l10n. أرسل لغة جديدة أو تصحيحًا للغة موجودة؛ ومراجعة متحدث أصلي لها قيمة كبيرة.';

  @override
  String get diagAudioFailed =>
      'تعذر تشغيل صوت الاختبار. تحقق من مكبرات الصوت ومستوى صوت Windows.';

  @override
  String get diagAudioOk => 'تم تشغيل صوت الاختبار.';

  @override
  String get diagAudioPlay => 'تشغيل صوت اختبار';

  @override
  String get diagAudioStop => 'إيقاف';

  @override
  String get diagAudioTitle => 'اختبار الصوت';

  @override
  String get diagClockOk => 'لم تُكتشف أي مشكلة في الساعة.';

  @override
  String get diagClockTitle => 'الساعة';

  @override
  String get diagClockUnchecked =>
      'لم تُلاحَظ مشكلة، لكن فحص وقت الشبكة متوقف، لذا لا يُقاس انحراف الساعة.';

  @override
  String get diagCopied =>
      'تم النسخ إلى الحافظة. لا يحتوي على أسماء ولا إحداثيات دقيقة.';

  @override
  String get diagCopy => 'نسخ التشخيص';

  @override
  String get diagCopyFailed => 'تعذر النسخ.';

  @override
  String diagEventAzan(String prayer) {
    return 'الأذان: $prayer';
  }

  @override
  String diagEventReminder(String prayer) {
    return 'تذكير: $prayer';
  }

  @override
  String diagEventTimes(String utc, String local) {
    return 'UTC $utc | محلي $local';
  }

  @override
  String get diagEventWake => 'منبه الإيقاظ';

  @override
  String get diagEventsEmpty => 'لا شيء مجدول.';

  @override
  String get diagEventsTitle => 'الأحداث المجدولة القادمة';

  @override
  String get diagLogNone => 'غير متاح.';

  @override
  String get diagLogTitle => 'ملفات السجل';

  @override
  String get diagTitle => 'التشخيص';

  @override
  String diagValue(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'yes': 'نعم',
      'no': 'لا',
      'unknown': 'غير معروف',
      'enabled': 'مسموح',
      'disabled': 'متوقف',
      'importantOnly': 'المهم فقط',
      'ok': 'يعمل',
      'failed': 'فشل',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String diagWakeAc(String value) {
    return 'مؤقتات الاستيقاظ عند التوصيل بالكهرباء: $value';
  }

  @override
  String diagWakeBattery(String value) {
    return 'مؤقتات الاستيقاظ على البطارية: $value';
  }

  @override
  String get diagWakeCheck => 'افحص الآن';

  @override
  String diagWakeInProcess(String value) {
    return 'المؤقت داخل التطبيق: $value';
  }

  @override
  String diagWakeModern(String value) {
    return 'الاستعداد الحديث: $value';
  }

  @override
  String get diagWakeNotChecked => 'لم يُفحص بعد.';

  @override
  String diagWakeTask(String value) {
    return 'المهمة المجدولة: $value';
  }

  @override
  String get diagWakeTitle => 'فحص الإيقاظ';

  @override
  String get formatAm => 'ص';

  @override
  String formatHours(String hours) {
    return '$hours س';
  }

  @override
  String formatHoursMinutes(String hours, String minutes) {
    return '$hours س $minutes د';
  }

  @override
  String formatMinutes(String minutes) {
    return '$minutes د';
  }

  @override
  String get formatPm => 'م';

  @override
  String formatRemaining(String duration) {
    return 'بعد $duration';
  }

  @override
  String formatRemainingLessThan(String minutes) {
    return 'بعد أقل من $minutes د';
  }

  @override
  String formatSeconds(String seconds) {
    return '$seconds ث';
  }

  @override
  String get homeAzanMutedIndefinite => 'الأذان: مكتوم حتى تعيد تشغيله';

  @override
  String homeAzanMutedUntil(String time) {
    return 'الأذان: مكتوم حتى $time';
  }

  @override
  String get homeAzanOff => 'الأذان: متوقف';

  @override
  String get homeAzanOn => 'الأذان: يعمل';

  @override
  String homeAzanToggleOff(String prayer) {
    return 'إيقاف أذان $prayer';
  }

  @override
  String homeAzanToggleOn(String prayer) {
    return 'تشغيل أذان $prayer';
  }

  @override
  String get homeBackToToday => 'العودة إلى اليوم';

  @override
  String homeBannerClockSkew(String amount) {
    return 'ساعة الكمبيوتر تختلف عن الوقت الصحيح بنحو $amount.';
  }

  @override
  String get homeBannerDismiss => 'إغلاق';

  @override
  String get homeBannerMutedIndefinite => 'الأذان مكتوم حتى تعيد تشغيله.';

  @override
  String homeBannerMutedUntil(String time) {
    return 'الأذان مكتوم حتى $time.';
  }

  @override
  String get homeBannerSettingsReset =>
      'تعذرت قراءة ملف الإعدادات وأُعيدت الإعدادات إلى القيم الافتراضية.';

  @override
  String get homeBannerStaleZone =>
      'يعرض Windows وقتًا لهذا المكان يختلف عن قاعدة بيانات المناطق الزمنية. الأوقات في هذا التطبيق صحيحة؛ تحقق من ساعة Windows.';

  @override
  String homeCompass(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'p0': 'شمال',
      'p1': 'شمال شرق',
      'p2': 'شرق',
      'p3': 'جنوب شرق',
      'p4': 'جنوب',
      'p5': 'جنوب غرب',
      'p6': 'غرب',
      'p7': 'شمال غرب',
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
    return 'أوقات $date';
  }

  @override
  String homeEventAt(String event, String time) {
    return '$event $time';
  }

  @override
  String get homeHeroNoNext => 'لا يوجد ما يُعدّ له تنازليًا';

  @override
  String get homeMute => 'كتم';

  @override
  String get homeMuteCancel => 'إلغاء الكتم';

  @override
  String homeMuteForDuration(String duration) {
    return 'لمدة $duration';
  }

  @override
  String get homeMuteIndefinite => 'حتى أعيد تشغيله';

  @override
  String get homeMuteUntilNext => 'حتى الأذان التالي';

  @override
  String get homeNextDay => 'اليوم التالي';

  @override
  String get homeNextMarker => 'التالي';

  @override
  String homeNextWakeAlarm(String value) {
    return 'الإيقاظ التالي: $value';
  }

  @override
  String get homeNoTimesAction => 'إعدادات الحساب';

  @override
  String get homeNoTimesInfo =>
      'لا يمكن حساب كل الأوقات لهذا المكان في هذا اليوم. يمكنك تغيير قاعدة خطوط العرض العالية من الإعدادات.';

  @override
  String get homeNoValue => '—';

  @override
  String homeNowPlaying(String prayer) {
    return 'قيد التشغيل: $prayer';
  }

  @override
  String get homeNowPlayingGeneric => 'يتم تشغيل الأذان';

  @override
  String get homeOtherDayHint =>
      'أوقات هذا اليوم؛ العد التنازلي لليوم الحالي فقط.';

  @override
  String get homePreviousDay => 'اليوم السابق';

  @override
  String homeQiblaSummary(String degrees, String direction) {
    return 'القبلة: $degrees° $direction';
  }

  @override
  String homeReminderMinutes(String minutes) {
    return 'التذكير: قبل $minutes د';
  }

  @override
  String get homeReminderOff => 'التذكيرات: متوقفة';

  @override
  String homeReminderRange(String min, String max) {
    return 'التذكيرات: من $min إلى $max د قبل';
  }

  @override
  String get homeStatusTitle => 'الحالة';

  @override
  String get homeStop => 'إيقاف';

  @override
  String get homeSwitchLocation => 'تغيير الموقع';

  @override
  String get homeTimelineLabel => 'الجدول الزمني لليوم';

  @override
  String get homeToday => 'اليوم';

  @override
  String get homeTodayTimes => 'أوقات اليوم';

  @override
  String get homeTomorrowTimes => 'أوقات الغد';

  @override
  String homeUntilEvent(String event) {
    return 'حتى $event';
  }

  @override
  String homeViewingDay(String date) {
    return 'عرض $date';
  }

  @override
  String get navCalendar => 'التقويم';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navQibla => 'القبلة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navTimetable => 'الجدول';

  @override
  String get navWakeUp => 'الإيقاظ';

  @override
  String notifAzanBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String get notifAzanFailed => 'تعذر تشغيل الأذان.';

  @override
  String notifAzanTitle(String prayer) {
    return 'أذان $prayer';
  }

  @override
  String notifMissedBody(String time) {
    return 'كان الكمبيوتر في وضع السكون عند $time.';
  }

  @override
  String notifMissedTitle(String prayer) {
    return 'لم يتم تشغيل أذان $prayer';
  }

  @override
  String notifReminderBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String notifReminderTitle(String minutes, String prayer) {
    return '$minutes د حتى $prayer';
  }

  @override
  String get notifSoundFallback =>
      'لم يُعثر على ملف صوت الأذان؛ تم تشغيل الصوت الافتراضي.';

  @override
  String get notifStopAction => 'إيقاف';

  @override
  String get notifTrayHint => 'يبقى التطبيق قيد التشغيل بجانب ساعة Windows.';

  @override
  String get onboardingAzanBody =>
      'استمع إلى الأذان واختر هل يبدأ التطبيق مع Windows.';

  @override
  String get onboardingAzanTitle => 'الأذان والبدء';

  @override
  String get onboardingBack => 'رجوع';

  @override
  String get onboardingCityBody => 'ابحث عن مدينتك أو اخترها من محافظة.';

  @override
  String get onboardingCityNone => 'لم يتم العثور على مدينة.';

  @override
  String get onboardingCitySearchHint => 'ابحث عن مدينة';

  @override
  String onboardingCitySelected(String city) {
    return 'المحدد: $city';
  }

  @override
  String get onboardingCityTitle => 'مدينتك';

  @override
  String get onboardingFinish => 'ابدأ';

  @override
  String get onboardingLanguageBody =>
      'اختر لغتك. يمكنك تغييرها لاحقًا من الإعدادات.';

  @override
  String get onboardingLanguageTitle => 'اللغة';

  @override
  String get onboardingModeList => 'مدن إيران (قائمة بدون إنترنت)';

  @override
  String get onboardingModeOnline => 'أي مدينة في العالم (بحث عبر الإنترنت)';

  @override
  String get onboardingNext => 'التالي';

  @override
  String get onboardingOnlineBody =>
      'مدينتك غير موجودة في القائمة؟ ابحث عن أي مدينة في العالم. الإنترنت مطلوب لهذا البحث فقط، وبعده يعمل التطبيق بدون إنترنت.';

  @override
  String get onboardingPreview => 'تشغيل أذان تجريبي';

  @override
  String get onboardingProvinceAll => 'كل المحافظات';

  @override
  String get onboardingSkip => 'تخطي';

  @override
  String get onboardingStartWithWindows => 'البدء مع Windows';

  @override
  String get onboardingStartWithWindowsHint =>
      'يبدأ التطبيق بهدوء في علبة النظام.';

  @override
  String onboardingStepProgress(String step, String total) {
    return 'الخطوة $step من $total';
  }

  @override
  String get onboardingStopPreview => 'إيقاف';

  @override
  String get placeSearchAttribution =>
      'الأماكن © مساهمو OpenStreetMap (Nominatim). المنطقة الزمنية والارتفاع: Open-Meteo.';

  @override
  String get placeSearchButton => 'بحث';

  @override
  String get placeSearchFailBusy =>
      'خدمة البحث مشغولة. انتظر دقيقة ثم حاول مرة أخرى.';

  @override
  String get placeSearchFailDetails =>
      'تم العثور على المكان لكن تعذر جلب منطقته الزمنية. تحقق من الاتصال واختره مرة أخرى.';

  @override
  String get placeSearchFailGeneric => 'لم ينجح البحث. حاول مرة أخرى بعد قليل.';

  @override
  String get placeSearchFailOffline =>
      'لا يوجد اتصال بالإنترنت. اتصل ثم اضغط بحث مرة أخرى. بقية التطبيق تعمل بدون إنترنت.';

  @override
  String get placeSearchFailTimeout =>
      'لم تستجب خدمة البحث في الوقت المناسب. حاول مرة أخرى.';

  @override
  String get placeSearchHint => 'المدينة، الدولة (مثلاً مومباي، الهند)';

  @override
  String placeSearchNone(String query) {
    return 'لم يُعثر على مكان لـ «$query». تحقق من الإملاء أو أضف الدولة، مثلاً مومباي، الهند.';
  }

  @override
  String get placeSearchNotice =>
      'البحث يحتاج إلى الإنترنت هذه المرة فقط. يُرسل النص الذي تكتبه إلى خدمة البحث في OpenStreetMap (Nominatim) ولا يُرسل أي شيء آخر. بعد اختيار المكان يحتفظ التطبيق بما يلزمه ويعمل بدون إنترنت من جديد.';

  @override
  String placeSearchResolving(String place) {
    return 'جارٍ جلب المنطقة الزمنية والارتفاع لـ $place…';
  }

  @override
  String get placeSearchResultsTitle => 'النتائج: اختر مكانك';

  @override
  String get placeSearchTitle => 'البحث عن مكان';

  @override
  String get placeSearchTooShort => 'اكتب حرفين على الأقل ثم اضغط بحث.';

  @override
  String get placeSearchUnknownZone =>
      'المنطقة الزمنية لهذا المكان غير موجودة في قاعدة بيانات التطبيق. جرّب مكانًا آخر أو أضفه من «موقع مخصص» في الإعدادات.';

  @override
  String get placeSearching => 'جارٍ البحث…';

  @override
  String get prayerAsr => 'العصر';

  @override
  String get prayerDhuhr => 'الظهر';

  @override
  String get prayerFajr => 'الفجر';

  @override
  String get prayerImsak => 'الإمساك';

  @override
  String get prayerIsha => 'العشاء';

  @override
  String get prayerMaghrib => 'المغرب';

  @override
  String get prayerMidnight => 'منتصف الليل الشرعي';

  @override
  String get prayerSunrise => 'الشروق';

  @override
  String get prayerSunset => 'الغروب';

  @override
  String qiblaAccuracyValue(String meters) {
    return 'الدقة: نحو $meters م';
  }

  @override
  String get qiblaBearingLabel => 'الاتجاه (مع عقارب الساعة من الشمال الحقيقي)';

  @override
  String qiblaBearingValue(String degrees, String direction) {
    return '$degrees° ($direction)';
  }

  @override
  String get qiblaCamKaaba => 'الكعبة';

  @override
  String get qiblaCamNearby => 'حولي';

  @override
  String get qiblaCamOverview => 'المسار كاملًا';

  @override
  String qiblaCardinal(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'n': 'ش',
      'e': 'ق',
      's': 'ج',
      'w': 'غ',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String qiblaCompassSemantics(String degrees, String direction) {
    return 'البوصلة: القبلة عند $degrees درجة ($direction)';
  }

  @override
  String qiblaCompassSemanticsSun(String base, String azimuth) {
    return '$base؛ الشمس عند $azimuth درجة';
  }

  @override
  String get qiblaCoordsApply => 'عرض';

  @override
  String get qiblaCoordsHint => 'مثلًا ٣٦٫٢١٣٣، ٥٨٫٧٩٥٨';

  @override
  String get qiblaCoordsInvalid =>
      'إحداثيات غير صالحة. يجب أن يكون خط العرض بين ⁦-٩٠⁩ و ٩٠ وخط الطول بين ⁦-١٨٠⁩ و ١٨٠.';

  @override
  String get qiblaCoordsLabel => 'خط العرض وخط الطول';

  @override
  String get qiblaCoordsOr => 'أو أدخل الإحداثيات بنفسك';

  @override
  String qiblaCustomPlaceShown(String place) {
    return 'القياس من $place.';
  }

  @override
  String get qiblaDeviceFixShown => 'يتم عرض موقع هذا الجهاز.';

  @override
  String get qiblaDistanceLabel => 'المسافة إلى الكعبة';

  @override
  String qiblaDistanceValue(String km) {
    return '$km كم';
  }

  @override
  String get qiblaFailGeneric => 'تعذرت قراءة الموقع؛ تُعرض المدينة المحددة.';

  @override
  String get qiblaFailPermissionDenied =>
      'لم يسمح Windows لهذا التطبيق بقراءة الموقع. اتبع الخطوات أدناه وحاول مرة أخرى؛ أو استخدم المدينة المحددة.';

  @override
  String get qiblaFailPermissionForever =>
      'تم رفض الوصول إلى الموقع. لإتاحته من جديد، اتبع الخطوات أدناه.';

  @override
  String get qiblaFailServiceDisabled =>
      'خدمات الموقع متوقفة على هذا الجهاز. اتبع الخطوات أدناه؛ أو استخدم المدينة المحددة أو أي نقطة.';

  @override
  String get qiblaFailTimeout =>
      'لم يصل أي موقع في الوقت المناسب. نادرًا ما تحتوي أجهزة الكمبيوتر على GPS، ويقدّر Windows الموقع من Wi-Fi. حاول مرة أخرى أو استخدم المدينة.';

  @override
  String get qiblaFailUnsupported =>
      'لا يستطيع هذا الجهاز تحديد الموقع؛ تُعرض المدينة المحددة.';

  @override
  String qiblaForLocation(String place) {
    return 'اتجاه القبلة في $place';
  }

  @override
  String get qiblaHelpOther =>
      'شغّل الموقع من إعدادات نظام التشغيل، واسمح لهذا التطبيق باستخدامه، ثم حاول مرة أخرى.';

  @override
  String get qiblaHelpTitleOther => 'كيف أشغّل الموقع؟';

  @override
  String get qiblaHelpTitleWindows => 'كيف أشغّل الموقع في Windows؟';

  @override
  String get qiblaHelpWin1 =>
      'اضغط الزر أعلاه لفتح صفحة Location في إعدادات Windows. إذا لم تُفتح، فاذهب إليها يدويًا: Start > Settings > Privacy & security > Location (في Windows 10: Privacy > Location)';

  @override
  String get qiblaHelpWin2 =>
      'شغّل Location services. إذا ظهر في أعلى الصفحة Location for this device is off، فاضغط Change وشغّله.';

  @override
  String get qiblaHelpWin3 =>
      'بعد ذلك بقليل شغّل Let desktop apps access your location (في Windows 10: Allow desktop apps to access your location). Salaat تطبيق سطح مكتب ولا يُسمح له إلا بهذا المفتاح.';

  @override
  String get qiblaHelpWin4 =>
      'ارجع إلى Salaat واضغط «العثور على موقعي» مرة أخرى. إذا استمر الفشل، فأغلق التطبيق مرة واحدة ثم افتحه من جديد.';

  @override
  String get qiblaLocateAgain => 'العثور مرة أخرى';

  @override
  String get qiblaLocateButton => 'العثور على موقعي';

  @override
  String get qiblaLocating => 'جارٍ تحديد موقعك…';

  @override
  String get qiblaMapAttribution => '© مساهمو OpenStreetMap';

  @override
  String get qiblaMapAttributionSatellite =>
      'الصور © Esri وMaxar وEarthstar Geographics ومجتمع مستخدمي GIS';

  @override
  String get qiblaMapConsentBody =>
      'لرسم خط القبلة على خريطة، تُجلب صور الخريطة من الإنترنت وتُرسل المنطقة التي تنظر إليها إلى ذلك الخادم: خريطة الشوارع من OpenStreetMap، وإذا اخترت «قمر صناعي» فصور جوية من Esri. لا يُطلب شيء قبل موافقتك. وتظهر زاوية القبلة والمسافة بشكل صحيح من دون الخريطة أيضًا.';

  @override
  String get qiblaMapConsentButton => 'عرض الخريطة';

  @override
  String get qiblaMapConsentTitle => 'خريطة القبلة';

  @override
  String get qiblaMapKaaba => 'الكعبة';

  @override
  String get qiblaMapLineNote =>
      'الخط هو أقصر مسار على الكرة الأرضية إلى مركز الكعبة. يبدو منحنيًا على الخريطة المسطحة لكنه يبدأ في اتجاه القبلة. ميزاب الكعبة يبعد بضعة أمتار فقط عن المركز ولا يحدث فرقًا ظاهرًا في الاتجاه. اضغط «حولي» للمقارنة مع الشوارع والمباني.';

  @override
  String get qiblaMapOfflineBanner =>
      'تعذر تحميل صور الخريطة (لا يوجد إنترنت؟). ما زال خط القبلة وزاويتها صحيحين.';

  @override
  String qiblaMapSemantics(String place, String bearing, String distance) {
    return 'خريطة القبلة: من $place إلى الكعبة، $bearing، $distance';
  }

  @override
  String get qiblaMapTapHint => 'انقر على الخريطة لاختيار نقطة أخرى.';

  @override
  String get qiblaMapTurnOff => 'إيقاف الخريطة';

  @override
  String get qiblaMapYou => 'موقعك';

  @override
  String get qiblaNoCompassNote =>
      'ليس في الكمبيوتر بوصلة، لذا يكون الرسم نسبةً إلى الشمال الحقيقي (الشمال في الأعلى).';

  @override
  String get qiblaOpenSettingsFailed =>
      'تعذر فتح صفحة الإعدادات؛ اتبع الخطوات يدويًا.';

  @override
  String get qiblaOpenSettingsOther => 'فتح إعدادات الموقع';

  @override
  String get qiblaOpenSettingsWindows => 'فتح إعدادات الموقع في Windows';

  @override
  String get qiblaSourceCity => 'المدينة المحددة';

  @override
  String qiblaSourceCityHelp(String city) {
    return 'المدينة التي اخترتها لأوقات الصلاة: $city.';
  }

  @override
  String get qiblaSourceCustom => 'أي نقطة';

  @override
  String get qiblaSourceCustomHelp =>
      'ابحث عن مكان بالاسم (يلزم الإنترنت مرة واحدة)، أو المس الخريطة، أو أدخل الإحداثيات.';

  @override
  String get qiblaSourceDevice => 'هذا الجهاز';

  @override
  String get qiblaSourceDeviceHelp =>
      'يُقرأ الموقع من الجهاز فقط عند الضغط على الزر؛ ولا يُخزَّن ولا يُرسل إلى أي مكان.';

  @override
  String get qiblaSourceTitle => 'قياس القبلة من';

  @override
  String get qiblaStatLatitude => 'خط العرض';

  @override
  String get qiblaStatLongitude => 'خط الطول';

  @override
  String get qiblaStyleLabel => 'نوع الخريطة';

  @override
  String get qiblaStyleSatellite => 'قمر صناعي';

  @override
  String get qiblaStyleStreet => 'خريطة';

  @override
  String get qiblaSunBelow => 'الشمس تحت الأفق.';

  @override
  String get qiblaSunInHelp =>
      'في هذه اللحظة تكون الشمس تمامًا في اتجاه القبلة؛ واجه الشمس.';

  @override
  String get qiblaSunInTitle => 'الشمس في اتجاه القبلة';

  @override
  String get qiblaSunNone => 'لا يحدث اليوم.';

  @override
  String get qiblaSunNowLabel => 'الشمس الآن';

  @override
  String qiblaSunNowValue(String azimuth, String altitude) {
    return 'السمت $azimuth°، الارتفاع $altitude°';
  }

  @override
  String get qiblaSunOppHelp => 'في هذه اللحظة يشير ظل عصا قائمة نحو القبلة.';

  @override
  String get qiblaSunOppTitle => 'الشمس عكس القبلة';

  @override
  String get qiblaSunTimesTitle => 'الشمس والقبلة اليوم';

  @override
  String get qiblaTabCompass => 'البوصلة والشمس';

  @override
  String get qiblaTabMap => 'الخريطة';

  @override
  String get qiblaTitle => 'القبلة';

  @override
  String get settingsAboutPlaceholder =>
      'يظهر الإصدار والتراخيص وصفحة التشخيص في هذا القسم.';

  @override
  String get settingsAppAutostart => 'البدء مع Windows';

  @override
  String get settingsAppAutostartHelp =>
      'يبدأ التطبيق بهدوء بجانب الساعة عند تسجيل دخولك إلى Windows.';

  @override
  String get settingsAppCloseToTray => 'الإغلاق إلى علبة النظام';

  @override
  String get settingsAppCloseToTrayHelp =>
      'إغلاق النافذة يُبقي التطبيق بجانب ساعة Windows ليستمر تشغيل الأذان. عند الإيقاف، يؤدي الإغلاق إلى إنهاء التطبيق.';

  @override
  String get settingsAppMinimized => 'البدء مصغّرًا';

  @override
  String get settingsAppMinimizedHelp =>
      'تبقى النافذة مغلقة عندما يشغّل Windows التطبيق.';

  @override
  String get settingsAsrHanafi => 'حنفي (الظل ضعف الجسم)';

  @override
  String get settingsAsrStandard => 'قياسي (الظل يساوي الجسم)';

  @override
  String get settingsAzanChoose => 'اختيار ملف…';

  @override
  String get settingsAzanEnabled => 'تشغيل الأذان';

  @override
  String get settingsAzanEnabledHelp =>
      'المفتاح الرئيسي؛ عند إيقافه لا يُشغَّل أي أذان.';

  @override
  String get settingsAzanFade => 'تصاعد الصوت تدريجيًا';

  @override
  String get settingsAzanFadeHelp => 'يرتفع الأذان بلطف إلى كامل مستوى الصوت.';

  @override
  String get settingsAzanMute => 'كتم سريع';

  @override
  String get settingsAzanMuteHelp => 'إسكات الأذان لبعض الوقت.';

  @override
  String get settingsAzanNotMuted => 'غير مكتوم';

  @override
  String settingsAzanPrayerSwitch(String prayer) {
    return 'أذان $prayer';
  }

  @override
  String get settingsAzanPrayerVolume => 'مستوى صوت هذا الأذان';

  @override
  String get settingsAzanPreview => 'معاينة';

  @override
  String get settingsAzanSound => 'الصوت';

  @override
  String get settingsAzanSoundDefault => 'الأذان المرفق';

  @override
  String settingsAzanSoundFile(String name) {
    return 'الملف: $name';
  }

  @override
  String get settingsAzanUseDefault => 'استخدام الصوت المرفق';

  @override
  String get settingsAzanVolume => 'مستوى الصوت';

  @override
  String get settingsAzanVolumeHelp => 'مستوى الصوت العام لكل أذان';

  @override
  String get settingsBackupExport => 'تصدير نسخة احتياطية';

  @override
  String get settingsBackupExportFailed => 'تعذر حفظ النسخة الاحتياطية.';

  @override
  String get settingsBackupExportHelp =>
      'تُحفظ كل الإعدادات والمواقع ومنبهات الإيقاظ في ملف واحد.';

  @override
  String settingsBackupExported(String path) {
    return 'تم حفظ النسخة الاحتياطية: $path';
  }

  @override
  String get settingsBackupImport => 'استيراد نسخة احتياطية';

  @override
  String get settingsBackupImportBody =>
      'تُستبدل كل الإعدادات الحالية بمحتوى هذا الملف.';

  @override
  String get settingsBackupImportConfirm => 'استعادة';

  @override
  String get settingsBackupImportHelp =>
      'يستعيد الإعدادات من ملف نسخة احتياطية.';

  @override
  String get settingsBackupImportInvalid =>
      'هذا الملف ليس نسخة احتياطية صالحة للإعدادات؛ لم تتغير الإعدادات.';

  @override
  String get settingsBackupImportReadFailed =>
      'تعذرت قراءة الملف؛ لم تتغير الإعدادات.';

  @override
  String get settingsBackupImportTitle => 'استعادة الإعدادات؟';

  @override
  String get settingsBackupImported => 'تمت استعادة الإعدادات.';

  @override
  String get settingsBackupTitle => 'النسخ الاحتياطي والاستعادة';

  @override
  String get settingsCalcAngleHelp => 'زاوية الشمس تحت الأفق بالدرجات';

  @override
  String get settingsCalcAsr => 'قاعدة العصر';

  @override
  String get settingsCalcFajrAngle => 'زاوية الفجر';

  @override
  String get settingsCalcHighLat => 'خطوط العرض العالية';

  @override
  String get settingsCalcHighLatHelp =>
      'للأماكن التي يكون فيها الليل قصيرًا جدًا ولا تُبلغ فيها زاوية الشفق.';

  @override
  String get settingsCalcImsak => 'الإمساك';

  @override
  String get settingsCalcImsakHelp => 'دقائق قبل الفجر';

  @override
  String get settingsCalcIshaAngle => 'زاوية العشاء';

  @override
  String get settingsCalcIshaMinutes => 'دقائق بعد المغرب';

  @override
  String get settingsCalcIshaMode => 'تعريف العشاء';

  @override
  String get settingsCalcIshaModeAngle => 'زاوية الشمس';

  @override
  String get settingsCalcIshaModeMinutes => 'دقائق بعد المغرب';

  @override
  String get settingsCalcMaghribAngle => 'زاوية المغرب';

  @override
  String get settingsCalcMaghribSunset => 'المغرب عند الغروب';

  @override
  String get settingsCalcMaghribSunsetHelp =>
      'عند الإيقاف، يُحسب المغرب بالزاوية أدناه.';

  @override
  String get settingsCalcMethod => 'الطريقة';

  @override
  String get settingsCalcMethodHelp =>
      'تغيير أي زاوية يحوّل الطريقة إلى «مخصصة».';

  @override
  String get settingsCalcMidnight => 'منتصف الليل الشرعي';

  @override
  String settingsCalcOffsetsHelp(String max) {
    return 'قدّم أي وقت أو أخّره حتى $max دقيقة.';
  }

  @override
  String get settingsCalcOffsetsReset => 'إعادة تعيين الكل';

  @override
  String get settingsCalcOffsetsTitle => 'تعديل الدقائق لكل وقت';

  @override
  String settingsCalcPreviewHelp(String date) {
    return 'أوقات اليوم ($date) بالإعدادات أعلاه';
  }

  @override
  String get settingsCalcPreviewTitle => 'معاينة مباشرة';

  @override
  String get settingsCalcRestore => 'استعادة الإعدادات الافتراضية لهذه الطريقة';

  @override
  String settingsCalcRestoreHelp(String method) {
    return 'تعود الزوايا والقواعد والإمساك إلى قيم «$method»؛ ولا تتغير تعديلات الدقائق لكل وقت.';
  }

  @override
  String get settingsCalcRowsHelp =>
      'الفجر والشروق والظهر والمغرب ومنتصف الليل الشرعي تظهر دائمًا.';

  @override
  String get settingsCalcRowsTitle => 'الصفوف المعروضة';

  @override
  String get settingsCancel => 'إلغاء';

  @override
  String get settingsDecrease => 'إنقاص';

  @override
  String get settingsDigitsArabic => 'العربية (٠١٢)';

  @override
  String get settingsDigitsLatin => 'اللاتينية (123)';

  @override
  String get settingsDigitsPersian => 'الفارسية (۱۲۳)';

  @override
  String get settingsDispDigits => 'الأرقام';

  @override
  String get settingsDispHijri => 'ضبط التاريخ الهجري';

  @override
  String get settingsDispHijriHelp =>
      'تتبع إيران رؤية الهلال، لذلك قد يختلف التاريخ الهجري المعروض عن التاريخ الرسمي؛ أزِحه بيوم أو يومين من هنا.';

  @override
  String get settingsDispHour => 'الساعة';

  @override
  String get settingsDispLanguage => 'اللغة';

  @override
  String get settingsDispLanguageHelp => 'يُطبَّق دون إعادة تشغيل.';

  @override
  String get settingsDispTheme => 'السمة';

  @override
  String get settingsHighLatAngleBased => 'حسب الزاوية';

  @override
  String get settingsHighLatNightMiddle => 'منتصف الليل';

  @override
  String get settingsHighLatNone => 'دون تعديل';

  @override
  String get settingsHighLatOneSeventh => 'سُبع الليل';

  @override
  String get settingsHour12 => 'نظام ١٢ ساعة';

  @override
  String get settingsHour24 => 'نظام ٢٤ ساعة';

  @override
  String get settingsIncrease => 'زيادة';

  @override
  String settingsInvalidNumber(String min, String max) {
    return 'أدخل رقمًا بين $min و $max.';
  }

  @override
  String get settingsLocActive => 'نشط';

  @override
  String get settingsLocAdd => 'إضافة';

  @override
  String get settingsLocAddCustom => 'موقع مخصص';

  @override
  String get settingsLocAddFromDb => 'من قائمة المدن';

  @override
  String get settingsLocAddSearch => 'بحث عبر الإنترنت';

  @override
  String get settingsLocAddTitle => 'إضافة موقع';

  @override
  String settingsLocAdded(String name) {
    return 'تمت إضافة $name.';
  }

  @override
  String get settingsLocAllProvinces => 'كل المحافظات';

  @override
  String get settingsLocAlreadySaved => 'محفوظ مسبقًا';

  @override
  String get settingsLocClose => 'إغلاق';

  @override
  String settingsLocCoords(String lat, String lon) {
    return 'عرض $lat، طول $lon';
  }

  @override
  String get settingsLocCustomBadge => 'مخصص';

  @override
  String get settingsLocDegrees => 'درجات';

  @override
  String get settingsLocDelete => 'حذف';

  @override
  String get settingsLocDeleteBody => 'تتم إزالة هذا الموقع من قائمتك.';

  @override
  String get settingsLocDeleteLast => 'لا يمكن حذف آخر موقع.';

  @override
  String settingsLocDeleteTitle(String name) {
    return 'حذف $name؟';
  }

  @override
  String get settingsLocEast => 'شرق';

  @override
  String get settingsLocEdit => 'تعديل';

  @override
  String get settingsLocElevation => 'الارتفاع (بالأمتار)';

  @override
  String settingsLocErrElevation(String min, String max) {
    return 'يجب أن يكون الارتفاع بين $min و $max متر.';
  }

  @override
  String settingsLocErrLatitude(String min, String max) {
    return 'يجب أن يكون خط العرض رقمًا بين $min و $max.';
  }

  @override
  String settingsLocErrLongitude(String min, String max) {
    return 'يجب أن يكون خط الطول رقمًا بين $min و $max.';
  }

  @override
  String get settingsLocErrName => 'أدخل اسمًا.';

  @override
  String settingsLocErrOffset(String min, String max) {
    return 'يجب أن تكون الإزاحة بين $min و $max.';
  }

  @override
  String get settingsLocErrZone => 'اختر منطقة زمنية من القائمة.';

  @override
  String get settingsLocFormatDecimal => 'درجات عشرية';

  @override
  String get settingsLocFormatDms => 'درجات ودقائق وثوانٍ';

  @override
  String get settingsLocLatitude => 'خط العرض';

  @override
  String get settingsLocLongitude => 'خط الطول';

  @override
  String get settingsLocMinutes => 'دقائق';

  @override
  String get settingsLocName => 'الاسم';

  @override
  String get settingsLocNoResults => 'لم يتم العثور على مدينة.';

  @override
  String get settingsLocNorth => 'شمال';

  @override
  String get settingsLocProvince => 'المحافظة';

  @override
  String get settingsLocSave => 'حفظ';

  @override
  String get settingsLocSavedHelp => 'تُحسب الأوقات للموقع النشط.';

  @override
  String get settingsLocSavedTitle => 'المواقع المحفوظة';

  @override
  String get settingsLocSearchHint => 'ابحث عن مدينة';

  @override
  String get settingsLocSeconds => 'ثوانٍ';

  @override
  String get settingsLocSetActive => 'تعيين كنشط';

  @override
  String get settingsLocSouth => 'جنوب';

  @override
  String get settingsLocWest => 'غرب';

  @override
  String get settingsLocZoneNone => 'لم يتم العثور على منطقة زمنية.';

  @override
  String get settingsLocZoneSearch => 'ابحث في المناطق الزمنية';

  @override
  String settingsLocZoneSelected(String zone) {
    return 'المنطقة الزمنية المحددة: $zone';
  }

  @override
  String get settingsMethodCustom => 'مخصصة';

  @override
  String get settingsMethodEgypt => 'الهيئة المصرية العامة للمساحة';

  @override
  String get settingsMethodIsna => 'الجمعية الإسلامية لأمريكا الشمالية';

  @override
  String get settingsMethodJafari => 'الشيعة الإثنا عشرية، معهد ليفا (قم)';

  @override
  String get settingsMethodKarachi => 'جامعة العلوم الإسلامية، كراتشي';

  @override
  String get settingsMethodMakkah => 'جامعة أم القرى، مكة المكرمة';

  @override
  String get settingsMethodMwl => 'رابطة العالم الإسلامي';

  @override
  String get settingsMethodTehran => 'جامعة طهران، معهد الجيوفيزياء';

  @override
  String get settingsMidnightJafari => 'بين الغروب والفجر';

  @override
  String get settingsMidnightStandard => 'بين الغروب والشروق';

  @override
  String get settingsOff => 'إيقاف';

  @override
  String settingsPercent(String value) {
    return '$value٪';
  }

  @override
  String get settingsRemChime => 'نغمة هادئة';

  @override
  String get settingsRemChimeHelp => 'تُشغَّل نغمة هادئة مع إشعار التذكير.';

  @override
  String get settingsRemChimeTest => 'تشغيل عينة';

  @override
  String settingsRemHelp(String max) {
    return '٠ يعني الإيقاف؛ حتى $max دقيقة قبل الأذان.';
  }

  @override
  String get settingsRemIndependent =>
      'إيقاف التذكيرات لا يؤثر أبدًا في الأذان.';

  @override
  String settingsRemSummary(String minutes) {
    return '$minutes د قبل الأذان';
  }

  @override
  String settingsRemTitle(String prayer) {
    return 'تذكير قبل $prayer';
  }

  @override
  String get settingsResetConfirm => 'مسح';

  @override
  String get settingsResetConfirmBody =>
      'تعود الإعدادات إلى القيم الافتراضية ويصبح الموقع النشط طهران. لا يمكن التراجع عن هذا.';

  @override
  String get settingsResetConfirmTitle => 'مسح كل الإعدادات؟';

  @override
  String get settingsResetDone => 'أُعيدت الإعدادات إلى القيم الافتراضية.';

  @override
  String get settingsResetHelp =>
      'تُمسح كل الإعدادات والمواقع المحفوظة ومنبهات الإيقاظ.';

  @override
  String get settingsResetTitle => 'إعادة الضبط إلى الافتراضي';

  @override
  String get settingsSaved => 'تم الحفظ';

  @override
  String get settingsSectionAbout => 'حول والتشخيص';

  @override
  String get settingsSectionApp => 'التطبيق';

  @override
  String get settingsSectionAzan => 'الأذان';

  @override
  String get settingsSectionCalculation => 'الحساب';

  @override
  String get settingsSectionDisplay => 'العرض';

  @override
  String get settingsSectionLocation => 'الموقع';

  @override
  String get settingsSectionReminders => 'التذكيرات';

  @override
  String get settingsSectionTime => 'الوقت';

  @override
  String get settingsSectionsLabel => 'أقسام الإعدادات';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeSystem => 'اتباع Windows';

  @override
  String get settingsTimeCheck => 'فحص الساعة مقابل وقت الشبكة';

  @override
  String get settingsTimeCheckHelp =>
      'عند بدء التطبيق وكل ست ساعات؛ متوقف افتراضيًا.';

  @override
  String get settingsTimeCheckNow => 'افحص الآن';

  @override
  String settingsTimeCheckedAt(String time) {
    return 'تم الفحص في $time';
  }

  @override
  String get settingsTimeChecking => 'جارٍ الفحص…';

  @override
  String get settingsTimeCorrect => 'تصحيح الوقت داخل التطبيق';

  @override
  String get settingsTimeCorrectHelp => 'لا تتغير ساعة Windows أبدًا.';

  @override
  String settingsTimeDiagLocation(String offset) {
    return 'إزاحة الموقع النشط (قاعدة البيانات): $offset';
  }

  @override
  String get settingsTimeDiagOk => 'لم تُكتشف أي مشكلة في الساعة.';

  @override
  String get settingsTimeDiagTitle => 'تشخيص الساعة';

  @override
  String settingsTimeDiagWindows(String offset) {
    return 'إزاحة Windows عن UTC: $offset';
  }

  @override
  String get settingsTimeError =>
      'تعذر الوصول إلى خادم الوقت. تحقق من اتصال الإنترنت واسم الخادم.';

  @override
  String get settingsTimeNever => 'لم يُفحص بعد.';

  @override
  String get settingsTimeServer => 'خادم الوقت';

  @override
  String get settingsTimeServerHelp => 'اسم خادم الوقت، مثل pool.ntp.org';

  @override
  String get settingsTimeServerInvalid => 'اسم الخادم غير صالح.';

  @override
  String settingsTimeSkewAhead(String amount) {
    return 'ساعة الكمبيوتر متقدمة بمقدار $amount.';
  }

  @override
  String settingsTimeSkewBehind(String amount) {
    return 'ساعة الكمبيوتر متأخرة بمقدار $amount.';
  }

  @override
  String get settingsTimeSkewZero => 'ساعة الكمبيوتر تطابق وقت الشبكة.';

  @override
  String get settingsTimeStatusTitle => 'آخر فحص';

  @override
  String get settingsZoneAuto => 'تلقائي (موصى به)';

  @override
  String settingsZoneAutoHelp(String zone) {
    return 'تُستخدم قاعدة بيانات المناطق الزمنية المدمجة في التطبيق: $zone';
  }

  @override
  String get settingsZoneFixed => 'إزاحة ثابتة';

  @override
  String get settingsZoneFixedAllYear =>
      'الإزاحة ثابتة وتبقى كما هي في كل أيام السنة.';

  @override
  String get settingsZoneFixedHelp =>
      'فرق ثابت واحد عن UTC ينطبق في كل أيام السنة.';

  @override
  String settingsZoneFixedValue(String offset) {
    return 'إزاحة ثابتة: $offset';
  }

  @override
  String get settingsZoneHourLess => 'أقل بساعة';

  @override
  String get settingsZoneHourMore => 'أكثر بساعة';

  @override
  String settingsZoneNext(String date, String time, String offset) {
    return 'التغيير التالي: $date الساعة $time، الإزاحة $offset';
  }

  @override
  String get settingsZoneNoChange =>
      'لا يوجد تغيير آخر مخطط لهذه المنطقة الزمنية.';

  @override
  String settingsZoneNow(String offset) {
    return 'الإزاحة السارية اليوم: $offset';
  }

  @override
  String get settingsZoneQuarterLess => 'أقل بربع ساعة';

  @override
  String get settingsZoneQuarterMore => 'أكثر بربع ساعة';

  @override
  String get settingsZoneTitle => 'المنطقة الزمنية';

  @override
  String get supportAvailableIn => 'يمكن استخدامها في:';

  @override
  String get supportCardCountries =>
      'إيران فقط: بطاقات المصارف الإيرانية على شبكة Shetab. لا يمكن الدفع بها من خارج إيران؛ استخدم خيار العملة المشفرة بدلًا منها.';

  @override
  String get supportCardNumberLabel => 'رقم البطاقة';

  @override
  String get supportCardTitle => 'بطاقة مصرفية إيرانية';

  @override
  String get supportCheckNote =>
      'قبل الدفع، قارن الرقم أو العنوان بالصفحة الرسمية للمشروع على GitHub. شكرًا لدعمك.';

  @override
  String get supportCryptoAddressLabel => 'عنوان المحفظة';

  @override
  String get supportCryptoCountries =>
      'كل الدول: من أي مكان تتوفر فيه محفظة عملات مشفرة أو منصة تداول، دون الحاجة إلى بطاقة مصرفية.';

  @override
  String get supportCryptoNetworkLabel => 'الشبكة';

  @override
  String get supportCryptoNetworkValue =>
      'BEP20 (BNB Smart Chain، وتسمى أيضًا BSC)';

  @override
  String get supportCryptoTitle => 'العملة المشفرة USDT (تيثر)';

  @override
  String get supportCryptoWarning =>
      'أرسل USDT فقط عبر شبكة BEP20. إرسال عملة أخرى أو استخدام شبكة أخرى إلى هذا العنوان يؤدي إلى ضياع المبلغ.';

  @override
  String get supportIntro =>
      'هذا التطبيق مجاني وبلا إعلانات ولا يحتاج إلى حساب ولا يحجب أي ميزة خلف الدفع. إذا كان مفيدًا لك وتود مساعدته على مواصلة النمو، فيمكنك استخدام إحدى الطرق أدناه. الدعم اختياري تمامًا وأي مبلغ موضع تقدير.';

  @override
  String get supportTitle => 'ادعم المشروع';

  @override
  String get timetableCalendarSwitch => 'نوع التقويم';

  @override
  String get timetableColDay => 'اليوم';

  @override
  String get timetableColWeekday => 'يوم الأسبوع';

  @override
  String get timetableMonthUnavailable => 'هذا الشهر خارج جدول التقويم القمري.';

  @override
  String get timetableNextMonth => 'الشهر التالي';

  @override
  String timetableOpenDay(String date) {
    return 'عرض $date في الشاشة الرئيسية';
  }

  @override
  String get timetablePreviousMonth => 'الشهر السابق';

  @override
  String get timetableToday => 'اليوم';

  @override
  String get trayMenuLocation => 'الموقع';

  @override
  String get trayMenuMute => 'كتم';

  @override
  String get trayMenuMuted => 'مكتوم';

  @override
  String get trayMenuQuit => 'خروج';

  @override
  String get trayMenuSettings => 'الإعدادات';

  @override
  String get trayMenuShow => 'إظهار النافذة';

  @override
  String get trayMenuStopAzan => 'إيقاف الأذان';

  @override
  String get trayMuteCancel => 'إلغاء الكتم';

  @override
  String trayMuteHours(String n) {
    return '$n س';
  }

  @override
  String get trayMuteIndefinite => 'حتى أوقفه';

  @override
  String get trayMuteUntilNext => 'حتى الأذان التالي';

  @override
  String trayNextLine(String prayer, String time) {
    return 'التالي: $prayer · $time';
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
  String get wakeAdd => 'إضافة منبه';

  @override
  String get wakeAfterHibernate => 'بعد الصوت: إسبات';

  @override
  String get wakeAfterHibernateChoice => 'إسبات';

  @override
  String get wakeAfterNote =>
      'قبل أن يدخل الكمبيوتر في السكون أو الإسبات، يمنحك عدّ تنازلي مدته ٣٠ ثانية فرصة للإلغاء.';

  @override
  String get wakeAfterNothing => 'لا تفعل شيئًا';

  @override
  String get wakeAfterSleep => 'بعد الصوت: سكون';

  @override
  String get wakeAfterSleepChoice => 'سكون';

  @override
  String get wakeAfterTitle => 'بعد الصوت';

  @override
  String get wakeCancel => 'إلغاء';

  @override
  String get wakeCapabilityChecking => 'جارٍ فحص هذا الكمبيوتر…';

  @override
  String get wakeCapabilityOkBody =>
      'لم يجد الفحص أي عائق. شغّل اختبار الدقيقتين للتأكد.';

  @override
  String get wakeCapabilityOkTitle => 'يستطيع هذا الكمبيوتر إيقاظ نفسه';

  @override
  String get wakeCapabilityRefresh => 'افحص مرة أخرى';

  @override
  String get wakeCapabilityUnknown => 'لم يُفحص بعد.';

  @override
  String get wakeCapabilityWarnTitle => 'قد لا يستيقظ هذا الكمبيوتر عند المنبه';

  @override
  String get wakeChoiceFixed => 'في وقت محدد';

  @override
  String get wakeChoiceRelative => 'قبل صلاة';

  @override
  String get wakeChooseFile => 'اختيار ملف…';

  @override
  String get wakeCountdownAfterAlarm => 'انتهى المنبه.';

  @override
  String get wakeCountdownCancel => 'إلغاء';

  @override
  String wakeCountdownHibernate(String time) {
    return 'سيدخل الكمبيوتر في الإسبات بعد $time.';
  }

  @override
  String wakeCountdownSleep(String time) {
    return 'سيدخل الكمبيوتر في السكون بعد $time.';
  }

  @override
  String get wakeDelete => 'حذف';

  @override
  String get wakeDeleteBody => 'سيتم حذف المنبه وطلب الإيقاظ الخاص به.';

  @override
  String get wakeDeleteConfirm => 'حذف';

  @override
  String get wakeDeleteTitle => 'حذف هذا المنبه؟';

  @override
  String get wakeDismiss => 'إغلاق';

  @override
  String get wakeEdit => 'تعديل';

  @override
  String get wakeEditorTitleAdd => 'منبه جديد';

  @override
  String get wakeEditorTitleEdit => 'تعديل المنبه';

  @override
  String get wakeEmpty =>
      'لا توجد منبهات بعد. أضف منبهًا لإيقاظ هذا الكمبيوتر في الوقت الذي تختاره.';

  @override
  String get wakeEnabledSwitch => 'تشغيل';

  @override
  String wakeErrorMinutes(String min, String max) {
    return 'أدخل عددًا صحيحًا من $min إلى $max.';
  }

  @override
  String get wakeFieldHour => 'الساعة';

  @override
  String get wakeFieldLabel => 'الاسم (اختياري)';

  @override
  String get wakeFieldMinute => 'الدقيقة';

  @override
  String get wakeFieldMinutesBefore => 'الدقائق قبل';

  @override
  String get wakeFieldPrayer => 'الصلاة';

  @override
  String get wakeHibernateNow => 'إسبات الآن';

  @override
  String get wakeIssueImportantOnly =>
      'يسمح Windows بمؤقتات الاستيقاظ المهمة فقط، وهذا التطبيق لا يندرج عادةً ضمنها.';

  @override
  String get wakeIssueInProcessTimer =>
      'تعذر إنشاء المؤقت الاحتياطي داخل التطبيق.';

  @override
  String get wakeIssueModernStandby =>
      'يستخدم هذا الكمبيوتر الاستعداد الحديث، والاستيقاظ في وقت محدد فيه غير موثوق غالبًا.';

  @override
  String get wakeIssueTaskCreationFailed =>
      'لم يسمح Windows بمهمة استيقاظ مجدولة لحسابك، لذا لا يعمل المنبه إلا أثناء تشغيل هذا التطبيق.';

  @override
  String get wakeIssueTimersOffAc =>
      'أوقف Windows مؤقتات الاستيقاظ أثناء توصيل الكمبيوتر بالكهرباء.';

  @override
  String get wakeIssueTimersOffBattery =>
      'أوقف Windows مؤقتات الاستيقاظ أثناء عمل الكمبيوتر على البطارية.';

  @override
  String get wakeIssueUnknown =>
      'تعذرت قراءة إعداد مؤقتات الاستيقاظ في Windows.';

  @override
  String get wakeListSeparator => '، ';

  @override
  String wakeNext(String remaining, String time) {
    return 'التالي: $remaining ($time)';
  }

  @override
  String get wakeNextNone => 'التالي: —';

  @override
  String wakeNextOtherDay(String remaining, String weekday, String time) {
    return 'التالي: $remaining ($weekday $time)';
  }

  @override
  String get wakeOff => 'إيقاف';

  @override
  String get wakeOpenPowerFailed =>
      'تعذر فتح إعدادات الطاقة. افتح Control Panel > Power Options بنفسك.';

  @override
  String get wakeOpenPowerOptions => 'فتح إعدادات الطاقة في Windows';

  @override
  String wakePercent(String percent) {
    return '$percent٪';
  }

  @override
  String get wakePlaySound => 'تشغيل صوت';

  @override
  String get wakePowerHint =>
      'في Windows: Power Options > Change plan settings > Change advanced power settings > Sleep > Allow wake timers. لا يغيّر هذا التطبيق أي إعداد للطاقة من تلقاء نفسه.';

  @override
  String get wakePreview => 'معاينة';

  @override
  String get wakePreviewStop => 'إيقاف المعاينة';

  @override
  String get wakeProblemHibernateUnavailable =>
      'الإسبات غير مفعّل على هذا الكمبيوتر.';

  @override
  String get wakeProblemProbeFailed => 'لم يكتمل فحص هذا الكمبيوتر.';

  @override
  String get wakeProblemSoundFailed =>
      'تعذر تشغيل صوت المنبه. تحقق من ملف الصوت ومكبرات الصوت.';

  @override
  String get wakeProblemSuspendRefused =>
      'لم يسمح Windows للكمبيوتر بالدخول في السكون.';

  @override
  String get wakeRepeatDaily => 'كل يوم';

  @override
  String get wakeRepeatOnce => 'مرة واحدة';

  @override
  String get wakeRepeatTitle => 'التكرار';

  @override
  String wakeRepeatWeekdays(String days) {
    return 'أيام $days';
  }

  @override
  String get wakeRepeatWeekdaysChoice => 'أيام محددة';

  @override
  String get wakeRinging => 'منبه يرن';

  @override
  String get wakeSave => 'حفظ';

  @override
  String get wakeSaveFailed => 'تعذر حفظ هذه القيم. تحقق من الوقت والأيام.';

  @override
  String get wakeSleepHint =>
      'ينتقل الكمبيوتر إلى السكون بعد عدّ تنازلي مدته خمس ثوانٍ يمكنك إلغاؤه.';

  @override
  String get wakeSleepNow => 'سكون الآن';

  @override
  String get wakeSoundDefault => 'صوت الأذان الافتراضي';

  @override
  String wakeSoundFile(String name) {
    return 'الملف: $name';
  }

  @override
  String get wakeSoundTitle => 'الصوت';

  @override
  String get wakeStop => 'إيقاف';

  @override
  String get wakeSyncError =>
      'تعذر تسجيل طلب الإيقاظ لدى Windows؛ قد يعمل المنبه فقط أثناء تشغيل التطبيق.';

  @override
  String get wakeTest => 'اختبار بعد دقيقتين';

  @override
  String get wakeTestCancel => 'إلغاء الاختبار';

  @override
  String wakeTestPending(String time) {
    return 'سيرنّ منبه تجريبي عند $time. أدخل الكمبيوتر في السكون الآن لترى هل يستيقظ.';
  }

  @override
  String get wakeTitle => 'منبهات الإيقاظ';

  @override
  String wakeTriggerAtPrayer(String prayer) {
    return 'عند $prayer';
  }

  @override
  String wakeTriggerFixed(String time) {
    return 'عند $time';
  }

  @override
  String wakeTriggerRelative(String minutes, String prayer) {
    return '$minutes قبل $prayer';
  }

  @override
  String get wakeTriggerTypeTitle => 'متى';

  @override
  String get wakeUseDefault => 'استخدام الافتراضي';

  @override
  String get wakeVolume => 'مستوى الصوت';

  @override
  String get wakeWeekdaysError => 'اختر يومًا واحدًا على الأقل.';
}
